import React from "react";
import { Pressable, Text, ActivityIndicator, PressableProps } from "react-native";
import { colors } from "@/theme/colors";

type ButtonProps = PressableProps & {
  title: string;
  loading?: boolean;
  variant?: "primary" | "ghost" | "danger" | "soft";
};

export function Button({ title, onPress, loading, variant = "primary", disabled, ...props }: ButtonProps) {
  const isDisabled = disabled || loading;
  const bg = variant === "primary" ? colors.primary : variant === "danger" ? colors.danger : variant === "soft" ? colors.surface2 : "transparent";
  const fg = variant === "primary" ? colors.textDark : colors.text;

  return (
    <Pressable
      {...props}
      onPress={onPress}
      disabled={isDisabled}
      accessibilityRole="button"
      accessibilityState={{ disabled: isDisabled, busy: loading }}
      style={({ pressed }) => [{
        backgroundColor: bg,
        borderColor: colors.border,
        borderWidth: variant === "ghost" ? 1 : 0,
        paddingVertical: 14,
        paddingHorizontal: 18,
        borderRadius: 18,
        alignItems: "center",
        justifyContent: "center",
        transform: [{ scale: pressed ? 0.98 : 1 }],
        opacity: isDisabled ? 0.55 : pressed ? 0.88 : 1
      }]}
    >
      {loading ? <ActivityIndicator color={fg} /> : <Text style={{ color: fg, fontWeight: "900" }}>{title}</Text>}
    </Pressable>
  );
}
