---
title: Optimization
description: A reference page in my new Starlight docs site.
---

I inspected the monorepo `whskee/scuba-pal`. Your repo structure matches the monorepo note: backend in `app/`, mobile Expo app in `mobile/`, and generated OpenAPI client in `mobile/src/api/generated`. 

Progress: **Post module hardening is ~75% complete.**
Next goal: **make post views avatar-aware and secure before expanding feed features.**

---

# Fix order

Do this in this order:

1. Fix post author profile images.
2. Remove unsafe `userId` from normal post creation/update.
3. Fix private post visibility leaks.
4. Add stronger validation.
5. Update Thymeleaf.
6. Regenerate OpenAPI and update mobile mapper.
7. Add tests.

---

# 1. Fix profile images on feed posts

Your `Profile` entity already has:

```java
@Column(name = "profile_image_url", length = 500)
private String profileImageUrl;
```

So the data exists. 

But `FeedPostView` does **not** expose an author profile image:

```java
public record FeedPostView(
        Long postId,
        Long userId,
        String username,
        String caption,
        VisibilityStatus visibilityStatus,
        String imageUrl,
        List<String> mediaUrls,
        long likes,
        long comments,
        LocalDateTime createdAt
) {
}
```



And your feed template only renders the username initial:

```html
<span class="avatar"
      th:text="${#strings.substring(post.username,0,1).toUpperCase()}">S</span>
```



## Change `FeedPostView`

Update:

```java
public record FeedPostView(
        Long postId,
        Long userId,
        String username,
        String authorProfileImageUrl,
        String caption,
        VisibilityStatus visibilityStatus,
        String imageUrl,
        List<String> mediaUrls,
        long likes,
        long comments,
        LocalDateTime createdAt
) {
}
```

Use `authorProfileImageUrl`, not `profileImageUrl`, because `imageUrl` already means the **post image**.

---

# 2. Add avatar to `PostDetailView` too

Your detail view has the same issue:

```java
public record PostDetailView(
        Long postId,
        Long userId,
        String username,
        String caption,
        VisibilityStatus visibilityStatus,
        String imageUrl,
        ...
)
```



Change it to:

```java
public record PostDetailView(
        Long postId,
        Long userId,
        String username,
        String authorProfileImageUrl,
        String caption,
        VisibilityStatus visibilityStatus,
        String imageUrl,
        List<String> mediaUrls,
        long likes,
        long comments,
        boolean likedByCurrentUser,
        LocalDateTime createdAt,
        List<CommentView> commentList
) {
}
```

Later, you should also add comment author avatars to `CommentView`, but do post author first.

---

# 3. Update `PostService` to pull profile images efficiently

You already have a useful method:

```java
List<Profile> findAllByUserIdsWithUser(Collection<Long> userIds);
```



So do **not** query profile once per post. Use one query per feed page.

Add imports:

```java
import com.scubapal.identity.profile.Profile;
import com.scubapal.identity.profile.ProfileRepository;

import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
```

Add field:

```java
private final ProfileRepository profileRepository;
```

Update constructor:

```java
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
```

Replace:

```java
return postRepository.findByVisibilityStatusOrderByCreatedAtDesc(VisibilityStatus.PUBLIC, pageable)
        .map(this::toFeedPostView);
```

with:

```java
Page<Post> page = postRepository.findByVisibilityStatusOrderByCreatedAtDesc(VisibilityStatus.PUBLIC, pageable);
Map<Long, String> authorImages = authorProfileImages(page.getContent());

return page.map(post -> toFeedPostView(post, authorImages.get(post.getUser().getId())));
```

Add helper:

```java
private Map<Long, String> authorProfileImages(List<Post> posts) {
    Set<Long> userIds = posts.stream()
            .map(post -> post.getUser().getId())
            .collect(Collectors.toSet());

    if (userIds.isEmpty()) {
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
```

Then change `toFeedPostView`:

```java
private FeedPostView toFeedPostView(Post post, String authorProfileImageUrl) {
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
            post.getCreatedAt()
    );
}
```

Since your project is Java 25, `getFirst()` is fine.

---

# 4. Update Thymeleaf feed avatar

Replace the current feed meta block with:

```html
<div class="feed-meta">
    <img class="avatar"
         th:if="${post.authorProfileImageUrl}"
         th:src="${post.authorProfileImageUrl}"
         alt="Profile image" />

    <span class="avatar"
          th:unless="${post.authorProfileImageUrl}"
          th:text="${#strings.substring(post.username,0,1).toUpperCase()}">S</span>

    <a th:href="@{'/profile/' + ${post.username}}">
        <strong th:text="${post.username}">username</strong>
    </a>
</div>
```

Do the same in `post-detail.html`, because it also only renders the username initial right now. 

---

# 5. Fix unsafe post creation

This is the biggest production/security issue.

Your `CreatePostRequest` currently accepts:

```java
@NotNull Long userId
```



And `PostController` exposes:

```java
@PostMapping
public ResponseEntity<FeedPostView> create(@Valid @RequestBody CreatePostRequest request) {
    return ResponseEntity.status(HttpStatus.CREATED).body(postService.createPost(request));
}
```



That means any authenticated client can create a post as another user by sending another `userId`.

You already have the better endpoint:

```java
@PostMapping("/me")
public ResponseEntity<FeedPostView> createForCurrentUser(...)
```



## Do this

Delete or admin-restrict:

```java
@PostMapping
public ResponseEntity<FeedPostView> create(...)
```

For now, I would delete it from normal API use.

Keep:

```java
POST /api/posts/me
```

That is what your mobile app already uses:

```ts
generatedPostsApi.createForCurrentUser(payload)
```



So mobile should not break from removing the unsafe generic create endpoint, after regeneration.

---

# 6. Split create and update requests

Right now `updatePost(...)` uses `CreatePostRequest`, which includes `userId`. 

Create this:

```java
public record UpdatePostRequest(
        @NotBlank
        @Size(max = 500)
        String caption,

        @NotNull
        VisibilityStatus visibilityStatus,

        @Size(max = 10)
        List<@NotBlank String> mediaUrls
) {
}
```

Then update controller:

```java
@PutMapping("/{id}")
public FeedPostView update(@PathVariable Long id,
                           @Valid @RequestBody UpdatePostRequest request,
                           Authentication authentication) {
    return postService.updatePost(id, request, authentication.getName());
}
```

And update service signature:

```java
public FeedPostView updatePost(Long postId, UpdatePostRequest request, String username)
```

---

# 7. Fix private post leaks

Current risk:

```java
public Page<FeedPostView> getPostsByUser(Long userId, Pageable pageable) {
    return postRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable).map(this::toFeedPostView);
}
```

This returns all posts by that user, including private posts. 

Also, your profile page calls that method directly:

```java
var posts = postService.getPostsByUser(user.id(), ...);
```



## Add visibility-aware methods

In `PostRepository` add:

```java
@EntityGraph(attributePaths = "user")
Page<Post> findByUserIdAndVisibilityStatusOrderByCreatedAtDesc(
        Long userId,
        VisibilityStatus visibilityStatus,
        Pageable pageable
);
```

Then in service:

```java
@Transactional(readOnly = true)
public Page<FeedPostView> getPublicPostsByUser(Long userId, Pageable pageable) {
    Page<Post> page = postRepository.findByUserIdAndVisibilityStatusOrderByCreatedAtDesc(
            userId,
            VisibilityStatus.PUBLIC,
            pageable
    );

    Map<Long, String> authorImages = authorProfileImages(page.getContent());

    return page.map(post -> toFeedPostView(post, authorImages.get(post.getUser().getId())));
}
```

Then update profile page:

```java
var posts = postService.getPublicPostsByUser(user.id(), PageRequest.of(...));
```

Later, add an owner-aware version:

```java
getVisiblePostsByUser(userId, currentUsername, pageable)
```

so users can see their own private posts.

---

# 8. Guard detail, like, and comment actions

Right now `getPostDetail(...)` fetches by ID and returns it without checking whether the current user is allowed to see it. 

Add:

```java
private void ensureCanView(Post post, String currentUsername) {
    boolean publicPost = post.getVisibilityStatus() == VisibilityStatus.PUBLIC;
    boolean owner = currentUsername != null && post.getUser().getUsername().equals(currentUsername);

    if (!publicPost && !owner) {
        throw new ResourceNotFoundException("Post not found: " + post.getId());
    }
}
```

Call it in:

```java
getPostDetail(...)
toggleLike(...)
addComment(...)
```

For private posts, returning `404 Not Found` is better than `403 Forbidden`, because it does not reveal that the private post exists.

---

# 9. Strengthen validation

Your form has `maxlength="500"`, but backend validation should enforce it too. The entity currently has:

```java
private String caption;
```



Change entity:

```java
@Column(nullable = false, length = 500)
private String caption;
```

Change request/form validation:

```java
@NotBlank
@Size(max = 500)
private String caption = "";
```

For comments, current request is only:

```java
public record CreateCommentRequest(@NotBlank String commentText) {
}
```



Change to:

```java
public record CreateCommentRequest(
        @NotBlank
        @Size(max = 500)
        String commentText
) {
}
```

---

# 10. Database migration improvements

Your migration already has a unique constraint on likes:

```sql
CONSTRAINT post_likes_unique_pair UNIQUE (post_id, user_id)
```

Good. 

But add better feed indexes in a new migration, for example:

```sql
CREATE INDEX idx_posts_visibility_created_at
          ON social.posts(visibility_status, created_at DESC);

CREATE INDEX idx_posts_user_visibility_created_at
          ON social.posts(user_id, visibility_status, created_at DESC);

CREATE INDEX idx_post_media_post_display_order
          ON social.post_media(post_id, display_order);

CREATE INDEX idx_post_comments_post_created_at
          ON social.post_comments(post_id, created_at);
```

Because you are in dev and editing schema often, you can also update `V002` directly if you are still using `create-drop`/fresh DB. But once any environment has run the migration, add a new `Vxxx__...sql`.

---

# 11. Mobile frontend impact

Good news: your mobile card already expects:

```ts
post.author?.profileImageUrl
```



But your mapper currently creates the author without profile image:

```ts
author: {
  id: input.userId ?? 0,
  username: input.username ?? "diver"
}
```



After backend adds `authorProfileImageUrl`, regenerate OpenAPI, then update `mobile/src/types/models.ts`:

```ts
author: {
  id: input.userId ?? 0,
  username: input.username ?? "diver",
  profileImageUrl: resolveMediaUrl(input.authorProfileImageUrl)
},
```

Do **not** manually edit `mobile/src/api/generated`. Regenerate it.

Command from repo root:

```bash
cd app
./mvnw spring-boot:run
```

What it does:

* `cd app`: moves into the Spring Boot backend folder.
* `./mvnw`: uses your project’s Maven wrapper.
* `spring-boot:run`: starts the backend so `/v3/api-docs` is available.

Then, in another terminal from repo root:

```bash
npx @openapitools/openapi-generator-cli generate \
  -i http://localhost:8080/v3/api-docs \
  -g typescript-axios \
  -o mobile/src/api/generated
```

Flags:

* `npx @openapitools/openapi-generator-cli generate`: runs OpenAPI Generator without requiring a global install.
* `-i`: input OpenAPI spec URL.
* `-g typescript-axios`: generate a TypeScript Axios client.
* `-o`: output folder for generated client.

Then update only hand-written mobile code:

```text
mobile/src/types/models.ts
```

Possibly also tests/screens if TypeScript flags changed method names, but based on your current code, the key mapper change is enough.

---

# 12. Tests to update

Your current `PostControllerTest` constructs `FeedPostView` and `PostDetailView` without avatar fields. 

After adding `authorProfileImageUrl`, update constructors:

```java
new FeedPostView(
        1L,
        1L,
        "dana",
        "https://example.com/avatar.jpg",
        "hello",
        VisibilityStatus.PUBLIC,
        null,
        List.of(),
        0,
        0,
        LocalDateTime.now()
);
```

And:

```java
new PostDetailView(
        10L,
        2L,
        "kai",
        "https://example.com/avatar.jpg",
        "Nice dive",
        VisibilityStatus.PUBLIC,
        null,
        List.of(),
        1,
        0,
        true,
        LocalDateTime.now(),
        List.of()
);
```

Add tests for:

```text
private post detail is hidden from non-owner
/api/posts/me uses authenticated user, not request userId
user profile page only shows public posts
feed post includes authorProfileImageUrl when profile has one
```

Run:

```bash
cd app
./mvnw test
```

What it does:

* `cd app`: enters backend project.
* `./mvnw test`: runs Maven test lifecycle using the wrapper.

---

# Final target state for post module

After this pass:

```text
Feed cards show author avatars
Post detail shows author avatar
Mobile feed gets author.profileImageUrl
Clients cannot create posts as other users
Private posts do not leak through profile/detail endpoints
Caption/comment length is enforced server-side
Feed queries have proper indexes
Generated OpenAPI stays source-of-truth for mobile
```

Start with **Step 1–4 only**: add `authorProfileImageUrl`, map it through `PostService`, update Thymeleaf, and update the mobile mapper after regenerating. That directly fixes your visible bug without mixing too many security changes into the first commit.
