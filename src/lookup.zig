//! Deterministic lookup traversal for context values.

const node_mod = @import("node.zig");
const propagation = @import("propagation.zig");

/// Value lookup delegates to the unified propagation layer so value, mask,
/// deadline, and cancellation semantics all compose from one effective-state model.
pub fn get(comptime KeyType: type, start: ?*const node_mod.Node) ?KeyType.Value {
    return propagation.effectiveValue(KeyType, start);
}

pub const Lookup = struct {};
