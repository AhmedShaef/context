const std = @import("std");
const context = @import("context");

test "cancel source cancel is idempotent" {
    const allocator = std.heap.page_allocator;

    const pair = try context.Context.empty().withCancel(allocator);

    pair.source.cancel();
    pair.source.cancel();
    pair.source.cancel();

    try std.testing.expect(pair.context.isCancelled());
}

test "cancel source token observes same state" {
    const allocator = std.heap.page_allocator;

    const pair = try context.Context.background().withCancel(allocator);
    const token = pair.source.token();

    try std.testing.expect(!token.isCancelled());
    pair.source.cancel();
    try std.testing.expect(token.isCancelled());
}
