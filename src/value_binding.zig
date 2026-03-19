//! Internal typed value-binding record shape for later storage layers.

const key = @import("key.zig");

/// Represents a typed payload bound to a comptime key identity.
///
/// This keeps key identity in the type system (`KeyType`) and keeps runtime data
/// limited to the payload itself.
pub fn ValueBinding(comptime KeyType: type) type {
    key.require(KeyType);

    return struct {
        pub const Key = KeyType;

        value: KeyType.Value,

        pub fn init(value: KeyType.Value) @This() {
            return .{ .value = value };
        }

        pub fn valuePtr(self: *const @This()) *const anyopaque {
            return @ptrCast(&self.value);
        }
    };
}

pub fn make(comptime KeyType: type, value: KeyType.Value) ValueBinding(KeyType) {
    return ValueBinding(KeyType).init(value);
}