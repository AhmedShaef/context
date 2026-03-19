//! Typed attach/get contract helpers for Context.

const std = @import("std");
const key = @import("key.zig");
const value_binding = @import("value_binding.zig");

pub const AttachError = key.KeyValidationError;

/// Contract-level attach helper.
///
/// The allocator is explicit because attachment may allocate in later storage
/// implementations, and allocator ownership must stay explicit in Zig APIs.
pub fn buildAttachment(comptime KeyType: type, value: KeyType.Value, allocator: std.mem.Allocator) AttachError!value_binding.ValueBinding(KeyType) {
    try key.validate(KeyType);
    _ = allocator;
    return value_binding.make(KeyType, value);
}

/// Contract-level typed retrieval shape without traversal semantics.
pub fn retrieve(comptime KeyType: type) ?KeyType.Value {
    key.require(KeyType);
    return null;
}