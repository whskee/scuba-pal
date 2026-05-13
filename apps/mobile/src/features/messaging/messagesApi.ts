import { api, unwrap } from "@/services/api";
import { Conversation, ID, Message, toConversation, toMessage } from "@/types/models";

type ConversationListResponse = {
  conversations?: unknown[];
  content?: unknown[];
};

type ConversationResponse = {
  conversationId?: number;
  id?: number;
};

type DirectMessageListResponse = {
  messages?: unknown[];
  content?: unknown[];
};

export const messagesApi = {
  async conversations(page = 0, size = 20): Promise<Conversation[]> {
    const response = await unwrap<ConversationListResponse>(api.get("/api/messages/conversations", { params: { page, size } }));
    return (response.conversations ?? response.content ?? []).map(toConversation);
  },

  async start(otherUserId: ID): Promise<Conversation> {
    const response = await unwrap<ConversationResponse>(api.post(`/api/messages/conversations/${otherUserId}`));
    const conversationId = response.conversationId ?? response.id ?? 0;
    return toConversation({ ...response, conversationId, otherUserId });
  },

  async thread(conversationId: ID, page = 0, size = 50): Promise<Message[]> {
    const response = await unwrap<DirectMessageListResponse>(api.get(`/api/messages/${conversationId}`, { params: { page, size } }));
    return (response.messages ?? response.content ?? []).map((item) => toMessage(item as any));
  },

  async send(conversationId: ID, body: string): Promise<void> {
    await unwrap(api.post(`/api/messages/${conversationId}`, { messageText: body }));
  },

  async markRead(conversationId: ID) {
    return unwrap(api.post(`/api/messages/${conversationId}/read`));
  }
};
