import Constants from "expo-constants";

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

function assertValidApiBaseUrl(value: string) {
  let parsed: URL;
  try {
    parsed = new URL(value);
  } catch {
    throw new Error(`Invalid EXPO_PUBLIC_API_BASE_URL: ${value}`);
  }

  if (!/^https?:$/.test(parsed.protocol)) {
    throw new Error("EXPO_PUBLIC_API_BASE_URL must start with http:// or https://.");
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
assertValidApiBaseUrl(apiBaseUrl);

export const env = {
  // Backend root URL, not /api.
  // iOS simulator: http://localhost:8080
  // Android emulator: http://10.0.2.2:8080
  // Physical Expo Go device: http://YOUR_MAC_LAN_IP:8080
  apiBaseUrl,
  requestTimeoutMs: extra?.requestTimeoutMs ?? Number(process.env.EXPO_PUBLIC_REQUEST_TIMEOUT_MS ?? 15000)
};
