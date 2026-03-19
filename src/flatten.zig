//! Lineage flattening for clone/migration.

const std = @import("std");
const node_mod = @import("node.zig");
const propagation = @import("propagation.zig");
const migration_policy = @import("migration_policy.zig");
const cancel_mod = @import("cancel.zig");

pub const FlattenError = std.mem.Allocator.Error || error{
    MissingCloneFunction,
    MissingValuePointer,
    MissingCancelState,
};

/// Reconstructs effective visible state into one self-contained node.
///
/// Flattening walks lineage once and keeps only effective values (masked values
/// are excluded), effective deadline, and cancellation according to policy.
pub fn flattenIntoNode(start: ?*const node_mod.Node, allocator: std.mem.Allocator, policy: migration_policy.MigrationPolicy) FlattenError!node_mod.Node {
    var seen_keys: std.ArrayListUnmanaged(*const anyopaque) = .{};
    defer seen_keys.deinit(allocator);

    var migrated_values: std.ArrayListUnmanaged(node_mod.FlatValue) = .{};
    defer migrated_values.deinit(allocator);

    var cursor = start;
    while (cursor) |n| : (cursor = n.parent) {
        switch (n.kind) {
            .mask => {
                const key_id = n.key_id orelse continue;
                if (!containsKey(seen_keys.items, key_id)) {
                    try seen_keys.append(allocator, key_id);
                }
            },
            .attach => {
                const key_id = n.key_id orelse continue;
                if (containsKey(seen_keys.items, key_id)) continue;

                try seen_keys.append(allocator, key_id);

                const src_ptr = n.value_ptr orelse return error.MissingValuePointer;
                const clone_fn = n.value_clone_fn orelse return error.MissingCloneFunction;
                const dst_ptr = try clone_fn(allocator, src_ptr);

                try migrated_values.append(allocator, .{
                    .key_id = key_id,
                    .value_ptr = dst_ptr,
                    .clone_fn = clone_fn,
                });
            },
            .flatten => {
                const flat = n.flat_values orelse &.{};
                for (flat) |entry| {
                    if (containsKey(seen_keys.items, entry.key_id)) continue;

                    try seen_keys.append(allocator, entry.key_id);
                    const dst_ptr = try entry.clone_fn(allocator, entry.value_ptr);
                    try migrated_values.append(allocator, .{
                        .key_id = entry.key_id,
                        .value_ptr = dst_ptr,
                        .clone_fn = entry.clone_fn,
                    });
                }
            },
            else => {},
        }
    }

    const values_slice = try migrated_values.toOwnedSlice(allocator);
    const effective_deadline = propagation.effectiveDeadline(start);
    const migrated_cancel = try migrateCancel(start, policy);

    return node_mod.Node.initFlatten(values_slice, effective_deadline, migrated_cancel);
}

fn containsKey(keys: []const *const anyopaque, needle: *const anyopaque) bool {
    for (keys) |k| {
        if (k == needle) return true;
    }
    return false;
}

fn migrateCancel(start: ?*const node_mod.Node, policy: migration_policy.MigrationPolicy) FlattenError!?*const cancel_mod.CancelState {
    return switch (policy.cancel) {
        .detach => null,
        .preserve_shared => blk: {
            var cursor = start;
            while (cursor) |n| : (cursor = n.parent) {
                if (n.cancel_state) |s| break :blk s;
            }
            break :blk null;
        },
    };
}
