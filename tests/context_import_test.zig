const std = @import("std");
const context = @import("context");

test "root module exports compile" {
    _ = std.testing;
    _ = context.Context{};
    _ = context.Key{};
    _ = context.Node{};
    _ = context.Lookup{};
    _ = context.Mask{};
    _ = context.Deadline{};
    _ = context.CancelSource{};
    _ = context.CancelToken{};
    _ = context.ClonePlan{};
    _ = context.DebugHooks{};
    _ = context.TestingSupport{};
    _ = context.constants.MAX_CONTEXT_DEPTH;
    _ = context.errors.ContextError;
}