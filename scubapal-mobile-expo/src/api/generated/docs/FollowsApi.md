# FollowsApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**follow**](#follow) | **POST** /api/users/{userId}/follow | Follow user|
|[**followers**](#followers) | **GET** /api/users/{userId}/followers | List followers|
|[**following**](#following) | **GET** /api/users/{userId}/following | List following|
|[**summary**](#summary) | **GET** /api/users/{userId}/follow-summary | Get follow summary|
|[**unfollow**](#unfollow) | **DELETE** /api/users/{userId}/follow | Unfollow user|

# **follow**
> FollowSummaryView follow()

Creates a follow relationship from the authenticated user to the target user.

### Example

```typescript
import {
    FollowsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new FollowsApi(configuration);

let userId: number; // (default to undefined)

const { status, data } = await apiInstance.follow(
    userId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **userId** | [**number**] |  | defaults to undefined|


### Return type

**FollowSummaryView**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Follow summary returned |  -  |
|**400** | Invalid request |  -  |
|**401** | Authentication required |  -  |
|**404** | User not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **followers**
> UserListResponse followers()

Returns a read-only paged list of users following the target user.

### Example

```typescript
import {
    FollowsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new FollowsApi(configuration);

let userId: number; // (default to undefined)
let page: number; // (optional) (default to 0)
let size: number; // (optional) (default to 20)

const { status, data } = await apiInstance.followers(
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
| **size** | [**number**] |  | (optional) defaults to 20|


### Return type

**UserListResponse**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Follower list returned |  -  |
|**404** | User not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **following**
> UserListResponse following()

Returns a read-only paged list of users followed by the target user.

### Example

```typescript
import {
    FollowsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new FollowsApi(configuration);

let userId: number; // (default to undefined)
let page: number; // (optional) (default to 0)
let size: number; // (optional) (default to 20)

const { status, data } = await apiInstance.following(
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
| **size** | [**number**] |  | (optional) defaults to 20|


### Return type

**UserListResponse**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Following list returned |  -  |
|**404** | User not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **summary**
> FollowSummaryView summary()

Returns follower/following counts and whether the current user follows the target user.

### Example

```typescript
import {
    FollowsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new FollowsApi(configuration);

let userId: number; // (default to undefined)

const { status, data } = await apiInstance.summary(
    userId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **userId** | [**number**] |  | defaults to undefined|


### Return type

**FollowSummaryView**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Follow summary returned |  -  |
|**404** | User not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unfollow**
> FollowSummaryView unfollow()

Removes a follow relationship for the authenticated user.

### Example

```typescript
import {
    FollowsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new FollowsApi(configuration);

let userId: number; // (default to undefined)

const { status, data } = await apiInstance.unfollow(
    userId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **userId** | [**number**] |  | defaults to undefined|


### Return type

**FollowSummaryView**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Follow summary returned |  -  |
|**401** | Authentication required |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

