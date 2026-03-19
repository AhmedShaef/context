const std = @import("std");
const context = @import("context");

const RequestID = struct { pub const Value = u128; };
const TenantID = struct { pub const Value = u64; };

test "value inheritance and shadow resolution" {
    const allocator = std.heap.page_allocator;

    const parent = try context.Context.empty().withValue(RequestID, @as(u128, 10), allocator);
    const inherited = try parent.derive(allocator);
    const shadowed = try inherited.withValue(RequestID, @as(u128, 20), allocator);

    try std.testing.expectEqual(@as(u128, 10), inherited.get(RequestID).?);
    try std.testing.expectEqual(@as(u128, 20), shadowed.get(RequestID).?);
}

test "mask suppresses only matching key" {
    const allocator = std.heap.page_allocator;

    var base = context.Context.background();
    base = try base.withValue(RequestID, @as(u128, 1), allocator);
    base = try base.withValue(TenantID, @as(u64, 2), allocator);

    const masked = try base.withoutValue(RequestID, allocator);

    try std.testing.expect(masked.get(RequestID) == null);
    try std.testing.expectEqual(@as(u64, 2), masked.get(TenantID).?);
}
