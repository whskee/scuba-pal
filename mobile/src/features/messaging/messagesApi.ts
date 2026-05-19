import { MessagingApi } from "@/api/generated";
import { api, apiConfig, unwrap } from "@/services/api";
import { Conversation, ID, Message, toConversation, toMessage } from "@/types/models";

const generatedMessagingApi = new MessagingApi(apiConfig, undefined, api);

export const messagesApi = {
  async conversations(page = 0, size = 20): Promise<Conversation[]> {
    const response = await unwrap(generatedMessagingApi.conversations(page, size));
    return (response.conversations ?? []).map(toConversation);
  },

  async start(otherUserId: ID): Promise<Conversation> {
    const response = await unwrap(generatedMessagingApi.startConversation(Number(otherUserId)));
    return toConversation(response);
  },

  async thread(conversationId: ID, page = 0, size = 50): Promise<Message[]> {
    const response = await unwrap(generatedMessagingApi.messages(Number(conversationId), page, size));
    return (response.messages ?? []).map(toMessage);
  },

  async send(conversationId: ID, body: string): Promise<void> {
    await unwrap(generatedMessagingApi.sendMessage(Number(conversationId), { messageText: body }));
  },

  async markRead(conversationId: ID) {
    return unwrap(generatedMessagingApi.markRead2(Number(conversationId)));
  }
};
