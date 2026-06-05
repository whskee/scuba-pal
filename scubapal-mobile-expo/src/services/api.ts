import axios, { AxiosError, InternalAxiosRequestConfig } from "axios";
import { env } from "@/config/env";
import { useAuthStore } from "@/store/authStore";
import { ApiErrorBody, toUser } from "@/types/models";
import { AuthResponse as GeneratedAuthResponse, Configuration, PageMetaResponse } from "@/api/generated";
import { refreshTokenStorage, tokenStorage } from "@/services/storage";

export class ApiError extends Error {
  readonly status?: number;
  readonly code?: string;

  constructor(message: string, status?: number, code?: string) {
    super(message);
    this.name = "ApiError";
    this.status = status;
    this.code = code;
  }
}

export const api = axios.create({
  baseURL: env.apiBaseUrl,
  timeout: env.requestTimeoutMs,
  headers: {
    Accept: "application/json",
    "Content-Type": "application/json"
  }
});

const PUBLIC_AUTH_PATHS = [
  "/api/auth/register",
  "/api/auth/login",
  "/api/auth/username-available",
  "/api/auth/forgot-password",
  "/api/auth/reset-password",
  "/api/auth/refresh",
  "/api/auth/logout"
];

type RetriableRequestConfig = InternalAxiosRequestConfig & { _retry?: boolean };

let refreshPromise: Promise<GeneratedAuthResponse> | undefined;

function isPublicAuthPath(url?: string): boolean {
  const requestPath = url ?? "";
  return PUBLIC_AUTH_PATHS.some((path) => requestPath.endsWith(path) || requestPath.includes(path));
}

async function refreshSession(refreshToken: string): Promise<string> {
  refreshPromise ??= axios
    .post<GeneratedAuthResponse>(
      `${env.apiBaseUrl}/api/auth/refresh`,
      { refreshToken },
      {
        timeout: env.requestTimeoutMs,
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json"
        }
      }
    )
    .then((response) => response.data)
    .finally(() => {
      refreshPromise = undefined;
    });

  const response = await refreshPromise;
  if (!response.accessToken) {
    throw new ApiError("The backend did not return a refreshed access token.", 401, "INVALID_REFRESH_RESPONSE");
  }

  const nextRefreshToken = response.refreshToken ?? refreshToken;
  await Promise.all([tokenStorage.set(response.accessToken), refreshTokenStorage.set(nextRefreshToken)]);

  const current = useAuthStore.getState();
  useAuthStore.setState({
    token: response.accessToken,
    refreshToken: nextRefreshToken,
    user: response.user ? toUser(response.user) : current.user,
    isAuthenticated: !!(response.user ?? current.user)
  });

  return response.accessToken;
}

api.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  if (isPublicAuthPath(config.url)) {
    delete config.headers.Authorization;
    return config;
  }

  const token = useAuthStore.getState().token;
  if (token) {
    config.headers.Authorization = token.startsWith("Basic ") || token.startsWith("Bearer ") ? token : `Bearer ${token}`;
  } else {
    delete config.headers.Authorization;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  async (error: AxiosError<ApiErrorBody>) => {
    const status = error.response?.status;
    const requestConfig = error.config as RetriableRequestConfig | undefined;

    if (status === 401 && requestConfig && !requestConfig._retry && !isPublicAuthPath(requestConfig.url)) {
      const refreshToken = useAuthStore.getState().refreshToken ?? (await refreshTokenStorage.get()) ?? undefined;
      if (refreshToken) {
        requestConfig._retry = true;
        try {
          const accessToken = await refreshSession(refreshToken);
          requestConfig.headers.Authorization = `Bearer ${accessToken}`;
          return api.request(requestConfig);
        } catch {
          await useAuthStore.getState().logout();
        }
      }
    }

    const body = error.response?.data;
    const message =
      body?.message ||
      body?.detail ||
      body?.error ||
      (status === 401 ? "Invalid username or password, or your session expired." : undefined) ||
      (status === 403 ? "You are not allowed to access this resource." : undefined) ||
      (status === 404 ? "This backend endpoint is not available yet." : undefined) ||
      (error.code === "ECONNABORTED" ? "The request timed out. Check that the backend is running." : undefined) ||
      (error.message === "Network Error"
        ? `Network Error. Confirm your phone can open ${env.apiBaseUrl}, Spring Boot is running on 0.0.0.0:8080, and your Mac firewall is not blocking port 8080.`
        : undefined) ||
      error.message ||
      "Something went wrong.";

    return Promise.reject(new ApiError(message, status, error.code));
  }
);

export const apiConfig = new Configuration({
  basePath: env.apiBaseUrl,
  accessToken: () => useAuthStore.getState().token ?? ""
});

export function unwrap<T>(promise: Promise<{ data: T }>): Promise<T> {
  return promise.then((r) => r.data);
}

export type PageMeta = Required<Pick<PageMetaResponse, "page" | "size" | "totalElements" | "totalPages" | "hasNext">>;

export type PagedResult<T> = {
  items: T[];
  page: PageMeta;
};

export function toPageMeta(page?: PageMetaResponse): PageMeta {
  return {
    page: page?.page ?? 0,
    size: page?.size ?? 0,
    totalElements: page?.totalElements ?? 0,
    totalPages: page?.totalPages ?? 0,
    hasNext: page?.hasNext ?? false
  };
}

export function toApiNumberId(value: string | number, label = "id"): number {
  const id = typeof value === "number" ? value : Number(value);
  if (!Number.isSafeInteger(id) || id <= 0) {
    throw new ApiError(`Invalid ${label}.`, undefined, "INVALID_ID");
  }
  return id;
}

export function pageParams(page = 0, size = 20): { page: number; size: number } {
  return {
    page: Math.max(0, Math.trunc(page)),
    size: Math.min(Math.max(1, Math.trunc(size)), 100)
  };
}
