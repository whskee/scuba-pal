import AsyncStorage from "@react-native-async-storage/async-storage";
import type { DiveLog, FakeDiveProfileName } from "@scuba-watch/dive-core";

const STORAGE_KEY = "scuba-watch-mvp:dive-logs";

export interface StoredDiveLog extends DiveLog {
  profileName?: FakeDiveProfileName;
  ascentWarningOccurred: boolean;
  safetyStopCompleted: boolean;
}

export async function getDiveLogs(): Promise<StoredDiveLog[]> {
  const raw = await AsyncStorage.getItem(STORAGE_KEY);

  if (!raw) {
    return [];
  }

  const parsed = JSON.parse(raw) as StoredDiveLog[];
  return parsed.sort((a, b) => b.startedAt - a.startedAt);
}

export async function saveDiveLog(log: StoredDiveLog): Promise<void> {
  const logs = await getDiveLogs();
  const nextLogs = [log, ...logs.filter((candidate) => candidate.id !== log.id)];
  await AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(nextLogs));
}

export async function getDiveLog(id: string): Promise<StoredDiveLog | undefined> {
  const logs = await getDiveLogs();
  return logs.find((log) => log.id === id);
}
