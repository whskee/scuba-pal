import React, { useMemo, useState } from "react";
import { Text, View, Pressable, Alert } from "react-native";
import { useMutation } from "@tanstack/react-query";
import { Screen } from "@/components/Screen";
import { Input } from "@/components/Input";
import { Button } from "@/components/Button";
import { authApi } from "./authApi";
import { useAuthStore } from "@/store/authStore";
import { colors } from "@/theme/colors";

export function LoginScreen({ navigation }: any) {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const setSession = useAuthStore((s) => s.setSession);

  const formError = useMemo(() => {
    if (!username.trim()) return "Enter your username.";
    if (!password) return "Enter your password.";
    return undefined;
  }, [username, password]);

  const mutation = useMutation({
    mutationFn: authApi.login,
    onSuccess: async ({ user, token }) => setSession(user, token),
    onError: (error: Error) => Alert.alert("Login failed", error.message)
  });

  return (
    <Screen style={{ justifyContent: "center", flexGrow: 1 }}>
      <Text style={{ color: colors.text, fontSize: 36, fontWeight: "900" }}>Scuba Pal</Text>
      <Text style={{ color: colors.muted, fontSize: 16, marginBottom: 18 }}>Dive logs, ocean friends, messages, and scuba learning in one place.</Text>
      <Input placeholder="Username" autoCapitalize="none" autoCorrect={false} value={username} onChangeText={setUsername} />
      <Input placeholder="Password" secureTextEntry value={password} onChangeText={setPassword} />
      <Button
        title="Log in"
        loading={mutation.isPending}
        disabled={!!formError || mutation.isPending}
        onPress={() => {
          if (formError) return Alert.alert("Missing info", formError);
          mutation.mutate({ username: username.trim(), password });
        }}
      />
      <View style={{ flexDirection: "row", justifyContent: "center", gap: 6 }}>
        <Text style={{ color: colors.muted }}>New here?</Text>
        <Pressable onPress={() => navigation.navigate("Register")}><Text style={{ color: colors.primary, fontWeight: "800" }}>Create account</Text></Pressable>
      </View>
    </Screen>
  );
}
