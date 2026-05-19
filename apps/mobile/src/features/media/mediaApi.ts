import axios from "axios";
import type { ImagePickerAsset } from "expo-image-picker";
import { CreateMediaUploadRequest, MediaApi, MediaUploadResponse } from "@/api/generated";
import { api, apiConfig, unwrap } from "@/services/api";

export type MediaUploadPurpose = "PROFILE_IMAGE" | "POST_IMAGE";

const generatedMediaApi = new MediaApi(apiConfig, undefined, api);

function contentTypeForAsset(asset: ImagePickerAsset): string {
  if (asset.mimeType) return asset.mimeType;
  const fileName = asset.fileName ?? asset.uri;
  const extension = fileName.split(".").pop()?.toLowerCase();
  if (extension === "png") return "image/png";
  if (extension === "webp") return "image/webp";
  if (extension === "heic") return "image/heic";
  if (extension === "heif") return "image/heif";
  return "image/jpeg";
}

async function blobFromUri(uri: string): Promise<Blob> {
  const response = await fetch(uri);
  if (!response.ok) {
    throw new Error("Could not read the selected image.");
  }
  return response.blob();
}

export const mediaApi = {
  async createUpload(asset: ImagePickerAsset, purpose: MediaUploadPurpose): Promise<{ upload: MediaUploadResponse; blob: Blob }> {
    const blob = await blobFromUri(asset.uri);
    const contentType = contentTypeForAsset(asset);
    const payload: CreateMediaUploadRequest = {
      purpose,
      contentType,
      fileName: asset.fileName ?? `upload.${contentType.split("/")[1] ?? "jpg"}`,
      contentLength: asset.fileSize ?? blob.size
    };

    const upload = await unwrap(generatedMediaApi.createUpload(payload));

    if (upload.maxBytes !== undefined && blob.size > upload.maxBytes) {
      throw new Error("That image is too large to upload.");
    }

    return { upload, blob };
  },

  async uploadImageAsset(asset: ImagePickerAsset, purpose: MediaUploadPurpose): Promise<MediaUploadResponse> {
    const { upload, blob } = await this.createUpload(asset, purpose);
    if (!upload.uploadUrl) throw new Error("The backend did not return a media upload URL.");

    await axios.put(upload.uploadUrl, blob, {
      headers: upload.headers ?? {},
      timeout: 60000,
      transformRequest: [(data) => data]
    });

    return upload;
  }
};
