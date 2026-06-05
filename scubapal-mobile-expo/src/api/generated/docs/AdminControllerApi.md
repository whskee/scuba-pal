# AdminControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**posts**](#posts) | **GET** /api/admin/posts | |
|[**stats**](#stats) | **GET** /api/admin/stats | |

# **posts**
> PageResponseFeedPostView posts()


### Example

```typescript
import {
    AdminControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminControllerApi(configuration);

let page: number; // (optional) (default to 0)
let size: number; // (optional) (default to 20)

const { status, data } = await apiInstance.posts(
    page,
    size
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **page** | [**number**] |  | (optional) defaults to 0|
| **size** | [**number**] |  | (optional) defaults to 20|


### Return type

**PageResponseFeedPostView**

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

# **stats**
> AdminStatsView stats()


### Example

```typescript
import {
    AdminControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminControllerApi(configuration);

const { status, data } = await apiInstance.stats();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**AdminStatsView**

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

