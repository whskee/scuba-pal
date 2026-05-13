# MessagingControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**markRead**](#markread) | **POST** /api/messages/{conversationId}/read | |
|[**messages**](#messages) | **GET** /api/messages/{conversationId} | |

# **markRead**
> UnreadCountView markRead()


### Example

```typescript
import {
    MessagingControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new MessagingControllerApi(configuration);

let conversationId: number; // (default to undefined)

const { status, data } = await apiInstance.markRead(
    conversationId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **conversationId** | [**number**] |  | defaults to undefined|


### Return type

**UnreadCountView**

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

# **messages**
> PageDirectMessageView messages()


### Example

```typescript
import {
    MessagingControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new MessagingControllerApi(configuration);

let conversationId: number; // (default to undefined)
let page: number; // (optional) (default to 0)
let size: number; // (optional) (default to 50)

const { status, data } = await apiInstance.messages(
    conversationId,
    page,
    size
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **conversationId** | [**number**] |  | defaults to undefined|
| **page** | [**number**] |  | (optional) defaults to 0|
| **size** | [**number**] |  | (optional) defaults to 50|


### Return type

**PageDirectMessageView**

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

