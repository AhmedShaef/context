const std = @import("std");
const context = @import("context");

test "clone preserves effective deadline" {
    const allocator = std.heap.page_allocator;

    var ctx = context.Context.empty();
    ctx = try ctx.withDeadline(context.Deadline.init(1_000), allocator);
    ctx = try ctx.withDeadline(context.Deadline.init(500), allocator);

    const cloned = try ctx.cloneInto(allocator);
    try std.testing.expectEqual(@as(u64, 500), cloned.deadline().?.nanos);
}
