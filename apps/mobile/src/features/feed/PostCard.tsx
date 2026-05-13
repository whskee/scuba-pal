import React from "react";
import { Pressable, Text, View } from "react-native";
import { Card } from "@/components/Card";
import { Post } from "@/types/models";
import { colors } from "@/theme/colors";
import { formatRelativeTime } from "@/utils/date";

export function PostCard({ post, onLike, onAuthorPress }: { post: Post; onLike: () => void; onAuthorPress?: () => void }) {
  return (
    <Card>
      <Pressable onPress={onAuthorPress}>
        <Text style={{ color: colors.text, fontWeight: "900", fontSize: 16 }}>@{post.author.username}</Text>
      </Pressable>
      <Text style={{ color: colors.text, fontSize: 15, lineHeight: 22, marginVertical: 12 }}>{post.content}</Text>
      <Text style={{ color: colors.muted, fontSize: 12 }}>{formatRelativeTime(post.createdAt)}</Text>
      <View style={{ flexDirection: "row", gap: 18, marginTop: 14 }}>
        <Pressable onPress={onLike}><Text style={{ color: post.likedByMe ? colors.primary : colors.muted, fontWeight: "800" }}>{post.likedByMe ? "Liked" : "Like"} · {post.likeCount}</Text></Pressable>
        <Text style={{ color: colors.muted, fontWeight: "800" }}>Comments · {post.commentCount}</Text>
      </View>
    </Card>
  );
}
