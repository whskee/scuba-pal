package com.scubapal.social.post;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import com.scubapal.identity.profile.ProfileRepository;
import com.scubapal.identity.role.Role;
import com.scubapal.identity.user.User;
import com.scubapal.identity.user.UserRepository;
import com.scubapal.media.MediaStorageService;
import com.scubapal.media.MediaType;
import com.scubapal.shared.VisibilityStatus;
import com.scubapal.social.comment.PostCommentRepository;
import com.scubapal.social.like.PostLike;
import com.scubapal.social.like.PostLikeRepository;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PostServiceTest {

    @Mock PostRepository postRepository;
    @Mock UserRepository userRepository;
    @Mock ProfileRepository profileRepository;
    @Mock PostLikeRepository postLikeRepository;
    @Mock PostCommentRepository postCommentRepository;
    @Mock MediaStorageService mediaStorageService;
    @InjectMocks PostService postService;

    @BeforeEach
    void setUp() {
        when(profileRepository.findAllByUserIdsWithUser(anyCollection())).thenReturn(List.of());
    }

    @Test
    void publicFeedOnlyAsksRepositoryForPublicPosts() {
        var post = post(1L, user(1L, "dana"), VisibilityStatus.PUBLIC);
        when(postRepository.findByVisibilityStatusOrderByCreatedAtDesc(eq(VisibilityStatus.PUBLIC), any())).thenReturn(new PageImpl<>(List.of(post)));
        when(postLikeRepository.countByPostId(1L)).thenReturn(3L);
        when(postCommentRepository.countByPostId(1L)).thenReturn(2L);

        var page = postService.getPublicFeed(PageRequest.of(0, 10));

        assertEquals(1, page.getTotalElements());
        assertEquals(VisibilityStatus.PUBLIC, page.getContent().get(0).visibilityStatus());
        assertEquals(3, page.getContent().get(0).likes());
        verify(postRepository).findByVisibilityStatusOrderByCreatedAtDesc(eq(VisibilityStatus.PUBLIC), any());
    }

    @Test
    void publicFeedSkipsInvalidStoredMediaUrls() {
        var post = post(1L, user(1L, "dana"), VisibilityStatus.PUBLIC);
        PostMedia media = new PostMedia();
        media.setId(7L);
        media.setPost(post);
        media.setMediaUrl("https://images.example.com/not-managed.jpg");
        media.setMediaType(MediaType.IMAGE);
        post.getMedia().add(media);
        when(postRepository.findByVisibilityStatusOrderByCreatedAtDesc(eq(VisibilityStatus.PUBLIC), any())).thenReturn(new PageImpl<>(List.of(post)));
        when(mediaStorageService.normalizeManagedUrl("https://images.example.com/not-managed.jpg")).thenThrow(new IllegalArgumentException("Media URL must come from Scuba Pal uploads."));

        var page = postService.getPublicFeed(PageRequest.of(0, 10));

        assertEquals(1, page.getTotalElements());
        assertNull(page.getContent().get(0).imageUrl());
        assertTrue(page.getContent().get(0).mediaUrls().isEmpty());
    }

    @Test
    void toggleLikeCreatesLikeWhenMissing() {
        User dana = user(1L, "dana");
        Post post = post(5L, user(2L, "kai"), VisibilityStatus.PUBLIC);
        when(userRepository.findByUsername("dana")).thenReturn(Optional.of(dana));
        when(postRepository.findByIdWithUser(5L)).thenReturn(Optional.of(post));
        when(postLikeRepository.findByPostIdAndUserId(5L, 1L)).thenReturn(Optional.empty());
        when(postLikeRepository.existsByPostIdAndUserId(5L, 1L)).thenReturn(true);
        when(postLikeRepository.countByPostId(5L)).thenReturn(1L);
        when(postCommentRepository.countByPostId(5L)).thenReturn(0L);
        when(postCommentRepository.findByPostIdWithUserOrderByCreatedAtAsc(5L)).thenReturn(List.of());

        var detail = postService.toggleLike(5L, "dana");

        assertTrue(detail.likedByCurrentUser());
        assertEquals(1, detail.likes());
        verify(postLikeRepository).save(any(PostLike.class));
        verify(postLikeRepository, never()).delete(any());
    }

    @Test
    void toggleLikeDeletesExistingLikeWhenPresent() {
        User dana = user(1L, "dana");
        Post post = post(5L, user(2L, "kai"), VisibilityStatus.PUBLIC);
        PostLike existing = new PostLike();
        existing.setId(99L);
        when(userRepository.findByUsername("dana")).thenReturn(Optional.of(dana));
        when(postRepository.findByIdWithUser(5L)).thenReturn(Optional.of(post));
        when(postLikeRepository.findByPostIdAndUserId(5L, 1L)).thenReturn(Optional.of(existing));
        when(postLikeRepository.existsByPostIdAndUserId(5L, 1L)).thenReturn(false);
        when(postLikeRepository.countByPostId(5L)).thenReturn(0L);
        when(postCommentRepository.countByPostId(5L)).thenReturn(0L);
        when(postCommentRepository.findByPostIdWithUserOrderByCreatedAtAsc(5L)).thenReturn(List.of());

        var detail = postService.toggleLike(5L, "dana");

        assertFalse(detail.likedByCurrentUser());
        assertEquals(0, detail.likes());
        verify(postLikeRepository).delete(existing);
        verify(postLikeRepository, never()).save(any());
    }

    private static User user(Long id, String username) {
        Role role = new Role();
        role.setId(1L);
        role.setName("user");
        User user = new User();
        user.setId(id);
        user.setUsername(username);
        user.setEmail(username + "@example.com");
        user.setPasswordHash("hash");
        user.setRole(role);
        user.setActive(true);
        return user;
    }

    private static Post post(Long id, User user, VisibilityStatus visibilityStatus) {
        Post post = new Post();
        post.setId(id);
        post.setUser(user);
        post.setCaption("caption");
        post.setPostType(PostType.TEXT);
        post.setVisibilityStatus(visibilityStatus);
        return post;
    }
}
