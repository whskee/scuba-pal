import React, { useMemo, useState } from "react";
import { ActivityIndicator, FlatList, RefreshControl, Text, View } from "react-native";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { Screen } from "@/components/Screen";
import { EmptyState } from "@/components/EmptyState";
import { colors } from "@/theme/colors";
import { typography } from "@/theme/typography";
import { Post } from "@/types/models";
import { useAuthStore } from "@/store/authStore";
import { feedApi } from "./feedApi";
import { CreatePostBox } from "./CreatePostBox";
import { PinterestPostCard } from "./PinterestPostCard";
import { FeedPill } from "./FeedPill";

const filters = ["For you", "Local", "Buddies", "Gear", "Training"];

function splitColumns(posts: Post[]) {
  return posts.reduce<[Post[], Post[]]>((columns, post, index) => {
    columns[index % 2].push(post);
    return columns;
  }, [[], []]);
}

export function FeedScreen({ navigation }: any) {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const [activeFilter, setActiveFilter] = useState("For you");
  const qc = useQueryClient();
  const query = useQuery({ queryKey: ["feed"], queryFn: () => feedApi.feed(), enabled: isAuthenticated, refetchOnMount: "always", retry: 1 });
  const posts = query.data ?? [];
  const columns = useMemo(() => splitColumns(posts), [posts]);

  const likeMutation = useMutation({
    mutationFn: (post: Post) => post.likedByMe ? feedApi.unlike(post.id) : feedApi.like(post.id),
    onMutate: async (post) => {
      await qc.cancelQueries({ queryKey: ["feed"] });
      const previous = qc.getQueryData<Post[]>(["feed"]);
      qc.setQueryData<Post[]>(["feed"], (old = []) => old.map(p => p.id === post.id ? { ...p, likedByMe: !p.likedByMe, likeCount: Math.max(0, p.likeCount + (p.likedByMe ? -1 : 1)) } : p));
      return { previous };
    },
    onError: (_e, _v, ctx) => ctx?.previous && qc.setQueryData(["feed"], ctx.previous),
    onSettled: () => qc.invalidateQueries({ queryKey: ["feed"] })
  });

  const onLike = (post: Post) => {
    if (!isAuthenticated) return;
    likeMutation.mutate(post);
  };

  const header = (
    <View style={{ gap: 16, paddingHorizontal: 18, paddingTop: 10, paddingBottom: 14 }}>
      <View style={{ backgroundColor: colors.surface, borderRadius: 30, padding: 18, overflow: "hidden", borderColor: colors.border, borderWidth: 1 }}>
        <View style={{ position: "absolute", right: -35, top: -35, width: 130, height: 130, borderRadius: 65, backgroundColor: "rgba(21,209,194,0.18)" }} />
        <Text style={[typography.caption, { color: colors.primary, textTransform: "uppercase", letterSpacing: 1.2 }]}>Scuba Pal</Text>
        <Text style={[typography.hero, { color: colors.text, marginTop: 8 }]}>Dive feed</Text>
        <Text style={{ color: colors.muted, lineHeight: 21, marginTop: 6 }}>Discover dive stories, buddy invites, gear ideas, and ocean moments in one sleek feed.</Text>
      </View>

      <FlatList
        horizontal
        data={filters}
        keyExtractor={(item) => item}
        showsHorizontalScrollIndicator={false}
        ItemSeparatorComponent={() => <View style={{ width: 10 }} />}
        renderItem={({ item }) => <FeedPill label={item} active={activeFilter === item} onPress={() => setActiveFilter(item)} />}
      />

      {isAuthenticated ? <CreatePostBox /> : <View style={{ backgroundColor: colors.surface2, borderRadius: 22, padding: 14, borderColor: colors.border, borderWidth: 1 }}>
        <Text style={{ color: colors.text, fontWeight: "900", fontSize: 16 }}>Guest preview</Text>
        <Text style={{ color: colors.muted, marginTop: 4, lineHeight: 20 }}>Log in to post, like, save, message divers, and see your live personalized feed.</Text>
      </View>}
    </View>
  );

  return (
    <Screen scroll={false} style={{ padding: 0 }}>
      <FlatList
        data={["masonry"]}
        keyExtractor={(item) => item}
        ListHeaderComponent={header}
        contentContainerStyle={{ paddingBottom: 120 }}
        refreshControl={isAuthenticated ? <RefreshControl tintColor={colors.primary} refreshing={query.isFetching} onRefresh={() => query.refetch()} /> : undefined}
        renderItem={() => {
          if (query.isLoading && isAuthenticated) return <ActivityIndicator color={colors.primary} style={{ marginTop: 30 }} />;
          if (!posts.length) return <View style={{ paddingHorizontal: 18 }}><EmptyState title="No posts yet" body="Create the first Scuba Pal post." /></View>;
          return (
            <View style={{ flexDirection: "row", gap: 14, paddingHorizontal: 14 }}>
              <View style={{ flex: 1 }}>
                {columns[0].map((post, index) => <PinterestPostCard key={String(post.id)} post={post} index={index * 2} onLike={() => onLike(post)} onPress={() => isAuthenticated && navigation.navigate("PostDetail", { postId: post.id, post })} onAuthorPress={() => isAuthenticated && navigation.getParent()?.navigate("ProfileStack", { screen: "UserProfile", params: { userId: post.author.id } })} />)}
              </View>
              <View style={{ flex: 1, paddingTop: 34 }}>
                {columns[1].map((post, index) => <PinterestPostCard key={String(post.id)} post={post} index={index * 2 + 1} onLike={() => onLike(post)} onPress={() => isAuthenticated && navigation.navigate("PostDetail", { postId: post.id, post })} onAuthorPress={() => isAuthenticated && navigation.getParent()?.navigate("ProfileStack", { screen: "UserProfile", params: { userId: post.author.id } })} />)}
              </View>
            </View>
          );
        }}
      />
    </Screen>
  );
}
