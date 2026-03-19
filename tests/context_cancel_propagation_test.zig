const std = @import("std");
const context = @import("context");

test "parent cancellation propagates to child contexts" {
    const allocator = std.heap.page_allocator;

    const parent_pair = try context.Context.empty().withCancel(allocator);
    const child = try parent_pair.context.derive(allocator);

    try std.testing.expect(!child.isCancelled());
    parent_pair.source.cancel();
    try std.testing.expect(child.isCancelled());
}

test "child cancellation does not affect parent" {
    const allocator = std.heap.page_allocator;

    const parent_pair = try context.Context.background().withCancel(allocator);
    const child_pair = try parent_pair.context.withCancel(allocator);

    try std.testing.expect(!parent_pair.context.isCancelled());
    child_pair.source.cancel();

    try std.testing.expect(child_pair.context.isCancelled());
    try std.testing.expect(!parent_pair.context.isCancelled());
}
