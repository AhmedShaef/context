//! Derivation API implementation.

const std = @import("std");
const context_mod = @import("context.zig");
const node_mod = @import("node.zig");

/// Derives a child context by allocating a new node that references the parent.
pub fn derive(ctx: context_mod.Context, allocator: std.mem.Allocator) std.mem.Allocator.Error!context_mod.Context {
    const child_node = try allocator.create(node_mod.Node);
    child_node.* = node_mod.Node.initDerived(ctx.node);
    return context_mod.Context.fromRaw(child_node, ctx.rootTag());
}
