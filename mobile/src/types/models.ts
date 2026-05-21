import type {
  CommentView,
  ConversationView,
  MessageView,
  FeedPostView,
  FollowSummaryView,
  NotificationView,
  PostDetailView,
  ProfileResponse,
  UserView
} from "@/api/generated";
import { env } from "@/config/env";
import { normalizeApiDateString } from "@/utils/date";

export type ID = string | number;

const fallbackPostImages = [
  "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1200",
  "https://images.unsplash.com/photo-1518877593221-1f28583780b4?w=1200",
  "https://images.unsplash.com/photo-1580019542155-247062e19ce4?w=1200",
  "https://images.unsplash.com/photo-1682687220063-4742bd7fd538?w=1200"
];

export function fallbackPostImage(id: ID): string {
  const numeric = typeof id === "number" ? id : Number.parseInt(String(id), 10);
  const index = Number.isFinite(numeric) ? Math.abs(numeric) % fallbackPostImages.length : 0;
  return fallbackPostImages[index];
}

function resolveMediaUrl(url?: string | null): string | undefined {
  if (!url?.trim()) return undefined;
  const trimmed = url.trim();
  if (trimmed.startsWith("http://") || trimmed.startsWith("https://") || trimmed.startsWith("file://")) return trimmed;
  const baseUrl = env.apiBaseUrl.replace(/\/+$/, "");
  return `${baseUrl}/${trimmed.replace(/^\/+/, "")}`;
}

export type User = {
  id: ID;
  username: string;
  firstName?: string;
  lastName?: string;
  email?: string;
  phoneNumber?: string;
  city?: string;
  state?: string;
  country?: string;
  profileImageUrl?: string;
  bio?: string;
  diveCount?: number;
  followersCount?: number;
  followingCount?: number;
  followedByMe?: boolean;
};

export type AuthResponse = {
  token?: string;
  accessToken?: string;
  jwt?: string;
  user?: User;
} & Partial<User>;

export type Comment = {
  id: ID;
  userId: ID;
  username: string;
  body: string;
  createdAt: string;
};

export type Post = {
  id: ID;
  author: User;
  content: string;
  imageUrl?: string;
  mediaUrls?: string[];
  createdAt: string;
  likeCount: number;
  commentCount: number;
  likedByMe: boolean;
  comments?: Comment[];
};

export type Notification = {
  id: ID;
  title: string;
  body: string;
  read: boolean;
  createdAt: string;
  type?: string;
};

export type Conversation = {
  id: ID;
  participant: User;
  lastMessage?: string;
  unreadCount: number;
  updatedAt: string;
};

export type Message = {
  id: ID;
  senderId: ID;
  receiverId?: ID;
  body: string;
  createdAt: string;
  readAt?: string | null;
  sentByCurrentUser?: boolean;
};

export type ApiErrorBody = {
  message?: string;
  error?: string;
  detail?: string;
  status?: number;
};

export function toUser(input?: UserView | ProfileResponse | null, follow?: FollowSummaryView): User {
  const profile = input as ProfileResponse | undefined;
  const view = input as UserView | undefined;
  const id = view?.id ?? profile?.userId ?? profile?.profileId ?? 0;
  const username = view?.username ?? profile?.username ?? `diver-${id || "unknown"}`;

  return {
    id,
    username,
    email: view?.email,
    firstName: view?.firstName ?? profile?.firstName,
    lastName: view?.lastName ?? profile?.lastName,
    phoneNumber: profile?.phoneNumber,
    city: view?.city ?? profile?.city,
    state: profile?.state,
    country: view?.country ?? profile?.country,
    profileImageUrl: resolveMediaUrl(view?.profileImageUrl ?? profile?.profileImageUrl),
    bio: view?.bio ?? profile?.bio,
    diveCount: view?.diveCount ?? profile?.diveCount ?? 0,
    followersCount: follow?.followerCount ?? 0,
    followingCount: follow?.followingCount ?? 0,
    followedByMe: follow?.followedByCurrentUser ?? false
  };
}

export function toComment(input?: CommentView | null): Comment {
  return {
    id: input?.commentId ?? `${input?.userId ?? "unknown"}-${input?.createdAt ?? Date.now()}`,
    userId: input?.userId ?? 0,
    username: input?.username ?? "diver",
    body: input?.commentText ?? "",
    createdAt: normalizeApiDateString(input?.createdAt ?? new Date().toISOString())
  };
}

export function toPost(input: FeedPostView | PostDetailView): Post {
  const detail = input as PostDetailView;
  const id = input.postId ?? 0;
  const mediaInput = input as FeedPostView & PostDetailView;
  const imageUrl = resolveMediaUrl(mediaInput.imageUrl ?? mediaInput.mediaUrls?.[0]);
  const mediaUrls = mediaInput.mediaUrls?.map(resolveMediaUrl).filter((url): url is string => !!url);

  return {
    id,
    author: {
      id: input.userId ?? 0,
      username: input.username ?? "diver"
    },
    content: input.caption ?? "",
    imageUrl: imageUrl || fallbackPostImage(id),
    mediaUrls: mediaUrls ?? (imageUrl ? [imageUrl] : []),
    createdAt: normalizeApiDateString(input.createdAt ?? new Date().toISOString()),
    likeCount: input.likes ?? 0,
    commentCount: input.comments ?? detail.commentList?.length ?? 0,
    likedByMe: "likedByCurrentUser" in input ? input.likedByCurrentUser ?? false : false,
    comments: detail.commentList?.map(toComment)
  };
}

export function toConversation(input: ConversationView): Conversation {
  const otherUserId = input.otherUserId ?? 0;
  return {
    id: input.conversationId ?? 0,
    participant: {
      id: otherUserId,
      username: input.otherUsername ?? (input.otherInitial ? `diver-${input.otherInitial}` : "diver")
    },
    lastMessage: input.lastMessagePreview ?? "No messages yet",
    unreadCount: input.unreadCount ?? 0,
    updatedAt: normalizeApiDateString(input.updatedAt ?? new Date().toISOString())
  };
}

export function toMessage(input: MessageView): Message {
  return {
    id: input.messageId ?? `${input.senderUserId ?? "unknown"}-${input.createdAt ?? Date.now()}`,
    senderId: input.senderUserId ?? 0,
    body: input.messageText ?? "",
    createdAt: normalizeApiDateString(input.createdAt ?? new Date().toISOString()),
    readAt: input.readAt ? normalizeApiDateString(input.readAt) : input.readAt,
    sentByCurrentUser: input.sentByCurrentUser
  };
}

export function toNotification(input: NotificationView): Notification {
  return {
    id: input.notificationId ?? 0,
    title: input.title ?? "Notification",
    body: input.message ?? "",
    read: input.read ?? false,
    createdAt: normalizeApiDateString(input.createdAt ?? new Date().toISOString()),
    type: undefined
  };
}
