const std = @import("std");
const context = @import("context");

const D = context.allocator_domain.AllocatorDomain;

test "allocator domain helpers classify boundaries" {
    try std.testing.expect(context.allocator_domain.isSame(D.request_arena, D.request_arena));
    try std.testing.expect(context.allocator_domain.crossesBoundary(D.request_arena, D.worker_arena));
    try std.testing.expect(context.allocator_domain.requiresMigrationPolicy(D.request_arena, D.worker_arena));
}

test "requiresCloneForDomainTransition policy is explicit" {
    try std.testing.expect(!context.Context.requiresCloneForDomainTransition(D.root_owned, D.root_owned));
    try std.testing.expect(context.Context.requiresCloneForDomainTransition(D.request_arena, D.worker_arena));
}
