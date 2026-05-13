import React from "react";
import { Pressable, Text } from "react-native";
import { colors } from "@/theme/colors";

export function FeedPill({ label, active, onPress }: { label: string; active?: boolean; onPress?: () => void }) {
  return (
    <Pressable onPress={onPress} style={({ pressed }) => ({
      paddingHorizontal: 16,
      paddingVertical: 10,
      borderRadius: 999,
      backgroundColor: active ? colors.primary : colors.surface,
      borderWidth: 1,
      borderColor: active ? "transparent" : colors.border,
      opacity: pressed ? 0.75 : 1
    })}>
      <Text style={{ color: active ? colors.textDark : colors.text, fontWeight: "900", fontSize: 13 }}>{label}</Text>
    </Pressable>
  );
}
