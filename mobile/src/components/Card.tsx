import React, { ReactNode } from "react";
import { View, ViewStyle } from "react-native";
import { colors } from "@/theme/colors";

export function Card({ children, style }: { children: ReactNode; style?: ViewStyle }) {
  return (
    <View style={[{
      backgroundColor: colors.surface,
      borderRadius: 26,
      padding: 16,
      borderColor: colors.border,
      borderWidth: 1,
      shadowColor: colors.shadow,
      shadowOpacity: 0.22,
      shadowRadius: 18,
      shadowOffset: { width: 0, height: 10 },
      elevation: 5
    }, style]}>{children}</View>
  );
}
