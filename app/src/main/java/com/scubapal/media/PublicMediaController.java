package com.scubapal.media;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import software.amazon.awssdk.services.s3.model.NoSuchKeyException;

import java.time.Duration;

@Controller
public class PublicMediaController {

    private final MediaStorageService mediaStorageService;

    public PublicMediaController(MediaStorageService mediaStorageService) {
        this.mediaStorageService = mediaStorageService;
    }

    @GetMapping("/media/**")
    public ResponseEntity<InputStreamResource> getMedia(HttpServletRequest request) {
        String key = request.getRequestURI().substring("/media/".length());
        try {
            var media = mediaStorageService.stream(key);
            ResponseEntity.BodyBuilder response = ResponseEntity.ok()
                    .contentType(MediaType.parseMediaType(media.contentType()))
                    .cacheControl(CacheControl.maxAge(Duration.ofDays(30)).cachePublic());
            if (media.contentLength() != null && media.contentLength() >= 0) {
                response.contentLength(media.contentLength());
            }
            return response.body(new InputStreamResource(media.stream()));
        } catch (NoSuchKeyException | IllegalArgumentException ex) {
            return ResponseEntity.notFound().build();
        }
    }
}
