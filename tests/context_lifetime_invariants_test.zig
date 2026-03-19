const std = @import("std");
const context = @import("context");

const D = context.allocator_domain.AllocatorDomain;

test "same-domain lineage policy allows structural sharing" {
    try context.Context.validateSharedLineage(.request_arena, .request_arena);
    try std.testing.expect(context.lifetime.sameDomainDerivationAllowed(.worker_arena, .worker_arena));
}

test "parent lifetime invariant is explicit via validation" {
    try std.testing.expectError(
        error.CrossDomainStructuralSharingForbidden,
        context.Context.validateSharedLineage(D.request_arena, D.worker_arena),
    );
}
