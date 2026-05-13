# User


## Properties

Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**id** | **number** |  | [optional] [default to undefined]
**createdAt** | **string** |  | [optional] [default to undefined]
**updatedAt** | **string** |  | [optional] [default to undefined]
**deletedAt** | **string** |  | [optional] [default to undefined]
**email** | **string** |  | [optional] [default to undefined]
**username** | **string** |  | [optional] [default to undefined]
**passwordHash** | **string** |  | [optional] [default to undefined]
**role** | [**Role**](Role.md) |  | [optional] [default to undefined]
**active** | **boolean** |  | [optional] [default to undefined]
**emailVerifiedAt** | **string** |  | [optional] [default to undefined]
**lastLoginAt** | **string** |  | [optional] [default to undefined]

## Example

```typescript
import { User } from './api';

const instance: User = {
    id,
    createdAt,
    updatedAt,
    deletedAt,
    email,
    username,
    passwordHash,
    role,
    active,
    emailVerifiedAt,
    lastLoginAt,
};
```

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)
