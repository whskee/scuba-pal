import React from "react";
import { FlatList, Pressable, Text, View } from "react-native";
import { useFocusEffect } from "@react-navigation/native";
import { Ionicons } from "@expo/vector-icons";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Screen } from "@/components/Screen";
import { EmptyState } from "@/components/EmptyState";
import { colors } from "@/theme/colors";
import { notificationsApi } from "./notificationsApi";
import { formatRelativeTime } from "@/utils/date";

function iconFor(type?: string): keyof typeof Ionicons.glyphMap {
  if (type?.toLowerCase().includes("message")) return "chatbubble-ellipses";
  if (type?.toLowerCase().includes("follow")) return "person-add";
  if (type?.toLowerCase().includes("like")) return "heart";
  if (type?.toLowerCase().includes("comment")) return "chatbox";
  return "notifications";
}

export function NotificationsScreen() {
  const qc = useQueryClient();
  const query = useQuery({ queryKey: ["notifications"], queryFn: () => notificationsApi.list(), refetchOnMount: "always", retry: 1 });
  const mutation = useMutation({
    mutationFn: notificationsApi.markRead,
    onMutate: async (id) => {
      await qc.cancelQueries({ queryKey: ["notifications"] });
      const previous = qc.getQueryData(["notifications"]);
      qc.setQueryData<any[]>(["notifications"], (old = []) => old.map((item) => String(item.id) === String(id) ? { ...item, read: true } : item));
      return { previous };
    },
    onError: (_error, _variables, context) => {
      if (context?.previous) qc.setQueryData(["notifications"], context.previous);
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["notifications"] });
      qc.invalidateQueries({ queryKey: ["unreadNotifications"] });
    }
  });

  useFocusEffect(
    React.useCallback(() => {
      qc.invalidateQueries({ queryKey: ["notifications"] });
      qc.invalidateQueries({ queryKey: ["unreadNotifications"] });
    }, [qc])
  );

  return (
    <Screen scroll={false}>
      <View style={{ marginBottom: 16 }}>
        <Text style={{ color: colors.text, fontSize: 31, fontWeight: "900" }}>Notifications</Text>
        <Text style={{ color: colors.muted, marginTop: 4 }}>Activity from your dive circle</Text>
      </View>

      <FlatList
        data={query.data ?? []}
        keyExtractor={(item) => String(item.id)}
        contentContainerStyle={{ paddingBottom: 120 }}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={<EmptyState title="No notifications" body="Follows, messages, likes, and comments will appear here." />}
        renderItem={({ item }) => (
          <Pressable
            onPress={() => !item.read && mutation.mutate(item.id)}
            style={({ pressed }) => ({
              padding: 15,
              backgroundColor: item.read ? colors.surface : colors.surface2,
              borderRadius: 28,
              marginBottom: 12,
              borderColor: item.read ? colors.border : colors.primary,
              borderWidth: item.read ? 1 : 1.5,
              opacity: pressed ? 0.86 : 1,
              transform: [{ scale: pressed ? 0.99 : 1 }]
            })}
          >
            <View style={{ flexDirection: "row", gap: 13, alignItems: "flex-start" }}>
              <View style={{ width: 48, height: 48, borderRadius: 24, backgroundColor: item.read ? colors.surface3 : colors.primary, alignItems: "center", justifyContent: "center" }}>
                <Ionicons name={iconFor(item.type)} size={21} color={item.read ? colors.text : colors.textDark} />
              </View>

              <View style={{ flex: 1 }}>
                <View style={{ flexDirection: "row", justifyContent: "space-between", gap: 10 }}>
                  <Text style={{ color: colors.text, fontWeight: "900", fontSize: 16, flex: 1 }}>{item.title}</Text>
                  {!item.read ? <View style={{ width: 10, height: 10, borderRadius: 5, backgroundColor: colors.primary, marginTop: 5 }} /> : null}
                </View>
                <Text style={{ color: item.read ? colors.muted : colors.text, marginTop: 6, lineHeight: 20 }}>{item.body}</Text>
                <Text style={{ color: colors.muted, fontSize: 12, marginTop: 10 }}>{formatRelativeTime(item.createdAt)}</Text>
              </View>
            </View>
          </Pressable>
        )}
      />
    </Screen>
  );
}
