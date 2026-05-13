# LocationControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**create3**](#create3) | **POST** /api/locations | |
|[**getAll2**](#getall2) | **GET** /api/locations | |

# **create3**
> DiveLocation create3(createLocationRequest)


### Example

```typescript
import {
    LocationControllerApi,
    Configuration,
    CreateLocationRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new LocationControllerApi(configuration);

let createLocationRequest: CreateLocationRequest; //

const { status, data } = await apiInstance.create3(
    createLocationRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **createLocationRequest** | **CreateLocationRequest**|  | |


### Return type

**DiveLocation**

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

# **getAll2**
> Array<DiveLocation> getAll2()


### Example

```typescript
import {
    LocationControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new LocationControllerApi(configuration);

let city: string; // (optional) (default to undefined)

const { status, data } = await apiInstance.getAll2(
    city
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **city** | [**string**] |  | (optional) defaults to undefined|


### Return type

**Array<DiveLocation>**

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

