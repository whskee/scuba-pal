import React, { useMemo, useState } from "react";
import { Image, Pressable, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { Post } from "@/types/models";
import { colors } from "@/theme/colors";

const fallbackImages = [
  "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900",
  "https://images.unsplash.com/photo-1518877593221-1f28583780b4?w=900",
  "https://images.unsplash.com/photo-1580019542155-247062e19ce4?w=900",
  "https://images.unsplash.com/photo-1682687220063-4742bd7fd538?w=900"
];

export function PinterestPostCard({ post, index, onLike, onAuthorPress, onPress }: { post: Post; index: number; onLike: () => void; onAuthorPress?: () => void; onPress?: () => void }) {
  const [saved, setSaved] = useState(false);
  const image = post.imageUrl || fallbackImages[index % fallbackImages.length];
  const imageHeight = useMemo(() => 190 + ((index * 53) % 130), [index]);
  const displayName = post.author?.username || "diver";

  return (
    <View style={{ width: "100%", marginBottom: 16 }}>
      <Pressable onPress={onPress} style={({ pressed }) => ({ opacity: pressed ? 0.92 : 1, transform: [{ scale: pressed ? 0.99 : 1 }] })}>
        <View style={{ backgroundColor: colors.card, borderRadius: 28, overflow: "hidden", shadowColor: colors.shadow, shadowOpacity: 0.2, shadowRadius: 18, shadowOffset: { width: 0, height: 10 }, elevation: 5 }}>
          <View>
            <Image source={{ uri: image }} style={{ width: "100%", height: imageHeight, backgroundColor: colors.surface2 }} />
            <View style={{ position: "absolute", top: 10, right: 10, flexDirection: "row", gap: 8 }}>
              <Pressable onPress={(event) => { event.stopPropagation(); onLike(); }} style={{ width: 38, height: 38, borderRadius: 19, backgroundColor: post.likedByMe ? "rgba(255,122,144,0.18)" : "rgba(255,255,255,0.88)", alignItems: "center", justifyContent: "center" }}>
                <Ionicons name={post.likedByMe ? "heart" : "heart-outline"} size={20} color={post.likedByMe ? colors.accent : colors.textDark} />
              </Pressable>
              <Pressable onPress={(event) => { event.stopPropagation(); setSaved((v) => !v); }} style={{ width: 38, height: 38, borderRadius: 19, backgroundColor: "rgba(255,255,255,0.88)", alignItems: "center", justifyContent: "center" }}>
                <Ionicons name={saved ? "bookmark" : "bookmark-outline"} size={19} color={saved ? colors.primaryDark : colors.textDark} />
              </Pressable>
            </View>
          </View>

          <View style={{ padding: 13, gap: 10 }}>
            <Text numberOfLines={3} style={{ color: colors.textDark, fontWeight: "800", lineHeight: 19 }}>{post.content}</Text>
            <View style={{ flexDirection: "row", alignItems: "center", justifyContent: "space-between", gap: 8 }}>
              <Pressable onPress={(event) => { event.stopPropagation(); onAuthorPress?.(); }} style={{ flexDirection: "row", alignItems: "center", gap: 8, flex: 1 }}>
                {post.author?.profileImageUrl ? <Image source={{ uri: post.author.profileImageUrl }} style={{ width: 26, height: 26, borderRadius: 13 }} /> : <View style={{ width: 26, height: 26, borderRadius: 13, backgroundColor: colors.primary, alignItems: "center", justifyContent: "center" }}><Text style={{ color: colors.textDark, fontWeight: "900", fontSize: 11 }}>{displayName[0]?.toUpperCase()}</Text></View>}
                <Text numberOfLines={1} style={{ color: colors.mutedDark, fontWeight: "800", fontSize: 12 }}>@{displayName}</Text>
              </Pressable>
              <View style={{ flexDirection: "row", alignItems: "center", gap: 4 }}>
                <Ionicons name={post.likedByMe ? "heart" : "heart-outline"} size={13} color={post.likedByMe ? colors.accent : colors.mutedDark} />
                <Text style={{ color: colors.mutedDark, fontWeight: "900", fontSize: 12 }}>{post.likeCount}</Text>
              </View>
            </View>
          </View>
        </View>
      </Pressable>
    </View>
  );
}
