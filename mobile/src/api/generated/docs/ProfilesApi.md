# ProfilesApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**create**](#create) | **POST** /api/profiles/{userId} | Create profile|
|[**currentProfile**](#currentprofile) | **GET** /api/me/profile | Get current user\&#39;s profile|
|[**get**](#get) | **GET** /api/profiles/{userId} | Get profile|
|[**get1**](#get1) | **GET** /api/users/{userId}/profile | Get profile|
|[**searchPublicProfiles**](#searchpublicprofiles) | **GET** /api/profiles | Search public profiles|
|[**update**](#update) | **PUT** /api/profiles/{userId} | Update profile|
|[**updateCurrentProfile**](#updatecurrentprofile) | **PUT** /api/me/profile | Update current user\&#39;s profile|

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

# **currentProfile**
> ProfileResponse currentProfile()

Returns profile details for the authenticated user.

### Example

```typescript
import {
    ProfilesApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfilesApi(configuration);

const { status, data } = await apiInstance.currentProfile();
```

### Parameters
This endpoint does not have any parameters.


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
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **get**
> PublicProfileResponse get()

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

**PublicProfileResponse**

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

# **get1**
> PublicProfileResponse get1()

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

const { status, data } = await apiInstance.get1(
    userId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **userId** | [**number**] |  | defaults to undefined|


### Return type

**PublicProfileResponse**

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

# **searchPublicProfiles**
> PageResponsePublicProfileResponse searchPublicProfiles()

Returns active public diver profiles visible to all users.

### Example

```typescript
import {
    ProfilesApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfilesApi(configuration);

let q: string; // (optional) (default to undefined)
let page: number; // (optional) (default to 0)
let size: number; // (optional) (default to 20)

const { status, data } = await apiInstance.searchPublicProfiles(
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
| **size** | [**number**] |  | (optional) defaults to 20|


### Return type

**PageResponsePublicProfileResponse**

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

# **update**
> ProfileResponse update(upsertProfileRequest)

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

const { status, data } = await apiInstance.update(
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

# **updateCurrentProfile**
> ProfileResponse updateCurrentProfile(upsertProfileRequest)

Updates profile details for the authenticated user.

### Example

```typescript
import {
    ProfilesApi,
    Configuration,
    UpsertProfileRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new ProfilesApi(configuration);

let upsertProfileRequest: UpsertProfileRequest; //

const { status, data } = await apiInstance.updateCurrentProfile(
    upsertProfileRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **upsertProfileRequest** | **UpsertProfileRequest**|  | |


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
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

