package com.social.scuba_pal.media;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.util.StringUtils;

@ConfigurationProperties(prefix = "app.media")
public record MediaStorageProperties(
        S3 s3,
        int uploadUrlExpiresMinutes,
        long maxProfileImageBytes,
        long maxPostImageBytes
) {
    public MediaStorageProperties {
        if (s3 == null) {
            s3 = new S3("scuba-pal-media-user-uploads-test-817455142561-us-west-2-an", "us-west-2", "");
        }
        if (uploadUrlExpiresMinutes <= 0) {
            uploadUrlExpiresMinutes = 10;
        }
        if (maxProfileImageBytes <= 0) {
            maxProfileImageBytes = 5 * 1024 * 1024;
        }
        if (maxPostImageBytes <= 0) {
            maxPostImageBytes = 10 * 1024 * 1024;
        }
    }

    public record S3(
            String bucket,
            String region,
            String publicBaseUrl
    ) {
        public S3 {
            if (!StringUtils.hasText(bucket)) {
                bucket = "scuba-pal-media-user-uploads-test-817455142561-us-west-2-an";
            }
            if (!StringUtils.hasText(region)) {
                region = "us-west-2";
            }
            if (publicBaseUrl == null) {
                publicBaseUrl = "";
            }
        }
    }
}
