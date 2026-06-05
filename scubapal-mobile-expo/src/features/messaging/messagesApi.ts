import { ConversationListResponse, MessageListResponse, MessagingApi, SendMessageRequest, UnreadCountView } from "@/api/generated";
import { api, apiConfig, pageParams, PagedResult, toApiNumberId, toPageMeta, unwrap } from "@/services/api";
import { Conversation, ID, Message, toConversation, toMessage } from "@/types/models";

const generatedMessagingApi = new MessagingApi(apiConfig, undefined, api);

export const messagesApi = {
  async conversationsPage(page = 0, size = 20): Promise<PagedResult<Conversation>> {
    const params = pageParams(page, size);
    const response = await unwrap<ConversationListResponse>(generatedMessagingApi.conversations(params.page, params.size));
    return {
      items: (response.conversations ?? []).map(toConversation),
      page: toPageMeta(response.page)
    };
  },

  async conversations(page = 0, size = 20): Promise<Conversation[]> {
    const response = await messagesApi.conversationsPage(page, size);
    return response.items;
  },

  async unreadCount(): Promise<{ count: number }> {
    const response = await unwrap<UnreadCountView>(generatedMessagingApi.unreadCount1());
    return { count: response.unreadMessageCount ?? 0 };
  },

  async start(otherUserId: ID): Promise<Conversation> {
    const response = await unwrap(generatedMessagingApi.startConversation(toApiNumberId(otherUserId, "user id")));
    return toConversation(response);
  },

  async threadPage(conversationId: ID, page = 0, size = 50): Promise<PagedResult<Message>> {
    const params = pageParams(page, size);
    const response = await unwrap<MessageListResponse>(generatedMessagingApi.messages(toApiNumberId(conversationId, "conversation id"), params.page, params.size));
    return {
      items: (response.messages ?? []).map(toMessage),
      page: toPageMeta(response.page)
    };
  },

  async thread(conversationId: ID, page = 0, size = 50): Promise<Message[]> {
    const response = await messagesApi.threadPage(conversationId, page, size);
    return response.items;
  },

  async send(conversationId: ID, body: string): Promise<void> {
    const messageText = body.trim();
    if (!messageText) return;
    const payload: SendMessageRequest = { messageText };
    await unwrap(generatedMessagingApi.sendMessage(toApiNumberId(conversationId, "conversation id"), payload));
  },

  async markRead(conversationId: ID): Promise<UnreadCountView> {
    return unwrap<UnreadCountView>(generatedMessagingApi.markRead2(toApiNumberId(conversationId, "conversation id")));
  }
};
