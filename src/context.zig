//! Core context handle and root context primitives.

const std = @import("std");
const derive_mod = @import("derive.zig");
const attach_mod = @import("attach.zig");
const node_mod = @import("node.zig");
const lookup_mod = @import("lookup.zig");
const mask_mod = @import("mask.zig");
const deadline_mod = @import("deadline.zig");
const cancel_mod = @import("cancel.zig");

const RootKind = enum(u2) {
    empty,
    background,
};

/// `Context` is a value type; copying this struct copies handle state deterministically.
pub const Context = struct {
    node: ?*const node_mod.Node = null,
    root: RootKind = .empty,

    pub const WithCancelResult = struct {
        context: Context,
        source: cancel_mod.CancelSource,
    };

    pub fn empty() Context {
        return .{ .node = null, .root = .empty };
    }

    pub fn background() Context {
        return .{ .node = null, .root = .background };
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

    pub fn withDeadline(self: Context, requested: deadline_mod.Deadline, allocator: std.mem.Allocator) std.mem.Allocator.Error!Context {
        const effective = deadline_mod.narrow(self.deadline(), requested);

        const child_node = try allocator.create(node_mod.Node);
        child_node.* = node_mod.Node.initDeadline(self.node, effective);

        return Context.fromRaw(child_node, self.root);
    }

    pub fn withTimeout(self: Context, duration_nanos: u64, now_nanos: u64, allocator: std.mem.Allocator) (std.mem.Allocator.Error || deadline_mod.TimeoutError)!Context {
        const requested = try deadline_mod.fromTimeout(now_nanos, duration_nanos);
        return self.withDeadline(requested, allocator);
    }

    /// Derives a context with a new child cancellation state and source.
    pub fn withCancel(self: Context, allocator: std.mem.Allocator) std.mem.Allocator.Error!WithCancelResult {
        const parent_state = self.cancelState();

        const state = try allocator.create(cancel_mod.CancelState);
        state.* = cancel_mod.CancelState.init(parent_state);

        const child_node = try allocator.create(node_mod.Node);
        child_node.* = node_mod.Node.initCancel(self.node, state);

        return .{
            .context = Context.fromRaw(child_node, self.root),
            .source = .{ .state = state },
        };
    }

    pub fn cancelToken(self: Context) cancel_mod.CancelToken {
        return .{ .state = self.cancelState() };
    }

    /// Polling-based cancellation observation.
    pub fn isCancelled(self: Context) bool {
        return self.cancelToken().isCancelled();
    }

    pub fn get(self: Context, comptime KeyType: type) ?KeyType.Value {
        return lookup_mod.get(KeyType, self.node);
    }

    pub fn deadline(self: Context) ?deadline_mod.Deadline {
        var cursor = self.node;
        while (cursor) |n| : (cursor = n.parent) {
            if (n.kind == .deadline) return n.deadline;
        }
        return null;
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
        return .{ .node = node, .root = root };
    }

    fn cancelState(self: Context) ?*const cancel_mod.CancelState {
        var cursor = self.node;
        while (cursor) |n| : (cursor = n.parent) {
            if (n.kind == .cancel) return n.cancel_state;
        }
        return null;
    }
};
