import React, { ReactNode } from "react";
import { ScrollView, ViewStyle } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { colors } from "@/theme/colors";

export function Screen({ children, scroll = true, style }: { children: ReactNode; scroll?: boolean; style?: ViewStyle }) {
  if (!scroll) {
    return <SafeAreaView style={[{ flex: 1, backgroundColor: colors.background, padding: 18 }, style]}>{children}</SafeAreaView>;
  }

  return (
    <SafeAreaView style={{ flex: 1, backgroundColor: colors.background }}>
      <ScrollView showsVerticalScrollIndicator={false} contentContainerStyle={[{ padding: 18, gap: 16, paddingBottom: 120 }, style]}>{children}</ScrollView>
    </SafeAreaView>
  );
}
