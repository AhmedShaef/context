//! Value masking implementation.

const std = @import("std");
const context_mod = @import("context.zig");
const node_mod = @import("node.zig");
const key = @import("key.zig");

pub const MaskError = std.mem.Allocator.Error || key.KeyValidationError;

/// Inserts a mask node for `KeyType`, which stops ancestor lookup for that key.
pub fn withoutValue(ctx: context_mod.Context, comptime KeyType: type, allocator: std.mem.Allocator) MaskError!context_mod.Context {
    try key.validate(KeyType);

    const mask_node = try allocator.create(node_mod.Node);
    mask_node.* = node_mod.Node.initMask(KeyType, ctx.node);

    return context_mod.Context.fromRaw(mask_node, ctx.rootTag());
}

pub const Mask = struct {};
