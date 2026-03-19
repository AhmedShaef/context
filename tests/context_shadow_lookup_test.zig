const std = @import("std");
const context = @import("context");

const RequestID = struct {
    pub const Value = u128;
};

test "shadow lookup resolves nearest child value" {
    const allocator = std.heap.page_allocator;

    const root = try context.Context.empty().withValue(RequestID, @as(u128, 1), allocator);
    const child = try root.withValue(RequestID, @as(u128, 2), allocator);

    try std.testing.expectEqual(@as(u128, 2), child.get(RequestID).?);
}

test "mask beats ancestor value after shadow chain" {
    const allocator = std.heap.page_allocator;

    const root = try context.Context.empty().withValue(RequestID, @as(u128, 1), allocator);
    const child = try root.withValue(RequestID, @as(u128, 2), allocator);
    const masked = try child.withoutValue(RequestID, allocator);

    try std.testing.expect(masked.get(RequestID) == null);
}
