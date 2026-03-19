const std = @import("std");
const context = @import("context");

const D = context.allocator_domain.AllocatorDomain;

test "cross-domain shared lineage is rejected by policy" {
    try std.testing.expectError(
        error.CrossDomainStructuralSharingForbidden,
        context.lifetime_validation.validateSharedLineage(D.request_arena, D.worker_arena),
    );
}

test "cross-domain movement is marked clone-required by policy" {
    try std.testing.expect(context.lifetime_validation.requiresCloneForDomainTransition(D.request_arena, D.worker_arena));
    try std.testing.expect(!context.lifetime_validation.requiresCloneForDomainTransition(D.worker_arena, D.worker_arena));
}
