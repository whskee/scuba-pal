import { useLocalSearchParams } from "expo-router";
import { useEffect, useState } from "react";
import { ScrollView, StyleSheet, Text, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { DepthChart } from "../components/DepthChart";
import { MetricTile } from "../components/MetricTile";
import { getDiveLog, type StoredDiveLog } from "../storage/diveLogStorage";
import { theme } from "../theme/theme";
import { formatDuration, formatMeters, formatTemperature } from "../utils/format";

export function LogDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const [log, setLog] = useState<StoredDiveLog>();

  useEffect(() => {
    if (id) {
      getDiveLog(id).then(setLog);
    }
  }, [id]);

  if (!log) {
    return (
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.centered}>
          <Text style={styles.emptyText}>Log not found.</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.content}>
        <View>
          <Text style={styles.eyebrow}>Saved dive</Text>
          <Text style={styles.title}>{new Date(log.startedAt).toLocaleString()}</Text>
        </View>

        <View style={styles.metricRow}>
          <MetricTile label="Max depth" value={formatMeters(log.maxDepthMeters)} />
          <MetricTile label="Duration" value={formatDuration(log.durationSeconds)} />
        </View>
        <View style={styles.metricRow}>
          <MetricTile label="Average depth" value={formatMeters(log.averageDepthMeters)} />
          <MetricTile label="Min temp" value={formatTemperature(log.minTemperatureC)} />
        </View>

        <View style={styles.summaryPanel}>
          <View style={styles.summaryLine}>
            <Text style={styles.summaryLabel}>Ascent warning</Text>
            <Text
              style={[
                styles.summaryValue,
                { color: log.ascentWarningOccurred ? theme.colors.coral : theme.colors.green }
              ]}
            >
              {log.ascentWarningOccurred ? "YES" : "NO"}
            </Text>
          </View>
          <View style={styles.summaryLine}>
            <Text style={styles.summaryLabel}>Safety stop completed</Text>
            <Text
              style={[
                styles.summaryValue,
                { color: log.safetyStopCompleted ? theme.colors.green : theme.colors.amber }
              ]}
            >
              {log.safetyStopCompleted ? "YES" : "NO"}
            </Text>
          </View>
        </View>

        <DepthChart samples={log.samples.slice(-160)} maxDepthMeters={log.maxDepthMeters} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: theme.colors.background
  },
  content: {
    gap: theme.spacing.lg,
    padding: theme.spacing.lg
  },
  centered: {
    flex: 1,
    justifyContent: "center",
    padding: theme.spacing.lg
  },
  eyebrow: {
    color: theme.colors.cyan,
    fontSize: 13,
    fontWeight: "900",
    letterSpacing: 0,
    textTransform: "uppercase"
  },
  title: {
    color: theme.colors.text,
    fontSize: 26,
    fontWeight: "900",
    letterSpacing: 0,
    marginTop: theme.spacing.xs
  },
  metricRow: {
    flexDirection: "row",
    gap: theme.spacing.md
  },
  summaryPanel: {
    backgroundColor: theme.colors.panel,
    borderColor: theme.colors.border,
    borderRadius: theme.radii.md,
    borderWidth: 1,
    gap: theme.spacing.md,
    padding: theme.spacing.lg
  },
  summaryLine: {
    alignItems: "center",
    flexDirection: "row",
    justifyContent: "space-between"
  },
  summaryLabel: {
    color: theme.colors.muted,
    flex: 1,
    fontSize: 15,
    fontWeight: "800"
  },
  summaryValue: {
    fontSize: 16,
    fontWeight: "900"
  },
  emptyText: {
    color: theme.colors.muted,
    fontSize: 16
  }
});
