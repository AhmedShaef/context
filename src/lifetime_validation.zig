//! Deterministic lifetime-policy validation helpers.

const allocator_domain = @import("allocator_domain.zig");
const lifetime = @import("lifetime.zig");

pub const ValidationError = lifetime.LifetimeError || error{
    NonDeterministicValidation,
};

pub fn validateSharedLineage(parent_domain: allocator_domain.AllocatorDomain, child_domain: allocator_domain.AllocatorDomain) ValidationError!void {
    try lifetime.validateSharedLineage(parent_domain, child_domain);
}

pub fn validateCancelBorrow(lineage_domain: allocator_domain.AllocatorDomain, cancel_domain: allocator_domain.AllocatorDomain) ValidationError!void {
    try lifetime.validateCancelBorrow(lineage_domain, cancel_domain);
}

pub fn requiresCloneForDomainTransition(from: allocator_domain.AllocatorDomain, to: allocator_domain.AllocatorDomain) bool {
    return lifetime.requiresCloneForDomainTransition(from, to);
}

/// Ensures validation outcomes are deterministic for identical policy inputs.
pub fn validateDeterministic(parent_domain: allocator_domain.AllocatorDomain, child_domain: allocator_domain.AllocatorDomain, cancel_domain: allocator_domain.AllocatorDomain) ValidationError!void {
    const shared_1 = lifetime.sameDomainDerivationAllowed(parent_domain, child_domain);
    const shared_2 = lifetime.sameDomainDerivationAllowed(parent_domain, child_domain);
    if (shared_1 != shared_2) return error.NonDeterministicValidation;

    const clone_1 = lifetime.requiresCloneForDomainTransition(parent_domain, child_domain);
    const clone_2 = lifetime.requiresCloneForDomainTransition(parent_domain, child_domain);
    if (clone_1 != clone_2) return error.NonDeterministicValidation;

    const cancel_ok_1 = canBorrowCancel(child_domain, cancel_domain);
    const cancel_ok_2 = canBorrowCancel(child_domain, cancel_domain);
    if (cancel_ok_1 != cancel_ok_2) return error.NonDeterministicValidation;
}

fn canBorrowCancel(lineage_domain: allocator_domain.AllocatorDomain, cancel_domain: allocator_domain.AllocatorDomain) bool {
    lifetime.validateCancelBorrow(lineage_domain, cancel_domain) catch return false;
    return true;
}
