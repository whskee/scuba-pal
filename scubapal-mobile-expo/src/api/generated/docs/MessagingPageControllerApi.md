# MessagingPageControllerApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**sendMessageInline**](#sendmessageinline) | **POST** /messages/{conversationId}/send | |
|[**updates**](#updates) | **GET** /messages/{conversationId}/updates | |

# **sendMessageInline**
> ConversationPollResponse sendMessageInline()


### Example

```typescript
import {
    MessagingPageControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new MessagingPageControllerApi(configuration);

let conversationId: number; // (default to undefined)
let messageText: string; // (default to undefined)

const { status, data } = await apiInstance.sendMessageInline(
    conversationId,
    messageText
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **conversationId** | [**number**] |  | defaults to undefined|
| **messageText** | [**string**] |  | defaults to undefined|


### Return type

**ConversationPollResponse**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updates**
> ConversationPollResponse updates()


### Example

```typescript
import {
    MessagingPageControllerApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new MessagingPageControllerApi(configuration);

let conversationId: number; // (default to undefined)
let page: number; // (optional) (default to 0)
let size: number; // (optional) (default to 50)

const { status, data } = await apiInstance.updates(
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

**ConversationPollResponse**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | OK |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

