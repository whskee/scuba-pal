import * as SecureStore from "expo-secure-store";
import { User } from "@/types/models";

const TOKEN_KEY = "scuba_pal_access_token";
const USER_KEY = "scuba_pal_user";

export const tokenStorage = {
  get: () => SecureStore.getItemAsync(TOKEN_KEY),
  set: (token: string) => SecureStore.setItemAsync(TOKEN_KEY, token),
  clear: () => SecureStore.deleteItemAsync(TOKEN_KEY)
};

export const userStorage = {
  async get(): Promise<User | undefined> {
    const raw = await SecureStore.getItemAsync(USER_KEY);
    if (!raw) return undefined;
    try {
      return JSON.parse(raw) as User;
    } catch {
      await SecureStore.deleteItemAsync(USER_KEY);
      return undefined;
    }
  },
  set: (user: User) => SecureStore.setItemAsync(USER_KEY, JSON.stringify(user)),
  clear: () => SecureStore.deleteItemAsync(USER_KEY)
};
