import React, { useCallback, useState } from "react";
import { ActivityIndicator, FlatList, Image, Pressable, RefreshControl, Text, View } from "react-native";
import { useFocusEffect } from "@react-navigation/native";
import { Ionicons } from "@expo/vector-icons";
import { useQuery, useQueryClient } from "@tanstack/react-query";
import { Screen } from "@/components/Screen";
import { EmptyState } from "@/components/EmptyState";
import { messagesApi } from "./messagesApi";
import { colors } from "@/theme/colors";
import { Conversation, User } from "@/types/models";
import { formatConversationTime } from "@/utils/date";

function MiniAvatar({ user }: { user: User }) {
  const letter = user.username?.[0]?.toUpperCase() ?? "D";
  return (
    <View style={{ width: 54, height: 54, borderRadius: 27, padding: 2, backgroundColor: colors.primary }}>
      {user.profileImageUrl ? (
        <Image source={{ uri: user.profileImageUrl }} style={{ flex: 1, borderRadius: 27 }} />
      ) : (
        <View style={{ flex: 1, borderRadius: 27, backgroundColor: colors.surface2, alignItems: "center", justifyContent: "center" }}>
          <Text style={{ color: colors.text, fontWeight: "900", fontSize: 19 }}>{letter}</Text>
        </View>
      )}
    </View>
  );
}

export function ConversationsScreen({ navigation }: any) {
  const qc = useQueryClient();
  const [refreshing, setRefreshing] = useState(false);
  const query = useQuery<Conversation[]>({
    queryKey: ["conversations"],
    queryFn: () => messagesApi.conversations(),
    refetchInterval: 5000,
    refetchOnMount: "always",
    retry: 1
  });
  const conversations = query.data ?? [];

  useFocusEffect(
    React.useCallback(() => {
      qc.invalidateQueries({ queryKey: ["conversations"] });
    }, [qc])
  );

  const refreshConversations = useCallback(async () => {
    setRefreshing(true);
    try {
      await query.refetch();
    } finally {
      setRefreshing(false);
    }
  }, [query]);

  return (
    <Screen scroll={false}>
      <View style={{ marginBottom: 16 }}>
        <Text style={{ color: colors.text, fontSize: 31, fontWeight: "900" }}>Messages</Text>
        <Text style={{ color: colors.muted, marginTop: 4 }}>Private dive buddy chats</Text>
      </View>

      {query.isLoading ? <ActivityIndicator color={colors.primary} style={{ marginTop: 20 }} /> : null}
      {query.isError ? <Text style={{ color: colors.danger, marginBottom: 12 }}>{query.error instanceof Error ? query.error.message : "Unable to load conversations."}</Text> : null}

      <FlatList
        data={conversations}
        keyExtractor={(item) => String(item.id)}
        contentContainerStyle={{ paddingBottom: 120, flexGrow: 1 }}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            tintColor={colors.primary}
            refreshing={refreshing}
            onRefresh={refreshConversations}
          />
        }
        ListEmptyComponent={!query.isLoading ? <EmptyState title="No conversations" body="Start by opening a diver profile and messaging them." /> : null}
        renderItem={({ item }) => (
          <Pressable
            onPress={() => navigation.navigate("Thread", { conversationId: item.id, participant: item.participant })}
            style={({ pressed }) => ({
              padding: 14,
              backgroundColor: colors.surface,
              borderRadius: 28,
              marginBottom: 12,
              borderColor: item.unreadCount > 0 ? colors.primary : colors.border,
              borderWidth: item.unreadCount > 0 ? 1.5 : 1,
              opacity: pressed ? 0.86 : 1,
              transform: [{ scale: pressed ? 0.99 : 1 }]
            })}
          >
            <View style={{ flexDirection: "row", alignItems: "center", gap: 13 }}>
              <MiniAvatar user={item.participant} />

              <View style={{ flex: 1 }}>
                <View style={{ flexDirection: "row", alignItems: "center", justifyContent: "space-between", gap: 10 }}>
                  <Text style={{ color: colors.text, fontWeight: "900", fontSize: 16 }} numberOfLines={1}>@{item.participant.username}</Text>
                  <Text style={{ color: colors.muted, fontSize: 12, fontWeight: "800" }}>{formatConversationTime(item.updatedAt)}</Text>
                </View>
                <View style={{ flexDirection: "row", alignItems: "center", gap: 10, marginTop: 7 }}>
                  <Text style={{ color: item.unreadCount > 0 ? colors.text : colors.muted, lineHeight: 20, fontWeight: item.unreadCount > 0 ? "800" : "500", flex: 1 }} numberOfLines={1}>
                    {item.lastMessage ?? "No messages yet"}
                  </Text>
                  {item.unreadCount > 0 ? (
                    <View style={{ minWidth: 26, height: 26, borderRadius: 13, backgroundColor: colors.primary, alignItems: "center", justifyContent: "center", paddingHorizontal: 8 }}>
                      <Text style={{ color: colors.textDark, fontWeight: "900", fontSize: 12 }}>{item.unreadCount}</Text>
                    </View>
                  ) : (
                    <Ionicons name="chevron-forward" size={18} color={colors.muted} />
                  )}
                </View>
              </View>
            </View>
          </Pressable>
        )}
      />
    </Screen>
  );
}
