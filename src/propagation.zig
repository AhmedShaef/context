//! Unified effective-state propagation semantics across lineage.

const key = @import("key.zig");
const node_mod = @import("node.zig");
const deadline_mod = @import("deadline.zig");

/// Effective non-value dimensions that compose independently.
pub const EffectiveState = struct {
    deadline: ?deadline_mod.Deadline,
    cancelled: bool,
};

/// Effective visible value for a key across child->parent lineage.
///
/// Rules:
/// - nearest attach binding wins
/// - nearest mask for the same key suppresses ancestor values for that key
/// - unrelated keys are unaffected by a mask
pub fn effectiveValue(comptime KeyType: type, start: ?*const node_mod.Node) ?KeyType.Value {
    key.require(KeyType);

    var cursor = start;
    while (cursor) |n| : (cursor = n.parent) {
        if (!n.matchesKey(KeyType)) continue;

        if (n.kind == .mask) return null;
        if (n.kind == .attach) return n.getImmediate(KeyType);
    }
    return null;
}

/// Effective deadline is the minimum visible deadline in the active lineage.
pub fn effectiveDeadline(start: ?*const node_mod.Node) ?deadline_mod.Deadline {
    var cursor = start;
    var effective: ?deadline_mod.Deadline = null;

    while (cursor) |n| : (cursor = n.parent) {
        if (n.kind != .deadline) continue;
        const d = n.deadline orelse continue;

        effective = if (effective) |current| deadline_mod.Deadline.min(current, d) else d;
    }
    return effective;
}

/// Effective cancellation is downward-observable and polling-based.
///
/// Each cancel node may carry a state linked to parent state; observing any
/// cancelled linked state in lineage yields a cancelled effective result.
pub fn effectiveCancellation(start: ?*const node_mod.Node) bool {
    var cursor = start;
    while (cursor) |n| : (cursor = n.parent) {
        if (n.kind != .cancel) continue;
        const state = n.cancel_state orelse continue;
        if (state.isCancelled()) return true;
    }
    return false;
}

pub fn effectiveState(start: ?*const node_mod.Node) EffectiveState {
    return .{
        .deadline = effectiveDeadline(start),
        .cancelled = effectiveCancellation(start),
    };
}
