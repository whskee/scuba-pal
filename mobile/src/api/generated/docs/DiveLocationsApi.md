# DiveLocationsApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**create2**](#create2) | **POST** /api/locations | Create dive location|
|[**getAll1**](#getall1) | **GET** /api/locations | List dive locations|

# **create2**
> DiveLocationResponse create2(createLocationRequest)

Creates a new dive location.

### Example

```typescript
import {
    DiveLocationsApi,
    Configuration,
    CreateLocationRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new DiveLocationsApi(configuration);

let createLocationRequest: CreateLocationRequest; //

const { status, data } = await apiInstance.create2(
    createLocationRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **createLocationRequest** | **CreateLocationRequest**|  | |


### Return type

**DiveLocationResponse**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**201** | Location created |  -  |
|**400** | Invalid request |  -  |
|**401** | Authentication required |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAll1**
> Array<DiveLocationResponse> getAll1()

Returns dive locations, optionally filtered by city.

### Example

```typescript
import {
    DiveLocationsApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new DiveLocationsApi(configuration);

let city: string; // (optional) (default to undefined)

const { status, data } = await apiInstance.getAll1(
    city
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **city** | [**string**] |  | (optional) defaults to undefined|


### Return type

**Array<DiveLocationResponse>**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Location list returned |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

