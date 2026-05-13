import { create } from "zustand";
import { User } from "@/types/models";
import { tokenStorage, userStorage } from "@/services/storage";

type AuthState = {
  token?: string;
  user?: User;
  hydrated: boolean;
  isAuthenticated: boolean;
  setSession: (user: User, token?: string) => Promise<void>;
  updateUser: (user: User) => Promise<void>;
  restore: () => Promise<void>;
  logout: () => Promise<void>;
};

export const useAuthStore = create<AuthState>((set) => ({
  hydrated: false,
  isAuthenticated: false,

  async setSession(user, token) {
    if (token) await tokenStorage.set(token);
    else await tokenStorage.clear();
    await userStorage.set(user);
    set({ token, user, isAuthenticated: true });
  },

  async updateUser(user) {
    await userStorage.set(user);
    set({ user, isAuthenticated: true });
  },

  async restore() {
    const [token, user] = await Promise.all([tokenStorage.get(), userStorage.get()]);
    set({ token: token ?? undefined, user, hydrated: true, isAuthenticated: !!user });
  },

  async logout() {
    await Promise.all([tokenStorage.clear(), userStorage.clear()]);
    set({ token: undefined, user: undefined, isAuthenticated: false });
  }
}));
