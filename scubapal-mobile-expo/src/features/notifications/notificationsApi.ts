import { NotificationsApi } from "@/api/generated";
import { api, apiConfig, pageParams, PagedResult, toApiNumberId, toPageMeta, unwrap } from "@/services/api";
import { ID, Notification, toNotification } from "@/types/models";

const generatedNotificationsApi = new NotificationsApi(apiConfig, undefined, api);

export const notificationsApi = {
  async listPage(page = 0, size = 20): Promise<PagedResult<Notification>> {
    const params = pageParams(page, size);
    const response = await unwrap(generatedNotificationsApi.notifications(params.page, params.size));
    return {
      items: (response.notifications ?? []).map(toNotification),
      page: toPageMeta(response.page)
    };
  },

  async list(page = 0, size = 20): Promise<Notification[]> {
    const response = await notificationsApi.listPage(page, size);
    return response.items;
  },

  async unreadCount(): Promise<{ count: number }> {
    const response = await unwrap(generatedNotificationsApi.unreadCount());
    return { count: response.unreadNotificationCount ?? 0 };
  },

  async markRead(id: ID): Promise<void> {
    await unwrap(generatedNotificationsApi.markRead1(toApiNumberId(id, "notification id")));
  }
};
