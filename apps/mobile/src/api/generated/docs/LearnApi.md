# LearnApi

All URIs are relative to *http://localhost:8080*

|Method | HTTP request | Description|
|------------- | ------------- | -------------|
|[**article**](#article) | **GET** /api/learn/articles/{slug} | Get learn article|
|[**articles**](#articles) | **GET** /api/learn/articles | List learn articles|

# **article**
> LearnArticleResponse article()

Returns one published scuba education article by slug.

### Example

```typescript
import {
    LearnApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new LearnApi(configuration);

let slug: string; // (default to undefined)

const { status, data } = await apiInstance.article(
    slug
);
```

### Parameters

|Name | Type | Description  | Notes|
|------------- | ------------- | ------------- | -------------|
| **slug** | [**string**] |  | defaults to undefined|


### Return type

**LearnArticleResponse**

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

# **articles**
> Array<LearnArticleResponse> articles()

Returns published scuba education articles.

### Example

```typescript
import {
    LearnApi,
    Configuration
} from './api';

const configuration = new Configuration();
const apiInstance = new LearnApi(configuration);

const { status, data } = await apiInstance.articles();
```

### Parameters
This endpoint does not have any parameters.


### Return type

**Array<LearnArticleResponse>**

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

