import React, { useCallback, useEffect, useMemo, useState } from "react";
import { ActivityIndicator, FlatList, Image, Pressable, RefreshControl, Text, View } from "react-native";
import { Ionicons } from "@expo/vector-icons";
import { useQuery } from "@tanstack/react-query";
import { Screen } from "@/components/Screen";
import { Input } from "@/components/Input";
import { EmptyState } from "@/components/EmptyState";
import { colors } from "@/theme/colors";
import { DiveLocation, DiveShop, User } from "@/types/models";
import { useAuthStore } from "@/store/authStore";
import { SearchFilter, searchApi } from "./searchApi";

const FILTERS: Array<{ key: SearchFilter; label: string; icon: keyof typeof Ionicons.glyphMap }> = [
  { key: "profiles", label: "Profiles", icon: "people-outline" },
  { key: "shops", label: "Shops", icon: "storefront-outline" },
  { key: "locations", label: "Locations", icon: "map-outline" }
];

function FilterButton({ filter, active, onPress }: { filter: (typeof FILTERS)[number]; active: boolean; onPress: () => void }) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ selected: active }}
      onPress={onPress}
      style={({ pressed }) => ({
        flex: 1,
        minHeight: 44,
        borderRadius: 18,
        backgroundColor: active ? colors.primary : colors.surface,
        borderWidth: 1,
        borderColor: active ? colors.primary : colors.border,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "row",
        gap: 7,
        paddingHorizontal: 10,
        opacity: pressed ? 0.78 : 1
      })}
    >
      <Ionicons name={filter.icon} size={17} color={active ? colors.textDark : colors.text} />
      <Text style={{ color: active ? colors.textDark : colors.text, fontWeight: "900", fontSize: 12 }} numberOfLines={1}>{filter.label}</Text>
    </Pressable>
  );
}

function UserRow({ user, onPress }: { user: User; onPress: () => void }) {
  const letter = user.username?.[0]?.toUpperCase() ?? "D";
  const displayName = `${user.firstName ?? ""} ${user.lastName ?? ""}`.trim();
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => ({
        padding: 14,
        backgroundColor: colors.surface,
        borderRadius: 26,
        borderWidth: 1,
        borderColor: colors.border,
        marginBottom: 12,
        opacity: pressed ? 0.86 : 1,
        transform: [{ scale: pressed ? 0.99 : 1 }]
      })}
    >
      <View style={{ flexDirection: "row", alignItems: "center", gap: 13 }}>
        {user.profileImageUrl ? (
          <Image source={{ uri: user.profileImageUrl }} style={{ width: 52, height: 52, borderRadius: 26, backgroundColor: colors.surface2 }} />
        ) : (
          <View style={{ width: 52, height: 52, borderRadius: 26, backgroundColor: colors.primary, alignItems: "center", justifyContent: "center" }}>
            <Text style={{ color: colors.textDark, fontWeight: "900", fontSize: 18 }}>{letter}</Text>
          </View>
        )}
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontWeight: "900", fontSize: 16 }} numberOfLines={1}>@{user.username}</Text>
          <Text style={{ color: colors.muted, marginTop: 4 }} numberOfLines={1}>{displayName || user.bio || "Scuba Pal diver"}</Text>
        </View>
        <Ionicons name="chevron-forward" size={18} color={colors.muted} />
      </View>
    </Pressable>
  );
}

function LocationRow({ location }: { location: DiveLocation }) {
  const place = [location.city, location.state, location.country].filter(Boolean).join(", ");
  return (
    <View
      style={{
        padding: 14,
        backgroundColor: colors.surface,
        borderRadius: 26,
        borderWidth: 1,
        borderColor: colors.border,
        marginBottom: 12
      }}
    >
      <View style={{ flexDirection: "row", alignItems: "center", gap: 13 }}>
        {location.imageUrl ? (
          <Image source={{ uri: location.imageUrl }} style={{ width: 64, height: 64, borderRadius: 18, backgroundColor: colors.surface2 }} />
        ) : (
          <View style={{ width: 64, height: 64, borderRadius: 18, backgroundColor: colors.surface2, alignItems: "center", justifyContent: "center" }}>
            <Ionicons name="location" size={24} color={colors.primary} />
          </View>
        )}
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontWeight: "900", fontSize: 16 }} numberOfLines={1}>{location.name}</Text>
          <Text style={{ color: colors.muted, marginTop: 4 }} numberOfLines={1}>{place || location.difficultyLevel || "Dive location"}</Text>
          {location.description ? (
            <Text style={{ color: colors.muted, marginTop: 7, lineHeight: 19 }} numberOfLines={2}>{location.description}</Text>
          ) : null}
        </View>
      </View>
    </View>
  );
}

function ShopRow({ shop }: { shop: DiveShop }) {
  const place = [shop.city, shop.state, shop.country].filter(Boolean).join(", ");
  return (
    <View
      style={{
        padding: 14,
        backgroundColor: colors.surface,
        borderRadius: 26,
        borderWidth: 1,
        borderColor: colors.border,
        marginBottom: 12
      }}
    >
      <View style={{ flexDirection: "row", alignItems: "center", gap: 13 }}>
        {shop.imageUrl ? (
          <Image source={{ uri: shop.imageUrl }} style={{ width: 64, height: 64, borderRadius: 18, backgroundColor: colors.surface2 }} />
        ) : (
          <View style={{ width: 64, height: 64, borderRadius: 18, backgroundColor: colors.surface2, alignItems: "center", justifyContent: "center" }}>
            <Ionicons name="storefront" size={23} color={colors.primary} />
          </View>
        )}
        <View style={{ flex: 1 }}>
          <Text style={{ color: colors.text, fontWeight: "900", fontSize: 16 }} numberOfLines={1}>{shop.name}</Text>
          <Text style={{ color: colors.muted, marginTop: 4 }} numberOfLines={1}>{place || shop.locationName || "Dive shop"}</Text>
          {shop.description ? (
            <Text style={{ color: colors.muted, marginTop: 7, lineHeight: 19 }} numberOfLines={2}>{shop.description}</Text>
          ) : null}
        </View>
      </View>
    </View>
  );
}

export function SearchScreen({ navigation }: any) {
  const [term, setTerm] = useState("");
  const [debouncedTerm, setDebouncedTerm] = useState("");
  const [activeFilter, setActiveFilter] = useState<SearchFilter>("profiles");
  const [refreshing, setRefreshing] = useState(false);
  const currentUser = useAuthStore((s) => s.user);
  const searchKey = useMemo(() => debouncedTerm.trim().toLowerCase(), [debouncedTerm]);
  const query = useQuery<Array<User | DiveLocation | DiveShop>>({
    queryKey: ["search", activeFilter, searchKey],
    queryFn: () => {
      if (activeFilter === "profiles") return searchApi.profiles(searchKey);
      if (activeFilter === "locations") return searchApi.locations(searchKey);
      return searchApi.shops(searchKey);
    },
    staleTime: 60_000,
    refetchOnMount: false,
    refetchOnWindowFocus: false,
    retry: 1
  });

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedTerm(term), 250);
    return () => clearTimeout(timer);
  }, [term]);

  const users = useMemo(
    () => {
      const rawUsers = (activeFilter === "profiles" ? query.data : []) as User[] | undefined;
      return (rawUsers ?? []).filter((user) => {
        if (String(user.id) === String(currentUser?.id)) return false;
        return user.username?.toLowerCase() !== currentUser?.username?.toLowerCase();
      });
    },
    [activeFilter, currentUser?.id, currentUser?.username, query.data]
  );
  const locations = useMemo(() => {
    const rawLocations = (activeFilter === "locations" ? query.data : []) as DiveLocation[] | undefined;
    return rawLocations ?? [];
  }, [activeFilter, query.data]);
  const shops = useMemo(() => {
    const rawShops = (activeFilter === "shops" ? query.data : []) as DiveShop[] | undefined;
    return rawShops ?? [];
  }, [activeFilter, query.data]);

  const refreshSearch = useCallback(async () => {
    setRefreshing(true);
    try {
      await query.refetch();
    } finally {
      setRefreshing(false);
    }
  }, [query]);

  return (
    <Screen scroll={false}>
      <View style={{ marginBottom: 14 }}>
        <Text style={{ color: colors.text, fontSize: 31, fontWeight: "900" }}>Search</Text>
        <Text style={{ color: colors.muted, marginTop: 4 }}>Find profiles, shops, and dive locations</Text>
      </View>

      <View style={{ marginBottom: 14 }}>
        <Input
          placeholder={activeFilter === "locations" ? "Search city, country, or location..." : activeFilter === "shops" ? "Search shop, city, or location..." : "Search username..."}
          autoCapitalize="none"
          value={term}
          onChangeText={setTerm}
          style={{ paddingLeft: 16 }}
        />
      </View>

      <View style={{ flexDirection: "row", gap: 8, marginBottom: 14 }}>
        {FILTERS.map((filter) => (
          <FilterButton
            key={filter.key}
            filter={filter}
            active={activeFilter === filter.key}
            onPress={() => setActiveFilter(filter.key)}
          />
        ))}
      </View>

      {query.isFetching && !refreshing ? <ActivityIndicator color={colors.primary} style={{ marginBottom: 10 }} /> : null}

      {activeFilter === "shops" ? (
        <FlatList
          data={shops}
          keyExtractor={(item) => String(item.id)}
          contentContainerStyle={{ paddingBottom: 120, flexGrow: 1 }}
          keyboardShouldPersistTaps="handled"
          refreshControl={<RefreshControl tintColor={colors.primary} refreshing={refreshing} onRefresh={refreshSearch} />}
          ListEmptyComponent={
            <EmptyState
              title={query.isFetching ? "Searching..." : query.isError ? "Could not load shops" : "No shops found"}
              body={query.isError && query.error instanceof Error ? query.error.message : term.trim() ? "Try a shop name, city, or location." : "Pull to refresh or search by city."}
            />
          }
          renderItem={({ item }) => <ShopRow shop={item} />}
        />
      ) : activeFilter === "locations" ? (
        <FlatList
          data={locations}
          keyExtractor={(item) => String(item.id)}
          contentContainerStyle={{ paddingBottom: 120, flexGrow: 1 }}
          keyboardShouldPersistTaps="handled"
          refreshControl={<RefreshControl tintColor={colors.primary} refreshing={refreshing} onRefresh={refreshSearch} />}
          ListEmptyComponent={
            <EmptyState
              title={query.isFetching ? "Searching..." : query.isError ? "Could not load locations" : "No locations found"}
              body={query.isError && query.error instanceof Error ? query.error.message : term.trim() ? "Try a city, country, or another location name." : "Pull to refresh or search by city."}
            />
          }
          renderItem={({ item }) => <LocationRow location={item} />}
        />
      ) : (
        <FlatList
          data={users}
          keyExtractor={(item) => String(item.id)}
          contentContainerStyle={{ paddingBottom: 120, flexGrow: 1 }}
          keyboardShouldPersistTaps="handled"
          refreshControl={<RefreshControl tintColor={colors.primary} refreshing={refreshing} onRefresh={refreshSearch} />}
          ListEmptyComponent={
            <EmptyState
              title={query.isFetching ? "Searching..." : query.isError ? "Could not load profiles" : "No profiles found"}
              body={query.isError && query.error instanceof Error ? query.error.message : term.trim() ? "Try a different username or name." : "Pull to refresh or start typing to search profiles."}
            />
          }
          renderItem={({ item }) => (
            <UserRow
              user={item}
              onPress={() => navigation.navigate("SearchUserProfile", { userId: item.id, user: item })}
            />
          )}
        />
      )}
    </Screen>
  );
}
