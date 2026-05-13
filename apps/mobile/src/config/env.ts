import Constants from "expo-constants";

const LOOPBACK_HOSTS = new Set(["localhost", "127.0.0.1", "0.0.0.0"]);

type ExtraConfig = {
  apiBaseUrl?: string;
  apiUrl?: string;
  requestTimeoutMs?: number;
};

const extra = Constants.expoConfig?.extra as ExtraConfig | undefined;

function stripTrailingSlash(value: string) {
  return value.replace(/\/+$/, "");
}

function stripApiSuffix(value: string) {
  return stripTrailingSlash(value).replace(/\/api$/, "");
}

function assertUsableApiBaseUrl(value: string) {
  let parsed: URL;
  try {
    parsed = new URL(value);
  } catch {
    throw new Error(`Invalid EXPO_PUBLIC_API_BASE_URL: ${value}`);
  }

  if (!/^https?:$/.test(parsed.protocol)) {
    throw new Error("EXPO_PUBLIC_API_BASE_URL must start with http:// or https://.");
  }

  if (LOOPBACK_HOSTS.has(parsed.hostname)) {
    throw new Error(
      "EXPO_PUBLIC_API_BASE_URL points to localhost. For Expo Go on a physical phone, use your Mac LAN IP, for example http://192.168.1.25:8080."
    );
  }
}

const configuredBaseUrl =
  process.env.EXPO_PUBLIC_API_BASE_URL ??
  process.env.EXPO_PUBLIC_API_URL ??
  extra?.apiBaseUrl ??
  extra?.apiUrl;

if (!configuredBaseUrl) {
  throw new Error("Missing EXPO_PUBLIC_API_BASE_URL. Copy .env.example to .env.local and set your backend URL.");
}

const apiBaseUrl = stripApiSuffix(configuredBaseUrl);
assertUsableApiBaseUrl(apiBaseUrl);

export const env = {
  // Backend root URL, not /api.
  // Physical Expo Go example: http://192.168.1.25:8080
  apiBaseUrl,
  requestTimeoutMs: extra?.requestTimeoutMs ?? Number(process.env.EXPO_PUBLIC_REQUEST_TIMEOUT_MS ?? 15000),
};
