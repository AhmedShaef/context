const std = @import("std");
const context = @import("context");

const RequestID = struct { pub const Value = u128; };

test "clone flattens lineage into single node" {
    const allocator = std.heap.page_allocator;

    var ctx = context.Context.empty();
    ctx = try ctx.withValue(RequestID, @as(u128, 10), allocator);
    ctx = try ctx.withDeadline(context.Deadline.init(500), allocator);
    const pair = try ctx.withCancel(allocator);

    const cloned = try pair.context.cloneInto(allocator);

    try std.testing.expect(!cloned.hasParentLineage());
    try std.testing.expect(cloned.hasImmediateBinding());
    try std.testing.expectEqual(@as(u128, 10), cloned.get(RequestID).?);
    try std.testing.expectEqual(@as(u64, 500), cloned.deadline().?.nanos);
    try std.testing.expect(!cloned.isCancelled());
}
