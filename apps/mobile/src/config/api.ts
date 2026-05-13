// // src/config/api.ts

// const API_BASE_URL = process.env.EXPO_PUBLIC_API_BASE_URL;

// if (!API_BASE_URL) {
//   throw new Error("Missing EXPO_PUBLIC_API_BASE_URL");
// }

// export const API_CONFIG = {
//   baseUrl: API_BASE_URL,
//   timeoutMs: 15000,
// };

// export function apiUrl(path: string) {
//   const cleanPath = path.startsWith("/") ? path : `/${path}`;
//   return `${API_CONFIG.baseUrl}${cleanPath}`;
// }

import { env } from "./env";

export const API_CONFIG = {
  baseUrl: env.apiBaseUrl,
  timeoutMs: env.requestTimeoutMs,
};

export function apiUrl(path: string) {
  const cleanPath = path.startsWith("/") ? path : `/${path}`;
  return `${API_CONFIG.baseUrl}${cleanPath}`;
}

export function apiPath(path: string) {
  const cleanPath = path.startsWith("/") ? path : `/${path}`;
  return cleanPath;
}