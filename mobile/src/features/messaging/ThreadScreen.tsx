import React, { useCallback, useEffect, useMemo, useState } from "react";
import { ActivityIndicator, Image, KeyboardAvoidingView, Platform, Pressable, RefreshControl, SectionList, Text, View } from "react-native";
import { useFocusEffect } from "@react-navigation/native";
import { Ionicons } from "@expo/vector-icons";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Screen } from "@/components/Screen";
import { Input } from "@/components/Input";
import { messagesApi } from "./messagesApi";
import { colors } from "@/theme/colors";
import { useAuthStore } from "@/store/authStore";
import { Message } from "@/types/models";
import { formatDateHeader, formatMessageTime, localDateKey } from "@/utils/date";

type MessageSection = {
  title: string;
  data: Message[];
};

function groupMessagesByLocalDate(messages: Message[]): MessageSection[] {
  const sections = new Map<string, MessageSection>();
  messages.forEach((message) => {
    const key = localDateKey(message.createdAt);
    const existing = sections.get(key);
    if (existing) {
      existing.data.push(message);
      return;
    }
    sections.set(key, { title: formatDateHeader(message.createdAt), data: [message] });
  });
  return Array.from(sections.values());
}

export function ThreadScreen({ route, navigation }: any) {
  const { conversationId, participant } = route.params;
  const [body, setBody] = useState("");
  const [refreshing, setRefreshing] = useState(false);
  const user = useAuthStore((s) => s.user);
  const qc = useQueryClient();
  const query = useQuery({
    queryKey: ["thread", conversationId],
    queryFn: () => messagesApi.thread(conversationId),
    refetchInterval: 5000,
    refetchOnMount: "always",
    retry: 1
  });
  const sections = useMemo(() => groupMessagesByLocalDate(query.data ?? []), [query.data]);
  const participantInitial = participant.username?.[0]?.toUpperCase() ?? "D";
  const readMutation = useMutation({
    mutationFn: () => messagesApi.markRead(conversationId),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["conversations"] });
      qc.invalidateQueries({ queryKey: ["unreadMessages"] });
    }
  });
  const sendMutation = useMutation({
    mutationFn: () => messagesApi.send(conversationId, body.trim()),
    onMutate: async () => {
      const text = body.trim();
      await qc.cancelQueries({ queryKey: ["thread", conversationId] });
      const previous = qc.getQueryData<Message[]>(["thread", conversationId]);
      setBody("");
      qc.setQueryData<Message[]>(["thread", conversationId], (old = []) => [
        ...old,
        {
          id: `pending-${Date.now()}`,
          senderId: user?.id ?? "me",
          body: text,
          createdAt: new Date().toISOString(),
          sentByCurrentUser: true
        }
      ]);
      return { previous, text };
    },
    onError: (_error, _variables, context) => {
      if (context?.previous) qc.setQueryData(["thread", conversationId], context.previous);
      if (context?.text) setBody(context.text);
    },
    onSettled: () => {
      qc.invalidateQueries({ queryKey: ["thread", conversationId] });
      qc.invalidateQueries({ queryKey: ["conversations"] });
      qc.invalidateQueries({ queryKey: ["unreadMessages"] });
    }
  });

  useEffect(() => {
    readMutation.mutate();
  }, [conversationId]);

  useFocusEffect(
    useCallback(() => {
      qc.invalidateQueries({ queryKey: ["thread", conversationId] });
      qc.invalidateQueries({ queryKey: ["conversations"] });
      qc.invalidateQueries({ queryKey: ["unreadMessages"] });
    }, [conversationId, qc])
  );

  const refreshThread = useCallback(async () => {
    setRefreshing(true);
    try {
      await query.refetch();
      await qc.invalidateQueries({ queryKey: ["conversations"] });
      await qc.invalidateQueries({ queryKey: ["unreadMessages"] });
    } finally {
      setRefreshing(false);
    }
  }, [qc, query]);

  return (
    <Screen scroll={false}>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === "ios" ? "padding" : undefined} keyboardVerticalOffset={0}>
        <View style={{ flexDirection: "row", alignItems: "center", gap: 12, paddingBottom: 14, borderBottomWidth: 1, borderBottomColor: colors.border }}>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel="Back to conversations"
            onPress={() => navigation.goBack()}
            style={({ pressed }) => ({
              width: 42,
              height: 42,
              borderRadius: 21,
              backgroundColor: colors.surface,
              borderWidth: 1,
              borderColor: colors.border,
              alignItems: "center",
              justifyContent: "center",
              opacity: pressed ? 0.75 : 1
            })}
          >
            <Ionicons name="chevron-back" size={24} color={colors.text} />
          </Pressable>
          {participant.profileImageUrl ? (
            <Image source={{ uri: participant.profileImageUrl }} style={{ width: 44, height: 44, borderRadius: 22, backgroundColor: colors.surface2 }} />
          ) : (
            <View style={{ width: 44, height: 44, borderRadius: 22, backgroundColor: colors.primary, alignItems: "center", justifyContent: "center" }}>
              <Text style={{ color: colors.textDark, fontWeight: "900", fontSize: 16 }}>{participantInitial}</Text>
            </View>
          )}
          <View style={{ flex: 1 }}>
            <Text style={{ color: colors.text, fontSize: 22, fontWeight: "900" }} numberOfLines={1}>@{participant.username}</Text>
            <Text style={{ color: colors.muted, marginTop: 2 }}>Private conversation</Text>
          </View>
        </View>

        <SectionList
          style={{ flex: 1 }}
          sections={sections}
          keyExtractor={(item) => String(item.id)}
          contentContainerStyle={{ paddingVertical: 12, flexGrow: 1 }}
          showsVerticalScrollIndicator={false}
          refreshControl={
            <RefreshControl
              tintColor={colors.primary}
              refreshing={refreshing}
              onRefresh={refreshThread}
            />
          }
          stickySectionHeadersEnabled={false}
          renderSectionHeader={({ section }) => (
            <View style={{ alignItems: "center", marginVertical: 10 }}>
              <Text style={{ color: colors.muted, fontSize: 12, fontWeight: "900", backgroundColor: colors.surface, borderRadius: 14, overflow: "hidden", paddingHorizontal: 12, paddingVertical: 6 }}>{section.title}</Text>
            </View>
          )}
          renderItem={({ item }) => {
            const mine = item.sentByCurrentUser ?? String(item.senderId) === String(user?.id);
            const senderImage = item.senderProfileImageUrl || (!mine ? participant.profileImageUrl : undefined);
            return (
              <View
                style={{
                  alignSelf: mine ? "flex-end" : "flex-start",
                  flexDirection: "row",
                  alignItems: "flex-end",
                  gap: 8,
                  marginBottom: 10,
                  maxWidth: "82%",
                }}
              >
                {!mine ? (
                  senderImage ? (
                    <Image source={{ uri: senderImage }} style={{ width: 30, height: 30, borderRadius: 15, backgroundColor: colors.surface2 }} />
                  ) : (
                    <View style={{ width: 30, height: 30, borderRadius: 15, backgroundColor: colors.primary, alignItems: "center", justifyContent: "center" }}>
                      <Text style={{ color: colors.textDark, fontWeight: "900", fontSize: 12 }}>{participantInitial}</Text>
                    </View>
                  )
                ) : null}
                <View
                  style={{
                    backgroundColor: mine ? colors.primary : colors.surface,
                    paddingHorizontal: 14,
                    paddingVertical: 11,
                    borderRadius: 22,
                    borderBottomRightRadius: mine ? 7 : 22,
                    borderBottomLeftRadius: mine ? 22 : 7,
                    borderColor: mine ? "transparent" : colors.border,
                    borderWidth: mine ? 0 : 1,
                    flexShrink: 1
                  }}
                >
                  <Text style={{ color: mine ? colors.textDark : colors.text, fontSize: 15, lineHeight: 21 }}>{item.body}</Text>
                  <Text style={{ color: mine ? "rgba(16,32,51,0.68)" : colors.muted, fontSize: 11, marginTop: 6, fontWeight: "800", alignSelf: "flex-end" }}>{formatMessageTime(item.createdAt)}</Text>
                  {mine && item.readAt ? (
                    <Text style={{ color: "rgba(16,32,51,0.68)", fontSize: 11, marginTop: 4, fontWeight: "800" }}>Read {formatMessageTime(item.readAt)}</Text>
                  ) : null}
                </View>
              </View>
            );
          }}
        />

        <View style={{ backgroundColor: colors.surface, borderRadius: 28, padding: 8, borderColor: colors.border, borderWidth: 1, flexDirection: "row", alignItems: "center", gap: 8 }}>
          <Input
            placeholder="Message..."
            value={body}
            onChangeText={setBody}
            style={{ flex: 1, minHeight: 46, borderRadius: 23, paddingVertical: 12 }}
          />
          <Pressable
            accessibilityRole="button"
            accessibilityLabel="Send message"
            disabled={!body.trim() || sendMutation.isPending}
            onPress={() => body.trim() && sendMutation.mutate()}
            style={({ pressed }) => ({
              width: 46,
              height: 46,
              borderRadius: 23,
              backgroundColor: body.trim() ? colors.primary : colors.surface3,
              alignItems: "center",
              justifyContent: "center",
              opacity: !body.trim() || sendMutation.isPending ? 0.55 : pressed ? 0.78 : 1,
              transform: [{ scale: pressed ? 0.96 : 1 }]
            })}
          >
            {sendMutation.isPending ? <ActivityIndicator color={colors.textDark} /> : <Ionicons name="send" size={19} color={colors.textDark} />}
          </Pressable>
        </View>
      </KeyboardAvoidingView>
    </Screen>
  );
}
