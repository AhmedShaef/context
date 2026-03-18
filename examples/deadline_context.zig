const std = @import("std");
const context = @import("context");

pub fn main() void {
    _ = context.Deadline{};
    std.debug.print("deadline_context scaffold\\n", .{});
}