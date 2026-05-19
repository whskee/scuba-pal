# ProfilesApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**create**](#create) | **POST** /api/profiles/{userId} | Create profile|
|[**get**](#get) | **GET** /api/profiles/{userId} | Get profile|
|[**update1**](#update1) | **PUT** /api/profiles/{userId} | Update profile|

# **create**
> ProfileResponse create(upsertProfileRequest)

Creates a profile for a user if one does not already exist.

### Example

```typescript
import {
    ProfilesApi,
    Configuration,
    UpsertProfileRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfilesApi(configuration);

let userId: number; // (default to undefined)
let upsertProfileRequest: UpsertProfileRequest; //

const { status, data } = await apiInstance.create(
    userId,
    upsertProfileRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **upsertProfileRequest** | **UpsertProfileRequest**|  | |
| **userId** | [**number**] |  | defaults to undefined|


### Return type

**ProfileResponse**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**201** | Profile created |  -  |
|**400** | Invalid request |  -  |
|**404** | User not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **get**
> ProfileResponse get()

Returns profile details for a user.

### Example

```typescript
import {
    ProfilesApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfilesApi(configuration);

let userId: number; // (default to undefined)

const { status, data } = await apiInstance.get(
    userId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **userId** | [**number**] |  | defaults to undefined|


### Return type

**ProfileResponse**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Profile returned |  -  |
|**404** | Profile not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **update1**
> ProfileResponse update1(upsertProfileRequest)

Updates profile details for a user.

### Example

```typescript
import {
    ProfilesApi,
    Configuration,
    UpsertProfileRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfilesApi(configuration);

let userId: number; // (default to undefined)
let upsertProfileRequest: UpsertProfileRequest; //

const { status, data } = await apiInstance.update1(
    userId,
    upsertProfileRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **upsertProfileRequest** | **UpsertProfileRequest**|  | |
| **userId** | [**number**] |  | defaults to undefined|


### Return type

**ProfileResponse**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Profile updated |  -  |
|**400** | Invalid request |  -  |
|**404** | Profile not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

