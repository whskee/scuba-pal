import React from "react";
import { ActivityIndicator, FlatList, Image, Pressable, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useQuery } from "@tanstack/react-query";
import { Screen } from "@/components/Screen";
import { EmptyState } from "@/components/EmptyState";
import { colors } from "@/theme/colors";
import { User } from "@/types/models";
import { socialApi } from "@/features/social/socialApi";

function ConnectionRow({ user, onPress }: { user: User; onPress: () => void }) {
  const letter = user.username?.[0]?.toUpperCase() ?? "D";
  const displayName = `${user.firstName ?? ""} ${user.lastName ?? ""}`.trim();

  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => ({
        padding: 14,
        backgroundColor: colors.surface,
        borderRadius: 24,
        borderWidth: 1,
        borderColor: colors.border,
        marginBottom: 12,
        opacity: pressed ? 0.86 : 1,
        transform: [{ scale: pressed ? 0.99 : 1 }]
      })}
    >
      <View style={{ flexDirection: "row", alignItems: "center", gap: 13 }}>
        {user.profileImageUrl ? (
          <Image source={{ uri: user.profileImageUrl }} style={{ width: 52, height: 52, borderRadius: 26, backgroundColor: colors.surface2 }} />
        ) : (
          <View style={{ width: 52, height: 52, borderRadius: 26, backgroundColor: colors.primary, alignItems: "center", justifyContent: "center" }}>
            <Text style={{ color: colors.textDark, fontWeight: "900", fontSize: 18 }}>{letter}</Text>
          </View>
        )}
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontWeight: "900", fontSize: 16 }} numberOfLines={1}>@{user.username}</Text>
          <Text style={{ color: colors.muted, marginTop: 4 }} numberOfLines={1}>{displayName || user.bio || "Scuba Pal diver"}</Text>
        </View>
        <Ionicons name="chevron-forward" size={18} color={colors.muted} />
      </View>
    </Pressable>
  );
}

export function ProfileConnectionsScreen({ route, navigation }: any) {
  const { userId, mode } = route.params;
  const title = mode === "following" ? "Following" : "Followers";
  const query = useQuery({
    queryKey: ["profileConnections", userId, mode],
    queryFn: () => mode === "following" ? socialApi.following(userId) : socialApi.followers(userId),
    retry: 1
  });

  return (
    <Screen scroll={false}>
      <View style={{ marginBottom: 16 }}>
        <Text style={{ color: colors.text, fontSize: 31, fontWeight: "900" }}>{title}</Text>
        <Text style={{ color: colors.muted, marginTop: 4 }}>@{route.params?.username ?? "diver"}</Text>
      </View>

      {query.isLoading ? <ActivityIndicator color={colors.primary} style={{ marginTop: 20 }} /> : null}
      <FlatList
        data={query.data ?? []}
        keyExtractor={(item) => String(item.id)}
        contentContainerStyle={{ paddingBottom: 120, flexGrow: 1 }}
        showsVerticalScrollIndicator={false}
        ListEmptyComponent={!query.isLoading ? <EmptyState title={`No ${title.toLowerCase()}`} body="Nothing to show here yet." /> : null}
        renderItem={({ item }) => (
          <ConnectionRow
            user={item}
            onPress={() => navigation.navigate("UserProfile", { userId: item.id })}
          />
        )}
      />
    </Screen>
  );
}
