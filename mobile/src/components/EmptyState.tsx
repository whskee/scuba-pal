import React from "react";
import { Text, View } from "react-native";
import { colors } from "@/theme/colors";

export function EmptyState({ title, body }: { title: string; body?: string }) {
  return <View style={{ padding: 24, alignItems: "center" }}><Text style={{ color: colors.text, fontSize: 18, fontWeight: "800" }}>{title}</Text>{body ? <Text style={{ color: colors.muted, textAlign: "center", marginTop: 8 }}>{body}</Text> : null}</View>;
}
