import { UserManagementApi } from "@/api/generated";
import { api, apiConfig, unwrap } from "@/services/api";
import { User, toUser } from "@/types/models";

const generatedUsersApi = new UserManagementApi(apiConfig, undefined, api);

export const usersApi = {
  async search(username: string): Promise<User[]> {
    const allUsers = await unwrap(generatedUsersApi.getAll());
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
