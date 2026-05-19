import React, { useState } from "react";
import { Alert, Image, Pressable, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import * as ImagePicker from "expo-image-picker";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { Input } from "@/components/Input";
import { Button } from "@/components/Button";
import { colors } from "@/theme/colors";
import { feedApi } from "./feedApi";
import { mediaApi } from "@/features/media/mediaApi";

export function CreatePostBox() {
  const [content, setContent] = useState("");
  const [open, setOpen] = useState(false);
  const [asset, setAsset] = useState<ImagePicker.ImagePickerAsset | null>(null);
  const qc = useQueryClient();
  const mutation = useMutation({
    mutationFn: async () => {
      const upload = asset ? await mediaApi.uploadImageAsset(asset, "POST_IMAGE") : null;
      const uploadedUrl = upload?.publicUrl ?? upload?.objectKey;
      if (upload && !uploadedUrl) {
        throw new Error("The backend uploaded the image but did not return a usable media URL.");
      }
      return feedApi.create({ content: content.trim(), mediaUrls: uploadedUrl ? [uploadedUrl] : [] });
    },
    onSuccess: () => {
      setContent("");
      setAsset(null);
      setOpen(false);
      qc.invalidateQueries({ queryKey: ["feed"] });
    },
    onError: (error: any) => Alert.alert("Could not create post", error?.message ?? "Try again.")
  });

  const pickImage = async () => {
    const permission = await ImagePicker.requestMediaLibraryPermissionsAsync();
    if (!permission.granted) {
      Alert.alert("Photo access needed", "Allow photo library access to attach a dive photo.");
      return;
    }
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ["images"],
      allowsEditing: true,
      quality: 0.86
    });
    if (!result.canceled) {
      setAsset(result.assets[0]);
    }
  };

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
      {asset ? (
        <View style={{ borderRadius: 20, overflow: "hidden", borderWidth: 1, borderColor: colors.border, backgroundColor: colors.surface2 }}>
          <Image source={{ uri: asset.uri }} style={{ width: "100%", height: 210 }} resizeMode="cover" />
          <Pressable onPress={() => setAsset(null)} style={{ position: "absolute", top: 10, right: 10, width: 36, height: 36, borderRadius: 18, backgroundColor: "rgba(7,17,31,0.76)", alignItems: "center", justifyContent: "center" }}>
            <Ionicons name="close" size={20} color={colors.text} />
          </Pressable>
        </View>
      ) : null}
      <Pressable onPress={pickImage} disabled={mutation.isPending} style={({ pressed }) => ({ borderColor: colors.border, borderWidth: 1, borderRadius: 18, padding: 13, flexDirection: "row", alignItems: "center", justifyContent: "center", gap: 8, opacity: pressed ? 0.75 : 1 })}>
        <Ionicons name="image-outline" size={20} color={colors.primary} />
        <Text style={{ color: colors.text, fontWeight: "900" }}>{asset ? "Change photo" : "Add photo"}</Text>
      </Pressable>
      <View style={{ flexDirection: "row", gap: 10 }}>
        <View style={{ flex: 1 }}><Button title="Cancel" variant="ghost" onPress={() => { setOpen(false); setContent(""); setAsset(null); }} /></View>
        <View style={{ flex: 1 }}><Button title={asset ? "Upload & post" : "Post"} loading={mutation.isPending} disabled={!content.trim()} onPress={() => content.trim() && mutation.mutate()} /></View>
      </View>
    </View>
  );
}
