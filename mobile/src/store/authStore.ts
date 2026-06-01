import { create } from "zustand";
import { User } from "@/types/models";
import { refreshTokenStorage, tokenStorage, userStorage } from "@/services/storage";

type AuthState = {
  token?: string;
  refreshToken?: string;
  user?: User;
  hydrated: boolean;
  isAuthenticated: boolean;
  setSession: (user: User, token?: string, refreshToken?: string) => Promise<void>;
  updateUser: (user: User) => Promise<void>;
  restore: () => Promise<void>;
  logout: () => Promise<void>;
};

export const useAuthStore = create<AuthState>((set) => ({
  hydrated: false,
  isAuthenticated: false,

  async setSession(user, token, refreshToken) {
    if (token) await tokenStorage.set(token);
    else await tokenStorage.clear();
    if (refreshToken) await refreshTokenStorage.set(refreshToken);
    else await refreshTokenStorage.clear();
    await userStorage.set(user);
    set({ token, refreshToken, user, isAuthenticated: true });
  },

  async updateUser(user) {
    await userStorage.set(user);
    set({ user, isAuthenticated: true });
  },

  async restore() {
    const [token, refreshToken, user] = await Promise.all([tokenStorage.get(), refreshTokenStorage.get(), userStorage.get()]);
    set({
      token: token ?? undefined,
      refreshToken: refreshToken ?? undefined,
      user,
      hydrated: true,
      isAuthenticated: !!user && (!!token || !!refreshToken)
    });
  },

  async logout() {
    await Promise.all([tokenStorage.clear(), refreshTokenStorage.clear(), userStorage.clear()]);
    set({ token: undefined, refreshToken: undefined, user: undefined, isAuthenticated: false });
  }
}));
