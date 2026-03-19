const std = @import("std");
const context = @import("context");

const D = context.allocator_domain.AllocatorDomain;

test "cancel-state borrow across domains is restricted" {
    try std.testing.expectError(
        error.CancelStateCrossDomainBorrowForbidden,
        context.Context.validateCancelBorrow(D.worker_arena, D.request_arena),
    );
}

test "same-domain and long-lived cancel-state borrowing are valid" {
    try context.Context.validateCancelBorrow(D.request_arena, D.request_arena);
    try context.Context.validateCancelBorrow(D.worker_arena, D.long_lived_shared);
}

test "lifetime validation is deterministic for same inputs" {
    try context.lifetime_validation.validateDeterministic(D.request_arena, D.request_arena, D.request_arena);
}
