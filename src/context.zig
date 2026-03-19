//! Core context handle and root context primitives.

const std = @import("std");
const derive_mod = @import("derive.zig");
const attach_mod = @import("attach.zig");
const node_mod = @import("node.zig");

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

    /// Indicates whether this context is the empty root.
    pub fn isEmpty(self: Context) bool {
        return self.node == null and self.root == .empty;
    }

    /// Indicates whether this context is the background root.
    pub fn isBackground(self: Context) bool {
        return self.node == null and self.root == .background;
    }

    /// Creates a child context node with no value binding.
    pub fn derive(self: Context, allocator: std.mem.Allocator) std.mem.Allocator.Error!Context {
        return derive_mod.derive(self, allocator);
    }

    /// Attaches a typed key/value by deriving a new context node.
    pub fn withValue(self: Context, comptime KeyType: type, value: KeyType.Value, allocator: std.mem.Allocator) attach_mod.AttachContextError!Context {
        return attach_mod.withValue(self, KeyType, value, allocator);
    }

    /// Immediate-node retrieval only; parent traversal is intentionally deferred.
    pub fn get(self: Context, comptime KeyType: type) ?KeyType.Value {
        const n = self.node orelse return null;
        return n.getImmediate(KeyType);
    }

    /// Returns the immediate parent context, if this context has a node.
    pub fn parent(self: Context) ?Context {
        const n = self.node orelse return null;
        return Context.fromRaw(n.parent, self.root);
    }

    /// Returns true when the current node carries an attached value.
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
