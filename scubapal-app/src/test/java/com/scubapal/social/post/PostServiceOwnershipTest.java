package com.scubapal.social.post;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;

import com.scubapal.identity.user.User;
import com.scubapal.identity.user.UserRepository;
import com.scubapal.identity.profile.ProfileRepository;
import com.scubapal.media.MediaStorageService;
import com.scubapal.shared.VisibilityStatus;
import com.scubapal.social.comment.PostCommentRepository;
import com.scubapal.social.like.PostLikeRepository;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PostServiceOwnershipTest {
    @Mock PostRepository postRepository;
    @Mock UserRepository userRepository;
    @Mock ProfileRepository profileRepository;
    @Mock PostLikeRepository postLikeRepository;
    @Mock PostCommentRepository postCommentRepository;
    @Mock MediaStorageService mediaStorageService;
    @InjectMocks PostService postService;

    @Test
    void updatePostRejectsNonOwner() {
        User owner = user(1L, "owner");
        Post post = new Post();
        post.setId(10L);
        post.setUser(owner);
        post.setCaption("old");
        post.setVisibilityStatus(VisibilityStatus.PUBLIC);
        when(postRepository.findByIdWithUser(10L)).thenReturn(Optional.of(post));

        assertThrows(AccessDeniedException.class,
                () -> postService.updatePost(10L, new UpdatePostRequest("new", VisibilityStatus.PUBLIC, null), "intruder"));
        verify(postRepository, never()).save(any());
    }

    @Test
    void deletePostRejectsNonOwner() {
        User owner = user(1L, "owner");
        Post post = new Post();
        post.setId(10L);
        post.setUser(owner);
        when(postRepository.findByIdWithUser(10L)).thenReturn(Optional.of(post));

        assertThrows(AccessDeniedException.class, () -> postService.deletePost(10L, "intruder"));
        verify(postRepository, never()).delete(any());
    }

    private User user(Long id, String username) {
        User user = new User();
        user.setId(id);
        user.setUsername(username);
        user.setEmail(username + "@example.com");
        return user;
    }
}
