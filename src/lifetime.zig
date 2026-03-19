//! Lifetime invariants for domain-bounded structural sharing.

const allocator_domain = @import("allocator_domain.zig");

pub const LifetimeError = error{
    ParentChildInvariantViolation,
    CrossDomainStructuralSharingForbidden,
    CancelStateCrossDomainBorrowForbidden,
};

/// Authoritative structural invariant: child lifetime <= parent lifetime.
///
/// Under M09 policy, structural sharing is valid only in the same domain.
pub fn validateSharedLineage(parent_domain: allocator_domain.AllocatorDomain, child_domain: allocator_domain.AllocatorDomain) LifetimeError!void {
    if (allocator_domain.crossesBoundary(parent_domain, child_domain)) {
        return error.CrossDomainStructuralSharingForbidden;
    }
}

pub fn sameDomainDerivationAllowed(parent_domain: allocator_domain.AllocatorDomain, child_domain: allocator_domain.AllocatorDomain) bool {
    return !allocator_domain.crossesBoundary(parent_domain, child_domain);
}

pub fn requiresCloneForDomainTransition(from: allocator_domain.AllocatorDomain, to: allocator_domain.AllocatorDomain) bool {
    return allocator_domain.requiresMigrationPolicy(from, to);
}

/// Cancel-state lifetime is validated separately from value-lineage lifetime.
///
/// Borrowed cancel state must not silently cross domains. A long-lived shared
/// cancel domain is explicitly allowed by policy.
pub fn validateCancelBorrow(lineage_domain: allocator_domain.AllocatorDomain, cancel_domain: allocator_domain.AllocatorDomain) LifetimeError!void {
    if (lineage_domain == cancel_domain) return;
    if (cancel_domain == .long_lived_shared) return;
    return error.CancelStateCrossDomainBorrowForbidden;
}
