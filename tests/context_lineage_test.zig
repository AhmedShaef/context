const std = @import("std");
const context = @import("context");

const TenantID = struct {
    pub const Value = u64;
};

test "lineage chain is deterministic across derivation steps" {
    const allocator = std.heap.page_allocator;

    const root = context.Context.empty();
    const child = try root.derive(allocator);
    const grandchild = try child.derive(allocator);

    try std.testing.expect(grandchild.parent() != null);
    try std.testing.expect((grandchild.parent().?).parent() != null);
    try std.testing.expect((((grandchild.parent().?).parent()).?).isEmpty());
}

test "attachment node links to parent node" {
    const allocator = std.heap.page_allocator;

    const root = context.Context.background();
    const attached = try root.withValue(TenantID, @as(u64, 55), allocator);

    try std.testing.expect(attached.parent() != null);
    try std.testing.expect((attached.parent().?).isBackground());
    try std.testing.expect(attached.hasImmediateBinding());
}
