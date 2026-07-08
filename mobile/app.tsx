import { useState, useEffect } from "react";
import {
  AreaChart, Area, BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
} from "recharts";
import {
  ArrowLeft, Eye, EyeOff, Bell, Search, Star, MapPin, ChevronRight, Plus, TrendingUp,
  Package, Wallet, User, Home, BarChart2, Heart, CheckCircle2, Clock, Zap, Navigation,
  Phone, Mail, Shield, Camera, Upload, ChevronDown, AlertCircle, Truck, Store,
  ShoppingCart, ShoppingBag, Leaf, ToggleLeft, ToggleRight, Thermometer, Droplets,
  Wind, Settings, HelpCircle, LogOut, Edit2, Trash2, Image, FileText,
  MessageCircle, ChevronUp, Check, X, CreditCard, Banknote, Copy, Info,
  Filter, SortAsc, MoreVertical, Send, RefreshCw, AlertTriangle,
} from "lucide-react";

import logoImg from "@/imports/logo.png";
import farmerIconImg from "@/imports/farmer_icon.png";
import buyerIconImg from "@/imports/buyer_icon.png";
import transportIconImg from "@/imports/transport_icon.png";
import securePaymentImg from "@/imports/secure_payment_icon.png";

// ─── Types ───────────────────────────────────────────────────────────────────

type Role = "farmer" | "buyer" | "transport" | "retailer";

type Screen =
  | "splash" | "welcome" | "login" | "forgot-password" | "otp"
  | "role-select"
  | "profile-farmer" | "profile-buyer" | "profile-transport" | "profile-retailer"
  | "success"
  // Farmer
  | "dash-farmer" | "farmer-products" | "farmer-product-create"
  | "farmer-orders" | "farmer-order-detail" | "farmer-earnings"
  // Buyer
  | "dash-buyer" | "buyer-catalog" | "buyer-product-detail"
  | "buyer-cart" | "buyer-checkout" | "buyer-order-tracking" | "buyer-order-history" | "buyer-dispute"
  // Transport
  | "dash-transport" | "transport-available" | "transport-delivery-otp" | "transport-trips"
  // Retailer
  | "dash-retailer"
  // Common
  | "notifications" | "profile" | "settings" | "support";

// ─── Brand ───────────────────────────────────────────────────────────────────

const G = {
  primary: "#1B7F3B",
  secondary: "#2FA84F",
  gold: "#D4AF37",
  bg: "#F7FAF7",
  muted: "#5A7A63",
  light: "#E8F2EB",
  error: "#EF4444",
  warning: "#F59E0B",
  success: "#22C55E",
  dark: "#0F1F15",
  purple: "#6D28D9",
};

const font = "'Inter', sans-serif";
const headFont = "'Fraunces', serif";

// ─── Primitives ───────────────────────────────────────────────────────────────

function PhoneFrame({ children, dark = false }: { children: React.ReactNode; dark?: boolean }) {
  return (
    <div className="min-h-screen flex items-center justify-center p-4" style={{ background: dark ? "#060E08" : "linear-gradient(160deg,#0d3d20 0%,#1B7F3B 100%)", fontFamily: font }}>
      <div className="w-full max-w-[390px] min-h-[820px] rounded-[40px] overflow-hidden shadow-2xl relative flex flex-col" style={{ background: G.bg, boxShadow: "0 40px 80px rgba(0,0,0,0.45)" }}>
        <div className="flex justify-between items-center px-8 pt-3 pb-1 text-[11px] font-semibold" style={{ color: "inherit" }}>
          <span>9:41</span>
          <div className="flex gap-1 items-center">
            <div className="flex gap-0.5 items-end">{[3,4,4,3].map((h,i)=><div key={i} className="w-1 rounded-sm bg-current" style={{height:h*2+"px",opacity:i<3?1:0.4}}/>)}</div>
            <span className="ml-1">100%</span>
          </div>
        </div>
        <div className="flex-1 overflow-y-auto" style={{ scrollbarWidth: "none" }}>{children}</div>
      </div>
    </div>
  );
}

function BackBtn({ onClick, light = false }: { onClick: () => void; light?: boolean }) {
  return (
    <button onClick={onClick} className="w-10 h-10 rounded-2xl flex items-center justify-center flex-shrink-0" style={{ background: light ? "rgba(255,255,255,0.2)" : G.light }}>
      <ArrowLeft size={20} color={light ? "white" : G.primary} />
    </button>
  );
}

function PrimaryBtn({ label, onClick, variant = "primary", full = true, small = false, icon }: {
  label: string; onClick: () => void;
  variant?: "primary" | "outline" | "ghost" | "gold" | "danger" | "white";
  full?: boolean; small?: boolean; icon?: React.ReactNode;
}) {
  const sz = small ? "px-4 py-2.5 text-[13px]" : "px-6 py-3.5 text-[15px]";
  const base = `${full ? "w-full" : ""} ${sz} rounded-2xl font-bold transition-all active:scale-95 cursor-pointer flex items-center justify-center gap-2`;
  const styles: Record<string, React.CSSProperties> = {
    primary: { background: `linear-gradient(135deg,${G.secondary},${G.primary})`, color: "white", boxShadow: "0 4px 15px rgba(27,127,59,0.35)" },
    outline: { border: `2px solid ${G.primary}`, color: G.primary, background: "transparent" },
    ghost: { color: G.primary, background: "transparent" },
    gold: { background: `linear-gradient(135deg,#E8C547,${G.gold})`, color: "white", boxShadow: "0 4px 15px rgba(212,175,55,0.35)" },
    danger: { background: G.error, color: "white" },
    white: { background: "white", color: G.primary, boxShadow: "0 2px 12px rgba(0,0,0,0.12)" },
  };
  return <button className={base} style={styles[variant]} onClick={onClick}>{icon}{label}</button>;
}

function AppInput({ label, type = "text", placeholder, icon, hint }: { label?: string; type?: string; placeholder?: string; icon?: React.ReactNode; hint?: string }) {
  return (
    <div className="flex flex-col gap-1.5">
      {label && <label className="text-[13px] font-semibold" style={{ color: G.primary }}>{label}</label>}
      <div className="relative">
        {icon && <div className="absolute left-3.5 top-1/2 -translate-y-1/2">{icon}</div>}
        <input type={type} placeholder={placeholder} style={{ width: "100%", borderRadius: 16, border: `1.5px solid rgba(27,127,59,0.2)`, padding: `13px 16px 13px ${icon ? "44px" : "16px"}`, background: "white", fontFamily: font, fontSize: 14, outline: "none", color: G.dark }} />
      </div>
      {hint && <p className="text-[11px]" style={{ color: G.muted }}>{hint}</p>}
    </div>
  );
}

function Chip({ label, active = false, color = G.primary }: { label: string; active?: boolean; color?: string }) {
  return <span className="px-3 py-1.5 rounded-full text-[11px] font-semibold whitespace-nowrap" style={{ background: active ? color : G.light, color: active ? "white" : color }}>{label}</span>;
}

function SectionHeader({ title, action, onAction }: { title: string; action?: string; onAction?: () => void }) {
  return (
    <div className="flex justify-between items-center mb-3">
      <h3 className="font-bold text-[13px]" style={{ color: G.dark }}>{title}</h3>
      {action && <span className="text-[11px] font-semibold cursor-pointer" style={{ color: G.secondary }} onClick={onAction}>{action}</span>}
    </div>
  );
}

function StatusBadge({ label, color }: { label: string; color: string }) {
  return <span className="px-2.5 py-1 rounded-lg text-[10px] font-bold" style={{ background: color + "18", color }}>{label}</span>;
}

function BottomNav({ items, active, setActive }: { items: { icon: React.ReactNode; label: string }[]; active: number; setActive: (i: number) => void }) {
  return (
    <div className="sticky bottom-0 bg-white flex justify-around py-2 px-2" style={{ borderTop: `1px solid rgba(27,127,59,0.1)`, boxShadow: "0 -4px 20px rgba(0,0,0,0.06)" }}>
      {items.map((item, i) => (
        <button key={i} onClick={() => setActive(i)} className="flex flex-col items-center gap-0.5 px-3 py-1.5 rounded-xl transition-all" style={{ color: i === active ? G.primary : G.muted }}>
          <div style={{ transform: i === active ? "scale(1.1)" : "scale(1)", transition: "transform 0.2s" }}>{item.icon}</div>
          <span className="text-[10px] font-semibold">{item.label}</span>
        </button>
      ))}
    </div>
  );
}

function GradientHeader({ children, colors = [G.primary, G.secondary] }: { children: React.ReactNode; colors?: string[] }) {
  return (
    <div className="relative overflow-hidden px-5 pt-4 pb-5" style={{ background: `linear-gradient(135deg,${colors[0]},${colors[1]})` }}>
      <div className="absolute -top-10 -right-10 w-36 h-36 rounded-full opacity-10" style={{ background: "white" }} />
      <div className="absolute bottom-0 left-0 w-28 h-28 rounded-full opacity-5" style={{ background: G.gold }} />
      <div className="relative z-10">{children}</div>
    </div>
  );
}

function CardWrap({ children, className = "", onClick }: { children: React.ReactNode; className?: string; onClick?: () => void }) {
  return <div onClick={onClick} className={`rounded-2xl bg-white ${className}`} style={{ boxShadow: "0 2px 14px rgba(0,0,0,0.06)" }}>{children}</div>;
}

const farmersNavItems = [
  { icon: <Home size={20} />, label: "Home" },
  { icon: <Package size={20} />, label: "Products" },
  { icon: <ShoppingBag size={20} />, label: "Orders" },
  { icon: <BarChart2 size={20} />, label: "Analytics" },
  { icon: <User size={20} />, label: "Profile" },
];
const buyerNavItems = [
  { icon: <Home size={20} />, label: "Home" },
  { icon: <ShoppingCart size={20} />, label: "Market" },
  { icon: <ShoppingBag size={20} />, label: "Orders" },
  { icon: <Heart size={20} />, label: "Wishlist" },
  { icon: <User size={20} />, label: "Profile" },
];
const transportNavItems = [
  { icon: <Home size={20} />, label: "Home" },
  { icon: <ShoppingBag size={20} />, label: "Orders" },
  { icon: <Navigation size={20} />, label: "Map" },
  { icon: <Wallet size={20} />, label: "Wallet" },
  { icon: <User size={20} />, label: "Profile" },
];
const retailerNavItems = [
  { icon: <Home size={20} />, label: "Home" },
  { icon: <ShoppingBag size={20} />, label: "Orders" },
  { icon: <Store size={20} />, label: "Suppliers" },
  { icon: <BarChart2 size={20} />, label: "Reports" },
  { icon: <User size={20} />, label: "Profile" },
];

// ─── Screen data ─────────────────────────────────────────────────────────────

const weekRevenue = [
  { day: "M", val: 12400 }, { day: "T", val: 18900 }, { day: "W", val: 9200 },
  { day: "T", val: 22000 }, { day: "F", val: 31000 }, { day: "S", val: 28500 }, { day: "S", val: 15600 },
];
const earningsData = [
  { day: "M", val: 1200 }, { day: "T", val: 2800 }, { day: "W", val: 1900 },
  { day: "T", val: 3400 }, { day: "F", val: 4200 }, { day: "S", val: 3800 }, { day: "S", val: 2100 },
];
const purchaseData = [
  { week: "W1", val: 48000 }, { week: "W2", val: 72000 }, { week: "W3", val: 61000 }, { week: "W4", val: 89000 },
];

// ─── AUTH SCREENS ─────────────────────────────────────────────────────────────

function SplashScreen({ go }: { go: (s: Screen) => void }) {
  useEffect(() => { const t = setTimeout(() => go("welcome"), 2000); return () => clearTimeout(t); }, []);
  return (
    <div className="flex flex-col items-center justify-center min-h-full" style={{ background: `linear-gradient(160deg,${G.primary} 0%,${G.secondary} 60%,#3DC76A 100%)` }}>
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-16 right-8 w-48 h-48 rounded-full opacity-10" style={{ background: "white" }} />
        <div className="absolute bottom-24 left-4 w-32 h-32 rounded-full opacity-10" style={{ background: G.gold }} />
        <div className="absolute top-1/3 left-1/2 -translate-x-1/2 w-64 h-64 rounded-full opacity-5" style={{ background: "white" }} />
      </div>
      <div className="relative z-10 flex flex-col items-center gap-6">
        <div className="w-28 h-28 rounded-[32px] overflow-hidden" style={{ boxShadow: "0 20px 50px rgba(0,0,0,0.3)", background: "white" }}>
          <img src={logoImg} alt="Mambonami logo" className="w-full h-full object-contain p-2" />
        </div>
        <div className="text-center">
          <h1 className="text-4xl font-black text-white tracking-tight" style={{ fontFamily: headFont }}>MAMBONAMI</h1>
          <p className="text-white/75 text-[13px] mt-1 font-medium">Fresh from farm to your door</p>
        </div>
        <div className="flex gap-1.5 mt-8">
          {[1,2,3].map((i) => (
            <div key={i} className="rounded-full" style={{ width: i === 1 ? 24 : 8, height: 8, background: i === 1 ? "white" : "rgba(255,255,255,0.4)" }} />
          ))}
        </div>
      </div>
    </div>
  );
}

function WelcomeScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="flex flex-col min-h-full">
      <div className="relative overflow-hidden" style={{ height: 420, background: `linear-gradient(160deg,${G.primary} 0%,${G.secondary} 60%,#3DC76A 100%)` }}>
        <div className="absolute -top-12 -right-12 w-56 h-56 rounded-full opacity-10" style={{ background: "white" }} />
        <div className="absolute -bottom-6 -left-6 w-40 h-40 rounded-full opacity-10" style={{ background: G.gold }} />
        <div className="relative z-10 flex flex-col items-center pt-12 px-6">
          <div className="w-20 h-20 rounded-3xl bg-white overflow-hidden mb-3 flex items-center justify-center" style={{ boxShadow: "0 10px 30px rgba(0,0,0,0.2)" }}>
            <img src={logoImg} alt="MAMBONAMI" className="w-full h-full object-contain p-1.5" />
          </div>
          <h1 className="text-3xl font-black text-white tracking-tight" style={{ fontFamily: headFont }}>MAMBONAMI</h1>
          <p className="text-white/75 text-[12px] mt-1">Fresh from farm to your door</p>
          <div className="mt-7 relative w-full">
            <img src="https://images.unsplash.com/photo-1542838132-92c53300491e?w=340&h=180&fit=crop&auto=format"
              alt="Fresh market vegetables" className="w-full h-44 object-cover rounded-3xl" style={{ boxShadow: "0 16px 40px rgba(0,0,0,0.25)" }} />
            <div className="absolute -bottom-4 left-4 bg-white rounded-2xl px-3 py-2 flex items-center gap-2" style={{ boxShadow: "0 6px 20px rgba(0,0,0,0.14)" }}>
              <CheckCircle2 size={18} color={G.success} />
              <div>
                <div className="text-[11px] font-bold" style={{ color: G.dark }}>12,400+ Verified Farmers</div>
                <div className="text-[9px]" style={{ color: G.muted }}>across Kenya</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="flex-1 px-6 pt-9 pb-6 flex flex-col gap-4">
        <div className="text-center mb-1">
          <h2 className="text-[22px] font-extrabold leading-tight" style={{ color: G.dark, fontFamily: headFont }}>Kenya&apos;s #1 Farm<br />Marketplace</h2>
          <p className="text-[13px] mt-2" style={{ color: G.muted }}>Direct from farmers. Fair prices. Fresh produce.</p>
        </div>

        {/* Role icons row */}
        <div className="grid grid-cols-4 gap-3 my-1">
          {[
            { img: farmerIconImg, label: "Farmer" },
            { img: buyerIconImg, label: "Buyer" },
            { img: transportIconImg, label: "Transport" },
            { img: securePaymentImg, label: "Secure Pay" },
          ].map((r) => (
            <div key={r.label} className="flex flex-col items-center gap-1.5">
              <div className="w-14 h-14 rounded-2xl bg-white flex items-center justify-center p-2" style={{ boxShadow: "0 2px 10px rgba(0,0,0,0.07)" }}>
                <img src={r.img} alt={r.label} className="w-full h-full object-contain" />
              </div>
              <span className="text-[9px] font-semibold text-center" style={{ color: G.muted }}>{r.label}</span>
            </div>
          ))}
        </div>

        <PrimaryBtn label="Get Started" onClick={() => go("login")} />
        <PrimaryBtn label="I have an account — Log in" onClick={() => go("login")} variant="outline" />
        <p className="text-center text-[10px]" style={{ color: G.muted }}>
          By continuing you agree to our <span style={{ color: G.primary }} className="font-semibold">Terms & Privacy Policy</span>
        </p>
      </div>
    </div>
  );
}

function LoginScreen({ go }: { go: (s: Screen) => void }) {
  const [showPass, setShowPass] = useState(false);
  return (
    <div className="flex flex-col min-h-full">
      <div className="px-5 pt-5 pb-0">
        <BackBtn onClick={() => go("welcome")} />
      </div>
      <div className="px-6 pt-5 flex-1 flex flex-col">
        <div className="flex items-center gap-3 mb-7">
          <div className="w-12 h-12 rounded-2xl overflow-hidden bg-white" style={{ boxShadow: "0 2px 12px rgba(27,127,59,0.2)" }}>
            <img src={logoImg} alt="MAMBONAMI" className="w-full h-full object-contain p-1" />
          </div>
          <div>
            <h1 className="text-[22px] font-extrabold" style={{ color: G.dark }}>Welcome back 👋</h1>
            <p className="text-[12px]" style={{ color: G.muted }}>Sign in to your account</p>
          </div>
        </div>

        <div className="flex flex-col gap-4">
          <AppInput label="Phone Number" type="tel" placeholder="+254 700 000 000" icon={<Phone size={16} color={G.muted} />} />
          <div className="flex flex-col gap-1.5">
            <label className="text-[13px] font-semibold" style={{ color: G.primary }}>Password</label>
            <div className="relative">
              <input type={showPass ? "text" : "password"} placeholder="Enter your password"
                style={{ width: "100%", borderRadius: 16, border: `1.5px solid rgba(27,127,59,0.2)`, padding: "13px 44px 13px 16px", background: "white", fontFamily: font, fontSize: 14, outline: "none", color: G.dark }} />
              <button onClick={() => setShowPass(!showPass)} className="absolute right-3.5 top-1/2 -translate-y-1/2">
                {showPass ? <EyeOff size={16} color={G.muted} /> : <Eye size={16} color={G.muted} />}
              </button>
            </div>
          </div>
          <div className="flex justify-between items-center">
            <label className="flex items-center gap-2 text-[12px]" style={{ color: G.muted }}>
              <div className="w-4 h-4 rounded-md border-2 flex items-center justify-center" style={{ borderColor: G.primary, background: G.light }}>
                <Check size={10} color={G.primary} />
              </div>
              Remember me
            </label>
            <span className="text-[12px] font-semibold cursor-pointer" style={{ color: G.secondary }} onClick={() => go("forgot-password")}>Forgot password?</span>
          </div>
        </div>

        <div className="mt-6 flex flex-col gap-3">
          <PrimaryBtn label="Login" onClick={() => go("otp")} />
          <div className="flex items-center gap-3">
            <div className="flex-1 h-px" style={{ background: "rgba(27,127,59,0.15)" }} />
            <span className="text-[11px]" style={{ color: G.muted }}>or</span>
            <div className="flex-1 h-px" style={{ background: "rgba(27,127,59,0.15)" }} />
          </div>
          <button className="w-full py-3.5 rounded-2xl border text-[14px] font-semibold flex items-center justify-center gap-3" style={{ borderColor: "rgba(27,127,59,0.2)", background: "white", color: G.dark }}>
            <svg width="18" height="18" viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
            Continue with Google
          </button>
        </div>

        <p className="text-center text-[13px] mt-6 pb-4" style={{ color: G.muted }}>
          No account? <span className="font-bold cursor-pointer" style={{ color: G.primary }} onClick={() => go("role-select")}>Create one</span>
        </p>
      </div>
    </div>
  );
}

function ForgotPasswordScreen({ go }: { go: (s: Screen) => void }) {
  const [sent, setSent] = useState(false);
  return (
    <div className="flex flex-col min-h-full px-6 pt-5">
      <BackBtn onClick={() => go("login")} />
      <div className="mt-7 mb-8">
        <div className="w-16 h-16 rounded-2xl flex items-center justify-center mb-4" style={{ background: G.light }}>
          <Shield size={28} color={G.primary} />
        </div>
        <h1 className="text-[22px] font-extrabold" style={{ color: G.dark }}>Forgot Password?</h1>
        <p className="text-[13px] mt-2" style={{ color: G.muted }}>Enter your registered phone number. We&apos;ll send a reset code via SMS.</p>
      </div>

      {!sent ? (
        <>
          <AppInput label="Phone Number" type="tel" placeholder="+254 700 000 000" icon={<Phone size={16} color={G.muted} />} />
          <div className="mt-6">
            <PrimaryBtn label="Send Reset Code" onClick={() => setSent(true)} />
          </div>
        </>
      ) : (
        <div className="flex flex-col items-center text-center gap-4 mt-4">
          <div className="w-20 h-20 rounded-full flex items-center justify-center" style={{ background: G.light }}>
            <Send size={32} color={G.primary} />
          </div>
          <h2 className="text-[18px] font-bold" style={{ color: G.dark }}>Code Sent!</h2>
          <p className="text-[13px]" style={{ color: G.muted }}>A 4-digit reset code was sent to <span className="font-bold" style={{ color: G.dark }}>+254 7** *** 678</span>. Check your SMS.</p>
          <PrimaryBtn label="Enter Code" onClick={() => go("otp")} />
          <span className="text-[12px] cursor-pointer" style={{ color: G.secondary }}>Resend in 00:45</span>
        </div>
      )}
    </div>
  );
}

function OtpScreen({ go }: { go: (s: Screen) => void }) {
  const [otp, setOtp] = useState(["6","2","",""] as string[]);
  return (
    <div className="flex flex-col min-h-full px-6 pt-5">
      <BackBtn onClick={() => go("login")} />
      <div className="mt-7 mb-8">
        <div className="w-16 h-16 rounded-2xl flex items-center justify-center mb-4" style={{ background: G.light }}>
          <Phone size={28} color={G.primary} />
        </div>
        <h1 className="text-[22px] font-extrabold" style={{ color: G.dark }}>Verify your phone</h1>
        <p className="text-[13px] mt-2" style={{ color: G.muted }}>We sent a 4-digit code to<br /><span className="font-bold" style={{ color: G.dark }}>+254 712 345 678</span></p>
      </div>

      <div className="flex gap-3 justify-center mb-8">
        {otp.map((v, i) => (
          <div key={i} className="w-16 h-16 rounded-2xl flex items-center justify-center text-2xl font-bold border-2 transition-all"
            style={{ borderColor: v ? G.primary : "rgba(27,127,59,0.2)", background: v ? G.light : "white", color: G.primary, fontFamily: font }}>
            {v || ""}
          </div>
        ))}
      </div>

      <PrimaryBtn label="Verify & Continue" onClick={() => go("role-select")} />
      <div className="text-center mt-5 flex flex-col gap-2">
        <div className="flex items-center justify-center gap-2" style={{ color: G.muted }}>
          <Clock size={13} /><span className="text-[12px]">Resend code in <span className="font-semibold" style={{ color: G.primary }}>00:45</span></span>
        </div>
        <span className="text-[13px] font-semibold cursor-pointer" style={{ color: G.secondary }}>Resend OTP</span>
      </div>
    </div>
  );
}

function RoleSelectScreen({ go, setRole }: { go: (s: Screen) => void; setRole: (r: Role) => void }) {
  const roles = [
    { id: "farmer" as Role, img: farmerIconImg, title: "Farmer", desc: "Sell fresh produce directly to buyers across Kenya", color: G.primary },
    { id: "buyer" as Role, img: buyerIconImg, title: "Buyer / Consumer", desc: "Buy fresh farm produce delivered to your door", color: G.secondary },
    { id: "transport" as Role, img: transportIconImg, title: "Transport Provider", desc: "Deliver orders and earn daily income", color: G.warning },
    { id: "retailer" as Role, img: securePaymentImg, title: "Retailer / Business", desc: "Bulk orders for your grocery or restaurant", color: G.purple },
  ];
  return (
    <div className="flex flex-col min-h-full px-6 pt-5 pb-6">
      <BackBtn onClick={() => go("login")} />
      <div className="mt-6 mb-6">
        <h1 className="text-[22px] font-extrabold" style={{ color: G.dark }}>Choose your role</h1>
        <p className="text-[13px] mt-1" style={{ color: G.muted }}>How will you use MAMBONAMI?</p>
      </div>
      <div className="flex flex-col gap-3 flex-1">
        {roles.map((r) => (
          <button key={r.id} onClick={() => { setRole(r.id); go(`profile-${r.id}` as Screen); }}
            className="flex items-center gap-4 p-4 rounded-2xl text-left transition-all bg-white"
            style={{ boxShadow: "0 2px 12px rgba(0,0,0,0.06)" }}>
            <div className="w-14 h-14 rounded-2xl flex items-center justify-center p-2.5 flex-shrink-0" style={{ background: r.color + "15" }}>
              <img src={r.img} alt={r.title} className="w-full h-full object-contain" />
            </div>
            <div className="flex-1">
              <div className="font-bold text-[14px]" style={{ color: G.dark }}>{r.title}</div>
              <div className="text-[11px] mt-0.5" style={{ color: G.muted }}>{r.desc}</div>
            </div>
            <ChevronRight size={16} color={G.muted} />
          </button>
        ))}
      </div>
      <p className="text-center text-[11px] mt-4" style={{ color: G.muted }}>You can add more roles later in settings</p>
    </div>
  );
}

function ProgressBar({ step, total, label }: { step: number; total: number; label: string }) {
  return (
    <div className="mb-4">
      <div className="flex justify-between items-center mb-1.5">
        <span className="text-[11px]" style={{ color: G.muted }}>Step {step} of {total}</span>
        <span className="text-[11px] font-semibold" style={{ color: G.dark }}>{label}</span>
      </div>
      <div className="h-1.5 rounded-full" style={{ background: G.light }}>
        <div className="h-full rounded-full transition-all" style={{ width: `${(step / total) * 100}%`, background: `linear-gradient(90deg,${G.secondary},${G.primary})` }} />
      </div>
    </div>
  );
}

function ProfileFarmerScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="flex flex-col min-h-full">
      <div className="px-5 pt-5 pb-2 flex items-center gap-3">
        <BackBtn onClick={() => go("role-select")} />
        <div>
          <h2 className="font-bold text-[14px]" style={{ color: G.dark }}>Farmer Profile</h2>
          <p className="text-[11px]" style={{ color: G.muted }}>Complete your registration</p>
        </div>
      </div>
      <div className="px-5 pt-2 pb-8 flex flex-col gap-4">
        <ProgressBar step={4} total={4} label="Farm Details" />
        <div className="flex justify-center mb-1">
          <div className="relative">
            <div className="w-20 h-20 rounded-3xl flex items-center justify-center" style={{ background: G.light }}>
              <img src={farmerIconImg} alt="Farmer" className="w-12 h-12 object-contain" />
            </div>
            <button className="absolute -bottom-1.5 -right-1.5 w-8 h-8 rounded-xl flex items-center justify-center" style={{ background: G.primary }}>
              <Camera size={14} color="white" />
            </button>
          </div>
        </div>
        <AppInput label="Full Name" placeholder="John Kamau" />
        <AppInput label="National ID Number" placeholder="12345678" icon={<FileText size={16} color={G.muted} />} />
        <AppInput label="M-Pesa Number" type="tel" placeholder="+254 7XX XXX XXX" icon={<Phone size={16} color={G.muted} />} />
        <div>
          <label className="text-[13px] font-semibold mb-2 block" style={{ color: G.primary }}>Product Categories</label>
          <div className="flex flex-wrap gap-2">
            {["🥬 Vegetables","🍎 Fruits","🌾 Grains","🥔 Roots","🐄 Livestock"].map((c,i)=>(
              <button key={c} className="px-3 py-1.5 rounded-xl text-[11px] font-semibold border" style={{ background: i<2?G.primary:"white", color: i<2?"white":G.primary, borderColor: G.primary+"40" }}>{c}</button>
            ))}
          </div>
        </div>
        <div className="rounded-2xl p-3.5 flex items-center gap-3" style={{ background: G.light }}>
          <MapPin size={18} color={G.primary} />
          <div className="flex-1">
            <div className="text-[13px] font-semibold" style={{ color: G.dark }}>Farm GPS Location</div>
            <div className="text-[11px]" style={{ color: G.muted }}>Tap to pick on map</div>
          </div>
          <button className="px-3 py-1.5 rounded-xl text-[11px] font-bold text-white" style={{ background: G.primary }}>Pick</button>
        </div>
        <AppInput label="Cooperative Name (optional)" placeholder="e.g. Kiambu Growers Coop" />
        <div className="rounded-2xl p-3.5" style={{ background: "#FFFBEB", border: `1px solid ${G.gold}40` }}>
          <div className="flex items-start gap-2">
            <Info size={14} color={G.gold} className="mt-0.5 flex-shrink-0" />
            <p className="text-[11px]" style={{ color: G.muted }}>Cooperative endorsement increases buyer trust and gives you priority listings. Unaffiliated farmers may continue without it.</p>
          </div>
        </div>
        <div>
          <label className="text-[13px] font-semibold mb-2 block" style={{ color: G.primary }}>Farm Photos</label>
          <div className="flex gap-2">
            <div className="flex-1 h-20 rounded-2xl border-2 border-dashed flex flex-col items-center justify-center gap-1 cursor-pointer" style={{ borderColor: G.primary+"40" }}>
              <Upload size={16} color={G.muted} />
              <span className="text-[10px]" style={{ color: G.muted }}>Add photo</span>
            </div>
            <img src="https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=120&h=80&fit=crop&auto=format" alt="Farm" className="h-20 w-24 object-cover rounded-2xl" />
          </div>
        </div>
        <PrimaryBtn label="Create Account" onClick={() => go("success")} />
      </div>
    </div>
  );
}

function ProfileBuyerScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="flex flex-col min-h-full">
      <div className="px-5 pt-5 pb-2 flex items-center gap-3">
        <BackBtn onClick={() => go("role-select")} />
        <div>
          <h2 className="font-bold text-[14px]" style={{ color: G.dark }}>Buyer Profile</h2>
          <p className="text-[11px]" style={{ color: G.muted }}>Complete your registration</p>
        </div>
      </div>
      <div className="px-5 pt-2 pb-8 flex flex-col gap-4">
        <ProgressBar step={4} total={4} label="Personal Details" />
        <div className="flex justify-center mb-1">
          <div className="relative">
            <div className="w-20 h-20 rounded-3xl flex items-center justify-center" style={{ background: G.light }}>
              <img src={buyerIconImg} alt="Buyer" className="w-12 h-12 object-contain" />
            </div>
            <button className="absolute -bottom-1.5 -right-1.5 w-8 h-8 rounded-xl flex items-center justify-center" style={{ background: G.primary }}><Camera size={14} color="white" /></button>
          </div>
        </div>
        <AppInput label="Full Name" placeholder="Mary Wanjiku" />
        <AppInput label="Email Address" type="email" placeholder="mary@example.com" icon={<Mail size={16} color={G.muted} />} />
        <AppInput label="Phone Number" type="tel" placeholder="+254 7XX XXX XXX" icon={<Phone size={16} color={G.muted} />} />
        <div className="rounded-2xl p-3.5 flex items-center gap-3" style={{ background: G.light }}>
          <MapPin size={18} color={G.primary} />
          <div className="flex-1">
            <div className="text-[13px] font-semibold" style={{ color: G.dark }}>Delivery Address</div>
            <div className="text-[11px]" style={{ color: G.muted }}>Westlands, Nairobi</div>
          </div>
          <button className="px-3 py-1.5 rounded-xl text-[11px] font-bold text-white" style={{ background: G.primary }}>Change</button>
        </div>
        <AppInput label="Preferred Delivery Instructions" placeholder="e.g. Call when at gate" />
        <PrimaryBtn label="Create Account" onClick={() => go("success")} />
      </div>
    </div>
  );
}

function ProfileTransportScreen({ go }: { go: (s: Screen) => void }) {
  const [vehicle, setVehicle] = useState("Motorcycle");
  return (
    <div className="flex flex-col min-h-full">
      <div className="px-5 pt-5 pb-2 flex items-center gap-3">
        <BackBtn onClick={() => go("role-select")} />
        <div>
          <h2 className="font-bold text-[14px]" style={{ color: G.dark }}>Transport Provider</h2>
          <p className="text-[11px]" style={{ color: G.muted }}>Complete your registration</p>
        </div>
      </div>
      <div className="px-5 pt-2 pb-8 flex flex-col gap-4">
        <ProgressBar step={4} total={4} label="Vehicle Details" />
        <div className="flex justify-center mb-1">
          <div className="relative">
            <div className="w-20 h-20 rounded-3xl flex items-center justify-center" style={{ background: G.light }}>
              <img src={transportIconImg} alt="Transport" className="w-12 h-12 object-contain" />
            </div>
            <button className="absolute -bottom-1.5 -right-1.5 w-8 h-8 rounded-xl flex items-center justify-center" style={{ background: G.primary }}><Camera size={14} color="white" /></button>
          </div>
        </div>
        <AppInput label="Full Name" placeholder="David Ochieng" />
        <AppInput label="National ID Number" placeholder="12345678" icon={<FileText size={16} color={G.muted} />} />
        <div>
          <label className="text-[13px] font-semibold mb-2 block" style={{ color: G.primary }}>Vehicle Type</label>
          <div className="grid grid-cols-2 gap-2">
            {[{l:"Motorcycle",e:"🏍️"},{l:"Pickup",e:"🛻"},{l:"Van",e:"🚐"},{l:"Lorry",e:"🚛"}].map((v)=>(
              <button key={v.l} onClick={()=>setVehicle(v.l)} className="py-3 rounded-2xl flex flex-col items-center gap-1 border-2 transition-all"
                style={{ borderColor:vehicle===v.l?G.primary:"rgba(27,127,59,0.15)", background:vehicle===v.l?G.light:"white" }}>
                <span className="text-xl">{v.e}</span>
                <span className="text-[11px] font-semibold" style={{ color:vehicle===v.l?G.primary:G.muted }}>{v.l}</span>
              </button>
            ))}
          </div>
        </div>
        <AppInput label="License Plate" placeholder="KAA 000A" />
        <AppInput label="Driver License Number" placeholder="A000000Z" />
        <div className="rounded-2xl p-4" style={{ background:"#FFFBEB", border:`1px solid ${G.gold}40` }}>
          <div className="flex items-center gap-2 mb-2">
            <AlertCircle size={15} color={G.gold} />
            <span className="text-[13px] font-bold" style={{ color:G.dark }}>Refundable Deposit: KES 500</span>
          </div>
          <p className="text-[11px] mb-3" style={{ color:G.muted }}>Pay via M-Pesa PayBill <strong>123456</strong>, Account: <strong>DEP-TRANSPORT-ID</strong>. Refunded via B2C when you leave in good standing.</p>
          <button className="w-full py-2.5 rounded-xl text-[12px] font-bold text-white" style={{ background:G.gold }}>Pay Deposit via M-Pesa</button>
        </div>
        <PrimaryBtn label="Create Account" onClick={() => go("success")} />
      </div>
    </div>
  );
}

function ProfileRetailerScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="flex flex-col min-h-full">
      <div className="px-5 pt-5 pb-2 flex items-center gap-3">
        <BackBtn onClick={() => go("role-select")} />
        <div>
          <h2 className="font-bold text-[14px]" style={{ color: G.dark }}>Retailer Profile</h2>
          <p className="text-[11px]" style={{ color: G.muted }}>Complete your registration</p>
        </div>
      </div>
      <div className="px-5 pt-2 pb-8 flex flex-col gap-4">
        <ProgressBar step={4} total={4} label="Business Details" />
        <AppInput label="Business Name" placeholder="Kamau Fresh Groceries" />
        <AppInput label="Owner Full Name" placeholder="James Kamau" />
        <AppInput label="Business Phone" type="tel" placeholder="+254 7XX XXX XXX" icon={<Phone size={16} color={G.muted} />} />
        <AppInput label="Business Email" type="email" placeholder="info@kamaufresh.co.ke" icon={<Mail size={16} color={G.muted} />} />
        <AppInput label="Business Address" placeholder="Tom Mboya St, Nairobi" icon={<MapPin size={16} color={G.muted} />} />
        <div>
          <label className="text-[13px] font-semibold mb-1.5 block" style={{ color: G.primary }}>Business Type</label>
          <div className="relative">
            <select className="w-full rounded-2xl border text-[13px] outline-none appearance-none pr-10"
              style={{ padding:"13px 40px 13px 16px", borderColor:"rgba(27,127,59,0.2)", background:"white", fontFamily:font, color:G.dark }}>
              <option>Grocery / Supermarket</option>
              <option>Restaurant</option>
              <option>Hotel / Catering</option>
              <option>Market Stall</option>
            </select>
            <ChevronDown size={15} color={G.muted} className="absolute right-3.5 top-1/2 -translate-y-1/2 pointer-events-none" />
          </div>
        </div>
        <AppInput label="KRA PIN (optional)" placeholder="A000000000Z" />
        <PrimaryBtn label="Create Account" onClick={() => go("success")} />
      </div>
    </div>
  );
}

function SuccessScreen({ go, role }: { go: (s: Screen) => void; role: Role }) {
  return (
    <div className="flex flex-col min-h-full items-center justify-center px-8 text-center">
      <div className="w-28 h-28 rounded-full flex items-center justify-center mb-6" style={{ background:`linear-gradient(135deg,${G.secondary},${G.primary})`, boxShadow:`0 16px 40px rgba(27,127,59,0.4)` }}>
        <CheckCircle2 size={56} color="white" />
      </div>
      <div className="w-16 h-1 rounded-full mb-5" style={{ background: G.gold }} />
      <h1 className="text-[24px] font-extrabold mb-2" style={{ color: G.dark }}>Account Created! 🎉</h1>
      <p className="text-[13px] mb-8" style={{ color: G.muted }}>Welcome to the MAMBONAMI family. Your {role} account is ready.</p>
      <img src="https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=300&h=180&fit=crop&auto=format"
        alt="Fresh produce" className="w-full h-44 object-cover rounded-3xl mb-8" />
      <PrimaryBtn label="Go to Dashboard →" onClick={() => go(`dash-${role}` as Screen)} />
    </div>
  );
}

// ─── FARMER SCREENS ──────────────────────────────────────────────────────────

function FarmerDash({ go }: { go: (s: Screen) => void }) {
  const [nav, setNav] = useState(0);
  const handleNav = (i: number) => {
    if (i === 1) go("farmer-products");
    else if (i === 2) go("farmer-orders");
    else if (i === 3) go("farmer-earnings");
    else if (i === 4) go("profile");
    else setNav(i);
  };
  return (
    <div className="flex flex-col min-h-full">
      <GradientHeader>
        <div className="flex justify-between items-start mb-3">
          <div>
            <div className="text-white/70 text-[11px] font-medium">Good morning 🌅</div>
            <div className="text-white text-[19px] font-extrabold">John Kamau</div>
            <div className="flex items-center gap-1 text-white/70 text-[11px] mt-0.5"><MapPin size={10}/> Kiambu, Kenya</div>
          </div>
          <div className="flex gap-2">
            <button onClick={() => go("notifications")} className="w-9 h-9 rounded-xl flex items-center justify-center relative" style={{ background:"rgba(255,255,255,0.2)" }}>
              <Bell size={18} color="white" />
              <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full" style={{ background:G.error }} />
            </button>
            <button onClick={() => go("profile")} className="w-9 h-9 rounded-xl overflow-hidden">
              <img src="https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=40&h=40&fit=crop" alt="Profile" className="w-full h-full object-cover" />
            </button>
          </div>
        </div>
        <div className="flex gap-4">
          {[{i:<Thermometer size={11}/>,t:"24°C"},{i:<Droplets size={11}/>,t:"68%"},{i:<Wind size={11}/>,t:"12km/h"},{i:null,t:"☀️ Clear"}].map((w,k)=>(
            <div key={k} className="flex items-center gap-1 text-white/75 text-[11px]">{w.i}{w.t}</div>
          ))}
        </div>
      </GradientHeader>

      <div className="flex-1 px-5 pt-4 pb-2 overflow-y-auto" style={{ background:G.bg }}>
        {/* Revenue card */}
        <CardWrap className="p-4 mb-4">
          <div className="flex justify-between items-start mb-2">
            <div>
              <span className="text-[11px]" style={{ color:G.muted }}>Total Earnings (MTD)</span>
              <div className="text-[24px] font-extrabold" style={{ color:G.dark }}>KES 45,750</div>
            </div>
            <span className="text-[11px] font-bold px-2 py-1 rounded-lg" style={{ background:G.success+"15", color:G.success }}>▲ 18.3%</span>
          </div>
          <ResponsiveContainer width="100%" height={56}>
            <AreaChart data={weekRevenue}>
              <defs><linearGradient id="gf" x1="0" y1="0" x2="0" y2="1"><stop offset="5%" stopColor={G.secondary} stopOpacity={0.3}/><stop offset="95%" stopColor={G.secondary} stopOpacity={0}/></linearGradient></defs>
              <Area type="monotone" dataKey="val" stroke={G.secondary} strokeWidth={2} fill="url(#gf)" dot={false} />
              <Tooltip contentStyle={{ display:"none" }} />
            </AreaChart>
          </ResponsiveContainer>
        </CardWrap>

        {/* Stats */}
        <div className="grid grid-cols-2 gap-3 mb-4">
          {[
            { l:"Pending Orders", v:"12", badge:"3 new", c:G.primary, icon:<Package size={16} color={G.primary}/> },
            { l:"Ready Pickup", v:"5", c:G.success, icon:<CheckCircle2 size={16} color={G.success}/> },
            { l:"Monthly Revenue", v:"KES 12,300", badge:"4.8%", c:G.secondary, icon:<TrendingUp size={16} color={G.secondary}/> },
            { l:"Avg Rating", v:"4.8 ★", c:G.gold, icon:<Star size={16} color={G.gold}/> },
          ].map((s)=>(
            <CardWrap key={s.l} className="p-3.5">
              <div className="flex justify-between items-start mb-2">
                <div className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ background:s.c+"15" }}>{s.icon}</div>
                {s.badge && <span className="text-[10px] font-bold" style={{ color:G.success }}>▲ {s.badge}</span>}
              </div>
              <div className="text-[17px] font-extrabold" style={{ color:G.primary }}>{s.v}</div>
              <div className="text-[10px] mt-0.5" style={{ color:G.muted }}>{s.l}</div>
            </CardWrap>
          ))}
        </div>

        {/* Quick actions */}
        <SectionHeader title="Quick Actions" />
        <div className="grid grid-cols-4 gap-2 mb-4">
          {[
            {l:"Add Product", icon:<Plus size={18} color="white"/>, bg:G.primary, action:()=>go("farmer-product-create")},
            {l:"View Orders", icon:<Package size={18} color="white"/>, bg:G.secondary, action:()=>go("farmer-orders")},
            {l:"Earnings", icon:<Wallet size={18} color="white"/>, bg:G.gold, action:()=>go("farmer-earnings")},
            {l:"Notifications", icon:<Bell size={18} color="white"/>, bg:G.purple, action:()=>go("notifications")},
          ].map((a)=>(
            <button key={a.l} className="flex flex-col items-center gap-1.5" onClick={a.action}>
              <div className="w-12 h-12 rounded-2xl flex items-center justify-center" style={{ background:a.bg, boxShadow:`0 4px 12px ${a.bg}50` }}>{a.icon}</div>
              <span className="text-[10px] font-semibold text-center" style={{ color:G.dark }}>{a.l}</span>
            </button>
          ))}
        </div>

        {/* Recent orders */}
        <SectionHeader title="Recent Orders" action="View all" onAction={()=>go("farmer-orders")} />
        <div className="flex flex-col gap-2 mb-4">
          {[
            {buyer:"Mary Wanjiku",item:"Sukuma Wiki 5kg",amount:"KES 250",status:"Paid",color:G.success},
            {buyer:"Retail Hub Ltd",item:"Avocado 20kg",amount:"KES 3,200",status:"Confirmed",color:G.secondary},
            {buyer:"James Mwangi",item:"Tomatoes 10kg",amount:"KES 900",status:"Pending",color:G.warning},
          ].map((o)=>(
            <CardWrap key={o.buyer} className="flex items-center gap-3 p-3" onClick={()=>go("farmer-order-detail")}>
              <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background:o.color+"15" }}>
                <Package size={16} color={o.color}/>
              </div>
              <div className="flex-1 min-w-0">
                <div className="text-[12px] font-bold truncate" style={{ color:G.dark }}>{o.buyer}</div>
                <div className="text-[10px]" style={{ color:G.muted }}>{o.item}</div>
              </div>
              <div className="text-right">
                <div className="text-[12px] font-bold" style={{ color:G.dark }}>{o.amount}</div>
                <StatusBadge label={o.status} color={o.color} />
              </div>
            </CardWrap>
          ))}
        </div>

        {/* Inventory */}
        <SectionHeader title="Inventory Overview" action="Manage" onAction={()=>go("farmer-products")} />
        <div className="flex flex-col gap-2 pb-2">
          {[
            {name:"Avocado",qty:"120 kg",pct:60,img:"https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=40&h=40&fit=crop"},
            {name:"Tomatoes",qty:"80 kg",pct:40,img:"https://images.unsplash.com/photo-1546470427-e26264be0b07?w=40&h=40&fit=crop"},
            {name:"Sukuma Wiki",qty:"200 bunches",pct:85,img:"https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=40&h=40&fit=crop"},
          ].map((p)=>(
            <CardWrap key={p.name} className="flex items-center gap-3 p-3">
              <img src={p.img} alt={p.name} className="w-10 h-10 object-cover rounded-xl"/>
              <div className="flex-1">
                <div className="flex justify-between mb-1.5">
                  <span className="text-[12px] font-bold" style={{ color:G.dark }}>{p.name}</span>
                  <span className="text-[11px]" style={{ color:G.muted }}>{p.qty}</span>
                </div>
                <div className="h-1.5 rounded-full" style={{ background:G.light }}>
                  <div className="h-full rounded-full transition-all" style={{ width:`${p.pct}%`, background:p.pct<50?G.warning:G.secondary }}/>
                </div>
              </div>
            </CardWrap>
          ))}
        </div>
      </div>
      <BottomNav active={nav} setActive={handleNav} items={farmersNavItems} />
    </div>
  );
}

function FarmerProductsScreen({ go }: { go: (s: Screen) => void }) {
  const [filter, setFilter] = useState("All");
  return (
    <div className="flex flex-col min-h-full">
      <GradientHeader>
        <div className="flex items-center gap-3 mb-3">
          <BackBtn onClick={() => go("dash-farmer")} light />
          <h1 className="text-white font-bold text-[17px]">My Products</h1>
          <div className="flex-1"/>
          <button onClick={() => go("farmer-product-create")} className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ background:"rgba(255,255,255,0.25)" }}>
            <Plus size={18} color="white"/>
          </button>
        </div>
        <div className="relative">
          <Search size={14} color="rgba(255,255,255,0.6)" className="absolute left-3.5 top-1/2 -translate-y-1/2"/>
          <input placeholder="Search products..." style={{ width:"100%", borderRadius:16, border:"none", padding:"11px 16px 11px 36px", background:"rgba(255,255,255,0.2)", fontFamily:font, fontSize:13, color:"white", outline:"none" }} />
        </div>
      </GradientHeader>
      <div className="flex gap-2 px-5 pt-4 pb-2 overflow-x-auto" style={{ scrollbarWidth:"none" }}>
        {["All","Vegetables","Fruits","Grains","Livestock"].map((c)=>(
          <button key={c} onClick={()=>setFilter(c)} className="flex-shrink-0"><Chip label={c} active={filter===c}/></button>
        ))}
      </div>
      <div className="flex-1 px-5 pb-4 overflow-y-auto">
        <div className="flex justify-between items-center py-3">
          <span className="text-[12px]" style={{ color:G.muted }}>12 products listed</span>
          <button className="flex items-center gap-1 text-[12px] font-semibold" style={{ color:G.primary }}><Filter size={13}/>Filter</button>
        </div>
        <div className="flex flex-col gap-3">
          {[
            {name:"Ripe Avocado",cat:"Fruits",qty:"120 kg",price:"KES 250/kg",status:"Active",img:"https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=80&h=80&fit=crop"},
            {name:"Fresh Tomatoes",cat:"Vegetables",qty:"80 kg",price:"KES 120/kg",status:"Active",img:"https://images.unsplash.com/photo-1546470427-e26264be0b07?w=80&h=80&fit=crop"},
            {name:"Sukuma Wiki",cat:"Vegetables",qty:"200 bunches",price:"KES 40/bunch",status:"Low Stock",img:"https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=80&h=80&fit=crop"},
            {name:"Dry Maize",cat:"Grains",qty:"500 kg",price:"KES 55/kg",status:"Active",img:"https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=80&h=80&fit=crop"},
          ].map((p)=>(
            <CardWrap key={p.name} className="flex gap-3 p-3 items-center">
              <img src={p.img} alt={p.name} className="w-16 h-16 object-cover rounded-xl flex-shrink-0"/>
              <div className="flex-1 min-w-0">
                <div className="text-[13px] font-bold" style={{ color:G.dark }}>{p.name}</div>
                <div className="text-[11px]" style={{ color:G.muted }}>{p.cat} · {p.qty}</div>
                <div className="text-[13px] font-extrabold mt-1" style={{ color:G.primary }}>{p.price}</div>
              </div>
              <div className="flex flex-col items-end gap-2">
                <StatusBadge label={p.status} color={p.status==="Active"?G.success:G.warning}/>
                <div className="flex gap-1">
                  <button className="w-7 h-7 rounded-lg flex items-center justify-center" style={{ background:G.light }}><Edit2 size={12} color={G.primary}/></button>
                  <button className="w-7 h-7 rounded-lg flex items-center justify-center" style={{ background:G.error+"15" }}><Trash2 size={12} color={G.error}/></button>
                </div>
              </div>
            </CardWrap>
          ))}
        </div>
      </div>
      <div className="px-5 pb-5">
        <PrimaryBtn label="+ Add New Product" onClick={() => go("farmer-product-create")} />
      </div>
    </div>
  );
}

function FarmerProductCreateScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="flex flex-col min-h-full">
      <div className="px-5 pt-5 pb-2 flex items-center gap-3">
        <BackBtn onClick={() => go("farmer-products")} />
        <div>
          <h2 className="font-bold text-[15px]" style={{ color:G.dark }}>Add New Product</h2>
          <p className="text-[11px]" style={{ color:G.muted }}>Fill in your product details</p>
        </div>
      </div>
      <div className="px-5 pb-8 pt-2 flex flex-col gap-4">
        {/* Image upload */}
        <div className="h-40 rounded-2xl border-2 border-dashed flex flex-col items-center justify-center gap-2 cursor-pointer" style={{ borderColor:G.primary+"40", background:G.light }}>
          <div className="w-12 h-12 rounded-2xl flex items-center justify-center" style={{ background:G.primary }}><Image size={20} color="white"/></div>
          <span className="text-[13px] font-semibold" style={{ color:G.primary }}>Upload Product Photos</span>
          <span className="text-[11px]" style={{ color:G.muted }}>Tap to select from gallery</span>
        </div>
        <AppInput label="Product Name" placeholder="e.g. Ripe Avocado" />
        <div>
          <label className="text-[13px] font-semibold mb-1.5 block" style={{ color:G.primary }}>Category</label>
          <div className="relative">
            <select className="w-full rounded-2xl border text-[13px] outline-none appearance-none pr-10"
              style={{ padding:"13px 40px 13px 16px", borderColor:"rgba(27,127,59,0.2)", background:"white", fontFamily:font, color:G.dark }}>
              <option>Vegetables (Mboga)</option>
              <option>Fruits (Matunda)</option>
              <option>Grains (Nafaka)</option>
              <option>Roots (Mizizi)</option>
              <option>Livestock Products (Mifugo)</option>
            </select>
            <ChevronDown size={15} color={G.muted} className="absolute right-3.5 top-1/2 -translate-y-1/2 pointer-events-none"/>
          </div>
        </div>
        <div className="grid grid-cols-2 gap-3">
          <AppInput label="Price (KES)" type="number" placeholder="250" />
          <div>
            <label className="text-[13px] font-semibold mb-1.5 block" style={{ color:G.primary }}>Unit</label>
            <div className="relative">
              <select className="w-full rounded-2xl border text-[13px] outline-none appearance-none pr-8"
                style={{ padding:"13px 32px 13px 16px", borderColor:"rgba(27,127,59,0.2)", background:"white", fontFamily:font, color:G.dark }}>
                <option>kg</option><option>bunch</option><option>piece</option><option>litre</option><option>tray</option>
              </select>
              <ChevronDown size={15} color={G.muted} className="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none"/>
            </div>
          </div>
        </div>
        <AppInput label="Available Quantity" type="number" placeholder="e.g. 100" />
        <AppInput label="Harvest / Pack Date" type="date" />
        <div>
          <label className="text-[13px] font-semibold mb-1.5 block" style={{ color:G.primary }}>Description (optional)</label>
          <textarea placeholder="Describe your product — freshness, quality, etc."
            rows={3} style={{ width:"100%", borderRadius:16, border:`1.5px solid rgba(27,127,59,0.2)`, padding:"13px 16px", background:"white", fontFamily:font, fontSize:13, outline:"none", color:G.dark, resize:"none" }}/>
        </div>
        <PrimaryBtn label="List Product" onClick={() => go("farmer-products")} />
      </div>
    </div>
  );
}

function FarmerOrdersScreen({ go }: { go: (s: Screen) => void }) {
  const [tab, setTab] = useState(0);
  const tabs = ["New (3)", "Confirmed", "Ready", "All"];
  const orders = [
    {id:"ORD-3841",buyer:"Mary Wanjiku",item:"Sukuma Wiki 5kg",amount:"KES 250",status:"New",color:G.warning,time:"2 min ago"},
    {id:"ORD-3840",buyer:"Retail Hub Ltd",item:"Avocado 20kg",amount:"KES 3,200",status:"Confirmed",color:G.secondary,time:"15 min ago"},
    {id:"ORD-3838",buyer:"James Mwangi",item:"Tomatoes 10kg",amount:"KES 900",status:"Ready",color:G.success,time:"1 hr ago"},
    {id:"ORD-3835",buyer:"Nairobi Grocers",item:"Maize 50kg",amount:"KES 2,750",status:"New",color:G.warning,time:"2 hr ago"},
  ];
  return (
    <div className="flex flex-col min-h-full">
      <GradientHeader>
        <div className="flex items-center gap-3 mb-3">
          <BackBtn onClick={() => go("dash-farmer")} light />
          <h1 className="text-white font-bold text-[17px]">Order Requests</h1>
        </div>
        <div className="flex gap-2">
          {tabs.map((t,i)=>(
            <button key={t} onClick={()=>setTab(i)} className="px-3 py-1.5 rounded-full text-[11px] font-semibold"
              style={{ background:i===tab?"white":"rgba(255,255,255,0.2)", color:i===tab?G.primary:"white" }}>{t}</button>
          ))}
        </div>
      </GradientHeader>
      <div className="flex-1 px-5 pt-4 pb-4 overflow-y-auto" style={{ background:G.bg }}>
        <div className="flex flex-col gap-3">
          {orders.map((o)=>(
            <CardWrap key={o.id} className="p-4" onClick={()=>go("farmer-order-detail")}>
              <div className="flex justify-between items-start mb-2">
                <div>
                  <div className="text-[13px] font-bold" style={{ color:G.dark }}>{o.id}</div>
                  <div className="text-[11px]" style={{ color:G.muted }}>{o.buyer} · {o.time}</div>
                </div>
                <StatusBadge label={o.status} color={o.color}/>
              </div>
              <div className="flex items-center gap-2 mb-3">
                <Package size={13} color={G.muted}/>
                <span className="text-[12px]" style={{ color:G.muted }}>{o.item}</span>
                <div className="flex-1"/>
                <span className="text-[14px] font-extrabold" style={{ color:G.primary }}>{o.amount}</span>
              </div>
              {o.status === "New" && (
                <div className="flex gap-2 mt-1">
                  <PrimaryBtn label="Confirm Order" onClick={()=>go("farmer-order-detail")} small />
                  <PrimaryBtn label="Decline" onClick={()=>{}} variant="danger" small full={false} />
                </div>
              )}
            </CardWrap>
          ))}
        </div>
      </div>
    </div>
  );
}

function FarmerOrderDetailScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="flex flex-col min-h-full">
      <GradientHeader>
        <div className="flex items-center gap-3">
          <BackBtn onClick={() => go("farmer-orders")} light />
          <h1 className="text-white font-bold text-[17px]">Order #ORD-3841</h1>
        </div>
      </GradientHeader>
      <div className="flex-1 px-5 pt-4 pb-6 overflow-y-auto" style={{ background:G.bg }}>
        <CardWrap className="p-4 mb-4">
          <div className="flex justify-between items-center mb-3">
            <span className="text-[13px] font-bold" style={{ color:G.dark }}>Order Status</span>
            <StatusBadge label="Paid — Escrow" color={G.success}/>
          </div>
          {/* Timeline */}
          <div className="flex flex-col gap-0">
            {[
              {label:"Order Placed",done:true,time:"10:32 AM"},
              {label:"Payment Received",done:true,time:"10:33 AM"},
              {label:"Farmer Accepted",done:false,time:"—"},
              {label:"Ready for Pickup",done:false,time:"—"},
              {label:"Transport Assigned",done:false,time:"—"},
            ].map((s,i)=>(
              <div key={s.label} className="flex gap-3 items-start">
                <div className="flex flex-col items-center">
                  <div className="w-6 h-6 rounded-full flex items-center justify-center flex-shrink-0" style={{ background:s.done?G.primary:G.light }}>
                    {s.done?<Check size={12} color="white"/>:<div className="w-2 h-2 rounded-full" style={{ background:G.muted }}/>}
                  </div>
                  {i<4&&<div className="w-0.5 h-5" style={{ background:s.done?G.primary:G.light }}/>}
                </div>
                <div className="pb-3 pt-0.5">
                  <div className="text-[12px] font-semibold" style={{ color:s.done?G.dark:G.muted }}>{s.label}</div>
                  <div className="text-[10px]" style={{ color:G.muted }}>{s.time}</div>
                </div>
              </div>
            ))}
          </div>
        </CardWrap>

        <CardWrap className="p-4 mb-4">
          <h3 className="text-[13px] font-bold mb-3" style={{ color:G.dark }}>Order Items</h3>
          <div className="flex items-center gap-3 mb-3 pb-3" style={{ borderBottom:`1px solid rgba(27,127,59,0.1)` }}>
            <img src="https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=50&h=50&fit=crop" alt="Sukuma" className="w-12 h-12 object-cover rounded-xl"/>
            <div className="flex-1">
              <div className="text-[13px] font-bold" style={{ color:G.dark }}>Sukuma Wiki</div>
              <div className="text-[11px]" style={{ color:G.muted }}>5 kg × KES 40/bunch</div>
            </div>
            <div className="text-[14px] font-extrabold" style={{ color:G.primary }}>KES 250</div>
          </div>
          <div className="flex justify-between text-[12px]">
            <span style={{ color:G.muted }}>Subtotal</span><span className="font-semibold" style={{ color:G.dark }}>KES 250</span>
          </div>
          <div className="flex justify-between text-[12px] mt-1">
            <span style={{ color:G.muted }}>Platform fee</span><span className="font-semibold" style={{ color:G.dark }}>KES 25</span>
          </div>
          <div className="flex justify-between text-[13px] font-extrabold mt-2 pt-2" style={{ borderTop:`1px solid rgba(27,127,59,0.1)` }}>
            <span style={{ color:G.dark }}>Your earnings</span><span style={{ color:G.primary }}>KES 225</span>
          </div>
        </CardWrap>

        <CardWrap className="p-4 mb-4">
          <h3 className="text-[13px] font-bold mb-2" style={{ color:G.dark }}>Buyer Details</h3>
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl overflow-hidden bg-gray-100">
              <img src="https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=40&h=40&fit=crop" alt="Buyer" className="w-full h-full object-cover"/>
            </div>
            <div>
              <div className="text-[13px] font-bold" style={{ color:G.dark }}>Mary Wanjiku</div>
              <div className="text-[11px]" style={{ color:G.muted }}>+254 712 345 678</div>
            </div>
          </div>
        </CardWrap>

        <div className="flex gap-3">
          <PrimaryBtn label="✓ Confirm Order" onClick={() => go("farmer-orders")} />
          <PrimaryBtn label="Decline" onClick={()=>{}} variant="danger" full={false} />
        </div>
      </div>
    </div>
  );
}

function FarmerEarningsScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="flex flex-col min-h-full">
      <GradientHeader>
        <div className="flex items-center gap-3 mb-3">
          <BackBtn onClick={()=>go("dash-farmer")} light/>
          <h1 className="text-white font-bold text-[17px]">Earnings & Wallet</h1>
        </div>
        <div className="rounded-2xl p-4" style={{ background:"rgba(255,255,255,0.15)" }}>
          <div className="text-white/70 text-[11px]">Available Balance</div>
          <div className="text-white text-[28px] font-extrabold">KES 45,750</div>
          <div className="flex gap-3 mt-2">
            <button className="flex-1 py-2 rounded-xl text-[12px] font-bold text-white" style={{ background:"rgba(255,255,255,0.25)" }}>Withdraw</button>
            <button className="flex-1 py-2 rounded-xl text-[12px] font-bold" style={{ background:"white", color:G.primary }}>History</button>
          </div>
        </div>
      </GradientHeader>
      <div className="flex-1 px-5 pt-4 pb-6 overflow-y-auto" style={{ background:G.bg }}>
        <CardWrap className="p-4 mb-4">
          <div className="flex justify-between mb-3">
            <span className="text-[13px] font-bold" style={{ color:G.dark }}>Weekly Earnings</span>
            <span className="text-[11px] font-bold" style={{ color:G.success }}>▲ 18.3%</span>
          </div>
          <ResponsiveContainer width="100%" height={110}>
            <BarChart data={weekRevenue} barSize={24}>
              <Bar dataKey="val" fill={G.primary} radius={[6,6,0,0]}/>
              <XAxis dataKey="day" tick={{ fontSize:10, fill:G.muted }} axisLine={false} tickLine={false}/>
              <Tooltip formatter={(v:number)=>[`KES ${v.toLocaleString()}`,"Earnings"]} contentStyle={{ borderRadius:12, fontSize:11 }}/>
            </BarChart>
          </ResponsiveContainer>
        </CardWrap>

        <SectionHeader title="Recent Payouts" />
        <div className="flex flex-col gap-2">
          {[
            {desc:"Order ORD-3835 — Maize 50kg",amount:"+KES 2,750",date:"Today 14:20",type:"payout"},
            {desc:"Order ORD-3820 — Avocado",amount:"+KES 3,200",date:"Yesterday 09:15",type:"payout"},
            {desc:"M-Pesa Withdrawal",amount:"-KES 10,000",date:"Mon 16:00",type:"withdraw"},
          ].map((t,i)=>(
            <CardWrap key={i} className="flex items-center gap-3 p-3">
              <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background:t.type==="payout"?G.success+"15":G.error+"15" }}>
                {t.type==="payout"?<TrendingUp size={16} color={G.success}/>:<Banknote size={16} color={G.error}/>}
              </div>
              <div className="flex-1">
                <div className="text-[12px] font-semibold" style={{ color:G.dark }}>{t.desc}</div>
                <div className="text-[10px]" style={{ color:G.muted }}>{t.date}</div>
              </div>
              <div className="font-bold text-[13px]" style={{ color:t.type==="payout"?G.success:G.error }}>{t.amount}</div>
            </CardWrap>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── BUYER SCREENS ────────────────────────────────────────────────────────────

function BuyerDash({ go }: { go: (s: Screen) => void }) {
  const [nav, setNav] = useState(0);
  const [activeCat, setActiveCat] = useState(0);
  const handleNav = (i: number) => {
    if (i === 1) go("buyer-catalog");
    else if (i === 2) go("buyer-order-history");
    else if (i === 4) go("profile");
    else setNav(i);
  };
  const cats = ["All","Vegetables","Fruits","Grains","Dairy","Roots"];
  const products = [
    {name:"Avocado",farmer:"Kamau Farm",price:"KES 250/kg",rating:4.8,img:"https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=120&h=120&fit=crop"},
    {name:"Fresh Tomatoes",farmer:"Wanjiku Growers",price:"KES 120/kg",rating:4.6,img:"https://images.unsplash.com/photo-1546470427-e26264be0b07?w=120&h=120&fit=crop"},
    {name:"Spinach",farmer:"Mwangi Farm",price:"KES 80/bunch",rating:4.9,img:"https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=120&h=120&fit=crop"},
    {name:"Bananas",farmer:"Coastal Farms",price:"KES 180/kg",rating:4.7,img:"https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=120&h=120&fit=crop"},
  ];
  return (
    <div className="flex flex-col min-h-full">
      <div className="px-5 pt-4 pb-3" style={{ background:G.bg }}>
        <div className="flex justify-between items-center mb-4">
          <div>
            <div className="text-[11px]" style={{ color:G.muted }}>Delivery to</div>
            <div className="flex items-center gap-1 font-bold text-[14px]" style={{ color:G.dark }}>
              <MapPin size={13} color={G.primary}/>Westlands, Nairobi<ChevronDown size={13} color={G.muted}/>
            </div>
          </div>
          <div className="flex gap-2">
            <button onClick={()=>go("notifications")} className="w-9 h-9 rounded-xl flex items-center justify-center relative bg-white" style={{ boxShadow:"0 2px 8px rgba(0,0,0,0.08)" }}>
              <Bell size={17} color={G.primary}/>
              <span className="absolute top-1.5 right-1.5 w-2 h-2 rounded-full" style={{ background:G.error }}/>
            </button>
            <button onClick={()=>go("profile")} className="w-9 h-9 rounded-xl overflow-hidden">
              <img src="https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=40&h=40&fit=crop" alt="Profile" className="w-full h-full object-cover"/>
            </button>
          </div>
        </div>
        <div className="relative mb-4">
          <Search size={15} color={G.muted} className="absolute left-3.5 top-1/2 -translate-y-1/2"/>
          <input placeholder="Search products, farmers..." style={{ width:"100%", borderRadius:16, border:`1.5px solid rgba(27,127,59,0.15)`, padding:"12px 16px 12px 40px", background:"white", fontFamily:font, fontSize:13, outline:"none" }}
            onClick={() => go("buyer-catalog")} />
        </div>
        {/* Banner */}
        <div className="relative rounded-3xl overflow-hidden mb-4" style={{ height:140 }}>
          <img src="https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=160&fit=crop" alt="Fresh vegetables" className="w-full h-full object-cover"/>
          <div className="absolute inset-0" style={{ background:`linear-gradient(90deg,rgba(27,127,59,0.88) 0%,transparent 60%)` }}/>
          <div className="absolute left-5 top-1/2 -translate-y-1/2">
            <div className="text-white/80 text-[11px] font-medium mb-1">Flash Deal 🔥</div>
            <div className="text-white font-extrabold text-[18px] leading-tight">Fresh from<br/>the Farm</div>
            <div className="text-white/75 text-[11px] mt-1">Up to 30% off today</div>
          </div>
          <button className="absolute right-4 top-1/2 -translate-y-1/2 px-3 py-2 rounded-xl text-[12px] font-bold text-white" style={{ background:G.gold }}>Shop Now</button>
        </div>
        {/* Categories */}
        <div className="flex gap-2 overflow-x-auto pb-1" style={{ scrollbarWidth:"none" }}>
          {cats.map((c,i)=>(
            <button key={c} onClick={()=>setActiveCat(i)} className="flex-shrink-0"><Chip label={c} active={i===activeCat}/></button>
          ))}
        </div>
      </div>

      <div className="flex-1 px-5 pb-4 overflow-y-auto" style={{ background:G.bg }}>
        {/* Nearby farmers */}
        <div className="mb-4">
          <SectionHeader title="Nearby Farmers" action="View all"/>
          <div className="flex gap-3 overflow-x-auto pb-1" style={{ scrollbarWidth:"none" }}>
            {[
              {name:"Kamau Farm",dist:"2.1 km",img:"https://images.unsplash.com/photo-1607305387299-a3d9611cd469?w=60&h=60&fit=crop"},
              {name:"Wanjiku Farm",dist:"3.4 km",img:"https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=60&h=60&fit=crop"},
              {name:"Coastal Farms",dist:"5.2 km",img:"https://images.unsplash.com/photo-1560493676-04071c5f467b?w=60&h=60&fit=crop"},
            ].map((f)=>(
              <div key={f.name} className="flex-shrink-0 flex flex-col items-center gap-1.5 cursor-pointer">
                <div className="w-16 h-16 rounded-2xl overflow-hidden border-2" style={{ borderColor:G.light }}>
                  <img src={f.img} alt={f.name} className="w-full h-full object-cover"/>
                </div>
                <div className="text-[10px] font-bold text-center" style={{ color:G.dark }}>{f.name}</div>
                <div className="text-[9px]" style={{ color:G.muted }}>{f.dist}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Products grid */}
        <SectionHeader title="Recommended for You" action="See all" onAction={()=>go("buyer-catalog")}/>
        <div className="grid grid-cols-2 gap-3 mb-4">
          {products.map((p)=>(
            <CardWrap key={p.name} className="overflow-hidden" onClick={()=>go("buyer-product-detail")}>
              <div className="relative">
                <img src={p.img} alt={p.name} className="w-full h-28 object-cover"/>
                <button className="absolute top-2 right-2 w-7 h-7 rounded-lg flex items-center justify-center bg-white">
                  <Heart size={13} color={G.error}/>
                </button>
              </div>
              <div className="p-2.5">
                <div className="font-bold text-[12px]" style={{ color:G.dark }}>{p.name}</div>
                <div className="text-[10px] mb-1.5" style={{ color:G.muted }}>{p.farmer}</div>
                <div className="flex items-center justify-between">
                  <span className="text-[12px] font-extrabold" style={{ color:G.primary }}>{p.price}</span>
                  <button className="w-6 h-6 rounded-lg flex items-center justify-center" style={{ background:G.primary }}><Plus size={12} color="white"/></button>
                </div>
                <div className="flex items-center gap-1 mt-1">
                  <Star size={10} color={G.gold} fill={G.gold}/><span className="text-[10px] font-semibold" style={{ color:G.dark }}>{p.rating}</span>
                </div>
              </div>
            </CardWrap>
          ))}
        </div>

        {/* Order tracking strip */}
        <SectionHeader title="Your Active Order"/>
        <CardWrap className="p-4">
          <div className="flex justify-between items-center mb-3">
            <span className="text-[12px] font-bold" style={{ color:G.dark }}>Order #ORD-2847</span>
            <StatusBadge label="On the way" color={G.secondary}/>
          </div>
          <div className="flex items-center mb-3">
            {["Placed","Confirmed","Pickup","On way","Delivered"].map((s,i)=>(
              <div key={s} className="flex items-center flex-1">
                <div className="w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0" style={{ background:i<4?G.primary:G.light }}>
                  {i<4?<Check size={10} color="white"/>:<div className="w-1.5 h-1.5 rounded-full bg-gray-300"/>}
                </div>
                {i<4&&<div className="h-0.5 flex-1" style={{ background:i<3?G.primary:G.light }}/>}
              </div>
            ))}
          </div>
          <div className="flex items-center gap-2 text-[11px]" style={{ color:G.muted }}>
            <Navigation size={12} color={G.secondary}/>
            David O. is <span className="font-bold" style={{ color:G.dark }}>1.2 km</span> away · ETA <span className="font-bold" style={{ color:G.dark }}>8 min</span>
          </div>
          <button className="mt-3 w-full text-[12px] font-bold py-2 rounded-xl" style={{ background:G.light, color:G.primary }} onClick={()=>go("buyer-order-tracking")}>
            View Full Tracking →
          </button>
        </CardWrap>
      </div>
      <BottomNav active={nav} setActive={handleNav} items={buyerNavItems}/>
    </div>
  );
}

function BuyerCatalogScreen({ go }: { go: (s: Screen) => void }) {
  const [activeCat, setActiveCat] = useState(0);
  const cats = ["All","Vegetables","Fruits","Grains","Dairy","Roots","Livestock"];
  const products = [
    {name:"Avocado",farmer:"Kamau Farm",price:"KES 250/kg",rating:4.8,badge:"Organic",img:"https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=120&h=120&fit=crop"},
    {name:"Fresh Tomatoes",farmer:"Wanjiku Farm",price:"KES 120/kg",rating:4.6,badge:null,img:"https://images.unsplash.com/photo-1546470427-e26264be0b07?w=120&h=120&fit=crop"},
    {name:"Spinach",farmer:"Mwangi Farm",price:"KES 80/bunch",rating:4.9,badge:"Fresh",img:"https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=120&h=120&fit=crop"},
    {name:"Bananas",farmer:"Coastal Farms",price:"KES 180/kg",rating:4.7,badge:null,img:"https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=120&h=120&fit=crop"},
    {name:"Dry Maize",farmer:"Thika Farms",price:"KES 55/kg",rating:4.5,badge:null,img:"https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b?w=120&h=120&fit=crop"},
    {name:"Sweet Potato",farmer:"Muranga Farm",price:"KES 90/kg",rating:4.3,badge:null,img:"https://images.unsplash.com/photo-1597736045734-4fd26ecbb879?w=120&h=120&fit=crop"},
  ];
  return (
    <div className="flex flex-col min-h-full">
      <div className="px-5 pt-4 pb-3" style={{ background:"white" }}>
        <div className="flex items-center gap-3 mb-3">
          <BackBtn onClick={()=>go("dash-buyer")}/>
          <div className="flex-1 relative">
            <Search size={14} color={G.muted} className="absolute left-3 top-1/2 -translate-y-1/2"/>
            <input placeholder="Search products, farmers..." style={{ width:"100%", borderRadius:14, border:`1.5px solid rgba(27,127,59,0.2)`, padding:"10px 16px 10px 34px", background:G.bg, fontFamily:font, fontSize:13, outline:"none" }}/>
          </div>
          <button className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ background:G.light }}>
            <Filter size={16} color={G.primary}/>
          </button>
        </div>
        <div className="flex gap-2 overflow-x-auto pb-1" style={{ scrollbarWidth:"none" }}>
          {cats.map((c,i)=>(
            <button key={c} onClick={()=>setActiveCat(i)} className="flex-shrink-0"><Chip label={c} active={i===activeCat}/></button>
          ))}
        </div>
      </div>
      <div className="flex-1 px-5 pt-3 pb-4 overflow-y-auto" style={{ background:G.bg }}>
        <div className="flex justify-between items-center mb-3">
          <span className="text-[12px]" style={{ color:G.muted }}>86 products found</span>
          <button className="flex items-center gap-1 text-[12px] font-semibold" style={{ color:G.primary }}><SortAsc size={13}/>Sort</button>
        </div>
        <div className="grid grid-cols-2 gap-3">
          {products.map((p)=>(
            <CardWrap key={p.name} className="overflow-hidden" onClick={()=>go("buyer-product-detail")}>
              <div className="relative">
                <img src={p.img} alt={p.name} className="w-full h-28 object-cover"/>
                {p.badge && <span className="absolute top-2 left-2 px-2 py-0.5 rounded-lg text-[9px] font-bold text-white" style={{ background:G.gold }}>{p.badge}</span>}
                <button className="absolute top-2 right-2 w-7 h-7 rounded-lg flex items-center justify-center bg-white">
                  <Heart size={13} color={G.error}/>
                </button>
              </div>
              <div className="p-2.5">
                <div className="font-bold text-[12px]" style={{ color:G.dark }}>{p.name}</div>
                <div className="text-[10px] mb-1.5" style={{ color:G.muted }}>{p.farmer}</div>
                <div className="flex items-center justify-between">
                  <span className="text-[12px] font-extrabold" style={{ color:G.primary }}>{p.price}</span>
                  <button className="w-6 h-6 rounded-lg flex items-center justify-center" style={{ background:G.primary }}><Plus size={12} color="white"/></button>
                </div>
                <div className="flex items-center gap-1 mt-1">
                  <Star size={10} color={G.gold} fill={G.gold}/><span className="text-[10px] font-semibold" style={{ color:G.dark }}>{p.rating}</span>
                </div>
              </div>
            </CardWrap>
          ))}
        </div>
      </div>
    </div>
  );
}

function BuyerProductDetailScreen({ go }: { go: (s: Screen) => void }) {
  const [qty, setQty] = useState(2);
  return (
    <div className="flex flex-col min-h-full">
      <div className="relative">
        <img src="https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=400&h=260&fit=crop" alt="Avocado" className="w-full h-64 object-cover"/>
        <div className="absolute top-5 left-5"><BackBtn onClick={()=>go("buyer-catalog")} light/></div>
        <button className="absolute top-5 right-5 w-10 h-10 rounded-2xl flex items-center justify-center" style={{ background:"rgba(0,0,0,0.3)" }}>
          <Heart size={18} color="white"/>
        </button>
        <div className="absolute top-5 left-1/2 -translate-x-1/2 px-3 py-1.5 rounded-full text-[11px] font-bold text-white" style={{ background:G.gold }}>Organic</div>
      </div>
      <div className="flex-1 px-5 pt-4 pb-6 overflow-y-auto" style={{ background:"white" }}>
        <div className="flex justify-between items-start mb-2">
          <div>
            <h1 className="text-[20px] font-extrabold" style={{ color:G.dark }}>Ripe Avocado</h1>
            <div className="flex items-center gap-2 mt-1">
              <Star size={13} color={G.gold} fill={G.gold}/>
              <span className="text-[12px] font-semibold" style={{ color:G.dark }}>4.8</span>
              <span className="text-[11px]" style={{ color:G.muted }}>(248 reviews)</span>
            </div>
          </div>
          <div className="text-right">
            <div className="text-[22px] font-extrabold" style={{ color:G.primary }}>KES 250</div>
            <div className="text-[11px]" style={{ color:G.muted }}>per kg</div>
          </div>
        </div>

        {/* Farmer row */}
        <div className="flex items-center gap-3 p-3 rounded-2xl mb-4 cursor-pointer" style={{ background:G.light }}>
          <img src="https://images.unsplash.com/photo-1607305387299-a3d9611cd469?w=48&h=48&fit=crop" alt="Farm" className="w-12 h-12 object-cover rounded-xl"/>
          <div className="flex-1">
            <div className="text-[13px] font-bold" style={{ color:G.dark }}>Kamau Farm</div>
            <div className="flex items-center gap-1 text-[11px]" style={{ color:G.muted }}><MapPin size={10}/>Kiambu · 2.1 km away</div>
          </div>
          <div className="flex flex-col items-end">
            <StatusBadge label="Verified ✓" color={G.primary}/>
          </div>
        </div>

        {/* Details */}
        <div className="flex gap-3 mb-4">
          {[{l:"Available",v:"120 kg"},{l:"Harvest",v:"2 days ago"},{l:"Min Order",v:"1 kg"}].map((d)=>(
            <div key={d.l} className="flex-1 rounded-xl p-2.5 text-center" style={{ background:G.bg }}>
              <div className="text-[13px] font-bold" style={{ color:G.dark }}>{d.v}</div>
              <div className="text-[10px]" style={{ color:G.muted }}>{d.l}</div>
            </div>
          ))}
        </div>

        <p className="text-[13px] mb-4 leading-relaxed" style={{ color:G.muted }}>
          Premium Fuerte avocados, hand-picked at peak ripeness from Kiambu highlands. Rich, creamy texture with excellent shelf life. Certified organic, no pesticides.
        </p>

        {/* Qty selector */}
        <div className="flex items-center justify-between mb-6 p-3 rounded-2xl" style={{ background:G.bg }}>
          <span className="text-[13px] font-semibold" style={{ color:G.dark }}>Quantity</span>
          <div className="flex items-center gap-4">
            <button onClick={()=>setQty(Math.max(1,qty-1))} className="w-8 h-8 rounded-xl flex items-center justify-center" style={{ background:"white", boxShadow:"0 2px 6px rgba(0,0,0,0.1)" }}>
              <span className="text-lg font-bold" style={{ color:G.primary }}>−</span>
            </button>
            <span className="text-[16px] font-extrabold w-8 text-center" style={{ color:G.dark }}>{qty}</span>
            <button onClick={()=>setQty(qty+1)} className="w-8 h-8 rounded-xl flex items-center justify-center" style={{ background:G.primary }}>
              <Plus size={16} color="white"/>
            </button>
          </div>
        </div>
      </div>
      <div className="px-5 pb-6 pt-3 bg-white flex gap-3" style={{ borderTop:`1px solid ${G.light}` }}>
        <div className="flex-1">
          <div className="text-[11px]" style={{ color:G.muted }}>Total</div>
          <div className="text-[18px] font-extrabold" style={{ color:G.dark }}>KES {qty*250}</div>
        </div>
        <PrimaryBtn label="Add to Cart 🛒" onClick={()=>go("buyer-cart")} full={false} />
      </div>
    </div>
  );
}

function BuyerCartScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="flex flex-col min-h-full">
      <div className="px-5 pt-5 pb-3 bg-white flex items-center gap-3" style={{ boxShadow:"0 1px 8px rgba(0,0,0,0.05)" }}>
        <BackBtn onClick={()=>go("dash-buyer")}/>
        <h1 className="font-bold text-[17px]" style={{ color:G.dark }}>My Cart</h1>
        <div className="flex-1"/>
        <span className="text-[12px]" style={{ color:G.muted }}>3 items</span>
      </div>
      <div className="flex-1 px-5 pt-4 pb-4 overflow-y-auto" style={{ background:G.bg }}>
        {/* Cart grouped by farmer */}
        {[
          {farmer:"Kamau Farm",items:[{n:"Avocado",qty:"2 kg",price:"KES 500",img:"https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=60&h=60&fit=crop"},{n:"Spinach",qty:"3 bunches",price:"KES 240",img:"https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=60&h=60&fit=crop"}]},
          {farmer:"Wanjiku Growers",items:[{n:"Fresh Tomatoes",qty:"3 kg",price:"KES 360",img:"https://images.unsplash.com/photo-1546470427-e26264be0b07?w=60&h=60&fit=crop"}]},
        ].map((group)=>(
          <CardWrap key={group.farmer} className="p-4 mb-3">
            <div className="flex items-center gap-2 mb-3 pb-2" style={{ borderBottom:`1px solid ${G.light}` }}>
              <Leaf size={14} color={G.primary}/><span className="text-[12px] font-bold" style={{ color:G.primary }}>{group.farmer}</span>
            </div>
            {group.items.map((item)=>(
              <div key={item.n} className="flex items-center gap-3 mb-3">
                <img src={item.img} alt={item.n} className="w-14 h-14 object-cover rounded-xl"/>
                <div className="flex-1">
                  <div className="text-[13px] font-bold" style={{ color:G.dark }}>{item.n}</div>
                  <div className="text-[11px]" style={{ color:G.muted }}>{item.qty}</div>
                </div>
                <div className="text-right">
                  <div className="text-[13px] font-extrabold" style={{ color:G.primary }}>{item.price}</div>
                  <button className="mt-1"><Trash2 size={13} color={G.error}/></button>
                </div>
              </div>
            ))}
          </CardWrap>
        ))}

        {/* Summary */}
        <CardWrap className="p-4 mb-4">
          <h3 className="text-[13px] font-bold mb-3" style={{ color:G.dark }}>Order Summary</h3>
          {[["Subtotal","KES 1,100"],["Delivery fee","KES 150"],["Platform fee","KES 55"]].map(([l,v])=>(
            <div key={l} className="flex justify-between text-[12px] mb-1.5">
              <span style={{ color:G.muted }}>{l}</span><span className="font-semibold" style={{ color:G.dark }}>{v}</span>
            </div>
          ))}
          <div className="flex justify-between font-extrabold text-[14px] pt-2 mt-1" style={{ borderTop:`1.5px solid ${G.light}` }}>
            <span style={{ color:G.dark }}>Total</span><span style={{ color:G.primary }}>KES 1,305</span>
          </div>
        </CardWrap>

        {/* Delivery */}
        <CardWrap className="p-4">
          <div className="flex items-center gap-2 mb-2">
            <MapPin size={14} color={G.primary}/>
            <span className="text-[13px] font-bold" style={{ color:G.dark }}>Deliver to</span>
          </div>
          <div className="text-[12px]" style={{ color:G.muted }}>Westlands, Nairobi · Home</div>
          <button className="text-[11px] font-semibold mt-1.5" style={{ color:G.secondary }}>Change address</button>
        </CardWrap>
      </div>
      <div className="px-5 pb-6 pt-3 bg-white" style={{ borderTop:`1px solid ${G.light}` }}>
        <PrimaryBtn label="Proceed to Payment — KES 1,305" onClick={()=>go("buyer-checkout")}/>
      </div>
    </div>
  );
}

function BuyerCheckoutScreen({ go }: { go: (s: Screen) => void }) {
  const [copied, setCopied] = useState(false);
  return (
    <div className="flex flex-col min-h-full">
      <GradientHeader>
        <div className="flex items-center gap-3">
          <BackBtn onClick={()=>go("buyer-cart")} light/>
          <h1 className="text-white font-bold text-[17px]">M-Pesa Payment</h1>
        </div>
      </GradientHeader>
      <div className="flex-1 px-5 pt-4 pb-6 overflow-y-auto" style={{ background:G.bg }}>
        {/* M-Pesa instructions */}
        <CardWrap className="p-5 mb-4">
          <div className="flex items-center gap-2 mb-4">
            <img src={securePaymentImg} alt="Secure payment" className="w-10 h-10 object-contain"/>
            <div>
              <div className="text-[15px] font-extrabold" style={{ color:G.dark }}>Pay via M-Pesa</div>
              <div className="text-[11px]" style={{ color:G.muted }}>Funds held securely in escrow</div>
            </div>
          </div>
          <div className="rounded-2xl p-4 mb-4" style={{ background:G.light }}>
            <div className="text-[11px] font-semibold mb-3" style={{ color:G.muted }}>FOLLOW THESE STEPS</div>
            {[
              "Open your M-Pesa app or dial *334#",
              "Select Lipa na M-Pesa → Pay Bill",
              "Enter Business Number: 123456",
              "Enter Account Number: ORD-2847",
              "Enter Amount: KES 1,305",
              "Enter your M-Pesa PIN and confirm",
            ].map((step,i)=>(
              <div key={i} className="flex gap-3 mb-2.5">
                <div className="w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0 text-[10px] font-bold text-white mt-0.5" style={{ background:G.primary }}>{i+1}</div>
                <span className="text-[12px]" style={{ color:G.dark }}>{step}</span>
              </div>
            ))}
          </div>
          <div className="flex gap-3">
            <div className="flex-1 rounded-xl p-3 text-center" style={{ background:"white", border:`1.5px solid ${G.primary}30` }}>
              <div className="text-[10px] font-semibold mb-1" style={{ color:G.muted }}>Paybill Number</div>
              <div className="text-[18px] font-extrabold" style={{ color:G.primary }}>123456</div>
            </div>
            <div className="flex-1 rounded-xl p-3 text-center" style={{ background:"white", border:`1.5px solid ${G.primary}30` }}>
              <div className="text-[10px] font-semibold mb-1" style={{ color:G.muted }}>Account Number</div>
              <div className="flex items-center justify-center gap-1">
                <span className="text-[16px] font-extrabold" style={{ color:G.primary }}>ORD-2847</span>
                <button onClick={()=>{setCopied(true);setTimeout(()=>setCopied(false),2000)}}>
                  {copied?<Check size={13} color={G.success}/>:<Copy size={13} color={G.muted}/>}
                </button>
              </div>
            </div>
          </div>
          <div className="mt-4 flex items-center justify-between p-3 rounded-xl" style={{ background:"#FFFBEB" }}>
            <div className="flex items-center gap-2"><Clock size={14} color={G.gold}/><span className="text-[12px]" style={{ color:G.dark }}>Payment expires in</span></div>
            <span className="text-[16px] font-extrabold" style={{ color:G.gold }}>14:23</span>
          </div>
        </CardWrap>

        <CardWrap className="p-4 mb-4">
          <h3 className="text-[13px] font-bold mb-2" style={{ color:G.dark }}>Payment Summary</h3>
          {[["Subtotal","KES 1,100"],["Delivery fee","KES 150"],["Platform fee","KES 55"]].map(([l,v])=>(
            <div key={l} className="flex justify-between text-[12px] mb-1.5">
              <span style={{ color:G.muted }}>{l}</span><span className="font-semibold" style={{ color:G.dark }}>{v}</span>
            </div>
          ))}
          <div className="flex justify-between font-extrabold text-[14px] pt-2 mt-1" style={{ borderTop:`1.5px solid ${G.light}` }}>
            <span style={{ color:G.dark }}>Total</span><span style={{ color:G.primary }}>KES 1,305</span>
          </div>
        </CardWrap>

        <div className="rounded-2xl p-3.5 flex gap-2" style={{ background:"rgba(27,127,59,0.07)", border:`1px solid rgba(27,127,59,0.2)` }}>
          <Shield size={14} color={G.primary} className="flex-shrink-0 mt-0.5"/>
          <p className="text-[11px]" style={{ color:G.muted }}>Your payment is held in escrow by MAMBONAMI until delivery is confirmed. You can dispute within 48 hours of delivery.</p>
        </div>
      </div>
      <div className="px-5 pb-6 pt-3 bg-white" style={{ borderTop:`1px solid ${G.light}` }}>
        <PrimaryBtn label="I Have Paid — Confirm" onClick={()=>go("buyer-order-tracking")}/>
      </div>
    </div>
  );
}

function BuyerOrderTrackingScreen({ go }: { go: (s: Screen) => void }) {
  const steps = [
    {label:"Order Placed",desc:"Order received and recorded",done:true,time:"10:32 AM"},
    {label:"Payment Received",desc:"Funds secured in escrow",done:true,time:"10:33 AM"},
    {label:"Farmer Accepted",desc:"John Kamau confirmed your order",done:true,time:"10:45 AM"},
    {label:"Order Ready",desc:"Produce packed and ready for pickup",done:true,time:"11:20 AM"},
    {label:"Transport Assigned",desc:"David O. picked up your order",done:true,time:"11:35 AM"},
    {label:"On the Way",desc:"1.2 km away · ETA 8 minutes",done:true,active:true,time:"11:52 AM"},
    {label:"Delivered",desc:"Awaiting confirmation",done:false,time:"—"},
  ];
  return (
    <div className="flex flex-col min-h-full">
      <GradientHeader>
        <div className="flex items-center gap-3 mb-2">
          <BackBtn onClick={()=>go("dash-buyer")} light/>
          <h1 className="text-white font-bold text-[17px]">Order Tracking</h1>
        </div>
        <div className="text-white/80 text-[13px]">Order #ORD-2847 · <span className="font-bold text-white">On the way</span></div>
      </GradientHeader>

      <div className="flex-1 px-5 pt-4 pb-6 overflow-y-auto" style={{ background:G.bg }}>
        {/* Map preview */}
        <CardWrap className="mb-4 overflow-hidden">
          <img src="https://images.unsplash.com/photo-1524661135-423995f22d0b?w=380&h=140&fit=crop" alt="Map" className="w-full h-36 object-cover"/>
          <div className="p-3 flex items-center gap-3">
            <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=40&h=40&fit=crop" alt="Driver" className="w-10 h-10 rounded-xl object-cover"/>
            <div className="flex-1">
              <div className="text-[13px] font-bold" style={{ color:G.dark }}>David Ochieng</div>
              <div className="flex items-center gap-1 text-[11px]" style={{ color:G.muted }}><Truck size={11}/>Motorcycle · KAB 123A</div>
            </div>
            <button className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ background:G.light }}>
              <Phone size={16} color={G.primary}/>
            </button>
          </div>
          <div className="px-3 pb-3 flex gap-2">
            <div className="flex-1 rounded-xl p-2.5 text-center" style={{ background:G.bg }}>
              <div className="text-[14px] font-extrabold" style={{ color:G.dark }}>1.2 km</div>
              <div className="text-[10px]" style={{ color:G.muted }}>Distance</div>
            </div>
            <div className="flex-1 rounded-xl p-2.5 text-center" style={{ background:G.bg }}>
              <div className="text-[14px] font-extrabold" style={{ color:G.dark }}>8 min</div>
              <div className="text-[10px]" style={{ color:G.muted }}>ETA</div>
            </div>
            <div className="flex-1 rounded-xl p-2.5 text-center" style={{ background:G.bg }}>
              <div className="text-[14px] font-extrabold" style={{ color:G.dark }}>★ 4.8</div>
              <div className="text-[10px]" style={{ color:G.muted }}>Rating</div>
            </div>
          </div>
        </CardWrap>

        {/* Timeline */}
        <CardWrap className="p-4">
          <h3 className="text-[13px] font-bold mb-4" style={{ color:G.dark }}>Order Timeline</h3>
          {steps.map((s,i)=>(
            <div key={s.label} className="flex gap-3">
              <div className="flex flex-col items-center">
                <div className="w-7 h-7 rounded-full flex items-center justify-center flex-shrink-0" style={{ background:s.done?(s.active?G.gold:G.primary):G.light }}>
                  {s.done?<Check size={13} color="white"/>:<div className="w-2 h-2 rounded-full" style={{ background:G.muted }}/>}
                </div>
                {i<steps.length-1&&<div className="w-0.5 h-6 mt-1" style={{ background:s.done?G.primary+"50":G.light }}/>}
              </div>
              <div className="pb-4">
                <div className="flex items-center gap-2">
                  <span className="text-[13px] font-bold" style={{ color:s.done?G.dark:G.muted }}>{s.label}</span>
                  {s.active&&<span className="text-[9px] font-bold px-1.5 py-0.5 rounded-full" style={{ background:G.gold+"20",color:G.gold }}>LIVE</span>}
                </div>
                <div className="text-[11px]" style={{ color:G.muted }}>{s.desc}</div>
                <div className="text-[10px] mt-0.5" style={{ color:G.muted }}>{s.time}</div>
              </div>
            </div>
          ))}
        </CardWrap>
      </div>
    </div>
  );
}

function BuyerOrderHistoryScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="flex flex-col min-h-full">
      <div className="px-5 pt-5 pb-3 bg-white flex items-center gap-3" style={{ boxShadow:"0 1px 8px rgba(0,0,0,0.05)" }}>
        <BackBtn onClick={()=>go("dash-buyer")}/>
        <h1 className="font-bold text-[17px]" style={{ color:G.dark }}>Order History</h1>
      </div>
      <div className="flex-1 px-5 pt-4 pb-4 overflow-y-auto" style={{ background:G.bg }}>
        <div className="flex flex-col gap-3">
          {[
            {id:"ORD-2847",items:"Avocado 2kg, Spinach 3 bunch, Tomatoes 3kg",amount:"KES 1,305",status:"Delivered",date:"Today",color:G.success},
            {id:"ORD-2831",items:"Maize 5kg, Sweet Potato 3kg",amount:"KES 720",status:"Delivered",date:"Yesterday",color:G.success},
            {id:"ORD-2814",items:"Avocado 5kg",amount:"KES 1,250",status:"Cancelled",date:"Mon",color:G.error},
            {id:"ORD-2809",items:"Tomatoes 10kg, Spinach 5 bunch",amount:"KES 1,600",status:"Delivered",date:"Last week",color:G.success},
          ].map((o)=>(
            <CardWrap key={o.id} className="p-4" onClick={()=>go("buyer-order-tracking")}>
              <div className="flex justify-between items-start mb-1.5">
                <div>
                  <div className="text-[13px] font-bold" style={{ color:G.dark }}>{o.id}</div>
                  <div className="text-[11px]" style={{ color:G.muted }}>{o.date}</div>
                </div>
                <StatusBadge label={o.status} color={o.color}/>
              </div>
              <div className="text-[11px] mb-2" style={{ color:G.muted }}>{o.items}</div>
              <div className="flex items-center justify-between">
                <span className="text-[14px] font-extrabold" style={{ color:G.primary }}>{o.amount}</span>
                {o.status==="Delivered"&&(
                  <button className="px-3 py-1.5 rounded-xl text-[11px] font-bold" style={{ background:G.light, color:G.primary }}>Reorder</button>
                )}
              </div>
            </CardWrap>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── TRANSPORT SCREENS ────────────────────────────────────────────────────────

function TransportDash({ go }: { go: (s: Screen) => void }) {
  const [nav, setNav] = useState(0);
  const [online, setOnline] = useState(true);
  const handleNav = (i: number) => {
    if (i === 1) go("transport-available");
    else if (i === 2) go("transport-trips");
    else if (i === 4) go("profile");
    else setNav(i);
  };
  return (
    <div className="flex flex-col min-h-full">
      <div className="relative overflow-hidden px-5 pt-4 pb-5" style={{ background: online ? `linear-gradient(135deg,${G.primary},${G.secondary})` : "linear-gradient(135deg,#374151,#4B5563)" }}>
        <div className="absolute -top-10 -right-10 w-36 h-36 rounded-full opacity-10 bg-white"/>
        <div className="flex justify-between items-center mb-3 relative z-10">
          <div>
            <div className="text-white/70 text-[11px]">Transport Provider</div>
            <div className="text-white font-extrabold text-[19px]">David Ochieng</div>
            <div className="flex items-center gap-1 text-white/70 text-[11px]"><Star size={10} fill="currentColor"/>4.8 rating</div>
          </div>
          <div className="flex gap-2">
            <button onClick={()=>go("notifications")} className="w-9 h-9 rounded-xl flex items-center justify-center relative" style={{ background:"rgba(255,255,255,0.2)" }}>
              <Bell size={18} color="white"/>
            </button>
            <button onClick={()=>go("profile")} className="w-9 h-9 rounded-xl overflow-hidden">
              <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=40&h=40&fit=crop" alt="Profile" className="w-full h-full object-cover"/>
            </button>
          </div>
        </div>
        <div className="flex items-center justify-between p-3 rounded-2xl relative z-10" style={{ background:"rgba(255,255,255,0.15)" }}>
          <div>
            <div className="text-white font-bold text-[14px]">{online?"You are Online ✓":"You are Offline"}</div>
            <div className="text-white/70 text-[11px]">{online?"Ready to accept orders":"Toggle to go online"}</div>
          </div>
          <button onClick={()=>setOnline(!online)}>
            {online?<ToggleRight size={42} color={G.gold}/>:<ToggleLeft size={42} color="rgba(255,255,255,0.5)"/>}
          </button>
        </div>
      </div>

      <div className="flex-1 px-5 pt-4 pb-2 overflow-y-auto" style={{ background:G.bg }}>
        {/* Stats */}
        <div className="grid grid-cols-3 gap-3 mb-4">
          {[["KES 6,450","Today's Earnings"],["3","Deliveries"],["124 km","Distance"]].map(([v,l])=>(
            <CardWrap key={l} className="p-3 text-center">
              <div className="text-[16px] font-extrabold" style={{ color:G.primary }}>{v}</div>
              <div className="text-[10px] mt-0.5" style={{ color:G.muted }}>{l}</div>
            </CardWrap>
          ))}
        </div>

        {/* Chart */}
        <CardWrap className="p-4 mb-4">
          <div className="flex justify-between mb-3">
            <span className="text-[13px] font-bold" style={{ color:G.dark }}>Weekly Earnings</span>
            <span className="text-[11px] font-bold" style={{ color:G.success }}>▲ 12.4%</span>
          </div>
          <ResponsiveContainer width="100%" height={100}>
            <BarChart data={earningsData} barSize={22}>
              <Bar dataKey="val" fill={G.primary} radius={[6,6,0,0]}/>
              <XAxis dataKey="day" tick={{ fontSize:10,fill:G.muted }} axisLine={false} tickLine={false}/>
              <Tooltip formatter={(v:number)=>[`KES ${v.toLocaleString()}`]} contentStyle={{ borderRadius:12,fontSize:11 }}/>
            </BarChart>
          </ResponsiveContainer>
        </CardWrap>

        {/* Current delivery */}
        {online&&(
          <CardWrap className="mb-4 overflow-hidden">
            <img src="https://images.unsplash.com/photo-1524661135-423995f22d0b?w=380&h=110&fit=crop" alt="Map" className="w-full h-28 object-cover"/>
            <div className="p-4">
              <div className="flex justify-between items-center mb-2">
                <div>
                  <div className="text-[11px]" style={{ color:G.muted }}>Active Delivery</div>
                  <div className="text-[14px] font-bold" style={{ color:G.dark }}>Order #ORD-3821</div>
                </div>
                <StatusBadge label="Picked Up" color={G.secondary}/>
              </div>
              <div className="flex items-center gap-2 text-[11px] mb-3" style={{ color:G.muted }}>
                <MapPin size={12} color={G.error}/>Westlands → Karen · <span className="font-bold" style={{ color:G.dark }}>6.4 km · 18 min</span>
              </div>
              <PrimaryBtn label="Mark as Delivered" onClick={()=>go("transport-delivery-otp")}/>
            </div>
          </CardWrap>
        )}

        {/* Pending offers */}
        {online&&(
          <>
            <SectionHeader title="New Order Offers" action="View all" onAction={()=>go("transport-available")}/>
            <CardWrap className="p-4 mb-4">
              <div className="flex justify-between items-start mb-2">
                <div>
                  <div className="text-[13px] font-bold" style={{ color:G.dark }}>ORD-3822 · 🏍️ Motorcycle</div>
                  <div className="text-[11px]" style={{ color:G.muted }}>Kiambu → Westlands · 8.2 km</div>
                </div>
                <div className="text-[15px] font-extrabold" style={{ color:G.primary }}>KES 480</div>
              </div>
              <div className="flex gap-2">
                <PrimaryBtn label="Accept" onClick={()=>{}} small/>
                <PrimaryBtn label="Decline" onClick={()=>{}} variant="outline" small full={false}/>
              </div>
              <div className="flex items-center gap-2 mt-2 text-[11px]" style={{ color:G.warning }}>
                <Clock size={12}/>Expires in <span className="font-bold">00:47</span>
              </div>
            </CardWrap>
          </>
        )}

        {/* Performance */}
        <SectionHeader title="Performance"/>
        <CardWrap className="p-4 mb-2">
          <div className="flex items-center gap-4">
            <div className="text-center">
              <div className="text-[24px] font-extrabold" style={{ color:G.gold }}>4.8</div>
              <div className="flex gap-0.5">{[1,2,3,4,5].map(i=><Star key={i} size={11} color={G.gold} fill={i<=4?G.gold:"none"}/>)}</div>
              <div className="text-[9px] mt-0.5" style={{ color:G.muted }}>Rating</div>
            </div>
            <div className="flex-1 flex flex-col gap-2">
              {[["On-time",96],["Accepted",88],["Completion",99]].map(([l,v])=>(
                <div key={l}>
                  <div className="flex justify-between text-[10px] mb-0.5">
                    <span style={{ color:G.muted }}>{l}</span>
                    <span className="font-bold" style={{ color:G.dark }}>{v}%</span>
                  </div>
                  <div className="h-1.5 rounded-full" style={{ background:G.light }}>
                    <div className="h-full rounded-full" style={{ width:`${v}%`, background:G.secondary }}/>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </CardWrap>
      </div>
      <BottomNav active={nav} setActive={handleNav} items={transportNavItems}/>
    </div>
  );
}

function TransportAvailableScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="flex flex-col min-h-full">
      <GradientHeader>
        <div className="flex items-center gap-3">
          <BackBtn onClick={()=>go("dash-transport")} light/>
          <h1 className="text-white font-bold text-[17px]">Available Orders</h1>
        </div>
      </GradientHeader>
      <div className="flex-1 px-5 pt-4 pb-4 overflow-y-auto" style={{ background:G.bg }}>
        <div className="flex flex-col gap-3">
          {[
            {id:"ORD-3822",from:"Kiambu Central",to:"Westlands, Nairobi",dist:"8.2 km",weight:"15 kg",vehicle:"🏍️",fee:"KES 480",expires:"00:47"},
            {id:"ORD-3824",from:"Thika Rd, Nairobi",to:"Karen, Nairobi",dist:"14.1 km",weight:"50 kg",vehicle:"🛻",fee:"KES 850",expires:"05:20"},
            {id:"ORD-3825",from:"Limuru",to:"Westlands",dist:"22 km",weight:"200 kg",vehicle:"🚛",fee:"KES 1,800",expires:"09:15"},
          ].map((o)=>(
            <CardWrap key={o.id} className="p-4">
              <div className="flex justify-between items-start mb-3">
                <div>
                  <div className="text-[13px] font-bold" style={{ color:G.dark }}>{o.id} {o.vehicle}</div>
                  <div className="text-[10px] mt-0.5" style={{ color:G.muted }}>{o.weight} · {o.dist}</div>
                </div>
                <div className="text-[17px] font-extrabold" style={{ color:G.primary }}>{o.fee}</div>
              </div>
              <div className="flex items-start gap-3 mb-3">
                <div className="flex flex-col items-center gap-1 mt-1">
                  <div className="w-2 h-2 rounded-full" style={{ background:G.success }}/>
                  <div className="w-0.5 h-5" style={{ background:G.light }}/>
                  <div className="w-2 h-2 rounded-full" style={{ background:G.error }}/>
                </div>
                <div className="flex-1">
                  <div className="text-[12px] font-semibold" style={{ color:G.dark }}>{o.from}</div>
                  <div className="text-[11px] mb-2" style={{ color:G.muted }}>Pickup location</div>
                  <div className="text-[12px] font-semibold" style={{ color:G.dark }}>{o.to}</div>
                  <div className="text-[11px]" style={{ color:G.muted }}>Delivery location</div>
                </div>
              </div>
              <div className="flex gap-2 items-center">
                <PrimaryBtn label="Accept" onClick={()=>go("dash-transport")} small/>
                <PrimaryBtn label="Decline" onClick={()=>{}} variant="outline" small full={false}/>
                <div className="flex items-center gap-1 ml-auto text-[11px]" style={{ color:G.warning }}>
                  <Clock size={12}/><span className="font-bold">{o.expires}</span>
                </div>
              </div>
            </CardWrap>
          ))}
        </div>
      </div>
    </div>
  );
}

function TransportDeliveryOtpScreen({ go }: { go: (s: Screen) => void }) {
  const [otp, setOtp] = useState(["","","",""]);
  const [photoTaken, setPhotoTaken] = useState(false);
  return (
    <div className="flex flex-col min-h-full px-5 pt-5">
      <div className="flex items-center gap-3 mb-6">
        <BackBtn onClick={()=>go("dash-transport")}/>
        <div>
          <h2 className="font-bold text-[15px]" style={{ color:G.dark }}>Confirm Delivery</h2>
          <p className="text-[11px]" style={{ color:G.muted }}>Order #ORD-3821</p>
        </div>
      </div>

      <CardWrap className="p-4 mb-5">
        <div className="flex items-center gap-3">
          <img src="https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=48&h=48&fit=crop" alt="Buyer" className="w-12 h-12 rounded-xl object-cover"/>
          <div>
            <div className="text-[14px] font-bold" style={{ color:G.dark }}>Mary Wanjiku</div>
            <div className="text-[11px]" style={{ color:G.muted }}>Westlands, Nairobi</div>
          </div>
        </div>
      </CardWrap>

      <div className="text-center mb-5">
        <div className="w-16 h-16 rounded-2xl flex items-center justify-center mx-auto mb-3" style={{ background:G.light }}>
          <Shield size={28} color={G.primary}/>
        </div>
        <h3 className="text-[17px] font-extrabold" style={{ color:G.dark }}>Enter Delivery OTP</h3>
        <p className="text-[12px] mt-1" style={{ color:G.muted }}>Ask the buyer for the 4-digit code shown in their app</p>
      </div>

      <div className="flex gap-3 justify-center mb-5">
        {otp.map((v,i)=>(
          <div key={i} className="w-16 h-16 rounded-2xl flex items-center justify-center text-2xl font-bold border-2"
            style={{ borderColor:v?G.primary:"rgba(27,127,59,0.2)", background:v?G.light:"white", color:G.primary, fontFamily:font }}>
            {v}
          </div>
        ))}
      </div>

      {/* Photo capture */}
      <div className="mb-5">
        <div className="text-[13px] font-semibold mb-2" style={{ color:G.dark }}>Delivery Photo <span style={{ color:G.error }}>*</span></div>
        {!photoTaken ? (
          <button onClick={()=>setPhotoTaken(true)} className="w-full h-28 rounded-2xl border-2 border-dashed flex flex-col items-center justify-center gap-2" style={{ borderColor:G.primary+"40" }}>
            <Camera size={24} color={G.muted}/>
            <span className="text-[12px]" style={{ color:G.muted }}>Take a photo at delivery location</span>
          </button>
        ):(
          <div className="relative">
            <img src="https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=110&fit=crop" alt="Delivery" className="w-full h-28 object-cover rounded-2xl"/>
            <div className="absolute top-2 right-2 w-8 h-8 rounded-lg flex items-center justify-center" style={{ background:G.success }}>
              <Check size={16} color="white"/>
            </div>
          </div>
        )}
      </div>

      <div className="rounded-2xl p-3 mb-5 flex gap-2" style={{ background:"#FFFBEB", border:`1px solid ${G.gold}30` }}>
        <AlertTriangle size={14} color={G.gold} className="flex-shrink-0 mt-0.5"/>
        <p className="text-[11px]" style={{ color:G.muted }}>OTP expires in <span className="font-bold" style={{ color:G.gold }}>5 minutes</span>. Max 3 attempts. Escrow released to farmer and you after confirmation.</p>
      </div>

      <PrimaryBtn label="Confirm Delivery ✓" onClick={()=>go("dash-transport")} />
    </div>
  );
}

function TransportTripsScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="flex flex-col min-h-full">
      <GradientHeader>
        <div className="flex items-center gap-3">
          <BackBtn onClick={()=>go("dash-transport")} light/>
          <h1 className="text-white font-bold text-[17px]">My Trips</h1>
        </div>
      </GradientHeader>
      <div className="flex-1 px-5 pt-4 pb-4 overflow-y-auto" style={{ background:G.bg }}>
        <div className="flex flex-col gap-3">
          {[
            {id:"ORD-3821",from:"Kiambu",to:"Westlands",dist:"8.2 km",fee:"KES 480",status:"Completed",date:"Today 11:55"},
            {id:"ORD-3815",from:"Thika Rd",to:"Karen",dist:"14.1 km",fee:"KES 850",status:"Completed",date:"Today 09:30"},
            {id:"ORD-3810",from:"Limuru",to:"Westlands",dist:"22 km",fee:"KES 1,800",status:"Completed",date:"Yesterday"},
            {id:"ORD-3805",from:"Kiambu",to:"CBD",dist:"12 km",fee:"KES 520",status:"Cancelled",date:"Mon"},
          ].map((t)=>(
            <CardWrap key={t.id} className="p-4">
              <div className="flex justify-between items-start mb-2">
                <div className="text-[12px] font-bold" style={{ color:G.dark }}>{t.id}</div>
                <StatusBadge label={t.status} color={t.status==="Completed"?G.success:G.error}/>
              </div>
              <div className="flex items-start gap-3 mb-2">
                <div className="flex flex-col items-center gap-1 mt-1">
                  <div className="w-2 h-2 rounded-full" style={{ background:G.success }}/>
                  <div className="w-0.5 h-4" style={{ background:G.light }}/>
                  <div className="w-2 h-2 rounded-full" style={{ background:G.error }}/>
                </div>
                <div className="flex-1">
                  <div className="text-[12px]" style={{ color:G.dark }}>{t.from}</div>
                  <div className="text-[12px]" style={{ color:G.dark }}>{t.to}</div>
                </div>
                <div className="text-right">
                  <div className="text-[14px] font-extrabold" style={{ color:G.primary }}>{t.fee}</div>
                  <div className="text-[10px]" style={{ color:G.muted }}>{t.dist}</div>
                  <div className="text-[10px]" style={{ color:G.muted }}>{t.date}</div>
                </div>
              </div>
            </CardWrap>
          ))}
        </div>
      </div>
    </div>
  );
}

// ─── BUYER DISPUTE ────────────────────────────────────────────────────────────

function BuyerDisputeScreen({ go }: { go: (s: Screen) => void }) {
  const [tab, setTab] = useState(0);
  const [issueType, setIssueType] = useState("Wrong item received");
  const [submitted, setSubmitted] = useState(false);

  return (
    <div className="flex flex-col min-h-full">
      <GradientHeader colors={[G.dark, G.primary]}>
        <div className="flex items-center gap-3">
          <BackBtn onClick={() => go("buyer-order-history")} light />
          <div>
            <h1 className="text-white font-bold text-[17px]">Raise a Dispute</h1>
            <p className="text-white/70 text-[11px]">Order #ORD-2847</p>
          </div>
        </div>
      </GradientHeader>

      {/* Tabs */}
      <div className="flex bg-white" style={{ borderBottom: `1px solid ${G.light}` }}>
        {["New Dispute", "My Disputes"].map((t, i) => (
          <button key={t} onClick={() => setTab(i)} className="flex-1 py-3 text-[13px] font-semibold transition-all"
            style={{ color: tab === i ? G.primary : G.muted, borderBottom: tab === i ? `2px solid ${G.primary}` : "2px solid transparent" }}>{t}</button>
        ))}
      </div>

      <div className="flex-1 px-5 pt-4 pb-6 overflow-y-auto" style={{ background: G.bg }}>
        {tab === 0 ? (
          submitted ? (
            <div className="flex flex-col items-center justify-center min-h-[60vh] gap-4">
              <div className="w-20 h-20 rounded-full flex items-center justify-center" style={{ background: G.success + "20" }}>
                <CheckCircle2 size={40} color={G.success} />
              </div>
              <h2 className="text-[18px] font-extrabold text-center" style={{ color: G.dark, fontFamily: headFont }}>Dispute Submitted</h2>
              <p className="text-[12px] text-center" style={{ color: G.muted }}>Our team will review and respond within 24 hours. Escrow funds are frozen pending resolution.</p>
              <PrimaryBtn label="Back to Orders" onClick={() => go("buyer-order-history")} />
            </div>
          ) : (
            <div className="flex flex-col gap-4">
              <CardWrap className="p-4">
                <h3 className="text-[13px] font-bold mb-3" style={{ color: G.dark }}>Issue Type</h3>
                <div className="flex flex-col gap-2">
                  {["Wrong item received", "Item damaged / spoiled", "Quantity short", "Delivery not received", "Other"].map((opt) => (
                    <button key={opt} onClick={() => setIssueType(opt)}
                      className="flex items-center gap-3 p-3 rounded-xl text-left transition-all"
                      style={{ background: issueType === opt ? G.light : "white", border: `1.5px solid ${issueType === opt ? G.primary : "rgba(27,127,59,0.12)"}` }}>
                      <div className="w-4 h-4 rounded-full border-2 flex items-center justify-center flex-shrink-0"
                        style={{ borderColor: issueType === opt ? G.primary : G.muted }}>
                        {issueType === opt && <div className="w-2 h-2 rounded-full" style={{ background: G.primary }} />}
                      </div>
                      <span className="text-[12px] font-semibold" style={{ color: G.dark }}>{opt}</span>
                    </button>
                  ))}
                </div>
              </CardWrap>

              <CardWrap className="p-4">
                <h3 className="text-[13px] font-bold mb-2" style={{ color: G.dark }}>Evidence Photos</h3>
                <p className="text-[11px] mb-3" style={{ color: G.muted }}>Attach photos showing the issue (max 3)</p>
                <div className="flex gap-2">
                  {[1, 2, 3].map((i) => (
                    <div key={i} className="w-20 h-20 rounded-xl border-2 border-dashed flex items-center justify-center cursor-pointer"
                      style={{ borderColor: G.primary + "40", background: G.light }}>
                      {i === 1 ? <Camera size={20} color={G.primary} /> : <Plus size={16} color={G.muted} />}
                    </div>
                  ))}
                </div>
              </CardWrap>

              <CardWrap className="p-4">
                <h3 className="text-[13px] font-bold mb-2" style={{ color: G.dark }}>Describe the Issue</h3>
                <textarea placeholder="What went wrong with your order? Be as specific as possible..." rows={4}
                  style={{ width: "100%", borderRadius: 14, border: `1.5px solid rgba(27,127,59,0.2)`, padding: "12px 14px", background: "white", fontFamily: font, fontSize: 12, outline: "none", color: G.dark, resize: "none" }} />
              </CardWrap>

              <div className="rounded-2xl p-3.5 flex gap-2" style={{ background: "#FFFBEB", border: `1px solid ${G.gold}30` }}>
                <AlertTriangle size={14} color={G.gold} className="flex-shrink-0 mt-0.5" />
                <p className="text-[11px]" style={{ color: G.muted }}>Escrow funds (KES 1,305) will remain frozen until your dispute is resolved. False claims may lead to account suspension.</p>
              </div>

              <PrimaryBtn label="Submit Dispute" onClick={() => setSubmitted(true)} />
            </div>
          )
        ) : (
          <div className="flex flex-col gap-3">
            {[
              { id: "DSP-102", order: "ORD-2701", issue: "Wrong item received", status: "Under Review", color: G.warning, date: "2 days ago" },
              { id: "DSP-098", order: "ORD-2655", issue: "Quantity short", status: "Resolved", color: G.success, date: "1 week ago" },
            ].map((d) => (
              <CardWrap key={d.id} className="p-4">
                <div className="flex justify-between items-start mb-2">
                  <div>
                    <div className="text-[13px] font-bold" style={{ color: G.dark }}>{d.id}</div>
                    <div className="text-[11px]" style={{ color: G.muted }}>Order {d.order} · {d.date}</div>
                  </div>
                  <StatusBadge label={d.status} color={d.color} />
                </div>
                <div className="text-[12px]" style={{ color: G.dark }}>{d.issue}</div>
              </CardWrap>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

// ─── RETAILER DASHBOARD ───────────────────────────────────────────────────────

function RetailerDash({ go }: { go: (s: Screen) => void }) {
  const [nav, setNav] = useState(0);
  const handleNav = (i: number) => {
    if (i === 4) go("profile");
    else setNav(i);
  };
  return (
    <div className="flex flex-col min-h-full">
      <GradientHeader colors={["#4C1D95","#6D28D9"]}>
        <div className="flex justify-between items-center mb-1">
          <div>
            <div className="text-white/70 text-[11px]">Retailer Dashboard</div>
            <div className="text-white font-extrabold text-[18px]">Kamau Fresh Groceries</div>
            <div className="flex items-center gap-1 text-white/70 text-[11px] mt-0.5"><MapPin size={10}/>Tom Mboya St, Nairobi</div>
          </div>
          <div className="flex gap-2">
            <button onClick={()=>go("notifications")} className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ background:"rgba(255,255,255,0.2)" }}>
              <Bell size={18} color="white"/>
            </button>
            <button onClick={()=>go("profile")} className="w-9 h-9 rounded-xl overflow-hidden">
              <img src="https://images.unsplash.com/photo-1560250097-0dc05ae89d08?w=40&h=40&fit=crop" alt="Profile" className="w-full h-full object-cover"/>
            </button>
          </div>
        </div>
      </GradientHeader>

      <div className="flex-1 px-5 pt-4 pb-2 overflow-y-auto" style={{ background:G.bg }}>
        <CardWrap className="p-4 mb-4">
          <div className="flex justify-between items-start mb-2">
            <div>
              <span className="text-[11px]" style={{ color:G.muted }}>Monthly Purchases</span>
              <div className="text-[22px] font-extrabold" style={{ color:G.dark }}>KES 270,400</div>
            </div>
            <span className="text-[11px] font-bold px-2 py-1 rounded-lg" style={{ background:G.success+"15",color:G.success }}>▲ 8.1%</span>
          </div>
          <ResponsiveContainer width="100%" height={90}>
            <BarChart data={purchaseData} barSize={32}>
              <Bar dataKey="val" fill="#6D28D9" radius={[6,6,0,0]}/>
              <XAxis dataKey="week" tick={{ fontSize:10,fill:G.muted }} axisLine={false} tickLine={false}/>
              <Tooltip formatter={(v:number)=>[`KES ${v.toLocaleString()}`]} contentStyle={{ borderRadius:12,fontSize:11 }}/>
            </BarChart>
          </ResponsiveContainer>
        </CardWrap>

        <div className="grid grid-cols-2 gap-3 mb-4">
          <CardWrap className="p-3.5">
            <div className="w-9 h-9 rounded-xl flex items-center justify-center mb-2" style={{ background:G.purple+"15" }}><ShoppingCart size={16} color={G.purple}/></div>
            <div className="text-[17px] font-extrabold" style={{ color:G.primary }}>8</div>
            <div className="text-[10px]" style={{ color:G.muted }}>Active Orders</div>
          </CardWrap>
          <CardWrap className="p-3.5">
            <div className="w-9 h-9 rounded-xl flex items-center justify-center mb-2" style={{ background:G.secondary+"15" }}><Store size={16} color={G.secondary}/></div>
            <div className="text-[17px] font-extrabold" style={{ color:G.primary }}>24</div>
            <div className="text-[10px]" style={{ color:G.muted }}>Suppliers</div>
          </CardWrap>
        </div>

        <SectionHeader title="Quick Reorder" action="All items"/>
        <div className="flex flex-col gap-2 mb-4">
          {[
            {name:"Avocado",supplier:"Kamau Farm",qty:"50 kg",price:"KES 12,500",img:"https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=50&h=50&fit=crop"},
            {name:"Tomatoes",supplier:"Wanjiku Farm",qty:"100 kg",price:"KES 9,000",img:"https://images.unsplash.com/photo-1546470427-e26264be0b07?w=50&h=50&fit=crop"},
            {name:"Sukuma Wiki",supplier:"Thika Farms",qty:"200 bunches",price:"KES 4,000",img:"https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=50&h=50&fit=crop"},
          ].map((p)=>(
            <CardWrap key={p.name} className="flex items-center gap-3 p-3">
              <img src={p.img} alt={p.name} className="w-12 h-12 object-cover rounded-xl"/>
              <div className="flex-1">
                <div className="text-[12px] font-bold" style={{ color:G.dark }}>{p.name}</div>
                <div className="text-[10px]" style={{ color:G.muted }}>{p.supplier} · {p.qty}</div>
                <div className="text-[12px] font-extrabold mt-0.5" style={{ color:G.primary }}>{p.price}</div>
              </div>
              <button className="px-3 py-1.5 rounded-xl text-[11px] font-bold text-white" style={{ background:G.primary }}>Reorder</button>
            </CardWrap>
          ))}
        </div>

        <SectionHeader title="Active Orders" action="View all"/>
        <div className="flex flex-col gap-2 pb-2">
          {[
            {id:"ORD-4821",farmer:"Kamau Farm",item:"Avocado 50kg",amount:"KES 12,500",status:"Picked Up",color:G.secondary},
            {id:"ORD-4819",farmer:"Wanjiku Farm",item:"Tomatoes 100kg",amount:"KES 9,000",status:"Farmer Ready",color:G.warning},
          ].map((o)=>(
            <CardWrap key={o.id} className="p-3">
              <div className="flex justify-between items-center mb-1">
                <span className="text-[12px] font-bold" style={{ color:G.dark }}>{o.id}</span>
                <StatusBadge label={o.status} color={o.color}/>
              </div>
              <div className="text-[11px] mb-1" style={{ color:G.muted }}>{o.farmer} · {o.item}</div>
              <div className="flex justify-between items-center">
                <span className="text-[13px] font-extrabold" style={{ color:G.primary }}>{o.amount}</span>
                <ChevronRight size={14} color={G.muted}/>
              </div>
            </CardWrap>
          ))}
        </div>
      </div>
      <BottomNav active={nav} setActive={handleNav} items={retailerNavItems}/>
    </div>
  );
}

// ─── COMMON SCREENS ───────────────────────────────────────────────────────────

function NotificationsScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="flex flex-col min-h-full">
      <div className="px-5 pt-5 pb-3 bg-white flex items-center gap-3" style={{ boxShadow:"0 1px 8px rgba(0,0,0,0.05)" }}>
        <BackBtn onClick={()=>go("dash-farmer")}/>
        <h1 className="font-bold text-[17px]" style={{ color:G.dark }}>Notifications</h1>
        <div className="flex-1"/>
        <button className="text-[12px] font-semibold" style={{ color:G.secondary }}>Mark all read</button>
      </div>
      <div className="flex-1 px-5 pt-4 pb-4 overflow-y-auto" style={{ background:G.bg }}>
        {[
          {icon:"💰",title:"Payment Received",desc:"KES 3,200 received for Order #ORD-3840",time:"2 min ago",unread:true,color:G.success},
          {icon:"📦",title:"New Order Request",desc:"Mary Wanjiku wants 5kg Sukuma Wiki",time:"15 min ago",unread:true,color:G.primary},
          {icon:"🚛",title:"Transport Assigned",desc:"David O. will pick up Order #ORD-3838",time:"32 min ago",unread:true,color:G.secondary},
          {icon:"⭐",title:"New Review",desc:"James gave you 5 stars for fresh tomatoes",time:"1 hr ago",unread:false,color:G.gold},
          {icon:"📢",title:"Market Price Update",desc:"Avocado market price: KES 280/kg today",time:"2 hr ago",unread:false,color:G.warning},
          {icon:"✅",title:"Order Delivered",desc:"Order #ORD-3830 delivered successfully",time:"3 hr ago",unread:false,color:G.success},
          {icon:"💳",title:"Payout Sent",desc:"KES 8,450 sent to your M-Pesa",time:"Yesterday",unread:false,color:G.primary},
        ].map((n,i)=>(
          <CardWrap key={i} className={`flex gap-3 p-3.5 mb-2 ${n.unread?"border-l-4":""}`} style={{ borderColor:n.unread?G.primary:undefined }}>
            <div className="w-10 h-10 rounded-xl flex items-center justify-center text-xl flex-shrink-0" style={{ background:n.color+"15" }}>
              {n.icon}
            </div>
            <div className="flex-1">
              <div className="flex justify-between items-start">
                <span className="text-[13px] font-bold" style={{ color:G.dark }}>{n.title}</span>
                {n.unread&&<div className="w-2 h-2 rounded-full mt-1 flex-shrink-0" style={{ background:G.primary }}/>}
              </div>
              <div className="text-[11px] mt-0.5" style={{ color:G.muted }}>{n.desc}</div>
              <div className="text-[10px] mt-1" style={{ color:G.muted }}>{n.time}</div>
            </div>
          </CardWrap>
        ))}
      </div>
    </div>
  );
}

function ProfileScreen({ go, role }: { go: (s: Screen) => void; role: Role }) {
  return (
    <div className="flex flex-col min-h-full">
      <GradientHeader>
        <div className="flex items-center gap-3 mb-4">
          <BackBtn onClick={()=>go(`dash-${role}` as Screen)} light/>
          <h1 className="text-white font-bold text-[17px]">My Profile</h1>
          <div className="flex-1"/>
          <button className="w-9 h-9 rounded-xl flex items-center justify-center" style={{ background:"rgba(255,255,255,0.2)" }}>
            <Edit2 size={16} color="white"/>
          </button>
        </div>
        <div className="flex items-center gap-4">
          <div className="relative">
            <div className="w-18 h-18 rounded-2xl overflow-hidden" style={{ width:72,height:72,boxShadow:"0 4px 16px rgba(0,0,0,0.2)" }}>
              <img src="https://images.unsplash.com/photo-1531123897727-8f129e1688ce?w=72&h=72&fit=crop" alt="Profile" className="w-full h-full object-cover"/>
            </div>
            <div className="absolute -bottom-1 -right-1 w-6 h-6 rounded-full flex items-center justify-center" style={{ background:G.success }}>
              <Check size={12} color="white"/>
            </div>
          </div>
          <div>
            <div className="text-white font-extrabold text-[18px]">John Kamau</div>
            <div className="text-white/75 text-[11px]">+254 712 345 678</div>
            <div className="flex items-center gap-1 mt-1">
              <span className="text-[10px] font-bold px-2 py-0.5 rounded-full" style={{ background:"rgba(212,175,55,0.3)", color:G.gold }}>✓ Verified Farmer</span>
            </div>
          </div>
        </div>
      </GradientHeader>

      <div className="flex-1 px-5 pt-4 pb-6 overflow-y-auto" style={{ background:G.bg }}>
        {/* Stats */}
        <div className="grid grid-cols-3 gap-3 mb-5">
          {[["KES 45,750","Earnings"],["4.8 ★","Rating"],["48","Orders"]].map(([v,l])=>(
            <CardWrap key={l} className="p-3 text-center">
              <div className="text-[15px] font-extrabold" style={{ color:G.primary }}>{v}</div>
              <div className="text-[10px] mt-0.5" style={{ color:G.muted }}>{l}</div>
            </CardWrap>
          ))}
        </div>

        {/* Verification */}
        <CardWrap className="p-4 mb-4">
          <h3 className="text-[13px] font-bold mb-3" style={{ color:G.dark }}>Verification Status</h3>
          {[
            {label:"Phone Number",done:true},
            {label:"National ID",done:true},
            {label:"Cooperative Endorsement",done:true},
            {label:"Farm GPS Location",done:true},
            {label:"Bank Account",done:false},
          ].map((v)=>(
            <div key={v.label} className="flex items-center justify-between py-2" style={{ borderBottom:`1px solid ${G.light}` }}>
              <span className="text-[12px]" style={{ color:G.dark }}>{v.label}</span>
              {v.done
                ?<span className="text-[10px] font-bold px-2 py-0.5 rounded-full" style={{ background:G.success+"15",color:G.success }}>✓ Verified</span>
                :<button className="text-[10px] font-bold px-2 py-0.5 rounded-full" style={{ background:G.warning+"15",color:G.warning }}>Add</button>
              }
            </div>
          ))}
        </CardWrap>

        {/* Menu items */}
        {[
          {icon:<Wallet size={18} color={G.primary}/>, label:"Wallet & Payouts", sub:"M-Pesa · Bank"},
          {icon:<Bell size={18} color={G.primary}/>, label:"Notifications", sub:"Order, payment alerts"},
          {icon:<Settings size={18} color={G.primary}/>, label:"Settings", action:()=>go("settings")},
          {icon:<HelpCircle size={18} color={G.primary}/>, label:"Help & Support", action:()=>go("support")},
        ].map((item,i)=>(
          <CardWrap key={i} className="flex items-center gap-3 p-4 mb-2" onClick={item.action}>
            <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background:G.light }}>{item.icon}</div>
            <div className="flex-1">
              <div className="text-[13px] font-semibold" style={{ color:G.dark }}>{item.label}</div>
              {item.sub&&<div className="text-[11px]" style={{ color:G.muted }}>{item.sub}</div>}
            </div>
            <ChevronRight size={16} color={G.muted}/>
          </CardWrap>
        ))}

        <button className="w-full flex items-center gap-3 p-4 rounded-2xl mt-2" style={{ background:G.error+"10" }} onClick={()=>go("welcome")}>
          <div className="w-10 h-10 rounded-xl flex items-center justify-center" style={{ background:G.error+"15" }}><LogOut size={18} color={G.error}/></div>
          <span className="text-[13px] font-semibold" style={{ color:G.error }}>Log Out</span>
        </button>
      </div>
    </div>
  );
}

function SettingsScreen({ go }: { go: (s: Screen) => void }) {
  const [notif, setNotif] = useState(true);
  const [darkMode, setDarkMode] = useState(false);
  const [location, setLocation] = useState(true);
  return (
    <div className="flex flex-col min-h-full">
      <div className="px-5 pt-5 pb-3 bg-white flex items-center gap-3" style={{ boxShadow:"0 1px 8px rgba(0,0,0,0.05)" }}>
        <BackBtn onClick={()=>go("profile")}/>
        <h1 className="font-bold text-[17px]" style={{ color:G.dark }}>Settings</h1>
      </div>
      <div className="flex-1 px-5 pt-4 pb-6 overflow-y-auto" style={{ background:G.bg }}>
        {/* Account */}
        <div className="text-[11px] font-bold mb-2 uppercase tracking-wide" style={{ color:G.muted }}>Account</div>
        {[
          {label:"Edit Profile",sub:"Name, phone, photo"},
          {label:"Change Password",sub:"Update security credentials"},
          {label:"Linked Accounts",sub:"Google, M-Pesa"},
          {label:"Language",sub:"English / Kiswahili"},
        ].map((s)=>(
          <CardWrap key={s.label} className="flex items-center justify-between p-4 mb-2">
            <div>
              <div className="text-[13px] font-semibold" style={{ color:G.dark }}>{s.label}</div>
              <div className="text-[11px]" style={{ color:G.muted }}>{s.sub}</div>
            </div>
            <ChevronRight size={15} color={G.muted}/>
          </CardWrap>
        ))}

        <div className="text-[11px] font-bold mb-2 mt-4 uppercase tracking-wide" style={{ color:G.muted }}>Preferences</div>
        {[
          {label:"Push Notifications",sub:"Orders, payments, updates",val:notif,set:setNotif},
          {label:"Dark Mode",sub:"Switch app appearance",val:darkMode,set:setDarkMode},
          {label:"Location Access",sub:"For GPS and delivery",val:location,set:setLocation},
        ].map((s)=>(
          <CardWrap key={s.label} className="flex items-center justify-between p-4 mb-2">
            <div>
              <div className="text-[13px] font-semibold" style={{ color:G.dark }}>{s.label}</div>
              <div className="text-[11px]" style={{ color:G.muted }}>{s.sub}</div>
            </div>
            <button onClick={()=>s.set(!s.val)}>
              {s.val?<ToggleRight size={36} color={G.primary}/>:<ToggleLeft size={36} color={G.muted}/>}
            </button>
          </CardWrap>
        ))}

        <div className="text-[11px] font-bold mb-2 mt-4 uppercase tracking-wide" style={{ color:G.muted }}>Privacy & Legal</div>
        {["Privacy Policy","Terms of Service","Delete Account"].map((label)=>(
          <CardWrap key={label} className="flex items-center justify-between p-4 mb-2">
            <span className="text-[13px] font-semibold" style={{ color:label==="Delete Account"?G.error:G.dark }}>{label}</span>
            <ChevronRight size={15} color={G.muted}/>
          </CardWrap>
        ))}
      </div>
    </div>
  );
}

function SupportScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="flex flex-col min-h-full">
      <GradientHeader>
        <div className="flex items-center gap-3">
          <BackBtn onClick={()=>go("profile")} light/>
          <h1 className="text-white font-bold text-[17px]">Help & Support</h1>
        </div>
      </GradientHeader>
      <div className="flex-1 px-5 pt-4 pb-6 overflow-y-auto" style={{ background:G.bg }}>
        {/* Contact options */}
        <div className="grid grid-cols-2 gap-3 mb-5">
          {[
            {icon:"💬",label:"Live Chat",sub:"Avg. 2 min reply",color:G.primary},
            {icon:"📞",label:"Call Us",sub:"+254 700 MAMBA",color:G.secondary},
            {icon:"📧",label:"Email",sub:"support@mambonami.com",color:G.purple},
            {icon:"🤖",label:"WhatsApp",sub:"+254 700 262262",color:G.success},
          ].map((c)=>(
            <CardWrap key={c.label} className="p-4 text-center">
              <div className="text-2xl mb-2">{c.icon}</div>
              <div className="text-[13px] font-bold" style={{ color:G.dark }}>{c.label}</div>
              <div className="text-[10px]" style={{ color:G.muted }}>{c.sub}</div>
            </CardWrap>
          ))}
        </div>

        {/* FAQ */}
        <SectionHeader title="Frequently Asked Questions"/>
        <div className="flex flex-col gap-2 mb-5">
          {[
            "How does M-Pesa escrow work?",
            "How do I confirm a delivery with OTP?",
            "What happens if a farmer cancels my order?",
            "How long do payouts take?",
            "How do I become a verified farmer?",
            "What vehicles are accepted for transport?",
          ].map((q,i)=>(
            <CardWrap key={i} className="flex items-center justify-between p-3.5">
              <span className="text-[12px] font-medium" style={{ color:G.dark }}>{q}</span>
              <ChevronRight size={14} color={G.muted}/>
            </CardWrap>
          ))}
        </div>

        {/* Ticket */}
        <CardWrap className="p-4">
          <h3 className="text-[13px] font-bold mb-2" style={{ color:G.dark }}>Submit a Ticket</h3>
          <div className="relative mb-3">
            <select className="w-full rounded-xl border text-[12px] outline-none appearance-none pr-8"
              style={{ padding:"11px 30px 11px 14px", borderColor:"rgba(27,127,59,0.2)", background:"white", fontFamily:font, color:G.dark }}>
              <option>Select issue type</option>
              <option>Payment / Escrow</option>
              <option>Order dispute</option>
              <option>App bug</option>
              <option>Account issue</option>
            </select>
            <ChevronDown size={13} color={G.muted} className="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none"/>
          </div>
          <textarea placeholder="Describe your issue in detail..." rows={3}
            style={{ width:"100%", borderRadius:14, border:`1.5px solid rgba(27,127,59,0.2)`, padding:"12px 14px", background:"white", fontFamily:font, fontSize:12, outline:"none", color:G.dark, resize:"none", marginBottom:12 }}/>
          <PrimaryBtn label="Submit Ticket" onClick={()=>{}}/>
        </CardWrap>
      </div>
    </div>
  );
}

// ─── ALL SCREENS ──────────────────────────────────────────────────────────────

const ALL_SCREENS: [Screen, string][] = [
  ["splash","Splash"],
  ["welcome","Welcome"],
  ["login","Login"],
  ["forgot-password","Forgot Password"],
  ["otp","OTP Verification"],
  ["role-select","Role Selection"],
  ["profile-farmer","🌱 Farmer Registration"],
  ["profile-buyer","🛒 Buyer Registration"],
  ["profile-transport","🚛 Transport Registration"],
  ["profile-retailer","🏪 Retailer Registration"],
  ["success","Success"],
  ["dash-farmer","🌱 Farmer Dashboard"],
  ["farmer-products","├ Product List"],
  ["farmer-product-create","├ Add Product"],
  ["farmer-orders","├ Order Requests"],
  ["farmer-order-detail","├ Order Detail"],
  ["farmer-earnings","└ Earnings & Wallet"],
  ["dash-buyer","🛒 Buyer Dashboard"],
  ["buyer-catalog","├ Product Catalog"],
  ["buyer-product-detail","├ Product Detail"],
  ["buyer-cart","├ Cart"],
  ["buyer-checkout","├ M-Pesa Checkout"],
  ["buyer-order-tracking","├ Order Tracking"],
  ["buyer-order-history","├ Order History"],
  ["buyer-dispute","└ Dispute"],
  ["dash-transport","🚛 Transport Dashboard"],
  ["transport-available","├ Available Orders"],
  ["transport-delivery-otp","├ Delivery OTP"],
  ["transport-trips","└ My Trips"],
  ["dash-retailer","🏪 Retailer Dashboard"],
  ["notifications","🔔 Notifications"],
  ["profile","👤 Profile"],
  ["settings","⚙️ Settings"],
  ["support","💬 Help & Support"],
];

// ─── ROOT ─────────────────────────────────────────────────────────────────────

export default function App() {
  const [screen, setScreen] = useState<Screen>("splash");
  const [role, setRole] = useState<Role>("farmer");
  const go = (s: Screen) => setScreen(s);

  const renderScreen = () => {
    switch (screen) {
      case "splash": return <SplashScreen go={go}/>;
      case "welcome": return <WelcomeScreen go={go}/>;
      case "login": return <LoginScreen go={go}/>;
      case "forgot-password": return <ForgotPasswordScreen go={go}/>;
      case "otp": return <OtpScreen go={go}/>;
      case "role-select": return <RoleSelectScreen go={go} setRole={setRole}/>;
      case "profile-farmer": return <ProfileFarmerScreen go={go}/>;
      case "profile-buyer": return <ProfileBuyerScreen go={go}/>;
      case "profile-transport": return <ProfileTransportScreen go={go}/>;
      case "profile-retailer": return <ProfileRetailerScreen go={go}/>;
      case "success": return <SuccessScreen go={go} role={role}/>;
      case "dash-farmer": return <FarmerDash go={go}/>;
      case "farmer-products": return <FarmerProductsScreen go={go}/>;
      case "farmer-product-create": return <FarmerProductCreateScreen go={go}/>;
      case "farmer-orders": return <FarmerOrdersScreen go={go}/>;
      case "farmer-order-detail": return <FarmerOrderDetailScreen go={go}/>;
      case "farmer-earnings": return <FarmerEarningsScreen go={go}/>;
      case "dash-buyer": return <BuyerDash go={go}/>;
      case "buyer-catalog": return <BuyerCatalogScreen go={go}/>;
      case "buyer-product-detail": return <BuyerProductDetailScreen go={go}/>;
      case "buyer-cart": return <BuyerCartScreen go={go}/>;
      case "buyer-checkout": return <BuyerCheckoutScreen go={go}/>;
      case "buyer-order-tracking": return <BuyerOrderTrackingScreen go={go}/>;
      case "buyer-order-history": return <BuyerOrderHistoryScreen go={go}/>;
      case "buyer-dispute": return <BuyerDisputeScreen go={go}/>;
      case "dash-transport": return <TransportDash go={go}/>;
      case "transport-available": return <TransportAvailableScreen go={go}/>;
      case "transport-delivery-otp": return <TransportDeliveryOtpScreen go={go}/>;
      case "transport-trips": return <TransportTripsScreen go={go}/>;
      case "dash-retailer": return <RetailerDash go={go}/>;
      case "notifications": return <NotificationsScreen go={go}/>;
      case "profile": return <ProfileScreen go={go} role={role}/>;
      case "settings": return <SettingsScreen go={go}/>;
      case "support": return <SupportScreen go={go}/>;
      default: return <WelcomeScreen go={go}/>;
    }
  };

  return (
    <div style={{ fontFamily:font }}>
      <style>{`.hide-scroll::-webkit-scrollbar{display:none}.hide-scroll{-ms-overflow-style:none;scrollbar-width:none}`}</style>

      {/* Desktop: sidebar + phone */}
      <div className="hidden md:flex min-h-screen" style={{ background:"#060E08" }}>
        <div className="w-64 flex flex-col py-8 px-5 overflow-y-auto flex-shrink-0" style={{ background:"rgba(255,255,255,0.04)", borderRight:"1px solid rgba(255,255,255,0.07)" }}>
          <div className="flex items-center gap-2.5 mb-6 px-1">
            <div className="w-9 h-9 rounded-xl overflow-hidden bg-white flex items-center justify-center">
              <img src={logoImg} alt="MAMBONAMI" className="w-full h-full object-contain p-0.5"/>
            </div>
            <span className="text-white font-extrabold text-[15px] tracking-tight">MAMBONAMI</span>
          </div>
          <div className="flex flex-col gap-0.5">
            {ALL_SCREENS.map(([s,label])=>{
              const indent = label.startsWith("├") || label.startsWith("└");
              return (
                <button key={s} onClick={()=>go(s)}
                  className={`text-left px-3 py-2 rounded-xl text-[12px] font-semibold transition-all ${indent?"ml-3":""}`}
                  style={{ background:screen===s?G.primary:"transparent", color:screen===s?"white":indent?"rgba(255,255,255,0.45)":"rgba(255,255,255,0.7)" }}>
                  {label}
                </button>
              );
            })}
          </div>
        </div>
        <div className="flex-1 flex items-center justify-center py-8">
          <PhoneFrame>{renderScreen()}</PhoneFrame>
        </div>
      </div>

      {/* Mobile: full screen */}
      <div className="md:hidden min-h-screen" style={{ background:G.bg }}>
        {renderScreen()}
      </div>
    </div>
  );
}
