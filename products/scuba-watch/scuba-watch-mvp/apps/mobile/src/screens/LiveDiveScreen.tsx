import { useRouter } from "expo-router";
import { useEffect } from "react";
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { DepthChart } from "../components/DepthChart";
import { MetricTile } from "../components/MetricTile";
import { StatusPill } from "../components/StatusPill";
import { useDiveSessionStore } from "../state/diveSessionStore";
import { theme } from "../theme/theme";
import { formatDuration, formatMeters, formatTemperature } from "../utils/format";

const SIMULATION_TICK_MS = 100;

function labelForState(state: string): string {
  return state.replace("_", " ");
}

function ascentTone(status?: string): "ok" | "slow" | "fast" {
  if (status === "FAST") {
    return "fast";
  }
  if (status === "SLOW") {
    return "slow";
  }
  return "ok";
}

export function LiveDiveScreen() {
  const router = useRouter();
  const metrics = useDiveSessionStore((state) => state.metrics);
  const visibleSamples = useDiveSessionStore((state) => state.visibleSamples);
  const running = useDiveSessionStore((state) => state.running);
  const summary = useDiveSessionStore((state) => state.summary);
  const tick = useDiveSessionStore((state) => state.tick);
  const pause = useDiveSessionStore((state) => state.pause);
  const resume = useDiveSessionStore((state) => state.resume);
  const endSimulation = useDiveSessionStore((state) => state.endSimulation);

  useEffect(() => {
    if (!running) {
      return;
    }

    const timer = setInterval(tick, SIMULATION_TICK_MS);
    return () => clearInterval(timer);
  }, [running, tick]);

  useEffect(() => {
    if (summary) {
      router.replace("/summary");
    }
  }, [router, summary]);

  if (!metrics) {
    return null;
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.watchFace}>
          <Text style={styles.state}>{labelForState(metrics.state)}</Text>
          <Text style={styles.depth}>{metrics.currentDepthMeters.toFixed(1)}</Text>
          <Text style={styles.depthUnit}>meters</Text>
          <View style={styles.statusRow}>
            <StatusPill label={metrics.ascentStatus} tone={ascentTone(metrics.ascentStatus)} />
            <StatusPill label={running ? "RUNNING" : "PAUSED"} tone="neutral" />
          </View>
        </View>

        <View style={styles.metricRow}>
          <MetricTile label="Dive time" value={formatDuration(metrics.diveTimeSeconds)} />
          <MetricTile label="Max depth" value={formatMeters(metrics.maxDepthMeters)} />
        </View>
        <View style={styles.metricRow}>
          <MetricTile label="Water temp" value={formatTemperature(metrics.temperatureC)} />
          <MetricTile
            label="Ascent rate"
            value={`${metrics.ascentRateMetersPerMinute.toFixed(1)} m/min`}
            accent={
              metrics.ascentStatus === "FAST"
                ? theme.colors.coral
                : metrics.ascentStatus === "SLOW"
                  ? theme.colors.amber
                  : theme.colors.green
            }
          />
        </View>

        {metrics.safetyStopRequired ? (
          <View style={styles.safetyPanel}>
            <Text style={styles.safetyLabel}>Safety stop</Text>
            <Text style={styles.safetyTime}>
              {formatDuration(metrics.safetyStopSecondsRemaining)}
            </Text>
          </View>
        ) : null}

        <DepthChart
          samples={visibleSamples}
          maxDepthMeters={metrics.maxDepthMeters}
        />

        <View style={styles.controls}>
          <Pressable
            style={styles.secondaryButton}
            onPress={running ? pause : resume}
          >
            <Text style={styles.secondaryButtonText}>
              {running ? "Pause" : "Resume"}
            </Text>
          </Pressable>
          <Pressable style={styles.endButton} onPress={endSimulation}>
            <Text style={styles.endButtonText}>End</Text>
          </Pressable>
        </View>
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
  watchFace: {
    alignItems: "center",
    backgroundColor: "#081A24",
    borderColor: theme.colors.border,
    borderRadius: theme.radii.md,
    borderWidth: 1,
    minHeight: 260,
    justifyContent: "center",
    padding: theme.spacing.lg
  },
  state: {
    color: theme.colors.cyan,
    fontSize: 14,
    fontWeight: "900",
    letterSpacing: 0,
    textTransform: "uppercase"
  },
  depth: {
    color: theme.colors.text,
    fontSize: 92,
    fontWeight: "900",
    letterSpacing: 0,
    lineHeight: 104,
    marginTop: theme.spacing.sm
  },
  depthUnit: {
    color: theme.colors.muted,
    fontSize: 16,
    fontWeight: "800",
    marginBottom: theme.spacing.md,
    textTransform: "uppercase"
  },
  statusRow: {
    flexDirection: "row",
    gap: theme.spacing.sm
  },
  metricRow: {
    flexDirection: "row",
    gap: theme.spacing.md
  },
  safetyPanel: {
    alignItems: "center",
    backgroundColor: theme.colors.panelRaised,
    borderColor: theme.colors.blue,
    borderRadius: theme.radii.md,
    borderWidth: 1,
    minHeight: 112,
    justifyContent: "center",
    padding: theme.spacing.md
  },
  safetyLabel: {
    color: theme.colors.muted,
    fontSize: 13,
    fontWeight: "800",
    letterSpacing: 0,
    textTransform: "uppercase"
  },
  safetyTime: {
    color: theme.colors.amber,
    fontSize: 42,
    fontWeight: "900",
    marginTop: theme.spacing.xs
  },
  controls: {
    flexDirection: "row",
    gap: theme.spacing.md
  },
  secondaryButton: {
    alignItems: "center",
    backgroundColor: theme.colors.panelRaised,
    borderRadius: theme.radii.md,
    flex: 1,
    minHeight: 56,
    justifyContent: "center"
  },
  secondaryButtonText: {
    color: theme.colors.text,
    fontSize: 16,
    fontWeight: "900"
  },
  endButton: {
    alignItems: "center",
    backgroundColor: theme.colors.coral,
    borderRadius: theme.radii.md,
    flex: 1,
    minHeight: 56,
    justifyContent: "center"
  },
  endButtonText: {
    color: theme.colors.background,
    fontSize: 16,
    fontWeight: "900"
  }
});
