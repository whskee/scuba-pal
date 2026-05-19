# MediaApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**createUpload**](#createupload) | **POST** /api/media/uploads | |

# **createUpload**
> MediaUploadResponse createUpload(createMediaUploadRequest)


### Example

```typescript
import {
    MediaApi,
    Configuration,
    CreateMediaUploadRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new MediaApi(configuration);

let createMediaUploadRequest: CreateMediaUploadRequest; //

const { status, data } = await apiInstance.createUpload(
    createMediaUploadRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **createMediaUploadRequest** | **CreateMediaUploadRequest**|  | |


### Return type

**MediaUploadResponse**

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

