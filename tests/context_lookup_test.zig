const std = @import("std");
const context = @import("context");

const TenantID = struct {
    pub const Value = u64;
};

test "basic lookup returns attached value" {
    const allocator = std.heap.page_allocator;

    const ctx = try context.Context.empty().withValue(TenantID, @as(u64, 77), allocator);
    try std.testing.expectEqual(@as(u64, 77), ctx.get(TenantID).?);
}

test "child lookup retrieves ancestor value" {
    const allocator = std.heap.page_allocator;

    const parent = try context.Context.background().withValue(TenantID, @as(u64, 99), allocator);
    const child = try parent.derive(allocator);

    try std.testing.expectEqual(@as(u64, 99), child.get(TenantID).?);
}
