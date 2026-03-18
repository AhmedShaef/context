const std = @import("std");
const context = @import("context");

test "context smoke test" {
    _ = std.testing;
    _ = context.Context{};
}