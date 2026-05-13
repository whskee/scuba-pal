import React from "react";
import { ActivityIndicator, FlatList, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useQuery } from "@tanstack/react-query";
import { Screen } from "@/components/Screen";
import { Card } from "@/components/Card";
import { EmptyState } from "@/components/EmptyState";
import { colors } from "@/theme/colors";
import { learnApi, LearnArticle } from "./learnApi";

function ArticleCard({ article }: { article: LearnArticle }) {
  return (
    <Card>
      <View style={{ flexDirection: "row", alignItems: "center", justifyContent: "space-between", gap: 12 }}>
        <View style={{ flexDirection: "row", alignItems: "center", gap: 8, flexShrink: 1 }}>
          <View style={{ width: 34, height: 34, borderRadius: 17, backgroundColor: colors.surface2, alignItems: "center", justifyContent: "center" }}>
            <Ionicons name="school-outline" size={18} color={colors.primary} />
          </View>
          <Text style={{ color: colors.primary, fontSize: 12, fontWeight: "900", textTransform: "uppercase" }} numberOfLines={1}>{article.category}</Text>
        </View>
        <Text style={{ color: colors.muted, fontSize: 12, fontWeight: "800" }}>{article.estimatedMinutes} min</Text>
      </View>
      <Text style={{ color: colors.text, fontSize: 19, fontWeight: "900", marginTop: 14 }}>{article.title}</Text>
      <Text style={{ color: colors.muted, marginTop: 8, lineHeight: 21 }}>{article.summary}</Text>
      <Text style={{ color: colors.text, marginTop: 12, lineHeight: 22 }}>{article.content}</Text>
      <Text style={{ color: colors.muted, marginTop: 12, fontWeight: "800" }}>{article.difficultyLevel}</Text>
    </Card>
  );
}

export function LearnScreen() {
  const query = useQuery({ queryKey: ["learnArticles"], queryFn: learnApi.articles, retry: 1 });

  return (
    <Screen scroll={false}>
      <FlatList
        data={query.data ?? []}
        keyExtractor={(item) => String(item.id || item.slug)}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={{ gap: 14, paddingBottom: 120, flexGrow: 1 }}
        ListHeaderComponent={
          <View style={{ marginBottom: 4 }}>
            <Text style={{ color: colors.text, fontSize: 31, fontWeight: "900" }}>Learn</Text>
            <Text style={{ color: colors.muted, marginTop: 4 }}>Scuba skills, safety, planning, and reef-friendly habits</Text>
          </View>
        }
        ListEmptyComponent={
          query.isLoading ? (
            <ActivityIndicator color={colors.primary} style={{ marginTop: 24 }} />
          ) : (
            <EmptyState title="No lessons yet" body={query.isError ? "The learn content source is unavailable." : "Lessons will appear here soon."} />
          )
        }
        renderItem={({ item }) => <ArticleCard article={item} />}
      />
    </Screen>
  );
}
