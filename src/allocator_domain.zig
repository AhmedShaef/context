//! Allocator/lifetime domain vocabulary for structural-sharing policy.

/// Semantic domains used to reason about lifetime safety boundaries.
///
/// This is policy vocabulary, not allocator implementation.
pub const AllocatorDomain = enum {
    root_owned,
    request_arena,
    worker_arena,
    long_lived_shared,
    external_borrowed,
};

pub fn isSame(a: AllocatorDomain, b: AllocatorDomain) bool {
    return a == b;
}

pub fn crossesBoundary(from: AllocatorDomain, to: AllocatorDomain) bool {
    return !isSame(from, to);
}

/// Cross-domain movement requires explicit migration policy (M10+ clone/flatten).
pub fn requiresMigrationPolicy(from: AllocatorDomain, to: AllocatorDomain) bool {
    return crossesBoundary(from, to);
}

pub fn isBorrowed(domain: AllocatorDomain) bool {
    return domain == .external_borrowed;
}

pub fn isLongLived(domain: AllocatorDomain) bool {
    return domain == .long_lived_shared or domain == .root_owned;
}
