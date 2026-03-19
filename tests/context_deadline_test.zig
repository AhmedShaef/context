const std = @import("std");
const context = @import("context");

test "withDeadline attaches deadline" {
    const allocator = std.heap.page_allocator;

    const d = context.Deadline.init(1_000);
    const ctx = try context.Context.empty().withDeadline(d, allocator);

    try std.testing.expectEqual(@as(u64, 1_000), ctx.deadline().?.nanos);
}

test "deadline propagates through derive" {
    const allocator = std.heap.page_allocator;

    const root = try context.Context.background().withDeadline(context.Deadline.init(5_000), allocator);
    const child = try root.derive(allocator);

    try std.testing.expectEqual(@as(u64, 5_000), child.deadline().?.nanos);
}
