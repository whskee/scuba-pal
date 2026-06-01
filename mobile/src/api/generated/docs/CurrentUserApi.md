# CurrentUserApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**changePassword**](#changepassword) | **PATCH** /api/me/password | |
|[**currentUser**](#currentuser) | **GET** /api/me | |
|[**updateSettings**](#updatesettings) | **PATCH** /api/me/settings | |

# **changePassword**
> MessageResponse changePassword(changePasswordRequest)


### Example

```typescript
import {
    CurrentUserApi,
    Configuration,
    ChangePasswordRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new CurrentUserApi(configuration);

let changePasswordRequest: ChangePasswordRequest; //

const { status, data } = await apiInstance.changePassword(
    changePasswordRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **changePasswordRequest** | **ChangePasswordRequest**|  | |


### Return type

**MessageResponse**

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

# **currentUser**
> CurrentUserView currentUser()


### Example

```typescript
import {
    CurrentUserApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new CurrentUserApi(configuration);

const { status, data } = await apiInstance.currentUser();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**CurrentUserView**

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

# **updateSettings**
> CurrentUserView updateSettings(updateCurrentUserSettingsRequest)


### Example

```typescript
import {
    CurrentUserApi,
    Configuration,
    UpdateCurrentUserSettingsRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new CurrentUserApi(configuration);

let updateCurrentUserSettingsRequest: UpdateCurrentUserSettingsRequest; //

const { status, data } = await apiInstance.updateSettings(
    updateCurrentUserSettingsRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **updateCurrentUserSettingsRequest** | **UpdateCurrentUserSettingsRequest**|  | |


### Return type

**CurrentUserView**

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

