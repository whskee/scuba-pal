# PostsApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**comment**](#comment) | **POST** /api/posts/{id}/comments | |
|[**createForCurrentUser**](#createforcurrentuser) | **POST** /api/posts/me | |
|[**delete1**](#delete1) | **DELETE** /api/posts/{id} | |
|[**deleteComment**](#deletecomment) | **DELETE** /api/posts/{postId}/comments/{commentId} | |
|[**getAll3**](#getall3) | **GET** /api/posts | |
|[**getById1**](#getbyid1) | **GET** /api/posts/{id} | |
|[**getByUser**](#getbyuser) | **GET** /api/posts/users/{userId} | |
|[**like**](#like) | **POST** /api/posts/{id}/like | |
|[**search**](#search) | **GET** /api/posts/search | |
|[**update2**](#update2) | **PUT** /api/posts/{id} | |

# **comment**
> PostDetailView comment(createCommentRequest)


### Example

```typescript
import {
    PostsApi,
    Configuration,
    CreateCommentRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new PostsApi(configuration);

let id: number; // (default to undefined)
let createCommentRequest: CreateCommentRequest; //

const { status, data } = await apiInstance.comment(
    id,
    createCommentRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **createCommentRequest** | **CreateCommentRequest**|  | |
| **id** | [**number**] |  | defaults to undefined|


### Return type

**PostDetailView**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **createForCurrentUser**
> FeedPostView createForCurrentUser(createCurrentUserPostRequest)


### Example

```typescript
import {
    PostsApi,
    Configuration,
    CreateCurrentUserPostRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new PostsApi(configuration);

let createCurrentUserPostRequest: CreateCurrentUserPostRequest; //

const { status, data } = await apiInstance.createForCurrentUser(
    createCurrentUserPostRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **createCurrentUserPostRequest** | **CreateCurrentUserPostRequest**|  | |


### Return type

**FeedPostView**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **delete1**
> MessageResponse delete1()


### Example

```typescript
import {
    PostsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new PostsApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.delete1(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**MessageResponse**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteComment**
> MessageResponse deleteComment()


### Example

```typescript
import {
    PostsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new PostsApi(configuration);

let postId: number; // (default to undefined)
let commentId: number; // (default to undefined)

const { status, data } = await apiInstance.deleteComment(
    postId,
    commentId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **postId** | [**number**] |  | defaults to undefined|
| **commentId** | [**number**] |  | defaults to undefined|


### Return type

**MessageResponse**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAll3**
> PagedModelFeedPostView getAll3()


### Example

```typescript
import {
    PostsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new PostsApi(configuration);

let page: number; // (optional) (default to 0)
let size: number; // (optional) (default to 10)

const { status, data } = await apiInstance.getAll3(
    page,
    size
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **page** | [**number**] |  | (optional) defaults to 0|
| **size** | [**number**] |  | (optional) defaults to 10|


### Return type

**PagedModelFeedPostView**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getById1**
> PostDetailView getById1()


### Example

```typescript
import {
    PostsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new PostsApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.getById1(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**PostDetailView**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getByUser**
> PagedModelFeedPostView getByUser()


### Example

```typescript
import {
    PostsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new PostsApi(configuration);

let userId: number; // (default to undefined)
let page: number; // (optional) (default to 0)
let size: number; // (optional) (default to 12)

const { status, data } = await apiInstance.getByUser(
    userId,
    page,
    size
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **userId** | [**number**] |  | defaults to undefined|
| **page** | [**number**] |  | (optional) defaults to 0|
| **size** | [**number**] |  | (optional) defaults to 12|


### Return type

**PagedModelFeedPostView**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **like**
> PostDetailView like()


### Example

```typescript
import {
    PostsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new PostsApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.like(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**PostDetailView**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **search**
> PagedModelFeedPostView search()


### Example

```typescript
import {
    PostsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new PostsApi(configuration);

let page: number; // (optional) (default to 0)
let size: number; // (optional) (default to 10)

const { status, data } = await apiInstance.search(
    page,
    size
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **page** | [**number**] |  | (optional) defaults to 0|
| **size** | [**number**] |  | (optional) defaults to 10|


### Return type

**PagedModelFeedPostView**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **update2**
> FeedPostView update2(updatePostRequest)


### Example

```typescript
import {
    PostsApi,
    Configuration,
    UpdatePostRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new PostsApi(configuration);

let id: number; // (default to undefined)
let updatePostRequest: UpdatePostRequest; //

const { status, data } = await apiInstance.update2(
    id,
    updatePostRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **updatePostRequest** | **UpdatePostRequest**|  | |
| **id** | [**number**] |  | defaults to undefined|


### Return type

**FeedPostView**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

