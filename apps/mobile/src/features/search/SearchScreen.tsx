import React, { useMemo, useState } from "react";
import { FlatList, Image, Pressable, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useQuery } from "@tanstack/react-query";
import { Screen } from "@/components/Screen";
import { Input } from "@/components/Input";
import { EmptyState } from "@/components/EmptyState";
import { colors } from "@/theme/colors";
import { User } from "@/types/models";
import { usersApi } from "./usersApi";
import { useAuthStore } from "@/store/authStore";

function UserRow({ user, onPress }: { user: User; onPress: () => void }) {
  const letter = user.username?.[0]?.toUpperCase() ?? "D";
  const displayName = `${user.firstName ?? ""} ${user.lastName ?? ""}`.trim();
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => ({
        padding: 14,
        backgroundColor: colors.surface,
        borderRadius: 26,
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

export function SearchScreen({ navigation }: any) {
  const [term, setTerm] = useState("");
  const currentUser = useAuthStore((s) => s.user);
  const debouncedKey = useMemo(() => term.trim().toLowerCase(), [term]);
  const query = useQuery({ queryKey: ["users", debouncedKey], queryFn: () => usersApi.search(debouncedKey), retry: 1 });
  const users = useMemo(
    () =>
      (query.data ?? []).filter((user) => {
        if (String(user.id) === String(currentUser?.id)) return false;
        return user.username?.toLowerCase() !== currentUser?.username?.toLowerCase();
      }),
    [currentUser?.id, currentUser?.username, query.data]
  );

  return (
    <Screen scroll={false}>
      <View style={{ marginBottom: 14 }}>
        <Text style={{ color: colors.text, fontSize: 31, fontWeight: "900" }}>Search</Text>
        <Text style={{ color: colors.muted, marginTop: 4 }}>Find divers by username</Text>
      </View>

      <View style={{ marginBottom: 14 }}>
        <Input
          placeholder="Search username..."
          autoCapitalize="none"
          value={term}
          onChangeText={setTerm}
          style={{ paddingLeft: 16 }}
        />
      </View>

      <FlatList
        data={users}
        keyExtractor={(item) => String(item.id)}
        contentContainerStyle={{ paddingBottom: 120, flexGrow: 1 }}
        keyboardShouldPersistTaps="handled"
        ListEmptyComponent={
          <EmptyState
            title={query.isFetching ? "Searching..." : query.isError ? "Could not load users" : "No users found"}
            body={query.isError && query.error instanceof Error ? query.error.message : term.trim() ? "Try a different username." : "Start typing to search all Scuba Pal users."}
          />
        }
        renderItem={({ item }) => (
          <UserRow
            user={item}
            onPress={() => navigation.navigate("SearchUserProfile", { userId: item.id })}
          />
        )}
      />
    </Screen>
  );
}
