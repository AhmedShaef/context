const std = @import("std");
const context = @import("context");

test "effective deadline inherits through lineage" {
    const allocator = std.heap.page_allocator;

    const parent = try context.Context.empty().withDeadline(context.Deadline.init(1_000), allocator);
    const child = try parent.derive(allocator);

    try std.testing.expectEqual(@as(u64, 1_000), child.deadline().?.nanos);
}

test "effective deadline stays narrowed" {
    const allocator = std.heap.page_allocator;

    const parent = try context.Context.empty().withDeadline(context.Deadline.init(1_000), allocator);
    const child = try parent.withDeadline(context.Deadline.init(2_000), allocator);
    const grandchild = try child.withDeadline(context.Deadline.init(500), allocator);

    try std.testing.expectEqual(@as(u64, 1_000), child.deadline().?.nanos);
    try std.testing.expectEqual(@as(u64, 500), grandchild.deadline().?.nanos);
}
