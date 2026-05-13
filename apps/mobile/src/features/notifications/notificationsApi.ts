import { api, unwrap } from "@/services/api";
import { ID, Notification, toNotification } from "@/types/models";

type NotificationListResponse = {
  notifications?: unknown[];
  content?: unknown[];
};

type UnreadNotificationCountResponse = {
  unreadNotificationCount?: number;
  count?: number;
};

export const notificationsApi = {
  async list(page = 0, size = 20): Promise<Notification[]> {
    const response = await unwrap<NotificationListResponse>(api.get("/api/notifications", { params: { page, size } }));
    return (response.notifications ?? response.content ?? []).map(toNotification);
  },

  async unreadCount(): Promise<{ count: number }> {
    const response = await unwrap<UnreadNotificationCountResponse>(api.get("/api/notifications/unread-count"));
    return { count: response.unreadNotificationCount ?? response.count ?? 0 };
  },

  async markRead(id: ID): Promise<void> {
    await unwrap(api.patch(`/api/notifications/${id}/read`));
  }
};
