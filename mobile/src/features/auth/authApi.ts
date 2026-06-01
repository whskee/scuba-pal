import { AuthenticationApi, AuthResponse as GeneratedAuthResponse, LoginRequest, RefreshTokenRequest, RegisterRequest } from "@/api/generated";
import { api, apiConfig, unwrap } from "@/services/api";
import { User, toUser } from "@/types/models";

const generatedAuthApi = new AuthenticationApi(apiConfig, undefined, api);

export type LoginInput = LoginRequest;
export type RegisterInput = RegisterRequest;
export type Session = { user: User; token: string; refreshToken: string };

export function toSession(data: GeneratedAuthResponse): Session {
  if (!data.user) {
    throw new Error("The backend did not return the authenticated user.");
  }
  if (!data.accessToken) {
    throw new Error("The backend did not return an access token.");
  }
  if (!data.refreshToken) {
    throw new Error("The backend did not return a refresh token.");
  }

  return {
    user: toUser(data.user),
    token: data.accessToken,
    refreshToken: data.refreshToken
  };
}

export const authApi = {
  async login(input: LoginInput): Promise<Session> {
    const response = await unwrap<GeneratedAuthResponse>(generatedAuthApi.login(input));
    return toSession(response);
  },

  async register(input: RegisterInput): Promise<Session> {
    const response = await unwrap<GeneratedAuthResponse>(generatedAuthApi.register(input));
    return toSession(response);
  },

  async logout(refreshToken?: string) {
    if (!refreshToken) return;
    const payload: RefreshTokenRequest = { refreshToken };
    return unwrap(generatedAuthApi.logout(payload));
  },

  async usernameAvailable(username: string): Promise<boolean> {
    const response = await unwrap<Record<string, boolean>>(generatedAuthApi.usernameAvailable(username));
    return !!response[username] || !!response.available;
  }
};
