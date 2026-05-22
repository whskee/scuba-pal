# DiveShopsApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**getAll2**](#getall2) | **GET** /api/shops | List dive shops|

# **getAll2**
> Array<DiveShopResponse> getAll2()

Returns dive shops, optionally filtered by shop name, city, state, country, or linked dive location.

### Example

```typescript
import {
    DiveShopsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new DiveShopsApi(configuration);

let q: string; // (optional) (default to undefined)

const { status, data } = await apiInstance.getAll2(
    q
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **q** | [**string**] |  | (optional) defaults to undefined|


### Return type

**Array<DiveShopResponse>**

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

