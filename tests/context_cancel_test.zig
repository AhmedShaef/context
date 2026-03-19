const std = @import("std");
const context = @import("context");

test "withCancel creates cancellable context" {
    const allocator = std.heap.page_allocator;

    const base = context.Context.empty();
    const pair = try base.withCancel(allocator);

    try std.testing.expect(!pair.context.isCancelled());

    pair.source.cancel();
    try std.testing.expect(pair.context.isCancelled());
}

test "context token observes cancellation" {
    const allocator = std.heap.page_allocator;

    const pair = try context.Context.background().withCancel(allocator);
    const token = pair.context.cancelToken();

    try std.testing.expect(!token.isCancelled());
    pair.source.cancel();
    try std.testing.expect(token.isCancelled());
}
