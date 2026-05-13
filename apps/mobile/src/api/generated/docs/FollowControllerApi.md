# FollowControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**follow**](#follow) | **POST** /api/users/{userId}/follow | |
|[**unfollow**](#unfollow) | **DELETE** /api/users/{userId}/follow | |

# **follow**
> FollowSummaryView follow()


### Example

```typescript
import {
    FollowControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new FollowControllerApi(configuration);

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
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **unfollow**
> FollowSummaryView unfollow()


### Example

```typescript
import {
    FollowControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new FollowControllerApi(configuration);

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
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

