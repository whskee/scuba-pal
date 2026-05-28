import { getFakeDiveProfiles, type FakeDiveProfileName } from "@scuba-watch/dive-core";
import { useFocusEffect, useRouter } from "expo-router";
import { useCallback, useState } from "react";
import {
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  View
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { DiveLogRow } from "../components/DiveLogRow";
import { getDiveLogs, type StoredDiveLog } from "../storage/diveLogStorage";
import { useDiveSessionStore } from "../state/diveSessionStore";
import { theme } from "../theme/theme";

const profiles = getFakeDiveProfiles();

export function HomeScreen() {
  const router = useRouter();
  const startProfile = useDiveSessionStore((state) => state.startProfile);
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

  function handleStart(profileName: FakeDiveProfileName) {
    startProfile(profileName);
    router.push("/live");
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.header}>
          <Text style={styles.eyebrow}>Dive logger prototype</Text>
          <Text style={styles.title}>Scuba Watch MVP</Text>
        </View>

        <View style={styles.profileGrid}>
          {profiles.map((profile) => (
            <Pressable
              key={profile.name}
              style={styles.profileCard}
              onPress={() => handleStart(profile.name)}
            >
              <Text style={styles.profileTitle}>{profile.label}</Text>
              <Text style={styles.profileDescription}>{profile.description}</Text>
            </Pressable>
          ))}
        </View>

        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Saved logs</Text>
          <Pressable style={styles.textButton} onPress={() => router.push("/logs")}>
            <Text style={styles.textButtonLabel}>View all</Text>
          </Pressable>
        </View>

        <View style={styles.logList}>
          {logs.slice(0, 3).map((log) => (
            <DiveLogRow
              key={log.id}
              log={log}
              onPress={() => router.push(`/logs/${log.id}`)}
            />
          ))}
          {logs.length === 0 ? (
            <Text style={styles.emptyText}>No saved dives yet.</Text>
          ) : null}
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
  header: {
    gap: theme.spacing.xs,
    paddingTop: theme.spacing.sm
  },
  eyebrow: {
    color: theme.colors.cyan,
    fontSize: 13,
    fontWeight: "800",
    letterSpacing: 0,
    textTransform: "uppercase"
  },
  title: {
    color: theme.colors.text,
    fontSize: 36,
    fontWeight: "900",
    letterSpacing: 0
  },
  profileGrid: {
    gap: theme.spacing.md
  },
  profileCard: {
    backgroundColor: theme.colors.panel,
    borderColor: theme.colors.border,
    borderRadius: theme.radii.md,
    borderWidth: 1,
    minHeight: 104,
    padding: theme.spacing.lg
  },
  profileTitle: {
    color: theme.colors.text,
    fontSize: 19,
    fontWeight: "900"
  },
  profileDescription: {
    color: theme.colors.muted,
    fontSize: 14,
    lineHeight: 20,
    marginTop: theme.spacing.xs
  },
  sectionHeader: {
    alignItems: "center",
    flexDirection: "row",
    justifyContent: "space-between"
  },
  sectionTitle: {
    color: theme.colors.text,
    fontSize: 20,
    fontWeight: "900"
  },
  textButton: {
    minHeight: 44,
    justifyContent: "center"
  },
  textButtonLabel: {
    color: theme.colors.cyan,
    fontSize: 15,
    fontWeight: "800"
  },
  logList: {
    gap: theme.spacing.sm
  },
  emptyText: {
    color: theme.colors.muted,
    fontSize: 15
  }
});
