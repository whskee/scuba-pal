# PostDetailView


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**postId** | **number** |  | [optional] [default to undefined]
**userId** | **number** |  | [optional] [default to undefined]
**username** | **string** |  | [optional] [default to undefined]
**caption** | **string** |  | [optional] [default to undefined]
**visibilityStatus** | **string** |  | [optional] [default to undefined]
**likes** | **number** |  | [optional] [default to undefined]
**comments** | **number** |  | [optional] [default to undefined]
**likedByCurrentUser** | **boolean** |  | [optional] [default to undefined]
**createdAt** | **string** |  | [optional] [default to undefined]
**commentList** | [**Array&lt;CommentView&gt;**](CommentView.md) |  | [optional] [default to undefined]

## Example

```typescript
import { PostDetailView } from './api';

const instance: PostDetailView = {
    postId,
    userId,
    username,
    caption,
    visibilityStatus,
    likes,
    comments,
    likedByCurrentUser,
    createdAt,
    commentList,
};
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
