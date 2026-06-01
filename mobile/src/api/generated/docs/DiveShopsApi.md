# DiveShopsApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**getAll2**](#getall2) | **GET** /api/shops | List dive shops|

# **getAll2**
> PageResponseDiveShopResponse getAll2()

Returns paged dive shops, optionally filtered by shop name, city, state, country, or linked dive location.

### Example

```typescript
import {
    DiveShopsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new DiveShopsApi(configuration);

let q: string; // (optional) (default to undefined)
let page: number; // (optional) (default to 0)
let size: number; // (optional) (default to 50)

const { status, data } = await apiInstance.getAll2(
    q,
    page,
    size
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **q** | [**string**] |  | (optional) defaults to undefined|
| **page** | [**number**] |  | (optional) defaults to 0|
| **size** | [**number**] |  | (optional) defaults to 50|


### Return type

**PageResponseDiveShopResponse**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Shop list returned |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

