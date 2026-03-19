//! Value attachment implementation for derived contexts.

const std = @import("std");
const context_mod = @import("context.zig");
const node_mod = @import("node.zig");
const value_contracts = @import("value_contracts.zig");

pub const AttachContextError = std.mem.Allocator.Error || value_contracts.AttachError;

/// Attaches a typed value by deriving a new node carrying one binding.
///
/// Parent contexts remain unchanged; child nodes shadow same-key ancestor values
/// by owning the newest immediate binding for that key.
pub fn withValue(ctx: context_mod.Context, comptime KeyType: type, value: KeyType.Value, allocator: std.mem.Allocator) AttachContextError!context_mod.Context {
    const binding = try value_contracts.buildAttachment(KeyType, value, allocator);

    const payload_ptr = try allocator.create(KeyType.Value);
    payload_ptr.* = binding.value;

    const child_node = try allocator.create(node_mod.Node);
    child_node.* = node_mod.Node.initBound(KeyType, ctx.node, payload_ptr);

    return context_mod.Context.fromRaw(child_node, ctx.rootTag());
}
