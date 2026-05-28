import { useFocusEffect, useRouter } from "expo-router";
import { useCallback, useState } from "react";
import { ScrollView, StyleSheet, Text } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { DiveLogRow } from "../components/DiveLogRow";
import { getDiveLogs, type StoredDiveLog } from "../storage/diveLogStorage";
import { theme } from "../theme/theme";

export function LogsScreen() {
  const router = useRouter();
  const [logs, setLogs] = useState<StoredDiveLog[]>([]);

  useFocusEffect(
    useCallback(() => {
      let mounted = true;
      getDiveLogs().then((nextLogs) => {
        if (mounted) {
          setLogs(nextLogs);
        }
      });

      return () => {
        mounted = false;
      };
    }, [])
  );

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.title}>Saved logs</Text>
        {logs.map((log) => (
          <DiveLogRow
            key={log.id}
            log={log}
            onPress={() => router.push(`/logs/${log.id}`)}
          />
        ))}
        {logs.length === 0 ? <Text style={styles.emptyText}>No saved dives yet.</Text> : null}
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
    gap: theme.spacing.md,
    padding: theme.spacing.lg
  },
  title: {
    color: theme.colors.text,
    fontSize: 30,
    fontWeight: "900",
    letterSpacing: 0,
    marginBottom: theme.spacing.sm
  },
  emptyText: {
    color: theme.colors.muted,
    fontSize: 15
  }
});
