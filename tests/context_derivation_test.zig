const std = @import("std");
const context = @import("context");

test "derive creates child context with parent linkage" {
    const allocator = std.heap.page_allocator;
    const root = context.Context.empty();

    const child = try root.derive(allocator);

    try std.testing.expect(!child.isEmpty());
    try std.testing.expect(child.parent() != null);
    try std.testing.expect((child.parent().?).isEmpty());
}

test "derive preserves parent immutability" {
    const allocator = std.heap.page_allocator;
    const root = context.Context.background();

    _ = try root.derive(allocator);

    try std.testing.expect(root.isBackground());
    try std.testing.expect(root.parent() == null);
}
