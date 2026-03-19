const std = @import("std");
const context = @import("context");

test "copying empty context preserves behavior" {
    const original = context.Context.empty();
    const copy = original;

    try std.testing.expect(copy.isEmpty());
    try std.testing.expect(!copy.isBackground());
    try std.testing.expectEqual(original.isEmpty(), copy.isEmpty());
    try std.testing.expectEqual(original.isBackground(), copy.isBackground());
}

test "copying background context preserves behavior" {
    const original = context.Context.background();
    const copy = original;

    try std.testing.expect(copy.isBackground());
    try std.testing.expect(!copy.isEmpty());
    try std.testing.expectEqual(original.isEmpty(), copy.isEmpty());
    try std.testing.expectEqual(original.isBackground(), copy.isBackground());
}