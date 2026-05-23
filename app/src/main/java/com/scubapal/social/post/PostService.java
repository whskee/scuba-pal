package com.scubapal.social.post;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.scubapal.identity.profile.ProfileRepository;
import com.scubapal.identity.user.User;
import com.scubapal.identity.user.UserRepository;
import com.scubapal.media.MediaStorageService;
import com.scubapal.media.MediaType;
import com.scubapal.shared.VisibilityStatus;
import com.scubapal.shared.exception.ResourceNotFoundException;
import com.scubapal.social.comment.CommentView;
import com.scubapal.social.comment.PostComment;
import com.scubapal.social.comment.PostCommentRepository;
import com.scubapal.social.like.PostLike;
import com.scubapal.social.like.PostLikeRepository;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class PostService {

    private static final Logger log = LoggerFactory.getLogger(PostService.class);

    private final PostRepository postRepository;
    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;
    private final PostLikeRepository postLikeRepository;
    private final PostCommentRepository postCommentRepository;
    private final MediaStorageService mediaStorageService;

    public PostService(PostRepository postRepository,
                       UserRepository userRepository,
                       ProfileRepository profileRepository,
                       PostLikeRepository postLikeRepository,
                       PostCommentRepository postCommentRepository,
                       MediaStorageService mediaStorageService) {
        this.postRepository = postRepository;
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.postLikeRepository = postLikeRepository;
        this.postCommentRepository = postCommentRepository;
        this.mediaStorageService = mediaStorageService;
    }

    @Transactional(readOnly = true)
    public Page<FeedPostView> getPublicFeed(Pageable pageable) {
        Page<Post> page = postRepository.findByVisibilityStatusOrderByCreatedAtDesc(VisibilityStatus.PUBLIC, pageable);
        return toFeedPostViews(page, null);
    }

    @Transactional(readOnly = true)
    public Page<FeedPostView> getPublicFeed(Pageable pageable, String currentUsername) {
        Page<Post> page = postRepository.findByVisibilityStatusOrderByCreatedAtDesc(VisibilityStatus.PUBLIC, pageable);
        return toFeedPostViews(page, currentUsername);
    }

    @Transactional(readOnly = true)
    public List<FeedPostView> getPublicFeed() {
        return getPublicFeed(Pageable.ofSize(20)).getContent();
    }

    private Map<Long, String> authorProfileImages(List<Post> posts) {
        Set<Long> userIds = posts.stream()
                .map(post -> post.getUser().getId())
                .collect(Collectors.toSet());

        return profileImagesByUserId(userIds);
    }

    private Map<Long, String> profileImagesByUserId(Collection<Long> userIds) {
        if (userIds == null || userIds.isEmpty()) {
            return Map.of();
        }

        return profileRepository.findAllByUserIdsWithUser(userIds).stream()
                .filter(profile -> profile.getProfileImageUrl() != null && !profile.getProfileImageUrl().isBlank())
                .collect(Collectors.toMap(
                        profile -> profile.getUser().getId(),
                        profile -> normalizeAuthorProfileImageUrl(profile.getProfileImageUrl())
                ));
    }

    private String normalizeAuthorProfileImageUrl(String url) {
        try {
            return mediaStorageService.normalizeManagedUrl(url);
        } catch (IllegalArgumentException ex) {
            return null;
        }
    }

    @Transactional(readOnly = true)
    public Page<FeedPostView> getPostsByUser(Long userId, Pageable pageable) {
        Page<Post> page = postRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
        return toFeedPostViews(page, null);
    }

    @Transactional(readOnly = true)
    public List<FeedPostView> getPostsByUser(Long userId) {
        return getPostsByUser(userId, Pageable.ofSize(12)).getContent();
    }

    @Transactional(readOnly = true)
    public FeedPostView getPost(Long postId) {
        Post post = postRepository.findByIdWithUser(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found: " + postId));
        ensureCanView(post, null);
        return toFeedPostView(post, authorProfileImageUrl(post), false);
    }

    private void ensureCanView(Post post, String currentUsername) {
        boolean publicPost = post.getVisibilityStatus() == VisibilityStatus.PUBLIC;
        boolean owner = currentUsername != null &&
                post.getUser().getUsername().equals(currentUsername);

        if (!publicPost && !owner) {
            throw new ResourceNotFoundException("Post not found: " + post.getId());
        }
    }

    @Transactional(readOnly = true)
    public PostDetailView getPostDetail(Long postId, String currentUsername) {
        Post post = postRepository.findByIdWithUser(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found: " + postId));

        ensureCanView(post, currentUsername);
        String authorProfileImageUrl = authorProfileImageUrl(post);

        Long currentUserId = currentUsername == null ? null : userRepository.findByUsername(currentUsername).map(User::getId).orElse(null);
        boolean likedByCurrentUser = currentUserId != null && postLikeRepository.existsByPostIdAndUserId(postId, currentUserId);

        List<PostComment> postComments = postCommentRepository.findByPostIdWithUserOrderByCreatedAtAsc(postId);
        Map<Long, String> commentAuthorImages = profileImagesByUserId(postComments.stream()
                .map(comment -> comment.getUser().getId())
                .collect(Collectors.toSet()));
        List<CommentView> comments = postComments
                .stream()
                .map(comment -> new CommentView(
                        comment.getId(),
                        comment.getUser().getId(),
                        comment.getUser().getUsername(),
                        commentAuthorImages.get(comment.getUser().getId()),
                        comment.getCommentText(),
                        comment.getCreatedAt()
                ))
                .toList();

        return new PostDetailView(
                post.getId(),
                post.getUser().getId(),
                post.getUser().getUsername(),
                authorProfileImageUrl,
                post.getCaption(),
                post.getVisibilityStatus(),
                primaryImageUrl(post),
                mediaUrls(post),
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
        return createPostForUser(user, request.caption(), request.visibilityStatus(), request.mediaUrls());
    }

    @Transactional
    public FeedPostView createPostForUsername(String username, String caption, VisibilityStatus visibilityStatus, List<String> mediaUrls) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        return createPostForUser(user, caption, visibilityStatus, mediaUrls);
    }

    private FeedPostView createPostForUser(User user, String caption, VisibilityStatus visibilityStatus, List<String> mediaUrls) {
        Post post = new Post();
        post.setUser(user);
        post.setCaption(caption);
        replaceMedia(post, mediaUrls);
        post.setPostType(post.getMedia().isEmpty() ? PostType.TEXT : PostType.IMAGE);
        post.setVisibilityStatus(visibilityStatus == null ? VisibilityStatus.PUBLIC : visibilityStatus);
        Post saved = postRepository.save(post);
        return toFeedPostView(saved, authorProfileImageUrl(saved), false);
    }

    @Transactional
    public PostDetailView toggleLike(Long postId, String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new ResourceNotFoundException("User not found: " + username));
        Post post = postRepository.findByIdWithUser(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found: " + postId));

        ensureCanView(post, username);

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

        ensureCanView(post, username);

        PostComment comment = new PostComment();
        comment.setPost(post);
        comment.setUser(user);
        comment.setCommentText(commentText.trim());
        postCommentRepository.save(comment);

        return getPostDetail(postId, username);
    }

    @Transactional
    public FeedPostView updatePost(Long postId, UpdatePostRequest request, String username) {
        Post post = postRepository.findByIdWithUser(postId)
                .orElseThrow(() -> new ResourceNotFoundException("Post not found: " + postId));
        ensurePostOwner(post, username);
        post.setCaption(request.caption());
        post.setVisibilityStatus(request.visibilityStatus());
        replaceMedia(post, request.mediaUrls());
        post.setPostType(post.getMedia().isEmpty() ? PostType.TEXT : PostType.IMAGE);
        Post saved = postRepository.save(post);
        return toFeedPostView(saved, authorProfileImageUrl(saved), false);
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

    private Page<FeedPostView> toFeedPostViews(Page<Post> page, String currentUsername) {
        Map<Long, String> authorImages = authorProfileImages(page.getContent());
        Set<Long> likedPostIds = likedPostIds(page.getContent(), currentUsername);
        return page.map(post -> toFeedPostView(
                post,
                authorImages.get(post.getUser().getId()),
                likedPostIds.contains(post.getId())
        ));
    }

    private String authorProfileImageUrl(Post post) {
        return authorProfileImages(List.of(post)).get(post.getUser().getId());
    }

    private Set<Long> likedPostIds(List<Post> posts, String currentUsername) {
        if (currentUsername == null || currentUsername.isBlank() || posts.isEmpty()) {
            return Set.of();
        }
        Long currentUserId = userRepository.findByUsername(currentUsername).map(User::getId).orElse(null);
        if (currentUserId == null) {
            return Set.of();
        }
        Set<Long> postIds = posts.stream().map(Post::getId).collect(Collectors.toSet());
        return Set.copyOf(postLikeRepository.findLikedPostIds(currentUserId, postIds));
    }

    private FeedPostView toFeedPostView(Post post, String authorProfileImageUrl, boolean likedByCurrentUser) {
        long likes = postLikeRepository.countByPostId(post.getId());
        long comments = postCommentRepository.countByPostId(post.getId());
        List<String> mediaUrls = mediaUrls(post);

        return new FeedPostView(
                post.getId(),
                post.getUser().getId(),
                post.getUser().getUsername(),
                authorProfileImageUrl,
                post.getCaption(),
                post.getVisibilityStatus(),
                mediaUrls.isEmpty() ? null : mediaUrls.getFirst(),
                mediaUrls,
                likes,
                comments,
                likedByCurrentUser,
                post.getCreatedAt()
        );
    }

    @Transactional(readOnly = true)
    public Page<FeedPostView> getPublicPostsByUser(Long userId, Pageable pageable) {
        Page<Post> page = postRepository.findByUserIdAndVisibilityStatusOrderByCreatedAtDesc(
                userId,
                VisibilityStatus.PUBLIC,
                pageable
        );

        return toFeedPostViews(page, null);
    }

    private void replaceMedia(Post post, List<String> requestedMediaUrls) {
        post.getMedia().clear();
        List<String> urls = requestedMediaUrls == null ? List.of() : requestedMediaUrls.stream()
                .filter(Objects::nonNull)
                .map(mediaStorageService::normalizeManagedUrl)
                .filter(Objects::nonNull)
                .distinct()
                .limit(10)
                .toList();
        for (int index = 0; index < urls.size(); index++) {
            PostMedia media = new PostMedia();
            media.setPost(post);
            media.setMediaUrl(urls.get(index));
            media.setMediaType(MediaType.IMAGE);
            media.setDisplayOrder(index);
            post.getMedia().add(media);
        }
    }

    private String primaryImageUrl(Post post) {
        List<String> urls = mediaUrls(post);
        return urls.isEmpty() ? null : urls.getFirst();
    }

    private List<String> mediaUrls(Post post) {
        return post.getMedia().stream()
                .map(PostMedia::getMediaUrl)
                .filter(Objects::nonNull)
                .map(url -> normalizeStoredMediaUrl(post, url))
                .filter(Objects::nonNull)
                .toList();
    }

    private String normalizeStoredMediaUrl(Post post, String mediaUrl) {
        try {
            return mediaStorageService.normalizeManagedUrl(mediaUrl);
        } catch (IllegalArgumentException ex) {
            log.warn("Ignoring invalid media URL on post {}: {}", post.getId(), mediaUrl);
            return null;
        }
    }
}
