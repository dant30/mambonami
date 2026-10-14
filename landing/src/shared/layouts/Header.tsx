import {
  Bell,
  ChevronDown,
  Heart,
  Leaf,
  LogOut,
  Menu,
  ShoppingBasket,
  UserCircle,
  X,
} from "lucide-react";
import { useEffect, useRef, useState } from "react";
import { Link, NavLink, useNavigate } from "react-router-dom";

import { useAuth } from "../../core/contexts/AuthContext";
import { useIsMobile } from "../../core/hooks";
import { useNotifications } from "../../core/lib";
import { CartCountBadge } from "../components/ui";

/**
 * ✅✅ ROLE-SPECIFIC HEADERS:
 * Headers change based on authentication state and user role.
 *
 * Guest: Home, Products, How it works, About, Support | Login, Get Started
 * Buyer: Shop, Orders, Wishlist | Search, Cart, Notifications, Profile
 * Farmer: Dashboard, Orders, Products, Sales, Analytics | Notifications, Profile
 * Retailer: Dashboard, Shop, Orders, Suppliers, Purchases | Search, Notifications, Profile
 * Transport: Dashboard, Jobs, Active, Vehicles | Availability, Notifications, Profile
 */
export function Header({ onMenuToggle }: { onMenuToggle?: () => void }) {
  const { isAuthenticated, user, logout } = useAuth();
  const isMobile = useIsMobile();
  const [menuOpen, setMenuOpen] = useState(false);
  const [userMenuOpen, setUserMenuOpen] = useState(false);
  const [notificationsOpen, setNotificationsOpen] = useState(false);
  const notificationsRef = useRef<HTMLDivElement>(null);
  const userMenuRef = useRef<HTMLDivElement>(null);
  const navigate = useNavigate();
  const isAdmin = Boolean(user?.is_staff || user?.is_superuser);
  const role = typeof user?.role === "string" ? user.role : "";

  // ✅✅ Dashboard path uses /app/{role} pattern
  const dashboardPath = isAdmin
    ? "/app/admin"
    : role === "buyer"
      ? "/app/buyer"
      : role === "farmer"
        ? "/app/farmer"
        : role === "retailer"
          ? "/app/retailer"
          : role === "transport_provider"
            ? "/app/transport"
            : "/";
  const profilePath =
    role === "buyer"
      ? "/app/buyer/profile"
      : role === "farmer"
        ? "/app/farmer/profile"
        : role === "retailer"
          ? "/app/retailer/profile"
          : role === "transport_provider"
            ? "/app/transport/profile"
            : dashboardPath;
  const settingsPath =
    role === "transport_provider" ? "/app/transport/settings" : `/app/${role}/settings`;
  const homePath = isAuthenticated ? dashboardPath : "/home";
  const { notifications } = useNotifications(isAuthenticated);
  const unreadNotifications = notifications.filter((notification) => !notification.is_read);

  const displayName = String(
    user?.first_name || user?.username || user?.phone || "MAMBONAMI member",
  );
  useEffect(() => {
    if (!notificationsOpen && !userMenuOpen) return;
    const closeOnOutsideClick = (event: MouseEvent) => {
      const target = event.target as Node;
      if (notificationsOpen && !notificationsRef.current?.contains(target))
        setNotificationsOpen(false);
      if (userMenuOpen && !userMenuRef.current?.contains(target)) setUserMenuOpen(false);
    };
    document.addEventListener("mousedown", closeOnOutsideClick);
    return () => document.removeEventListener("mousedown", closeOnOutsideClick);
  }, [notificationsOpen, userMenuOpen]);
  useEffect(() => {
    const closeOnEscape = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        setMenuOpen(false);
        setUserMenuOpen(false);
      }
    };
    window.addEventListener("keydown", closeOnEscape);
    return () => window.removeEventListener("keydown", closeOnEscape);
  }, []);
  const signOut = () => {
    logout();
    setUserMenuOpen(false);
    navigate("/");
  };

  return (
    <header className="sticky top-0 z-50 border-b border-border bg-background shadow-[0_6px_22px_-14px_rgba(41,74,54,0.5)]">
      <div className="mx-auto flex min-h-14 max-w-7xl items-center justify-between gap-3 px-4 sm:min-h-16 sm:gap-4 sm:px-6 lg:px-8">
        {/* ✅✅ Logo always links to /home (public marketplace, not dashboard) */}
        <Link
          to={homePath}
          className="flex shrink-0 items-center gap-2 sm:gap-2.5"
          aria-label="MAMBONAMI home"
        >
          <span className="flex h-8 w-8 items-center justify-center rounded-full bg-primary text-primary-foreground sm:h-9 sm:w-9">
            <Leaf className="h-4 w-4" />
          </span>
          <span className="font-display text-lg font-bold tracking-tight text-primary-dark sm:text-xl">
            MAMBONAMI
          </span>
        </Link>

        {/* ✅✅ Navigation changes by auth state */}
        <nav
          className={
            isMobile ? "hidden" : "hidden items-center gap-7 text-sm font-semibold md:flex"
          }
          aria-label="Main navigation"
        >
          {isAuthenticated ? (
            isAdmin ? (
              <>
                <NavLink
                  to="/app/admin"
                  end
                  className={({ isActive }) =>
                    isActive ? "text-primary" : "text-foreground hover:text-primary"
                  }
                >
                  Admin
                </NavLink>
                <NavLink
                  to="/app/admin/orders"
                  className={({ isActive }) =>
                    isActive ? "text-primary" : "text-foreground hover:text-primary"
                  }
                >
                  Orders
                </NavLink>
                <NavLink
                  to="/app/admin/products"
                  className={({ isActive }) =>
                    isActive ? "text-primary" : "text-foreground hover:text-primary"
                  }
                >
                  Products
                </NavLink>
                <NavLink
                  to="/app/admin/users"
                  className={({ isActive }) =>
                    isActive ? "text-primary" : "text-foreground hover:text-primary"
                  }
                >
                  Users
                </NavLink>
                <NavLink
                  to="/app/admin/analytics"
                  className={({ isActive }) =>
                    isActive ? "text-primary" : "text-foreground hover:text-primary"
                  }
                >
                  Analytics
                </NavLink>
              </>
            ) : (
              <>
                {role === "buyer" && (
                  <>
                    <NavLink
                      to="/app/buyer/products"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Shop
                    </NavLink>
                    <NavLink
                      to="/app/buyer/orders"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Orders
                    </NavLink>
                    <NavLink
                      to="/app/buyer/wishlist"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Wishlist
                    </NavLink>
                  </>
                )}
                {role === "farmer" && (
                  <>
                    <NavLink
                      to="/app/farmer"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Dashboard
                    </NavLink>
                    <NavLink
                      to="/app/farmer/orders"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Orders
                    </NavLink>
                    <NavLink
                      to="/app/farmer/products"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Products
                    </NavLink>
                    <NavLink
                      to="/app/farmer/sales"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Sales
                    </NavLink>
                  </>
                )}
                {role === "retailer" && (
                  <>
                    <NavLink
                      to="/app/retailer"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Dashboard
                    </NavLink>
                    <NavLink
                      to="/app/retailer/shop"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Shop
                    </NavLink>
                    <NavLink
                      to="/app/retailer/orders"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Orders
                    </NavLink>
                    <NavLink
                      to="/app/retailer/suppliers"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Suppliers
                    </NavLink>
                  </>
                )}
                {role === "transport_provider" && (
                  <>
                    <NavLink
                      to="/app/transport"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Dashboard
                    </NavLink>
                    <NavLink
                      to="/app/transport/jobs"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Jobs
                    </NavLink>
                    <NavLink
                      to="/app/transport/active-jobs"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Active
                    </NavLink>
                    <NavLink
                      to="/app/transport/vehicles"
                      className={({ isActive }) =>
                        isActive ? "text-primary" : "text-foreground hover:text-primary"
                      }
                    >
                      Vehicles
                    </NavLink>
                  </>
                )}
              </>
            )
          ) : (
            // Guest: Show public nav
            <>
              <NavLink
                to="/home"
                end
                className={({ isActive }) =>
                  isActive ? "text-primary" : "text-foreground hover:text-primary"
                }
              >
                Home
              </NavLink>
              <NavLink to="/products" className="text-foreground hover:text-primary">
                Products
              </NavLink>
              <NavLink to="/how-it-works" className="text-foreground hover:text-primary">
                How it works
              </NavLink>
              <NavLink to="/about" className="text-foreground hover:text-primary">
                About
              </NavLink>
              <NavLink to="/support" className="text-foreground hover:text-primary">
                Support
              </NavLink>
            </>
          )}
        </nav>

        {/* ✅✅ Right side actions */}
        <div className="hidden items-center gap-2 sm:flex">
          {isAuthenticated ? (
            // Authenticated actions
            <>
              {!isAdmin && role === "buyer" && (
                <Link
                  to="/app/buyer/cart"
                  className="relative rounded-full p-2 text-muted-foreground hover:bg-muted hover:text-foreground"
                  aria-label="Shopping cart"
                >
                  <ShoppingBasket className="h-5 w-5" />
                  <CartCountBadge />
                </Link>
              )}
              <div ref={notificationsRef} className="relative">
                <button
                  type="button"
                  onClick={() => setNotificationsOpen((open) => !open)}
                  className="relative rounded-full p-2 text-muted-foreground hover:bg-muted hover:text-foreground"
                  aria-label="Notifications"
                  aria-expanded={notificationsOpen}
                >
                  <Bell className="h-5 w-5" />
                  {unreadNotifications.length > 0 && (
                    <span className="absolute -right-0.5 -top-0.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-secondary px-1 text-[9px] font-bold text-secondary-foreground">
                      {unreadNotifications.length > 9 ? "9+" : unreadNotifications.length}
                    </span>
                  )}
                </button>
                {notificationsOpen && (
                  <div className="absolute right-0 mt-2 w-80 overflow-hidden rounded-2xl border border-border bg-card py-2 shadow-xl">
                    <p className="border-b border-border bg-muted px-4 py-3 text-xs font-bold uppercase tracking-[0.12em] text-primary-dark">
                      Notifications
                    </p>
                    {unreadNotifications.length ? (
                      unreadNotifications.slice(0, 3).map((notification) => (
                        <Link
                          key={notification.id}
                          to={notification.action_url || "/"}
                          onClick={() => setNotificationsOpen(false)}
                          className="block border-b border-border px-4 py-3 hover:bg-muted"
                        >
                          <p className="truncate text-xs font-bold text-primary-dark">
                            {notification.title}
                          </p>
                          <p className="mt-1 line-clamp-2 text-xs text-muted-foreground">
                            {notification.body}
                          </p>
                        </Link>
                      ))
                    ) : (
                      <p className="p-4 text-center text-xs text-muted-foreground">
                        No new notifications
                      </p>
                    )}
                    <Link
                      to="/notifications"
                      onClick={() => setNotificationsOpen(false)}
                      className="block px-4 py-3 text-center text-xs font-bold text-primary hover:bg-muted"
                    >
                      View all notifications
                    </Link>
                  </div>
                )}
              </div>
              <div ref={userMenuRef} className="relative">
                <button
                  type="button"
                  onClick={() => setUserMenuOpen((open) => !open)}
                  className="flex items-center gap-2 rounded-full border border-border bg-card px-2.5 py-1.5 text-sm font-semibold"
                  aria-expanded={userMenuOpen}
                  aria-controls="user-menu"
                  aria-haspopup="menu"
                >
                  <UserCircle className="h-5 w-5 text-primary" />
                  <span className="max-w-28 truncate">{displayName}</span>
                  <ChevronDown className="h-4 w-4" />
                </button>
                {userMenuOpen && (
                  <div
                    id="user-menu"
                    role="menu"
                    className="absolute right-0 mt-2 w-48 overflow-hidden rounded-2xl border border-border bg-card py-1 shadow-xl"
                  >
                    <Link
                      to={dashboardPath}
                      onClick={() => setUserMenuOpen(false)}
                      className="block px-4 py-2.5 text-sm hover:bg-muted"
                    >
                      {isAdmin ? "Admin Panel" : "Dashboard"}
                    </Link>
                    {!isAdmin && (
                      <>
                        <Link
                          to={profilePath}
                          onClick={() => setUserMenuOpen(false)}
                          className="block px-4 py-2.5 text-sm hover:bg-muted"
                        >
                          Profile
                        </Link>
                        <Link
                          to={settingsPath}
                          onClick={() => setUserMenuOpen(false)}
                          className="block px-4 py-2.5 text-sm hover:bg-muted"
                        >
                          Settings
                        </Link>
                      </>
                    )}
                    <button
                      type="button"
                      onClick={signOut}
                      className="flex w-full items-center gap-2 px-4 py-2.5 text-left text-sm text-destructive hover:bg-muted"
                    >
                      <LogOut className="h-4 w-4" />
                      Sign out
                    </button>
                  </div>
                )}
              </div>
            </>
          ) : (
            // Guest actions
            <>
              <Link
                to="/wishlist"
                className="rounded-full p-2 text-muted-foreground hover:bg-muted hover:text-foreground"
                aria-label="Wishlist"
              >
                <Heart className="h-5 w-5" />
              </Link>
              <Link
                to="/cart"
                className="relative rounded-full p-2 text-muted-foreground hover:bg-muted hover:text-foreground"
                aria-label="Shopping cart"
              >
                <ShoppingBasket className="h-5 w-5" />
                <CartCountBadge />
              </Link>
              <Link
                to="/login"
                className="rounded-full px-4 py-2 text-sm font-semibold text-muted-foreground hover:bg-muted"
              >
                Log in
              </Link>
              <Link
                to="/role-select"
                className="rounded-full bg-secondary px-4 py-2 text-sm font-bold text-secondary-foreground"
              >
                Get started
              </Link>
            </>
          )}
        </div>

        {/* ✅✅ Mobile menu toggle */}
        <button
          type="button"
          className="flex h-11 w-11 items-center justify-center rounded-full border border-border md:hidden"
          aria-label={menuOpen ? "Close navigation menu" : "Open navigation menu"}
          aria-expanded={menuOpen}
          aria-controls="mobile-navigation"
          onClick={() => {
            setMenuOpen((open) => !open);
            onMenuToggle?.();
          }}
        >
          {menuOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
        </button>
      </div>

      {/* ✅✅ Mobile menu */}
    </header>
  );
}
