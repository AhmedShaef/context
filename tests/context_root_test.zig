const std = @import("std");
const context = @import("context");

test "root contexts can be created" {
    const empty_ctx = context.Context.empty();
    const background_ctx = context.Context.background();

    try std.testing.expect(empty_ctx.isEmpty());
    try std.testing.expect(!empty_ctx.isBackground());

    try std.testing.expect(background_ctx.isBackground());
    try std.testing.expect(!background_ctx.isEmpty());
}

test "zero-value context is safe" {
    const zero_ctx = context.Context{};

    try std.testing.expect(zero_ctx.isEmpty());
    try std.testing.expect(!zero_ctx.isBackground());
}