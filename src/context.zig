//! Core context handle and root context primitives.

const std = @import("std");
const derive_mod = @import("derive.zig");
const attach_mod = @import("attach.zig");
const node_mod = @import("node.zig");
const lookup_mod = @import("lookup.zig");
const mask_mod = @import("mask.zig");

const RootKind = enum(u2) {
    empty,
    background,
};

/// `Context` is a value type; copying this struct copies handle state deterministically.
pub const Context = struct {
    node: ?*const node_mod.Node = null,
    root: RootKind = .empty,

    /// Returns the empty root context.
    pub fn empty() Context {
        return .{
            .node = null,
            .root = .empty,
        };
    }

    /// Returns the background root context.
    pub fn background() Context {
        return .{
            .node = null,
            .root = .background,
        };
    }

    pub fn isEmpty(self: Context) bool {
        return self.node == null and self.root == .empty;
    }

    pub fn isBackground(self: Context) bool {
        return self.node == null and self.root == .background;
    }

    pub fn derive(self: Context, allocator: std.mem.Allocator) std.mem.Allocator.Error!Context {
        return derive_mod.derive(self, allocator);
    }

    pub fn withValue(self: Context, comptime KeyType: type, value: KeyType.Value, allocator: std.mem.Allocator) attach_mod.AttachContextError!Context {
        return attach_mod.withValue(self, KeyType, value, allocator);
    }

    pub fn withoutValue(self: Context, comptime KeyType: type, allocator: std.mem.Allocator) mask_mod.MaskError!Context {
        return mask_mod.withoutValue(self, KeyType, allocator);
    }

    /// M05 typed retrieval: deterministic child-to-parent lookup with mask stop.
    pub fn get(self: Context, comptime KeyType: type) ?KeyType.Value {
        return lookup_mod.get(KeyType, self.node);
    }

    pub fn parent(self: Context) ?Context {
        const n = self.node orelse return null;
        return Context.fromRaw(n.parent, self.root);
    }

    pub fn hasImmediateBinding(self: Context) bool {
        const n = self.node orelse return false;
        return n.hasBinding();
    }

    pub fn rootTag(self: Context) RootKind {
        return self.root;
    }

    pub fn fromRaw(node: ?*const node_mod.Node, root: RootKind) Context {
        return .{
            .node = node,
            .root = root,
        };
    }
};
