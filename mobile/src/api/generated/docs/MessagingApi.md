# MessagingApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**conversations**](#conversations) | **GET** /api/messages/conversations | List conversations|
|[**markRead2**](#markread2) | **POST** /api/messages/{conversationId}/read | Mark conversation messages as read|
|[**messages**](#messages) | **GET** /api/messages/{conversationId} | List direct messages|
|[**sendMessage**](#sendmessage) | **POST** /api/messages/{conversationId} | Send direct message|
|[**startConversation**](#startconversation) | **POST** /api/messages/conversations/{otherUserId} | Start conversation|

# **conversations**
> ConversationListResponse conversations()

Returns paged conversations for the authenticated user.

### Example

```typescript
import {
    MessagingApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new MessagingApi(configuration);

let page: number; // (optional) (default to 0)
let size: number; // (optional) (default to 20)

const { status, data } = await apiInstance.conversations(
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

**ConversationListResponse**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Conversation list returned |  -  |
|**401** | Authentication required |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **markRead2**
> UnreadCountView markRead2()

Marks all unread messages in a conversation as read for the authenticated user.

### Example

```typescript
import {
    MessagingApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new MessagingApi(configuration);

let conversationId: number; // (default to undefined)

const { status, data } = await apiInstance.markRead2(
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
|**200** | Unread counters returned |  -  |
|**401** | Authentication required |  -  |
|**404** | Conversation not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **messages**
> MessageListResponse messages()

Returns paged direct messages for a conversation and marks unread items as read.

### Example

```typescript
import {
    MessagingApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new MessagingApi(configuration);

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

**MessageListResponse**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Message list returned |  -  |
|**401** | Authentication required |  -  |
|**404** | Conversation not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **sendMessage**
> MessageResponse sendMessage(sendMessageRequest)

Sends a message to a conversation participant.

### Example

```typescript
import {
    MessagingApi,
    Configuration,
    SendMessageRequest
} from './api';

const configuration = new Configuration();
const apiInstance = new MessagingApi(configuration);

let conversationId: number; // (default to undefined)
let sendMessageRequest: SendMessageRequest; //

const { status, data } = await apiInstance.sendMessage(
    conversationId,
    sendMessageRequest
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **sendMessageRequest** | **SendMessageRequest**|  | |
| **conversationId** | [**number**] |  | defaults to undefined|


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
|**201** | Message sent |  -  |
|**400** | Invalid request |  -  |
|**401** | Authentication required |  -  |
|**404** | Conversation not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **startConversation**
> ConversationView startConversation()

Finds or creates a direct-message conversation with another user.

### Example

```typescript
import {
    MessagingApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new MessagingApi(configuration);

let otherUserId: number; // (default to undefined)

const { status, data } = await apiInstance.startConversation(
    otherUserId
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **otherUserId** | [**number**] |  | defaults to undefined|


### Return type

**ConversationView**

### Authorization

[bearerAuth](../README.md#bearerAuth)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*


### HTTP response details
| Status code | Description | Response headers |
|-------------|-------------|------------------|
|**200** | Conversation returned |  -  |
|**400** | Invalid request |  -  |
|**401** | Authentication required |  -  |
|**404** | User not found |  -  |

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

