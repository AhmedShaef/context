const std = @import("std");
const context = @import("context");

const RequestID = struct { pub const Value = u128; };
const TenantID = struct { pub const Value = u64; };

test "clone preserves effective visible values" {
    const allocator = std.heap.page_allocator;

    var ctx = context.Context.empty();
    ctx = try ctx.withValue(RequestID, @as(u128, 10), allocator);
    ctx = try ctx.withValue(TenantID, @as(u64, 20), allocator);

    const cloned = try ctx.cloneInto(allocator);

    try std.testing.expectEqual(@as(u128, 10), cloned.get(RequestID).?);
    try std.testing.expectEqual(@as(u64, 20), cloned.get(TenantID).?);
}

test "clone omits masked values" {
    const allocator = std.heap.page_allocator;

    var ctx = context.Context.background();
    ctx = try ctx.withValue(RequestID, @as(u128, 10), allocator);
    ctx = try ctx.withoutValue(RequestID, allocator);

    const cloned = try ctx.cloneInto(allocator);
    try std.testing.expect(cloned.get(RequestID) == null);
}
