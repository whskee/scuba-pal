import React from "react";
import { ActivityIndicator, FlatList, Pressable, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useQuery } from "@tanstack/react-query";
import { Screen } from "@/components/Screen";
import { EmptyState } from "@/components/EmptyState";
import { colors } from "@/theme/colors";
import { Post } from "@/types/models";
import { formatRelativeTime } from "@/utils/date";
import { feedApi } from "@/features/feed/feedApi";
import { profileApi } from "./profileApi";

function DivePostRow({ post, onPress }: { post: Post; onPress: () => void }) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => ({
        padding: 15,
        backgroundColor: colors.surface,
        borderRadius: 24,
        borderWidth: 1,
        borderColor: colors.border,
        marginBottom: 12,
        opacity: pressed ? 0.86 : 1,
        transform: [{ scale: pressed ? 0.99 : 1 }]
      })}
    >
      <View style={{ flexDirection: "row", alignItems: "center", gap: 12 }}>
        <View style={{ width: 42, height: 42, borderRadius: 21, backgroundColor: colors.surface2, alignItems: "center", justifyContent: "center" }}>
          <Ionicons name="water-outline" size={21} color={colors.primary} />
        </View>
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontWeight: "900", fontSize: 15 }} numberOfLines={2}>{post.content}</Text>
          <Text style={{ color: colors.muted, marginTop: 5, fontSize: 12 }}>{formatRelativeTime(post.createdAt)}</Text>
        </View>
        <Ionicons name="chevron-forward" size={18} color={colors.muted} />
      </View>
    </Pressable>
  );
}

export function ProfileDivesScreen({ route, navigation }: any) {
  const { userId } = route.params;
  const profileQuery = useQuery({ queryKey: ["profile", userId], queryFn: () => profileApi.user(userId), retry: 1 });
  const postsQuery = useQuery({ queryKey: ["userPosts", userId], queryFn: () => feedApi.userPosts(userId), retry: 1 });
  const user = profileQuery.data;

  return (
    <Screen scroll={false}>
      <FlatList
        data={postsQuery.data ?? []}
        keyExtractor={(item) => String(item.id)}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ paddingBottom: 120, flexGrow: 1 }}
        ListHeaderComponent={
          <View style={{ marginBottom: 16, gap: 12 }}>
            <View>
              <Text style={{ color: colors.text, fontSize: 31, fontWeight: "900" }}>Dives</Text>
              <Text style={{ color: colors.muted, marginTop: 4 }}>@{user?.username ?? route.params?.username ?? "diver"}</Text>
            </View>
            <View style={{ backgroundColor: colors.surface, borderRadius: 26, borderWidth: 1, borderColor: colors.border, padding: 16 }}>
              <Text style={{ color: colors.primary, fontSize: 36, fontWeight: "900" }}>{user?.diveCount ?? 0}</Text>
              <Text style={{ color: colors.text, fontWeight: "900", marginTop: 2 }}>Logged dives</Text>
              <Text style={{ color: colors.muted, marginTop: 7, lineHeight: 20 }}>Recent dive posts from this profile appear below.</Text>
            </View>
            {postsQuery.isLoading ? <ActivityIndicator color={colors.primary} /> : null}
          </View>
        }
        ListEmptyComponent={!postsQuery.isLoading ? <EmptyState title="No dive posts yet" body="Dive activity will appear here when this profile posts." /> : null}
        renderItem={({ item }) => (
          <DivePostRow
            post={item}
            onPress={() => navigation.getParent()?.navigate("Feed", { screen: "PostDetail", params: { postId: item.id, post: item } })}
          />
        )}
      />
    </Screen>
  );
}
