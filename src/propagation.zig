//! Unified effective-state propagation semantics across lineage.

const key = @import("key.zig");
const node_mod = @import("node.zig");
const deadline_mod = @import("deadline.zig");
const lifetime_validation = @import("lifetime_validation.zig");
const allocator_domain = @import("allocator_domain.zig");

pub const EffectiveState = struct {
    deadline: ?deadline_mod.Deadline,
    cancelled: bool,
};

pub fn effectiveValue(comptime KeyType: type, start: ?*const node_mod.Node) ?KeyType.Value {
    key.require(KeyType);

    var cursor = start;
    while (cursor) |n| : (cursor = n.parent) {
        if (n.kind == .flatten) {
            return n.getImmediate(KeyType);
        }

        if (!n.matchesKey(KeyType)) continue;

        if (n.kind == .mask) return null;
        if (n.kind == .attach) return n.getImmediate(KeyType);
    }
    return null;
}

pub fn effectiveDeadline(start: ?*const node_mod.Node) ?deadline_mod.Deadline {
    var cursor = start;
    var effective: ?deadline_mod.Deadline = null;

    while (cursor) |n| : (cursor = n.parent) {
        if (n.deadline) |d| {
            effective = if (effective) |current| deadline_mod.Deadline.min(current, d) else d;
        }
    }
    return effective;
}

pub fn effectiveCancellation(start: ?*const node_mod.Node) bool {
    var cursor = start;
    while (cursor) |n| : (cursor = n.parent) {
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

pub fn effectiveStateWithLifetimeValidation(start: ?*const node_mod.Node, parent_domain: allocator_domain.AllocatorDomain, child_domain: allocator_domain.AllocatorDomain, cancel_domain: allocator_domain.AllocatorDomain) lifetime_validation.ValidationError!EffectiveState {
    try lifetime_validation.validateDeterministic(parent_domain, child_domain, cancel_domain);
    return effectiveState(start);
}
