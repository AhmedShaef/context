const std = @import("std");
const context = @import("context");

const RequestID = struct {
    pub const Value = u128;
};

test "child attachment shadows same-key parent binding" {
    const allocator = std.heap.page_allocator;

    const parent = try context.Context.empty().withValue(RequestID, @as(u128, 1), allocator);
    const child = try parent.withValue(RequestID, @as(u128, 2), allocator);

    try std.testing.expectEqual(@as(u128, 1), parent.get(RequestID).?);
    try std.testing.expectEqual(@as(u128, 2), child.get(RequestID).?);
}

test "parent context remains unchanged after child shadowing" {
    const allocator = std.heap.page_allocator;

    const parent = try context.Context.background().withValue(RequestID, @as(u128, 10), allocator);
    _ = try parent.withValue(RequestID, @as(u128, 20), allocator);

    try std.testing.expectEqual(@as(u128, 10), parent.get(RequestID).?);
}
