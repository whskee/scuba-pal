import React, { useMemo, useState } from "react";
import { ActivityIndicator, FlatList, Image, KeyboardAvoidingView, Platform, Pressable, Text, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { Ionicons } from "@expo/vector-icons";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Screen } from "@/components/Screen";
import { Input } from "@/components/Input";
import { colors } from "@/theme/colors";
import { Comment, Post } from "@/types/models";
import { feedApi } from "./feedApi";
import { formatRelativeTime } from "@/utils/date";

function CommentRow({ comment, onAuthorPress }: { comment: Comment; onAuthorPress: () => void }) {
  return (
    <View style={{ backgroundColor: colors.surface, borderRadius: 22, padding: 13, borderWidth: 1, borderColor: colors.border, marginBottom: 10 }}>
      <Pressable onPress={onAuthorPress}>
        <Text style={{ color: colors.primary, fontWeight: "900" }}>@{comment.username}</Text>
      </Pressable>
      <Text style={{ color: colors.text, marginTop: 7, lineHeight: 21 }}>{comment.body}</Text>
      <Text style={{ color: colors.muted, marginTop: 7, fontSize: 11 }}>{formatRelativeTime(comment.createdAt)}</Text>
    </View>
  );
}

function PostAction({
  icon,
  activeIcon,
  active,
  count,
  accessibilityLabel,
  loading,
  activeTint = colors.accent,
  onPress
}: {
  icon: keyof typeof Ionicons.glyphMap;
  activeIcon?: keyof typeof Ionicons.glyphMap;
  active?: boolean;
  count: number;
  accessibilityLabel: string;
  loading?: boolean;
  activeTint?: string;
  onPress: () => void;
}) {
  const tint = active ? activeTint : colors.text;

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={accessibilityLabel}
      disabled={loading}
      onPress={onPress}
      style={({ pressed }) => ({
        minWidth: 66,
        height: 46,
        borderRadius: 23,
        paddingHorizontal: 14,
        backgroundColor: active ? (activeTint === colors.primary ? "rgba(21,209,194,0.14)" : "rgba(255,122,144,0.14)") : colors.surface,
        borderWidth: 1,
        borderColor: active ? (activeTint === colors.primary ? "rgba(21,209,194,0.32)" : "rgba(255,122,144,0.32)") : colors.border,
        flexDirection: "row",
        alignItems: "center",
        justifyContent: "center",
        gap: 7,
        opacity: pressed ? 0.72 : 1,
        transform: [{ scale: pressed ? 0.98 : 1 }]
      })}
    >
      {loading ? (
        <ActivityIndicator color={tint} />
      ) : (
        <Ionicons name={active && activeIcon ? activeIcon : icon} size={24} color={tint} />
      )}
      <Text style={{ color: tint, fontWeight: "900" }}>{count}</Text>
    </Pressable>
  );
}

export function PostDetailScreen({ route, navigation }: any) {
  const initialPost = route.params?.post as Post | undefined;
  const postId = route.params?.postId ?? initialPost?.id;
  const [commentText, setCommentText] = useState("");
  const [commentComposerVisible, setCommentComposerVisible] = useState(false);
  const qc = useQueryClient();
  const insets = useSafeAreaInsets();
  const query = useQuery({ queryKey: ["post", postId], queryFn: () => feedApi.detail(postId), initialData: initialPost, enabled: !!postId, refetchOnMount: "always", retry: 1 });
  const post = query.data;
  const image = useMemo(() => post?.imageUrl, [post?.imageUrl]);

  const likeMutation = useMutation({
    mutationFn: () => (post?.likedByMe ? feedApi.unlike(post.id) : feedApi.like(post?.id ?? postId)),
    onMutate: async () => {
      if (!post) return undefined;
      await qc.cancelQueries({ queryKey: ["post", postId] });
      const previousPost = qc.getQueryData<Post>(["post", postId]);
      const nextPost = {
        ...post,
        likedByMe: !post.likedByMe,
        likeCount: Math.max(0, post.likeCount + (post.likedByMe ? -1 : 1))
      };
      qc.setQueryData(["post", postId], nextPost);
      qc.setQueryData<Post[]>(["feed"], (old) => old?.map((item) => item.id === post.id ? { ...item, likedByMe: nextPost.likedByMe, likeCount: nextPost.likeCount } : item));
      return { previousPost, nextPost };
    },
    onError: (_error, _variables, context) => {
      if (context?.previousPost) qc.setQueryData(["post", postId], context.previousPost);
    },
    onSuccess: (updated, _variables, context) => {
      const synced = context?.nextPost ? { ...updated, likedByMe: context.nextPost.likedByMe } : updated;
      qc.setQueryData(["post", postId], synced);
      qc.invalidateQueries({ queryKey: ["feed"] });
    }
  });

  const commentMutation = useMutation({
    mutationFn: () => feedApi.comment(postId, commentText.trim()),
    onSuccess: (updated) => {
      setCommentText("");
      setCommentComposerVisible(false);
      qc.setQueryData(["post", postId], updated);
      qc.invalidateQueries({ queryKey: ["feed"] });
    }
  });

  if (!post) {
    return (
      <Screen>
        <Text style={{ color: colors.text, fontWeight: "900", fontSize: 20 }}>Loading post...</Text>
      </Screen>
    );
  }

  const openAuthor = () => navigation.getParent()?.navigate("ProfileStack", { screen: "UserProfile", params: { userId: post.author.id } });

  return (
    <Screen scroll={false} style={{ padding: 0 }}>
      <KeyboardAvoidingView style={{ flex: 1 }} behavior={Platform.OS === "ios" ? "padding" : undefined} keyboardVerticalOffset={0}>
        <FlatList
          style={{ flex: 1 }}
          data={post.comments ?? []}
          keyExtractor={(item) => String(item.id)}
          showsVerticalScrollIndicator={false}
          keyboardShouldPersistTaps="handled"
          contentContainerStyle={{ paddingBottom: 18 }}
          ListHeaderComponent={
            <View>
              <View style={{ width: "100%", backgroundColor: colors.surface2 }}>
                {image ? (
                  <Image source={{ uri: image }} style={{ width: "100%", height: 360, backgroundColor: colors.surface2 }} resizeMode="cover" />
                ) : (
                  <View style={{ width: "100%", height: 220, backgroundColor: colors.surface2, alignItems: "center", justifyContent: "center" }}>
                    <Ionicons name="chatbubble-ellipses-outline" size={38} color={colors.muted} />
                  </View>
                )}
                <Pressable
                  onPress={() => navigation.goBack()}
                  style={{ position: "absolute", top: 14, left: 14, width: 42, height: 42, borderRadius: 21, backgroundColor: "rgba(7,17,31,0.72)", alignItems: "center", justifyContent: "center" }}
                >
                  <Ionicons name="chevron-back" size={24} color={colors.text} />
                </Pressable>
              </View>

              <View style={{ padding: 18, gap: 14 }}>
                <Pressable onPress={openAuthor} style={{ flexDirection: "row", alignItems: "center", gap: 12 }}>
                  {post.author.profileImageUrl ? (
                    <Image source={{ uri: post.author.profileImageUrl }} style={{ width: 44, height: 44, borderRadius: 22, backgroundColor: colors.surface2 }} />
                  ) : (
                    <View style={{ width: 44, height: 44, borderRadius: 22, backgroundColor: colors.primary, alignItems: "center", justifyContent: "center" }}>
                      <Text style={{ color: colors.textDark, fontWeight: "900", fontSize: 16 }}>{post.author.username[0]?.toUpperCase() ?? "D"}</Text>
                    </View>
                  )}
                  <View style={{ flex: 1 }}>
                    <Text style={{ color: colors.text, fontSize: 18, fontWeight: "900" }}>@{post.author.username}</Text>
                    <Text style={{ color: colors.muted, marginTop: 3 }}>{formatRelativeTime(post.createdAt)}</Text>
                  </View>
                  <Ionicons name="person-circle-outline" size={30} color={colors.primary} />
                </Pressable>

                <Text style={{ color: colors.text, fontSize: 18, lineHeight: 27, fontWeight: "700" }}>{post.content}</Text>

                <View style={{ flexDirection: "row", alignItems: "center", gap: 12 }}>
                  <PostAction
                    icon="heart-outline"
                    activeIcon="heart"
                    active={post.likedByMe}
                    count={post.likeCount}
                    accessibilityLabel={post.likedByMe ? "Unlike post" : "Like post"}
                    loading={likeMutation.isPending}
                    onPress={() => likeMutation.mutate()}
                  />
                  <PostAction
                    icon="chatbubble-outline"
                    active={commentComposerVisible}
                    activeTint={colors.primary}
                    count={post.commentCount}
                    accessibilityLabel="Write a comment"
                    onPress={() => setCommentComposerVisible((visible) => !visible)}
                  />
                </View>

                <Text style={{ color: colors.text, fontSize: 19, fontWeight: "900", marginTop: 4 }}>Comments</Text>
              </View>
            </View>
          }
          ListEmptyComponent={<Text style={{ color: colors.muted, paddingHorizontal: 18, marginBottom: 12 }}>No comments yet. Start the conversation.</Text>}
          renderItem={({ item }) => <View style={{ paddingHorizontal: 18 }}><CommentRow comment={item} onAuthorPress={() => navigation.getParent()?.navigate("ProfileStack", { screen: "UserProfile", params: { userId: item.userId } })} /></View>}
        />

        {commentComposerVisible ? (
          <View style={{ padding: 12, paddingBottom: Math.max(insets.bottom, 12), backgroundColor: colors.background, borderTopWidth: 1, borderTopColor: colors.border }}>
            <View style={{ backgroundColor: colors.surface, borderRadius: 28, borderWidth: 1, borderColor: colors.border, padding: 8, flexDirection: "row", alignItems: "flex-end", gap: 8 }}>
              <Input
                placeholder="Add a comment..."
                value={commentText}
                onChangeText={setCommentText}
                multiline
                style={{ flex: 1, minHeight: 46, maxHeight: 110, borderRadius: 23, paddingVertical: 12 }}
              />
              <Pressable
                accessibilityRole="button"
                accessibilityLabel="Post comment"
                disabled={!commentText.trim() || commentMutation.isPending}
                onPress={() => commentText.trim() && commentMutation.mutate()}
                style={({ pressed }) => ({
                  width: 46,
                  height: 46,
                  borderRadius: 23,
                  backgroundColor: commentText.trim() ? colors.primary : colors.surface3,
                  alignItems: "center",
                  justifyContent: "center",
                  opacity: !commentText.trim() || commentMutation.isPending ? 0.55 : pressed ? 0.78 : 1,
                  transform: [{ scale: pressed ? 0.96 : 1 }]
                })}
              >
                {commentMutation.isPending ? <ActivityIndicator color={colors.textDark} /> : <Ionicons name="send" size={19} color={colors.textDark} />}
              </Pressable>
            </View>
          </View>
        ) : null}
      </KeyboardAvoidingView>
    </Screen>
  );
}
