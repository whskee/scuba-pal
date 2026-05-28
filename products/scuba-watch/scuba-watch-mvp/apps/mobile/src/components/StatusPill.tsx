import { StyleSheet, Text, View } from "react-native";
import { theme } from "../theme/theme";

interface StatusPillProps {
  label: string;
  tone?: "ok" | "slow" | "fast" | "neutral";
}

const toneColors = {
  ok: theme.colors.green,
  slow: theme.colors.amber,
  fast: theme.colors.coral,
  neutral: theme.colors.cyan
};

export function StatusPill({ label, tone = "neutral" }: StatusPillProps) {
  const color = toneColors[tone];

  return (
    <View style={[styles.pill, { borderColor: color }]}>
      <Text style={[styles.text, { color }]}>{label}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  pill: {
    alignItems: "center",
    borderRadius: theme.radii.sm,
    borderWidth: 1,
    minHeight: 42,
    justifyContent: "center",
    paddingHorizontal: theme.spacing.md
  },
  text: {
    fontSize: 14,
    fontWeight: "800",
    letterSpacing: 0
  }
});
