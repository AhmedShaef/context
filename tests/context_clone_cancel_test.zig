const std = @import("std");
const context = @import("context");

test "clone applies default cancel detach policy" {
    const allocator = std.heap.page_allocator;

    const pair = try context.Context.empty().withCancel(allocator);
    pair.source.cancel();

    const cloned = try pair.context.cloneInto(allocator);
    try std.testing.expect(!cloned.isCancelled());
}
