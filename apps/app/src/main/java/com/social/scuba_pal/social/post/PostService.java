package com.social.scuba_pal.social.post;

import com.social.scuba_pal.identity.user.User;
import com.social.scuba_pal.identity.user.UserRepository;
import com.social.scuba_pal.shared.VisibilityStatus;
import com.social.scuba_pal.shared.exception.ResourceNotFoundException;
import com.social.scuba_pal.social.comment.CommentView;
import com.social.scuba_pal.social.comment.PostComment;
import com.social.scuba_pal.social.comment.PostCommentRepository;
import com.social.scuba_pal.social.like.PostLike;
import com.social.scuba_pal.social.like.PostLikeRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class PostService {

    private final PostRepository postRepository;
    private final UserRepository userRepository;
    private final PostLikeRepository postLikeRepository;
    private final PostCommentRepository postCommentRepository;

    public PostService(PostRepository postRepository,
                       UserRepository userRepository,
                       PostLikeRepository postLikeRepository,
                       PostCommentRepository postCommentRepository) {
        this.postRepository = postRepository;
        this.userRepository = userRepository;
        this.postLikeRepository = postLikeRepository;
        this.postCommentRepository = postCommentRepository;
    }

    @Transactional(readOnly = true)
    public Page<FeedPostView> getPublicFeed(Pageable pageable) {
        return postRepository.findByVisibilityStatusOrderByCreatedAtDesc(VisibilityStatus.PUBLIC, pageable)
                .map(this::toFeedPostView);
    }

    @Transactional(readOnly = true)
    public List<FeedPostView> getPublicFeed() {
        return getPublicFeed(Pageable.ofSize(20)).getContent();
    }

    @Transactional(readOnly = true)
    public Page<FeedPostView> getPostsByUser(Long userId, Pageable pageable) {
        return postRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable).map(this::toFeedPostView);
    }

    @Transactional(readOnly = true)
    public List<FeedPostView> getPostsByUser(Long userId) {
        return getPostsByUser(userId, Pageable.ofSize(12)).getContent();
    }

    @Transactional(readOnly = true)
    public FeedPostView getPost(Long postId) {
        Post post = postRepository.findByIdWithUser(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found: " + postId));
        return toFeedPostView(post);
    }

    @Transactional(readOnly = true)
    public PostDetailView getPostDetail(Long postId, String currentUsername) {
        Post post = postRepository.findByIdWithUser(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found: " + postId));

        Long currentUserId = currentUsername == null ? null : userRepository.findByUsername(currentUsername).map(User::getId).orElse(null);
        boolean likedByCurrentUser = currentUserId != null && postLikeRepository.existsByPostIdAndUserId(postId, currentUserId);

        List<CommentView> comments = postCommentRepository.findByPostIdWithUserOrderByCreatedAtAsc(postId)
                .stream()
                .map(comment -> new CommentView(
                        comment.getId(),
                        comment.getUser().getId(),
                        comment.getUser().getUsername(),
                        comment.getCommentText(),
                        comment.getCreatedAt()
                ))
                .toList();

        return new PostDetailView(
                post.getId(),
                post.getUser().getId(),
                post.getUser().getUsername(),
                post.getCaption(),
                post.getVisibilityStatus(),
                postLikeRepository.countByPostId(post.getId()),
                postCommentRepository.countByPostId(post.getId()),
                likedByCurrentUser,
                post.getCreatedAt(),
                comments
        );
    }

    @Transactional
    public FeedPostView createPost(CreatePostRequest request) {
        User user = userRepository.findById(request.userId())
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + request.userId()));

        Post post = new Post();
        post.setUser(user);
        post.setCaption(request.caption());
        post.setPostType(PostType.TEXT);
        post.setVisibilityStatus(request.visibilityStatus());
        Post saved = postRepository.save(post);
        return toFeedPostView(saved);
    }

    @Transactional
    public FeedPostView createPostForUsername(String username, String caption, VisibilityStatus visibilityStatus) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        return createPost(new CreatePostRequest(user.getId(), caption, visibilityStatus));
    }

    @Transactional
    public PostDetailView toggleLike(Long postId, String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        Post post = postRepository.findByIdWithUser(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found: " + postId));

        postLikeRepository.findByPostIdAndUserId(postId, user.getId())
                .ifPresentOrElse(postLikeRepository::delete, () -> {
                    PostLike like = new PostLike();
                    like.setPost(post);
                    like.setUser(user);
                    postLikeRepository.save(like);
                });

        return getPostDetail(postId, username);
    }

    @Transactional
    public PostDetailView addComment(Long postId, String username, String commentText) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        Post post = postRepository.findByIdWithUser(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found: " + postId));

        PostComment comment = new PostComment();
        comment.setPost(post);
        comment.setUser(user);
        comment.setCommentText(commentText.trim());
        postCommentRepository.save(comment);

        return getPostDetail(postId, username);
    }

    @Transactional
    public FeedPostView updatePost(Long postId, CreatePostRequest request, String username) {
        Post post = postRepository.findByIdWithUser(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found: " + postId));
        ensurePostOwner(post, username);
        post.setCaption(request.caption());
        post.setVisibilityStatus(request.visibilityStatus());
        return toFeedPostView(postRepository.save(post));
    }

    @Transactional
    public void deletePost(Long postId, String username) {
        Post post = postRepository.findByIdWithUser(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found: " + postId));
        ensurePostOwner(post, username);
        postRepository.delete(post);
    }

    @Transactional
    public void deleteComment(Long postId, Long commentId, String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        PostComment comment = postCommentRepository.findByIdWithPostAndUser(commentId)
                .orElseThrow(() -> new ResourceNotFoundException("Comment not found: " + commentId));
        if (!comment.getPost().getId().equals(postId)) {
            throw new ResourceNotFoundException("Comment not found: " + commentId);
        }
        boolean commentOwner = comment.getUser().getId().equals(user.getId());
        boolean postOwner = comment.getPost().getUser().getId().equals(user.getId());
        if (!commentOwner && !postOwner) {
            throw new AccessDeniedException("Only the comment owner or post owner can delete this comment.");
        }
        postCommentRepository.delete(comment);
    }

    private void ensurePostOwner(Post post, String username) {
        if (!post.getUser().getUsername().equals(username)) {
            throw new AccessDeniedException("Only the post owner can change this post.");
        }
    }

    private FeedPostView toFeedPostView(Post post) {
        long likes = postLikeRepository.countByPostId(post.getId());
        long comments = postCommentRepository.countByPostId(post.getId());
        return new FeedPostView(
                post.getId(),
                post.getUser().getId(),
                post.getUser().getUsername(),
                post.getCaption(),
                post.getVisibilityStatus(),
                likes,
                comments,
                post.getCreatedAt());
    }
}
