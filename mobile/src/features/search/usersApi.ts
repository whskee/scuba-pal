import { AdminUserManagementApi } from "@/api/generated";
import { ApiError, api, apiConfig, pageParams, unwrap } from "@/services/api";
import { User, toUser } from "@/types/models";

const generatedUsersApi = new AdminUserManagementApi(apiConfig, undefined, api);

export const usersApi = {
  async search(username: string): Promise<User[]> {
    const params = pageParams(0, 100);
    let allUsers;
    try {
      const response = await unwrap(generatedUsersApi.getAll1(params.page, params.size));
      allUsers = response.content ?? [];
    } catch (error) {
      if (error instanceof ApiError && (error.status === 401 || error.status === 403)) return [];
      throw error;
    }
    const term = username.trim().toLowerCase();
    return allUsers
      .map((user) => toUser(user))
      .filter((user) => {
        if (!term) return true;
        const name = `${user.firstName ?? ""} ${user.lastName ?? ""}`.trim().toLowerCase();
        return user.username.toLowerCase().includes(term) || name.includes(term) || user.city?.toLowerCase().includes(term);
      })
      .slice(0, 50);
  }
};
