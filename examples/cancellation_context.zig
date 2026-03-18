const std = @import("std");
const context = @import("context");

pub fn main() void {
    _ = context.CancelSource{};
    _ = context.CancelToken{};
    std.debug.print("cancellation_context scaffold\\n", .{});
}