import { toast } from "sonner";

export function notifyComingSoon() {
  toast("MAMBONAMI app is coming soon! 🌱", {
    description: "We're putting the finishing touches on it. Leave us your details and we'll let you know the moment it's live.",
    duration: 4500,
  });
}
