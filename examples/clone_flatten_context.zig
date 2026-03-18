const std = @import("std");
const context = @import("context");

pub fn main() void {
    _ = context.ClonePlan{};
    std.debug.print("clone_flatten_context scaffold\\n", .{});
}