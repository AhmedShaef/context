//! Context node representation for one derivation step.

const key = @import("key.zig");
const deadline_mod = @import("deadline.zig");
const cancel_mod = @import("cancel.zig");

/// Operation represented by this derivation node.
pub const NodeKind = enum {
    derive,
    attach,
    mask,
    deadline,
    cancel,
};

/// A node is a single immutable derivation layer.
///
/// Each node references its parent and may carry one operation payload
/// (attach/mask/deadline/cancel) for deterministic child-to-parent traversal.
pub const Node = struct {
    parent: ?*const Node = null,
    kind: NodeKind = .derive,
    key_marker: ?*const fn () void = null,
    value_ptr: ?*const anyopaque = null,
    deadline: ?deadline_mod.Deadline = null,
    cancel_state: ?*const cancel_mod.CancelState = null,

    pub fn initDerived(parent: ?*const Node) Node {
        return .{
            .parent = parent,
            .kind = .derive,
            .key_marker = null,
            .value_ptr = null,
            .deadline = null,
            .cancel_state = null,
        };
    }

    pub fn initBound(comptime KeyType: type, parent: ?*const Node, value_ptr: *const KeyType.Value) Node {
        key.require(KeyType);

        return .{
            .parent = parent,
            .kind = .attach,
            .key_marker = keyMarker(KeyType),
            .value_ptr = @ptrCast(value_ptr),
            .deadline = null,
            .cancel_state = null,
        };
    }

    pub fn initMask(comptime KeyType: type, parent: ?*const Node) Node {
        key.require(KeyType);

        return .{
            .parent = parent,
            .kind = .mask,
            .key_marker = keyMarker(KeyType),
            .value_ptr = null,
            .deadline = null,
            .cancel_state = null,
        };
    }

    pub fn initDeadline(parent: ?*const Node, deadline: deadline_mod.Deadline) Node {
        return .{
            .parent = parent,
            .kind = .deadline,
            .key_marker = null,
            .value_ptr = null,
            .deadline = deadline,
            .cancel_state = null,
        };
    }

    pub fn initCancel(parent: ?*const Node, state: *const cancel_mod.CancelState) Node {
        return .{
            .parent = parent,
            .kind = .cancel,
            .key_marker = null,
            .value_ptr = null,
            .deadline = null,
            .cancel_state = state,
        };
    }

    pub fn hasBinding(self: *const Node) bool {
        return self.kind == .attach and self.key_marker != null and self.value_ptr != null;
    }

    pub fn matchesKey(self: *const Node, comptime KeyType: type) bool {
        key.require(KeyType);
        return self.key_marker != null and self.key_marker.? == keyMarker(KeyType);
    }

    pub fn getImmediate(self: *const Node, comptime KeyType: type) ?KeyType.Value {
        if (self.kind != .attach) return null;
        if (!self.matchesKey(KeyType)) return null;

        const ptr = self.value_ptr orelse return null;
        const typed_ptr: *const KeyType.Value = @ptrCast(@alignCast(ptr));
        return typed_ptr.*;
    }

    fn keyMarker(comptime KeyType: type) *const fn () void {
        key.require(KeyType);
        return struct {
            fn marker() void {}
        }.marker;
    }
};
