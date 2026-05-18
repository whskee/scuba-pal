package com.scubapal.social.post;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;

import com.scubapal.shared.VisibilityStatus;

import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PostControllerTest {

    @Mock PostService postService;
    @InjectMocks PostController postController;

    @Test
    void getAllClampsPaginationAndSortsNewestFirst() {
        when(postService.getPublicFeed(any(Pageable.class))).thenReturn(Page.empty());

        postController.getAll(-5, 500);

        ArgumentCaptor<Pageable> pageableCaptor = ArgumentCaptor.forClass(Pageable.class);
        verify(postService).getPublicFeed(pageableCaptor.capture());
        Pageable pageable = pageableCaptor.getValue();
        assertEquals(0, pageable.getPageNumber());
        assertEquals(50, pageable.getPageSize());
        assertEquals("createdAt: DESC", pageable.getSort().toString());
    }

    @Test
    void likeReturnsUpdatedPostDetailInsteadOfRedirectingOrRefreshing() {
        var auth = new UsernamePasswordAuthenticationToken("dana", "password");
        var detail = new PostDetailView(10L, 2L, "kai", "Nice dive", VisibilityStatus.PUBLIC, null, List.of(), 1, 0, true, LocalDateTime.now(), List.of());
        when(postService.toggleLike(10L, "dana")).thenReturn(detail);

        PostDetailView response = postController.like(10L, auth);

        assertSame(detail, response);
        assertTrue(response.likedByCurrentUser());
        assertEquals(1, response.likes());
        verify(postService).toggleLike(10L, "dana");
    }

    @Test
    void feedEndpointReturnsPagedContent() {
        var item = new FeedPostView(1L, 1L, "dana", "hello", VisibilityStatus.PUBLIC, null, List.of(), 0, 0, LocalDateTime.now());
        when(postService.getPublicFeed(any(Pageable.class))).thenReturn(new PageImpl<>(List.of(item)));

        Page<FeedPostView> page = postController.getAll(0, 10);

        assertEquals(1, page.getTotalElements());
        assertEquals("hello", page.getContent().get(0).caption());
    }
}
