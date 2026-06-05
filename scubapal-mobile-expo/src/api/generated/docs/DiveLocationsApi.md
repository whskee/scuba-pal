# DiveLocationsApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**create1**](#create1) | **POST** /api/locations | Create dive location|
|[**getAll**](#getall) | **GET** /api/locations | List dive locations|

# **create1**
> DiveLocationResponse create1(createLocationRequest)

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

const { status, data } = await apiInstance.create1(
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

# **getAll**
> PageResponseDiveLocationResponse getAll()

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
let page: number; // (optional) (default to 0)
let size: number; // (optional) (default to 20)

const { status, data } = await apiInstance.getAll(
    city,
    page,
    size
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **city** | [**string**] |  | (optional) defaults to undefined|
| **page** | [**number**] |  | (optional) defaults to 0|
| **size** | [**number**] |  | (optional) defaults to 20|


### Return type

**PageResponseDiveLocationResponse**

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

