import axios from "axios";
import type { ImagePickerAsset } from "expo-image-picker";
import { api, unwrap } from "@/services/api";

export type MediaUploadPurpose = "PROFILE_IMAGE" | "POST_IMAGE";

type MediaUploadResponse = {
  objectKey: string;
  uploadUrl: string;
  publicUrl: string;
  method: "PUT";
  headers: Record<string, string>;
  expiresAt: string;
  maxBytes: number;
};

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
  async uploadImageAsset(asset: ImagePickerAsset, purpose: MediaUploadPurpose): Promise<MediaUploadResponse> {
    const blob = await blobFromUri(asset.uri);
    const contentType = contentTypeForAsset(asset);
    const response = await unwrap<MediaUploadResponse>(api.post("/api/media/uploads", {
      purpose,
      contentType,
      fileName: asset.fileName ?? `upload.${contentType.split("/")[1] ?? "jpg"}`,
      contentLength: asset.fileSize ?? blob.size
    }));

    if (blob.size > response.maxBytes) {
      throw new Error("That image is too large to upload.");
    }

    await axios.put(response.uploadUrl, blob, {
      headers: response.headers,
      timeout: 60000,
      transformRequest: [(data) => data]
    });

    return response;
  }
};
