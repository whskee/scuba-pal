import React, { useEffect } from "react";
import { ActivityIndicator, Text, View } from "react-native";
import { getFocusedRouteNameFromRoute } from "@react-navigation/native";
import { createNativeStackNavigator } from "@react-navigation/native-stack";
import { createBottomTabNavigator } from "@react-navigation/bottom-tabs";
import { Ionicons } from "@expo/vector-icons";
import { useQuery } from "@tanstack/react-query";
import { colors } from "@/theme/colors";
import { useAuthStore } from "@/store/authStore";
import { LoginScreen } from "@/features/auth/LoginScreen";
import { RegisterScreen } from "@/features/auth/RegisterScreen";
import { FeedScreen } from "@/features/feed/FeedScreen";
import { PostDetailScreen } from "@/features/feed/PostDetailScreen";
import { ConversationsScreen } from "@/features/messaging/ConversationsScreen";
import { ThreadScreen } from "@/features/messaging/ThreadScreen";
import { NotificationsScreen } from "@/features/notifications/NotificationsScreen";
import { ProfileScreen } from "@/features/profile/ProfileScreen";
import { ProfileConnectionsScreen } from "@/features/profile/ProfileConnectionsScreen";
import { ProfileDivesScreen } from "@/features/profile/ProfileDivesScreen";
import { LearnScreen } from "@/features/learn/LearnScreen";
import { SearchScreen } from "@/features/search/SearchScreen";
import { notificationsApi } from "@/features/notifications/notificationsApi";

const Stack = createNativeStackNavigator();
const Tabs = createBottomTabNavigator();

const tabBarStyle = {
  position: "absolute" as const,
  left: 18,
  right: 18,
  bottom: 18,
  height: 72,
  paddingTop: 10,
  paddingBottom: 12,
  borderRadius: 28,
  backgroundColor: "rgba(15,36,55,0.96)",
  borderTopWidth: 0,
  borderColor: colors.border,
  borderWidth: 1,
  shadowColor: colors.shadow,
  shadowOpacity: 0.3,
  shadowRadius: 20,
  shadowOffset: { width: 0, height: 10 },
  elevation: 8
};

function shouldHideTabBar(tabName: string, route: any) {
  const focusedRoute = getFocusedRouteNameFromRoute(route);
  return (tabName === "Feed" && focusedRoute === "PostDetail") || (tabName === "Messages" && focusedRoute === "Thread");
}

function FeedStack() {
  return (
    <Stack.Navigator screenOptions={{ headerStyle: { backgroundColor: colors.background }, headerTintColor: colors.text, headerShadowVisible: false }}>
      <Stack.Screen name="FeedHome" component={FeedScreen} options={{ headerShown: false }} />
      <Stack.Screen name="PostDetail" component={PostDetailScreen} options={{ headerShown: false }} />
    </Stack.Navigator>
  );
}

function MessagesStack() {
  return (
    <Stack.Navigator screenOptions={{ headerStyle: { backgroundColor: colors.background }, headerTintColor: colors.text, headerShadowVisible: false }}>
      <Stack.Screen name="Conversations" component={ConversationsScreen} options={{ headerShown: false }} />
      <Stack.Screen name="Thread" component={ThreadScreen} options={{ headerShown: false }} />
    </Stack.Navigator>
  );
}

function SearchStack() {
  return (
    <Stack.Navigator screenOptions={{ headerStyle: { backgroundColor: colors.background }, headerTintColor: colors.text, headerShadowVisible: false }}>
      <Stack.Screen name="SearchHome" component={SearchScreen} options={{ headerShown: false }} />
      <Stack.Screen name="SearchUserProfile" component={ProfileScreen} options={{ headerShown: false }} />
      <Stack.Screen name="ProfileConnections" component={ProfileConnectionsScreen} options={{ title: "Connections" }} />
      <Stack.Screen name="ProfileDives" component={ProfileDivesScreen} options={{ title: "Dives" }} />
    </Stack.Navigator>
  );
}

function ProfileStack() {
  return (
    <Stack.Navigator screenOptions={{ headerStyle: { backgroundColor: colors.background }, headerTintColor: colors.text, headerShadowVisible: false }}>
      <Stack.Screen name="Me" component={ProfileScreen} options={{ headerShown: false }} />
      <Stack.Screen name="UserProfile" component={ProfileScreen} options={{ headerShown: false }} />
      <Stack.Screen name="ProfileConnections" component={ProfileConnectionsScreen} options={{ title: "Connections" }} />
      <Stack.Screen name="ProfileDives" component={ProfileDivesScreen} options={{ title: "Dives" }} />
    </Stack.Navigator>
  );
}

function AppTabs() {
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  const unread = useQuery({ queryKey: ["unreadNotifications"], queryFn: notificationsApi.unreadCount, enabled: isAuthenticated, refetchInterval: 30000, retry: 1 });
  return (
    <Tabs.Navigator screenOptions={({ route }) => ({
      headerShown: false,
      tabBarStyle: shouldHideTabBar(route.name, route) ? { display: "none" } : tabBarStyle,
      tabBarLabelStyle: { fontSize: 11, fontWeight: "900" },
      tabBarActiveTintColor: colors.primary,
      tabBarInactiveTintColor: colors.muted,
      tabBarIcon: ({ color, size, focused }) => {
        const map: Record<string, keyof typeof Ionicons.glyphMap> = { Feed: focused ? "grid" : "grid-outline", Search: focused ? "search" : "search-outline", Messages: focused ? "chatbubbles" : "chatbubbles-outline", Notifications: focused ? "notifications" : "notifications-outline", ProfileStack: focused ? "person-circle" : "person-circle-outline" };
        return <Ionicons name={map[route.name] ?? "ellipse"} color={color} size={size} />;
      }
    })}>
      <Tabs.Screen name="Feed" component={FeedStack} />
      <Tabs.Screen name="Search" component={SearchStack} />
      <Tabs.Screen name="Messages" component={MessagesStack} />
      <Tabs.Screen name="Notifications" component={NotificationsScreen} options={{ tabBarBadge: unread.data?.count ? unread.data.count : undefined }} />
      <Tabs.Screen name="ProfileStack" component={ProfileStack} options={{ title: "Profile" }} />
    </Tabs.Navigator>
  );
}

export function RootNavigator() {
  const restore = useAuthStore((s) => s.restore);
  const hydrated = useAuthStore((s) => s.hydrated);
  const isAuthenticated = useAuthStore((s) => s.isAuthenticated);
  useEffect(() => { restore(); }, [restore]);
  if (!hydrated) return <View style={{ flex: 1, backgroundColor: colors.background, alignItems: "center", justifyContent: "center" }}><ActivityIndicator color={colors.primary} /><Text style={{ color: colors.muted, marginTop: 12 }}>Loading Scuba Pal...</Text></View>;
  return (
    <Stack.Navigator screenOptions={{ headerStyle: { backgroundColor: colors.background }, headerTintColor: colors.text, headerShadowVisible: false }}>
      {isAuthenticated ? <>
        <Stack.Screen name="AppTabs" component={AppTabs} options={{ headerShown: false }} />
        <Stack.Screen name="Learn" component={LearnScreen} options={{ title: "Learn" }} />
      </> : <>
        <Stack.Screen name="Login" component={LoginScreen} options={{ headerShown: false }} />
        <Stack.Screen name="Register" component={RegisterScreen} options={{ title: "Create account" }} />
      </>}
    </Stack.Navigator>
  );
}
