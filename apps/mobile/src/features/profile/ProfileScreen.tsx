import React, { useEffect, useMemo, useState } from "react";
import { Alert, Image, Modal, Pressable, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Screen } from "@/components/Screen";
import { Button } from "@/components/Button";
import { Input } from "@/components/Input";
import { colors } from "@/theme/colors";
import { profileApi } from "./profileApi";
import { socialApi } from "@/features/social/socialApi";
import { messagesApi } from "@/features/messaging/messagesApi";
import { useAuthStore } from "@/store/authStore";
import { User } from "@/types/models";

type ProfileForm = {
  firstName: string;
  lastName: string;
  bio: string;
  profileImageUrl: string;
};

function initials(user?: User) {
  const name = `${user?.firstName ?? ""} ${user?.lastName ?? ""}`.trim();
  const source = name || user?.username || "D";
  return source
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join("");
}

function Avatar({ user, size = 104, editable = false }: { user?: User; size?: number; editable?: boolean }) {
  const profileImageUrl = user?.profileImageUrl?.trim();
  const hasImage = !!profileImageUrl;

  return (
    <View
      style={{
        width: size,
        height: size,
        borderRadius: size / 2,
        padding: 3,
        backgroundColor: colors.primary,
        shadowColor: colors.primary,
        shadowOpacity: 0.28,
        shadowRadius: 18,
        shadowOffset: { width: 0, height: 10 }
      }}
    >
      <View style={{ flex: 1, borderRadius: size / 2, backgroundColor: colors.background, padding: 3 }}>
        {hasImage ? (
          <Image source={{ uri: profileImageUrl }} style={{ width: "100%", height: "100%", borderRadius: size / 2 }} />
        ) : (
          <View style={{ flex: 1, borderRadius: size / 2, backgroundColor: colors.surface2, alignItems: "center", justifyContent: "center" }}>
            <Text style={{ color: colors.text, fontSize: size * 0.32, fontWeight: "900" }}>{initials(user)}</Text>
          </View>
        )}
      </View>
      {editable ? (
        <View style={{ position: "absolute", right: 2, bottom: 2, width: 32, height: 32, borderRadius: 16, backgroundColor: colors.surface2, borderWidth: 2, borderColor: colors.background, alignItems: "center", justifyContent: "center" }}>
          <Ionicons name="camera-outline" size={17} color={colors.primary} />
        </View>
      ) : null}
    </View>
  );
}

function Stat({ value, label, onPress }: { value: number; label: string; onPress?: () => void }) {
  return (
    <Pressable
      onPress={onPress}
      disabled={!onPress}
      style={({ pressed }) => ({
        alignItems: "center",
        flex: 1,
        opacity: pressed ? 0.72 : 1,
        transform: [{ scale: pressed ? 0.98 : 1 }]
      })}
    >
      <Text style={{ color: colors.text, fontSize: 19, fontWeight: "900" }}>{value}</Text>
      <Text style={{ color: colors.muted, fontSize: 12, marginTop: 3 }}>{label}</Text>
    </Pressable>
  );
}

export function ProfileScreen({ route, navigation }: any) {
  const routeUserId = route.params?.userId;
  const currentUser = useAuthStore((s) => s.user);
  const updateStoredUser = useAuthStore((s) => s.updateUser);
  const logout = useAuthStore((s) => s.logout);
  const userId = routeUserId ?? currentUser?.id;
  const mine = !routeUserId || String(routeUserId) === String(currentUser?.id);
  const qc = useQueryClient();
  const [editing, setEditing] = useState(false);
  const [form, setForm] = useState<ProfileForm>({ firstName: "", lastName: "", bio: "", profileImageUrl: "" });
  const showBack = !mine;

  const query = useQuery({
    queryKey: ["profile", userId],
    queryFn: () => (mine ? profileApi.me() : profileApi.user(userId)),
    enabled: !!userId,
    retry: 1
  });

  const user = query.data;
  const displayName = useMemo(() => `${user?.firstName ?? ""} ${user?.lastName ?? ""}`.trim() || `@${user?.username ?? "diver"}`, [user]);

  useEffect(() => {
    if (!user) return;
    setForm({
      firstName: user.firstName ?? "",
      lastName: user.lastName ?? "",
      bio: user.bio ?? "",
      profileImageUrl: user.profileImageUrl ?? ""
    });
  }, [user]);

  const followMutation = useMutation({
    mutationFn: () => (query.data?.followedByMe ? socialApi.unfollow(userId) : socialApi.follow(userId)),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["profile", userId] });
      qc.invalidateQueries({ queryKey: ["notifications"] });
    }
  });

  const messageMutation = useMutation({
    mutationFn: () => messagesApi.start(userId),
    onSuccess: (conversation) => {
      qc.invalidateQueries({ queryKey: ["conversations"] });
      navigation.getParent()?.navigate("Messages", { screen: "Thread", params: { conversationId: conversation.id, participant: conversation.participant } });
    },
    onError: (error: any) => Alert.alert("Could not start chat", error?.message ?? "Try again.")
  });

  const updateMutation = useMutation({
    mutationFn: () =>
      profileApi.updateMe({
        firstName: form.firstName.trim(),
        lastName: form.lastName.trim(),
        bio: form.bio.trim(),
        profileImageUrl: form.profileImageUrl.trim() || undefined
      }),
    onSuccess: async (updated) => {
      await updateStoredUser(updated);
      setEditing(false);
      qc.setQueryData(["profile", userId], updated);
      qc.invalidateQueries({ queryKey: ["profile", userId] });
    },
    onError: (error: any) => {
      Alert.alert("Could not update profile", error?.message ?? "Check the backend profile update endpoint.");
    }
  });

  return (
    <Screen>
      <View style={{ flexDirection: "row", alignItems: "center", justifyContent: "space-between", gap: 12 }}>
        {showBack ? (
          <Pressable
            onPress={() => (navigation.canGoBack() ? navigation.goBack() : navigation.navigate("Me"))}
            style={({ pressed }) => ({
              width: 44,
              height: 44,
              borderRadius: 22,
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
        ) : null}
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontSize: 28, fontWeight: "900" }}>{mine ? "Profile" : `@${user?.username ?? "Diver"}`}</Text>
          <Text style={{ color: colors.muted, marginTop: 4 }}>{mine ? "Your ocean identity" : "Diver profile"}</Text>
        </View>
        {mine ? (
          <Pressable onPress={logout} style={{ padding: 12, borderRadius: 18, backgroundColor: colors.surface, borderWidth: 1, borderColor: colors.border }}>
            <Ionicons name="log-out-outline" size={22} color={colors.text} />
          </Pressable>
        ) : null}
      </View>

      {query.isError ? <Text style={{ color: colors.danger }}>{query.error instanceof Error ? query.error.message : "Unable to load profile."}</Text> : null}

      <View
        style={{
          backgroundColor: colors.surface,
          borderRadius: 34,
          borderWidth: 1,
          borderColor: colors.border,
          padding: 18,
          overflow: "hidden"
        }}
      >
        <View style={{ position: "absolute", width: 220, height: 220, borderRadius: 110, backgroundColor: "rgba(21,209,194,0.12)", right: -80, top: -80 }} />
        <View style={{ flexDirection: "row", alignItems: "center", gap: 18 }}>
          <Pressable onPress={() => mine && setEditing(true)} disabled={!mine} style={({ pressed }) => ({ opacity: pressed ? 0.82 : 1 })}>
            <Avatar user={user} editable={mine} />
          </Pressable>
          <View style={{ flex: 1, flexDirection: "row", gap: 10 }}>
            <Stat
              value={user?.followersCount ?? 0}
              label="followers"
              onPress={() => navigation.navigate("ProfileConnections", { userId, username: user?.username, mode: "followers" })}
            />
            <Stat
              value={user?.followingCount ?? 0}
              label="following"
              onPress={() => navigation.navigate("ProfileConnections", { userId, username: user?.username, mode: "following" })}
            />
            <Stat
              value={user?.diveCount ?? 0}
              label="dives"
              onPress={() => navigation.navigate("ProfileDives", { userId, username: user?.username })}
            />
          </View>
        </View>

        <Text style={{ color: colors.text, fontSize: 22, fontWeight: "900", marginTop: 18 }}>{displayName}</Text>
        <Text style={{ color: colors.primary, marginTop: 4, fontWeight: "800" }}>@{user?.username ?? "diver"}</Text>
        <Text style={{ color: colors.text, marginTop: 14, lineHeight: 22 }}>{user?.bio?.trim() || "No bio yet. Add a clean little intro, dive style, favorite places, or what kind of buddies you want to meet."}</Text>

        <View style={{ flexDirection: "row", gap: 10, marginTop: 18 }}>
          {mine ? (
            <>
              <View style={{ flex: 1 }}>
                <Button title="Settings" onPress={() => setEditing(true)} />
              </View>
              <Pressable onPress={() => setEditing(true)} style={{ width: 52, borderRadius: 18, backgroundColor: colors.surface2, alignItems: "center", justifyContent: "center" }}>
                <Ionicons name="settings-outline" size={22} color={colors.text} />
              </Pressable>
            </>
          ) : (
            <>
              <View style={{ flex: 1 }}>
                <Button title={user?.followedByMe ? "Following" : "Follow"} loading={followMutation.isPending} variant={user?.followedByMe ? "soft" : "primary"} onPress={() => followMutation.mutate()} />
              </View>
              <View style={{ flex: 1 }}>
                <Button title="Message" loading={messageMutation.isPending} variant="soft" onPress={() => messageMutation.mutate()} />
              </View>
            </>
          )}
        </View>
      </View>

      {mine ? (
        <View style={{ backgroundColor: colors.surface, borderRadius: 28, borderWidth: 1, borderColor: colors.border, padding: 16, gap: 12 }}>
          <Text style={{ color: colors.text, fontSize: 18, fontWeight: "900" }}>Profile tools</Text>
          <Pressable onPress={() => setEditing(true)} style={{ flexDirection: "row", alignItems: "center", justifyContent: "space-between", paddingVertical: 8 }}>
            <View style={{ flexDirection: "row", gap: 12, alignItems: "center" }}>
              <Ionicons name="person-outline" size={20} color={colors.primary} />
              <Text style={{ color: colors.text, fontWeight: "800" }}>Edit bio and profile image</Text>
            </View>
            <Ionicons name="chevron-forward" size={20} color={colors.muted} />
          </Pressable>
          <Pressable onPress={() => navigation.getParent()?.getParent()?.navigate("Learn")} style={{ flexDirection: "row", alignItems: "center", justifyContent: "space-between", paddingVertical: 8 }}>
            <View style={{ flexDirection: "row", gap: 12, alignItems: "center" }}>
              <Ionicons name="school-outline" size={20} color={colors.primary} />
              <Text style={{ color: colors.text, fontWeight: "800" }}>Learn scuba basics</Text>
            </View>
            <Ionicons name="chevron-forward" size={20} color={colors.muted} />
          </Pressable>
        </View>
      ) : null}

      <Modal visible={editing} animationType="slide" presentationStyle="pageSheet" onRequestClose={() => setEditing(false)}>
        <Screen>
          <View style={{ flexDirection: "row", alignItems: "center", justifyContent: "space-between" }}>
            <Pressable onPress={() => setEditing(false)} style={{ padding: 10 }}>
              <Text style={{ color: colors.text, fontSize: 16, fontWeight: "800" }}>Cancel</Text>
            </Pressable>
            <Text style={{ color: colors.text, fontSize: 18, fontWeight: "900" }}>Edit profile</Text>
            <Pressable onPress={() => updateMutation.mutate()} disabled={updateMutation.isPending} style={{ padding: 10 }}>
              <Text style={{ color: colors.primary, fontSize: 16, fontWeight: "900" }}>{updateMutation.isPending ? "Saving" : "Save"}</Text>
            </Pressable>
          </View>

          <View style={{ alignItems: "center", marginTop: 8 }}>
            <Avatar user={user ? { ...user, profileImageUrl: form.profileImageUrl } : undefined} size={116} />
            <Text style={{ color: colors.muted, marginTop: 12, textAlign: "center" }}>Paste an image URL for now. Later you can swap this with Expo ImagePicker + backend upload.</Text>
          </View>

          <View style={{ gap: 12 }}>
            <Input placeholder="First name" value={form.firstName} onChangeText={(firstName) => setForm((prev) => ({ ...prev, firstName }))} />
            <Input placeholder="Last name" value={form.lastName} onChangeText={(lastName) => setForm((prev) => ({ ...prev, lastName }))} />
            <Input placeholder="Profile image URL" autoCapitalize="none" value={form.profileImageUrl} onChangeText={(profileImageUrl) => setForm((prev) => ({ ...prev, profileImageUrl }))} />
            <Input placeholder="Bio" multiline value={form.bio} onChangeText={(bio) => setForm((prev) => ({ ...prev, bio }))} />
          </View>
        </Screen>
      </Modal>
    </Screen>
  );
}
