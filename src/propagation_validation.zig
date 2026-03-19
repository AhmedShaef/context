//! Propagation validation helpers for deterministic effective-state behavior.

const std = @import("std");
const node_mod = @import("node.zig");
const propagation = @import("propagation.zig");

pub const ValidationError = error{
    NonDeterministicValue,
    NonDeterministicDeadline,
    NonDeterministicCancellation,
};

/// Ensures repeated effective-state computation for a lineage is stable.
pub fn validateDeterministic(comptime KeyType: type, start: ?*const node_mod.Node) ValidationError!void {
    const v1 = propagation.effectiveValue(KeyType, start);
    const v2 = propagation.effectiveValue(KeyType, start);
    if (!std.meta.eql(v1, v2)) return error.NonDeterministicValue;

    const d1 = propagation.effectiveDeadline(start);
    const d2 = propagation.effectiveDeadline(start);
    if (!std.meta.eql(d1, d2)) return error.NonDeterministicDeadline;

    const c1 = propagation.effectiveCancellation(start);
    const c2 = propagation.effectiveCancellation(start);
    if (c1 != c2) return error.NonDeterministicCancellation;
}
