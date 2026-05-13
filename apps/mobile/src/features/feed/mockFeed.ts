import { Post } from "@/types/models";

export const guestFeed: Post[] = [
  {
    id: "guest-1",
    author: { id: "u1", username: "reef.ranger", profileImageUrl: "https://images.unsplash.com/photo-1530541930197-ff16ac917b0e?w=200" },
    content: "Blue hour at the reef. Visibility was unreal and the current stayed gentle all morning.",
    imageUrl: "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900",
    createdAt: new Date().toISOString(),
    likeCount: 248,
    commentCount: 31,
    likedByMe: false
  },
  {
    id: "guest-2",
    author: { id: "u2", username: "nitrox_nomad", profileImageUrl: "https://images.unsplash.com/photo-1502685104226-ee32379fefbe?w=200" },
    content: "Quick tip: always do a relaxed buddy check before the boat gets loud.",
    imageUrl: "https://images.unsplash.com/photo-1682687220063-4742bd7fd538?w=900",
    createdAt: new Date().toISOString(),
    likeCount: 98,
    commentCount: 12,
    likedByMe: true
  },
  {
    id: "guest-3",
    author: { id: "u3", username: "kelp.collective", profileImageUrl: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200" },
    content: "Looking for dive buddies for a weekend shore dive. Beginner-friendly pace.",
    imageUrl: "https://images.unsplash.com/photo-1518877593221-1f28583780b4?w=900",
    createdAt: new Date().toISOString(),
    likeCount: 176,
    commentCount: 44,
    likedByMe: false
  },
  {
    id: "guest-4",
    author: { id: "u4", username: "deep.stop", profileImageUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200" },
    content: "Which dive computer are you using in 2026? I want something clean, rugged, and not ugly.",
    imageUrl: "https://images.unsplash.com/photo-1580019542155-247062e19ce4?w=900",
    createdAt: new Date().toISOString(),
    likeCount: 313,
    commentCount: 87,
    likedByMe: false
  }
];
