package com.scubapal.media;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.scubapal.identity.user.UserRepository;
import com.scubapal.shared.exception.ResourceNotFoundException;

@Tag(name = "Media", description = "Endpoints for requesting direct-to-S3 media uploads")
@RestController
@RequestMapping("/api/media")
public class MediaController {

    private final UserRepository userRepository;
    private final MediaStorageService mediaStorageService;

    public MediaController(UserRepository userRepository, MediaStorageService mediaStorageService) {
        this.userRepository = userRepository;
        this.mediaStorageService = mediaStorageService;
    }

    @PostMapping("/uploads")
    public ResponseEntity<MediaUploadResponse> createUpload(@Valid @RequestBody CreateMediaUploadRequest request,
                                                            Authentication authentication) {
        var user = userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + authentication.getName()));
        return ResponseEntity.status(HttpStatus.CREATED).body(mediaStorageService.createUpload(user, request));
    }
}
