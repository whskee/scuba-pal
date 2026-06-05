import { ProfilesApi } from "@/api/generated";
import { api, apiConfig, pageParams, unwrap } from "@/services/api";
import { User, toUser } from "@/types/models";

const generatedProfilesApi = new ProfilesApi(apiConfig, undefined, api);

export const usersApi = {
  async search(username: string): Promise<User[]> {
    const params = pageParams(0, 100);
    const response = await unwrap(generatedProfilesApi.searchPublicProfiles(username.trim() || undefined, params.page, params.size));
    const term = username.trim().toLowerCase();
    return (response.content ?? [])
      .map((user) => toUser(user))
      .filter((user) => {
        if (!term) return true;
        const name = `${user.firstName ?? ""} ${user.lastName ?? ""}`.trim().toLowerCase();
        return user.username.toLowerCase().includes(term) || name.includes(term) || user.city?.toLowerCase().includes(term);
      })
      .slice(0, 50);
  }
};
