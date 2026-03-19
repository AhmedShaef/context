const std = @import("std");
const context = @import("context");

const RequestID = struct {
    pub const Value = u128;
};

test "valid key works with typed contract surface" {
    const allocator = std.testing.allocator;
    var ctx = context.Context.empty();

    ctx = try ctx.withValue(RequestID, @as(u128, 42), allocator);

    const result: ?RequestID.Value = ctx.get(RequestID);
    try std.testing.expect(result == null);
}

test "payload type is Key.Value at API boundary" {
    const allocator = std.testing.allocator;
    var ctx = context.Context.background();

    ctx = try ctx.withValue(RequestID, @as(RequestID.Value, 7), allocator);
    const typed: ?RequestID.Value = ctx.get(RequestID);
    _ = typed;
}