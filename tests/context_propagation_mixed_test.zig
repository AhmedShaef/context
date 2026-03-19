const std = @import("std");
const context = @import("context");

const RequestID = struct { pub const Value = u128; };
const TenantID = struct { pub const Value = u64; };

const Scenario = struct {
    ctx: context.Context,
    parent_source: context.CancelSource,
    child_source: context.CancelSource,
};

fn buildScenario(allocator: std.mem.Allocator) !Scenario {
    var base = context.Context.empty();
    base = try base.withValue(RequestID, @as(u128, 100), allocator);
    base = try base.withValue(TenantID, @as(u64, 42), allocator);
    base = try base.withDeadline(context.Deadline.init(1_000), allocator);

    const parent_cancel = try base.withCancel(allocator);

    var child = try parent_cancel.context.withValue(RequestID, @as(u128, 200), allocator);
    child = try child.withoutValue(TenantID, allocator);
    child = try child.withTimeout(700, 500, allocator);

    const child_cancel = try child.withCancel(allocator);

    return .{
        .ctx = child_cancel.context,
        .parent_source = parent_cancel.source,
        .child_source = child_cancel.source,
    };
}

test "mixed propagation remains deterministic" {
    const allocator = std.heap.page_allocator;

    var a = try buildScenario(allocator);
    var b = try buildScenario(allocator);

    a.parent_source.cancel();
    b.parent_source.cancel();

    try std.testing.expectEqual(@as(u128, 200), a.ctx.get(RequestID).?);
    try std.testing.expectEqual(@as(u128, 200), b.ctx.get(RequestID).?);

    try std.testing.expect(a.ctx.get(TenantID) == null);
    try std.testing.expect(b.ctx.get(TenantID) == null);

    try std.testing.expectEqual(@as(u64, 1_000), a.ctx.deadline().?.nanos);
    try std.testing.expectEqual(@as(u64, 1_000), b.ctx.deadline().?.nanos);

    try std.testing.expect(a.ctx.isCancelled());
    try std.testing.expect(b.ctx.isCancelled());

    try a.ctx.validatePropagation(RequestID);
    try b.ctx.validatePropagation(RequestID);

    a.child_source.cancel();
    b.child_source.cancel();
}
