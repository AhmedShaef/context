//! Cross-allocator clone contracts.

const migration_policy = @import("migration_policy.zig");

/// Placeholder plan type retained for public compatibility with earlier milestones.
pub const ClonePlan = struct {};

pub const ClonePolicy = migration_policy.MigrationPolicy;
