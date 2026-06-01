# PostPageControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**toggleLikeFetch**](#togglelikefetch) | **POST** /posts/{id}/like | |

# **toggleLikeFetch**
> PostDetailView toggleLikeFetch()


### Example

```typescript
import {
    PostPageControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new PostPageControllerApi(configuration);

let id: number; // (default to undefined)
let xRequestedWith: 'fetch'; // (optional) (default to undefined)

const { status, data } = await apiInstance.toggleLikeFetch(
    id,
    xRequestedWith
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|
| **xRequestedWith** | [**&#39;fetch&#39;**]**Array<&#39;fetch&#39;>** |  | (optional) defaults to undefined|


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

