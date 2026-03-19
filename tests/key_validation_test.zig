const std = @import("std");
const context = @import("context");

const ValidKey = struct {
    pub const Value = u32;
};

const MissingValueKey = struct {};

test "valid key passes validation helper" {
    try context.key.validate(ValidKey);
    try std.testing.expect(context.key.isValid(ValidKey));
}

test "missing Value key fails validation helper" {
    try std.testing.expectError(error.MissingValueDeclaration, context.key.validate(MissingValueKey));
}

test "string-like key types are rejected" {
    try std.testing.expectError(error.StringKeysForbidden, context.key.validate([]const u8));
    try std.testing.expect(!context.key.isValid([]const u8));
}