import type { StoredDiveLog } from "../storage/diveLogStorage";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { theme } from "../theme/theme";
import { formatDuration, formatMeters } from "../utils/format";

interface DiveLogRowProps {
  log: StoredDiveLog;
  onPress: () => void;
}

export function DiveLogRow({ log, onPress }: DiveLogRowProps) {
  return (
    <Pressable style={styles.row} onPress={onPress}>
      <View>
        <Text style={styles.title}>{new Date(log.startedAt).toLocaleDateString()}</Text>
        <Text style={styles.meta}>
          {formatMeters(log.maxDepthMeters)} max / {formatDuration(log.durationSeconds)}
        </Text>
      </View>
      <Text style={styles.chevron}>›</Text>
    </Pressable>
  );
}

const styles = StyleSheet.create({
  row: {
    alignItems: "center",
    backgroundColor: theme.colors.panel,
    borderColor: theme.colors.border,
    borderRadius: theme.radii.md,
    borderWidth: 1,
    flexDirection: "row",
    justifyContent: "space-between",
    minHeight: 72,
    padding: theme.spacing.md
  },
  title: {
    color: theme.colors.text,
    fontSize: 16,
    fontWeight: "800"
  },
  meta: {
    color: theme.colors.muted,
    fontSize: 13,
    marginTop: 4
  },
  chevron: {
    color: theme.colors.cyan,
    fontSize: 28
  }
});
