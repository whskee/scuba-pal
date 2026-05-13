import React from "react";
import { TextInput, TextInputProps } from "react-native";
import { colors } from "@/theme/colors";

export function Input(props: TextInputProps) {
  return <TextInput placeholderTextColor={colors.muted} {...props} style={[{ backgroundColor: colors.surface, color: colors.text, borderRadius: 18, padding: 15, borderColor: colors.border, borderWidth: 1, minHeight: props.multiline ? 92 : undefined }, props.style]} />;
}
