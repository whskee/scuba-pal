import { StyleSheet, Text, View } from "react-native";
import { theme } from "../theme/theme";

interface MetricTileProps {
  label: string;
  value: string;
  accent?: string;
}

export function MetricTile({ label, value, accent = theme.colors.cyan }: MetricTileProps) {
  return (
    <View style={styles.tile}>
      <Text style={styles.label}>{label}</Text>
      <Text style={[styles.value, { color: accent }]} numberOfLines={1}>
        {value}
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  tile: {
    backgroundColor: theme.colors.panel,
    borderColor: theme.colors.border,
    borderRadius: theme.radii.md,
    borderWidth: 1,
    minHeight: 86,
    padding: theme.spacing.md,
    flex: 1,
    justifyContent: "center"
  },
  label: {
    color: theme.colors.muted,
    fontSize: 12,
    fontWeight: "700",
    letterSpacing: 0,
    textTransform: "uppercase"
  },
  value: {
    fontSize: 25,
    fontWeight: "800",
    marginTop: theme.spacing.xs
  }
});
