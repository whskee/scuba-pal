import { AuthenticationApi, LoginRequest, RegisterRequest, UserView } from "@/api/generated";
import { api, apiConfig, unwrap } from "@/services/api";
import { AuthResponse, User, toUser } from "@/types/models";

const generatedAuthApi = new AuthenticationApi(apiConfig, undefined, api);

export type LoginInput = LoginRequest;
export type RegisterInput = RegisterRequest;
export type Session = { user: User; token?: string };

function isUserView(value: unknown): value is UserView {
  const candidate = value as UserView | undefined;
  return !!candidate && candidate.id !== undefined && typeof candidate.username === "string";
}

function encodeBase64(input: string): string {
  const globalBtoa = (globalThis as { btoa?: (value: string) => string }).btoa;
  if (globalBtoa) return globalBtoa(input);

  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
  let output = "";
  let i = 0;
  while (i < input.length) {
    const chr1 = input.charCodeAt(i++);
    const chr2 = input.charCodeAt(i++);
    const chr3 = input.charCodeAt(i++);
    const enc1 = chr1 >> 2;
    const enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
    let enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
    let enc4 = chr3 & 63;
    if (Number.isNaN(chr2)) {
      enc3 = 64;
      enc4 = 64;
    } else if (Number.isNaN(chr3)) {
      enc4 = 64;
    }
    output += chars.charAt(enc1) + chars.charAt(enc2) + chars.charAt(enc3) + chars.charAt(enc4);
  }
  return output;
}

function currentBackendBasicToken(input: LoginInput): string {
  return `Basic ${encodeBase64(`${input.username}:${input.password}`)}`;
}

export function toSession(data: AuthResponse | UserView, fallbackToken?: string): Session {
  if ("user" in data && data.user) {
    return { user: data.user, token: data.token ?? data.accessToken ?? data.jwt ?? fallbackToken };
  }

  if (isUserView(data)) {
    return { user: toUser(data), token: fallbackToken };
  }

  throw new Error("The backend returned an unsupported authentication response.");
}

export const authApi = {
  async login(input: LoginInput): Promise<Session> {
    const response = await unwrap<UserView>(generatedAuthApi.login(input));
    return toSession(response, currentBackendBasicToken(input));
  },

  async register(input: RegisterInput): Promise<Session> {
    const response = await unwrap<UserView>(generatedAuthApi.register(input));
    return toSession(response, currentBackendBasicToken(input));
  },

  async logout() {
    return unwrap(generatedAuthApi.logout());
  },

  async usernameAvailable(username: string): Promise<boolean> {
    const response = await unwrap<Record<string, boolean>>(generatedAuthApi.usernameAvailable(username));
    return !!response[username] || !!response.available;
  }
};
