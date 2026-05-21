package com.scubapal.media;

import jakarta.annotation.PreDestroy;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.scubapal.identity.user.User;

import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class MediaStorageService {

    private static final Set<String> SUPPORTED_IMAGE_TYPES = Set.of(
            "image/jpeg",
            "image/png",
            "image/webp",
            "image/heic",
            "image/heif"
    );

    private final MediaStorageProperties properties;
    private final S3Presigner presigner;
    private final S3Client s3Client;

    public MediaStorageService(MediaStorageProperties properties) {
        this.properties = properties;
        Region region = Region.of(properties.s3().region());
        this.presigner = S3Presigner.builder()
                .region(region)
                .credentialsProvider(DefaultCredentialsProvider.builder().build())
                .build();
        this.s3Client = S3Client.builder()
                .region(region)
                .credentialsProvider(DefaultCredentialsProvider.builder().build())
                .build();
    }

    public MediaUploadResponse createUpload(User user, CreateMediaUploadRequest request) {
        String contentType = normalizeContentType(request.contentType());
        long maxBytes = maxBytes(request.purpose());
        if (!SUPPORTED_IMAGE_TYPES.contains(contentType)) {
            throw new IllegalArgumentException("Only JPEG, PNG, WebP, HEIC, and HEIF images can be uploaded.");
        }
        if (request.contentLength() != null && request.contentLength() > maxBytes) {
            throw new IllegalArgumentException("Image is too large for " + request.purpose() + ".");
        }

        String objectKey = buildObjectKey(user, request.purpose(), request.fileName(), contentType);
        Map<String, String> metadata = Map.of(
                "uploader-user-id", String.valueOf(user.getId()),
                "upload-purpose", request.purpose().name()
        );
        PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                .bucket(bucketName())
                .key(objectKey)
                .contentType(contentType)
                .metadata(metadata)
                .build();

        Duration signatureDuration = Duration.ofMinutes(Math.max(1, properties.uploadUrlExpiresMinutes()));
        PutObjectPresignRequest presignRequest = PutObjectPresignRequest.builder()
                .signatureDuration(signatureDuration)
                .putObjectRequest(putObjectRequest)
                .build();

        var presigned = presigner.presignPutObject(presignRequest);
        return new MediaUploadResponse(
                objectKey,
                presigned.url().toString(),
                publicUrlForKey(objectKey),
                "PUT",
                uploadHeaders(contentType, metadata),
                Instant.now().plus(signatureDuration),
                maxBytes
        );
    }

    private Map<String, String> uploadHeaders(String contentType, Map<String, String> metadata) {
        return Map.of(
                "Content-Type", contentType,
                "x-amz-meta-uploader-user-id", metadata.get("uploader-user-id"),
                "x-amz-meta-upload-purpose", metadata.get("upload-purpose")
        );
    }

    @PreDestroy
    public void close() {
        presigner.close();
        s3Client.close();
    }

    public String publicUrlForKey(String objectKey) {
        return "/media/" + trimLeadingSlash(objectKey);
    }

    public StoredMedia read(String objectKey) {
        String normalizedKey = extractObjectKey(objectKey);
        var response = s3Client.getObjectAsBytes(GetObjectRequest.builder()
                .bucket(bucketName())
                .key(normalizedKey)
                .build());
        String contentType = StringUtils.hasText(response.response().contentType())
                ? response.response().contentType()
                : "application/octet-stream";
        return new StoredMedia(response.asByteArray(), contentType);
    }

    public String normalizeManagedUrl(String value) {
        if (!StringUtils.hasText(value)) {
            return null;
        }
        return publicUrlForKey(extractObjectKey(value));
    }

    private String buildObjectKey(User user, MediaUploadPurpose purpose, String fileName, String contentType) {
        String folder = purpose == MediaUploadPurpose.PROFILE_IMAGE ? "profile-images" : "post-images";
        return "%s/%s.%s".formatted(
                folder,
                UUID.randomUUID(),
                extension(fileName, contentType)
        );
    }

    private String extractObjectKey(String value) {
        String trimmed = value.trim();
        if (trimmed.startsWith("/media/")) {
            return trimLeadingSlash(trimmed.substring("/media/".length()));
        }
        if (trimmed.startsWith("media/")) {
            return trimLeadingSlash(trimmed.substring("media/".length()));
        }
        if (trimmed.startsWith("profile-images/") || trimmed.startsWith("post-images/") || trimmed.startsWith("users/")) {
            return trimLeadingSlash(trimmed);
        }
        if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
            URI uri = URI.create(trimmed);
            String path = trimLeadingSlash(uri.getPath());
            if (path.startsWith("media/")) {
                return trimLeadingSlash(path.substring("media/".length()));
            }
            String host = uri.getHost();
            if (StringUtils.hasText(host) && host.equals("%s.s3.%s.amazonaws.com".formatted(bucketName(), properties.s3().region()))) {
                return path;
            }
            if (StringUtils.hasText(host) && host.equals(bucketName() + ".s3.amazonaws.com")) {
                return path;
            }
        }
        throw new IllegalArgumentException("Media URL must come from Scuba Pal uploads.");
    }

    private String bucketName() {
        String bucket = properties.s3().bucket();
        if (!StringUtils.hasText(bucket)) {
            throw new IllegalStateException("app.media.s3.bucket must be configured.");
        }
        if (bucket.startsWith("http://") || bucket.startsWith("https://")) {
            return extractBucketFromUrl(bucket);
        }
        return bucket;
    }

    private String extractBucketFromUrl(String bucketUrl) {
        URI uri = URI.create(bucketUrl);
        String host = uri.getHost();
        if (!StringUtils.hasText(host)) {
            throw new IllegalArgumentException("Invalid S3 bucket URL.");
        }
        int marker = host.indexOf(".s3.");
        return marker > 0 ? host.substring(0, marker) : host;
    }

    private String normalizeContentType(String contentType) {
        return contentType.trim().toLowerCase(Locale.ROOT);
    }

    private long maxBytes(MediaUploadPurpose purpose) {
        return purpose == MediaUploadPurpose.PROFILE_IMAGE
                ? properties.maxProfileImageBytes()
                : properties.maxPostImageBytes();
    }

    private String extension(String fileName, String contentType) {
        if (StringUtils.hasText(fileName) && fileName.contains(".")) {
            String extension = fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase(Locale.ROOT);
            String decoded = URLDecoder.decode(extension, StandardCharsets.UTF_8);
            if (decoded.matches("[a-z0-9]{2,5}")) {
                return decoded.equals("jpg") ? "jpeg" : decoded;
            }
        }
        return switch (contentType) {
            case "image/png" -> "png";
            case "image/webp" -> "webp";
            case "image/heic" -> "heic";
            case "image/heif" -> "heif";
            default -> "jpeg";
        };
    }

    private String trimLeadingSlash(String value) {
        return value.replaceAll("^/+", "");
    }

    public record StoredMedia(
            byte[] bytes,
            String contentType
    ) {
    }
}
