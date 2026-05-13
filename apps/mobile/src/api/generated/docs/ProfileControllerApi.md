# ProfileControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**create**](#create) | **POST** /api/profiles/{userId} | |
|[**get**](#get) | **GET** /api/profiles/{userId} | |
|[**update1**](#update1) | **PUT** /api/profiles/{userId} | |

# **create**
> Profile create(profile)


### Example

```typescript
import {
    ProfileControllerApi,
    Configuration,
    Profile
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileControllerApi(configuration);

let userId: number; // (default to undefined)
let profile: Profile; //

const { status, data } = await apiInstance.create(
    userId,
    profile
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **profile** | **Profile**|  | |
| **userId** | [**number**] |  | defaults to undefined|


### Return type

**Profile**

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

# **get**
> Profile get()


### Example

```typescript
import {
    ProfileControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileControllerApi(configuration);

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

**Profile**

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

# **update1**
> Profile update1(profile)


### Example

```typescript
import {
    ProfileControllerApi,
    Configuration,
    Profile
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfileControllerApi(configuration);

let userId: number; // (default to undefined)
let profile: Profile; //

const { status, data } = await apiInstance.update1(
    userId,
    profile
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **profile** | **Profile**|  | |
| **userId** | [**number**] |  | defaults to undefined|


### Return type

**Profile**

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

