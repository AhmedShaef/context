const std = @import("std");
const context = @import("context");

test "cloneInto creates self-contained context" {
    const allocator = std.heap.page_allocator;

    var ctx = context.Context.empty();
    ctx = try ctx.derive(allocator);

    const cloned = try ctx.cloneInto(allocator);

    try std.testing.expect(!cloned.hasParentLineage());
}
