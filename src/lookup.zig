//! Deterministic lookup traversal for context values.

const node_mod = @import("node.zig");
const key = @import("key.zig");

/// Traverses child-to-parent until attach/mask/root.
///
/// First matching attach returns value. First matching mask terminates with
/// null, preventing ancestor resolution for that key.
pub fn get(comptime KeyType: type, start: ?*const node_mod.Node) ?KeyType.Value {
    key.require(KeyType);

    var cursor = start;
    while (cursor) |n| : (cursor = n.parent) {
        if (!n.matchesKey(KeyType)) continue;

        if (n.kind == .mask) return null;
        if (n.kind == .attach) return n.getImmediate(KeyType);
    }
    return null;
}

pub const Lookup = struct {};
