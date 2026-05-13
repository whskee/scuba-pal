import React, { useState } from "react";
import { Pressable, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Input } from "@/components/Input";
import { Button } from "@/components/Button";
import { colors } from "@/theme/colors";
import { feedApi } from "./feedApi";

export function CreatePostBox() {
  const [content, setContent] = useState("");
  const [open, setOpen] = useState(false);
  const qc = useQueryClient();
  const mutation = useMutation({
    mutationFn: feedApi.create,
    onSuccess: () => { setContent(""); setOpen(false); qc.invalidateQueries({ queryKey: ["feed"] }); }
  });

  if (!open) {
    return (
      <Pressable onPress={() => setOpen(true)} style={({ pressed }) => ({ backgroundColor: colors.surface, borderColor: colors.border, borderWidth: 1, borderRadius: 24, padding: 14, flexDirection: "row", alignItems: "center", gap: 12, opacity: pressed ? 0.85 : 1 })}>
        <View style={{ width: 42, height: 42, borderRadius: 21, backgroundColor: colors.primary, alignItems: "center", justifyContent: "center" }}><Ionicons name="add" size={24} color={colors.textDark} /></View>
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontWeight: "900" }}>Share something from the ocean</Text>
          <Text style={{ color: colors.muted, fontSize: 12, marginTop: 2 }}>Dive log, photo, question, or buddy invite</Text>
        </View>
      </Pressable>
    );
  }

  return (
    <View style={{ gap: 12, backgroundColor: colors.surface, borderRadius: 24, padding: 14, borderWidth: 1, borderColor: colors.border }}>
      <Input placeholder="Share a dive, question, or ocean thought..." multiline value={content} onChangeText={setContent} />
      <View style={{ flexDirection: "row", gap: 10 }}>
        <View style={{ flex: 1 }}><Button title="Cancel" variant="ghost" onPress={() => { setOpen(false); setContent(""); }} /></View>
        <View style={{ flex: 1 }}><Button title="Post" loading={mutation.isPending} onPress={() => content.trim() && mutation.mutate(content.trim())} /></View>
      </View>
    </View>
  );
}
