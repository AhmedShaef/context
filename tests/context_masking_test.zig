const std = @import("std");
const context = @import("context");

const RequestID = struct {
    pub const Value = u128;
};

test "withoutValue masks ancestor value" {
    const allocator = std.heap.page_allocator;

    const parent = try context.Context.empty().withValue(RequestID, @as(u128, 123), allocator);
    const masked = try parent.withoutValue(RequestID, allocator);

    try std.testing.expectEqual(@as(u128, 123), parent.get(RequestID).?);
    try std.testing.expect(masked.get(RequestID) == null);
}

test "masking preserves parent immutability" {
    const allocator = std.heap.page_allocator;

    const parent = try context.Context.background().withValue(RequestID, @as(u128, 555), allocator);
    _ = try parent.withoutValue(RequestID, allocator);

    try std.testing.expectEqual(@as(u128, 555), parent.get(RequestID).?);
}
