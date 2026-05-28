import { useRouter } from "expo-router";
import { useState } from "react";
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { MetricTile } from "../components/MetricTile";
import { saveDiveLog } from "../storage/diveLogStorage";
import { useDiveSessionStore } from "../state/diveSessionStore";
import { theme } from "../theme/theme";
import { formatDuration, formatMeters, formatTemperature } from "../utils/format";

export function DiveSummaryScreen() {
  const router = useRouter();
  const summary = useDiveSessionStore((state) => state.summary);
  const clearSummary = useDiveSessionStore((state) => state.clearSummary);
  const [saving, setSaving] = useState(false);

  if (!summary) {
    return (
      <SafeAreaView style={styles.safeArea}>
        <View style={styles.centered}>
          <Text style={styles.title}>No completed dive</Text>
          <Pressable style={styles.primaryButton} onPress={() => router.replace("/")}>
            <Text style={styles.primaryButtonText}>Home</Text>
          </Pressable>
        </View>
      </SafeAreaView>
    );
  }

  const { log } = summary;

  async function handleSave() {
    if (!summary) {
      return;
    }

    setSaving(true);
    await saveDiveLog({
      ...summary.log,
      profileName: summary.profileName,
      ascentWarningOccurred: summary.ascentWarningOccurred,
      safetyStopCompleted: summary.safetyStopCompleted
    });
    setSaving(false);
    clearSummary();
    router.replace("/logs");
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.content}>
        <View>
          <Text style={styles.eyebrow}>Dive summary</Text>
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
                { color: summary.ascentWarningOccurred ? theme.colors.coral : theme.colors.green }
              ]}
            >
              {summary.ascentWarningOccurred ? "YES" : "NO"}
            </Text>
          </View>
          <View style={styles.summaryLine}>
            <Text style={styles.summaryLabel}>Safety stop completed</Text>
            <Text
              style={[
                styles.summaryValue,
                { color: summary.safetyStopCompleted ? theme.colors.green : theme.colors.amber }
              ]}
            >
              {summary.safetyStopCompleted ? "YES" : "NO"}
            </Text>
          </View>
        </View>

        <Pressable style={styles.primaryButton} onPress={handleSave} disabled={saving}>
          <Text style={styles.primaryButtonText}>
            {saving ? "Saving" : "Save log"}
          </Text>
        </Pressable>
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
    gap: theme.spacing.lg,
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
    fontSize: 28,
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
  primaryButton: {
    alignItems: "center",
    backgroundColor: theme.colors.cyan,
    borderRadius: theme.radii.md,
    minHeight: 58,
    justifyContent: "center",
    paddingHorizontal: theme.spacing.lg
  },
  primaryButtonText: {
    color: theme.colors.background,
    fontSize: 16,
    fontWeight: "900"
  }
});
