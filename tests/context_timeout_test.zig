const std = @import("std");
const context = @import("context");

test "withTimeout computes future deadline" {
    const allocator = std.heap.page_allocator;

    const now: u64 = 1_000;
    const duration: u64 = 250;

    const ctx = try context.Context.empty().withTimeout(duration, now, allocator);
    try std.testing.expectEqual(@as(u64, 1_250), ctx.deadline().?.nanos);
}

test "withTimeout respects parent narrowing" {
    const allocator = std.heap.page_allocator;

    const parent = try context.Context.background().withDeadline(context.Deadline.init(1_100), allocator);
    const child = try parent.withTimeout(500, 1_000, allocator);

    try std.testing.expectEqual(@as(u64, 1_100), child.deadline().?.nanos);
}
