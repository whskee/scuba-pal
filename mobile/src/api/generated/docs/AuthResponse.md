# AuthResponse


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**accessToken** | **string** |  | [optional] [default to undefined]
**refreshToken** | **string** |  | [optional] [default to undefined]
**tokenType** | **string** |  | [optional] [default to undefined]
**expiresAt** | **string** |  | [optional] [default to undefined]
**user** | [**CurrentUserView**](CurrentUserView.md) |  | [optional] [default to undefined]

## Example

```typescript
import { AuthResponse } from './api';

const instance: AuthResponse = {
    accessToken,
    refreshToken,
    tokenType,
    expiresAt,
    user,
};
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
