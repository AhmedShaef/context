const std = @import("std");
const context = @import("context");

pub fn main() void {
    _ = context.Context{};
    std.debug.print("basic_context scaffold\\n", .{});
}