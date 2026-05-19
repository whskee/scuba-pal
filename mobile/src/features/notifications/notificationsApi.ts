import { NotificationsApi } from "@/api/generated";
import { api, apiConfig, unwrap } from "@/services/api";
import { ID, Notification, toNotification } from "@/types/models";

const generatedNotificationsApi = new NotificationsApi(apiConfig, undefined, api);

export const notificationsApi = {
  async list(page = 0, size = 20): Promise<Notification[]> {
    const response = await unwrap(generatedNotificationsApi.notifications(page, size));
    return (response.notifications ?? []).map(toNotification);
  },

  async unreadCount(): Promise<{ count: number }> {
    const response = await unwrap(generatedNotificationsApi.unreadCount());
    return { count: response.unreadNotificationCount ?? 0 };
  },

  async markRead(id: ID): Promise<void> {
    await unwrap(generatedNotificationsApi.markRead1(Number(id)));
  }
};
