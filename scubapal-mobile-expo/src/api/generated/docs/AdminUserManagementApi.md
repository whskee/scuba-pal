# AdminUserManagementApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**create2**](#create2) | **POST** /api/admin/users | |
|[**deactivate**](#deactivate) | **DELETE** /api/admin/users/{id} | |
|[**getAll1**](#getall1) | **GET** /api/admin/users | |
|[**getById1**](#getbyid1) | **GET** /api/admin/users/{id} | |
|[**update2**](#update2) | **PATCH** /api/admin/users/{id} | |

# **create2**
> AdminUserView create2(adminCreateUserRequest)


### Example

```typescript
import {
    AdminUserManagementApi,
    Configuration,
    AdminCreateUserRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminUserManagementApi(configuration);

let adminCreateUserRequest: AdminCreateUserRequest; //

const { status, data } = await apiInstance.create2(
    adminCreateUserRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **adminCreateUserRequest** | **AdminCreateUserRequest**|  | |


### Return type

**AdminUserView**

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

# **deactivate**
> MessageResponse deactivate()


### Example

```typescript
import {
    AdminUserManagementApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminUserManagementApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.deactivate(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**MessageResponse**

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

# **getAll1**
> PageResponseAdminUserView getAll1()


### Example

```typescript
import {
    AdminUserManagementApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminUserManagementApi(configuration);

let page: number; // (optional) (default to 0)
let size: number; // (optional) (default to 20)

const { status, data } = await apiInstance.getAll1(
    page,
    size
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **page** | [**number**] |  | (optional) defaults to 0|
| **size** | [**number**] |  | (optional) defaults to 20|


### Return type

**PageResponseAdminUserView**

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

# **getById1**
> AdminUserView getById1()


### Example

```typescript
import {
    AdminUserManagementApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminUserManagementApi(configuration);

let id: number; // (default to undefined)

const { status, data } = await apiInstance.getById1(
    id
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **id** | [**number**] |  | defaults to undefined|


### Return type

**AdminUserView**

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

# **update2**
> AdminUserView update2(updateUserRequest)


### Example

```typescript
import {
    AdminUserManagementApi,
    Configuration,
    UpdateUserRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new AdminUserManagementApi(configuration);

let id: number; // (default to undefined)
let updateUserRequest: UpdateUserRequest; //

const { status, data } = await apiInstance.update2(
    id,
    updateUserRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **updateUserRequest** | **UpdateUserRequest**|  | |
| **id** | [**number**] |  | defaults to undefined|


### Return type

**AdminUserView**

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

