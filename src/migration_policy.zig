//! Migration policy for cross-allocator clone.

pub const CancelMigration = enum {
    detach,
    preserve_shared,
};

pub const MigrationPolicy = struct {
    cancel: CancelMigration = .detach,
};

pub fn defaultPolicy() MigrationPolicy {
    return .{ .cancel = .detach };
}
