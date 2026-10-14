import { describe, expect, it } from "vitest";

import { getRoleDashboardPath } from "../src/core/utils/roleRoutes";

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
});
