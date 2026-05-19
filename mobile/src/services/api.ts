import axios, { AxiosError, InternalAxiosRequestConfig } from "axios";
import { env } from "@/config/env";
import { useAuthStore } from "@/store/authStore";
import { ApiErrorBody } from "@/types/models";
import { Configuration } from "@/api/generated";

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
  "/api/auth/reset-password"
];

api.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const requestPath = config.url ?? "";
  const isPublicAuthRequest = PUBLIC_AUTH_PATHS.some((path) => requestPath.endsWith(path) || requestPath.includes(path));
  if (isPublicAuthRequest) {
    delete config.headers.Authorization;
    return config;
  }

  const token = useAuthStore.getState().token;
  if (token) {
    config.headers.Authorization = token.startsWith("Basic ") || token.startsWith("Bearer ") ? token : `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error: AxiosError<ApiErrorBody>) => {
    const status = error.response?.status;
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
  basePath: env.apiBaseUrl
});

export function unwrap<T>(promise: Promise<{ data: T }>): Promise<T> {
  return promise.then((r) => r.data);
}
