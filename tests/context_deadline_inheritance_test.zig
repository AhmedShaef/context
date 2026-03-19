const std = @import("std");
const context = @import("context");

test "child deadline cannot extend parent deadline" {
    const allocator = std.heap.page_allocator;

    const parent = try context.Context.empty().withDeadline(context.Deadline.init(100), allocator);
    const child = try parent.withDeadline(context.Deadline.init(1_000), allocator);

    try std.testing.expectEqual(@as(u64, 100), child.deadline().?.nanos);
}

test "child deadline can narrow parent deadline" {
    const allocator = std.heap.page_allocator;

    const parent = try context.Context.background().withDeadline(context.Deadline.init(1_000), allocator);
    const child = try parent.withDeadline(context.Deadline.init(100), allocator);

    try std.testing.expectEqual(@as(u64, 100), child.deadline().?.nanos);
}
