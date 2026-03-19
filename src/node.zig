//! Context node representation for one derivation step.

const key = @import("key.zig");

/// A node is a single immutable derivation layer.
///
/// Each node optionally carries one typed key/value binding and a pointer to its
/// parent node, which forms deterministic parent-child lineage.
pub const Node = struct {
    parent: ?*const Node = null,
    key_marker: ?*const fn () void = null,
    value_ptr: ?*const anyopaque = null,

    pub fn initDerived(parent: ?*const Node) Node {
        return .{
            .parent = parent,
            .key_marker = null,
            .value_ptr = null,
        };
    }

    pub fn initBound(comptime KeyType: type, parent: ?*const Node, value_ptr: *const KeyType.Value) Node {
        key.require(KeyType);

        return .{
            .parent = parent,
            .key_marker = keyMarker(KeyType),
            .value_ptr = @ptrCast(value_ptr),
        };
    }

    pub fn hasBinding(self: *const Node) bool {
        return self.key_marker != null and self.value_ptr != null;
    }

    pub fn matchesKey(self: *const Node, comptime KeyType: type) bool {
        key.require(KeyType);

        return self.key_marker != null and self.key_marker.? == keyMarker(KeyType);
    }

    /// Returns the value only when this node's immediate binding matches `KeyType`.
    /// M04 intentionally does not traverse parent lineage for lookup.
    pub fn getImmediate(self: *const Node, comptime KeyType: type) ?KeyType.Value {
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
