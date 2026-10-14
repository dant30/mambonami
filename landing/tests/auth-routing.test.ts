import { describe, expect, it } from "vitest";

import { getRoleDashboardPath, getRoleNotificationsPath } from "../src/core/utils/roleRoutes";

describe("post-login routing", () => {
  it.each([
    ["buyer", "/app/buyer"],
    ["farmer", "/app/farmer"],
    ["retailer", "/app/retailer"],
    ["transport_provider", "/app/transport"],
  ])("routes %s users to their workspace", (role, destination) => {
    expect(getRoleDashboardPath(role)).toBe(destination);
  });

  it("prioritizes staff access and falls back safely for unknown roles", () => {
    expect(getRoleDashboardPath("buyer", true)).toBe("/app/admin");
    expect(getRoleDashboardPath("unknown")).toBe("/app/buyer");
  });

  it.each([
    ["buyer", "/app/buyer/notifications"],
    ["farmer", "/app/farmer/notifications"],
    ["retailer", "/app/retailer/notifications"],
    ["transport_provider", "/app/transport/notifications"],
  ])("routes %s notifications to its workspace", (role, destination) => {
    expect(getRoleNotificationsPath(role)).toBe(destination);
  });

  it("routes staff notifications to the admin workspace", () => {
    expect(getRoleNotificationsPath("buyer", true)).toBe("/app/admin/notifications");
  });
});
