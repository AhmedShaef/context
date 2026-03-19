const std = @import("std");
const context = @import("context");

const TenantID = struct {
    pub const Value = u64;
};

test "attachment contract is allocator-threaded and typed" {
    const allocator = std.testing.allocator;

    const binding = try context.value_contracts.buildAttachment(TenantID, @as(TenantID.Value, 9), allocator);
    try std.testing.expectEqual(@as(TenantID.Value, 9), binding.value);
}

test "typed retrieval contract returns optional payload type" {
    const result: ?TenantID.Value = context.value_contracts.retrieve(TenantID);
    try std.testing.expect(result == null);
}