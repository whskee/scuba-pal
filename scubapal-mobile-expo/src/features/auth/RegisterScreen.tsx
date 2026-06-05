import React, { useMemo, useState } from "react";
import { Alert, Text } from "react-native";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Screen } from "@/components/Screen";
import { Input } from "@/components/Input";
import { Button } from "@/components/Button";
import { authApi } from "./authApi";
import { useAuthStore } from "@/store/authStore";
import { colors } from "@/theme/colors";

export function RegisterScreen() {
  const [form, setForm] = useState({ username: "", email: "", password: "", firstName: "", lastName: "" });
  const setSession = useAuthStore((s) => s.setSession);
  const qc = useQueryClient();

  const formError = useMemo(() => {
    if (!form.firstName.trim()) return "Enter your first name.";
    if (!form.lastName.trim()) return "Enter your last name.";
    if (!form.username.trim()) return "Enter a username.";
    if (!/^\S+@\S+\.\S+$/.test(form.email.trim())) return "Enter a valid email.";
    if (form.password.length < 6) return "Password must be at least 6 characters.";
    return undefined;
  }, [form]);

  const mutation = useMutation({
    mutationFn: authApi.register,
    onSuccess: async ({ user, token, refreshToken }) => {
      await setSession(user, token, refreshToken);
      qc.removeQueries({ queryKey: ["search"] });
    },
    onError: (error: Error) => Alert.alert("Registration failed", error.message)
  });

  return (
    <Screen>
      <Text style={{ color: colors.text, fontSize: 28, fontWeight: "900" }}>Create your dive profile</Text>
      <Input placeholder="First name" value={form.firstName} onChangeText={(v) => setForm({ ...form, firstName: v })} />
      <Input placeholder="Last name" value={form.lastName} onChangeText={(v) => setForm({ ...form, lastName: v })} />
      <Input placeholder="Username" autoCapitalize="none" autoCorrect={false} value={form.username} onChangeText={(v) => setForm({ ...form, username: v })} />
      <Input placeholder="Email" autoCapitalize="none" autoCorrect={false} keyboardType="email-address" value={form.email} onChangeText={(v) => setForm({ ...form, email: v })} />
      <Input placeholder="Password" secureTextEntry value={form.password} onChangeText={(v) => setForm({ ...form, password: v })} />
      <Button
        title="Create account"
        loading={mutation.isPending}
        disabled={!!formError || mutation.isPending}
        onPress={() => {
          if (formError) return Alert.alert("Missing info", formError);
          mutation.mutate({
            username: form.username.trim(),
            email: form.email.trim(),
            password: form.password,
            firstName: form.firstName.trim(),
            lastName: form.lastName.trim()
          });
        }}
      />
    </Screen>
  );
}
