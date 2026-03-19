//! Context node representation for one derivation step.

const std = @import("std");
const key = @import("key.zig");
const deadline_mod = @import("deadline.zig");
const cancel_mod = @import("cancel.zig");

pub const CloneValueFn = *const fn (allocator: std.mem.Allocator, src: *const anyopaque) std.mem.Allocator.Error!*const anyopaque;

pub const FlatValue = struct {
    key_id: *const anyopaque,
    value_ptr: *const anyopaque,
    clone_fn: CloneValueFn,
};

pub const NodeKind = enum {
    derive,
    attach,
    mask,
    deadline,
    cancel,
    flatten,
};

pub const Node = struct {
    parent: ?*const Node = null,
    kind: NodeKind = .derive,
    key_id: ?*const anyopaque = null,
    value_ptr: ?*const anyopaque = null,
    value_clone_fn: ?CloneValueFn = null,
    flat_values: ?[]const FlatValue = null,
    deadline: ?deadline_mod.Deadline = null,
    cancel_state: ?*const cancel_mod.CancelState = null,

    pub fn initDerived(parent: ?*const Node) Node {
        return .{
            .parent = parent,
            .kind = .derive,
            .key_id = null,
            .value_ptr = null,
            .value_clone_fn = null,
            .flat_values = null,
            .deadline = null,
            .cancel_state = null,
        };
    }

    pub fn initBound(comptime KeyType: type, parent: ?*const Node, value_ptr: *const KeyType.Value) Node {
        key.require(KeyType);

        return .{
            .parent = parent,
            .kind = .attach,
            .key_id = keyId(KeyType),
            .value_ptr = @ptrCast(value_ptr),
            .value_clone_fn = cloneFn(KeyType),
            .flat_values = null,
            .deadline = null,
            .cancel_state = null,
        };
    }

    pub fn initMask(comptime KeyType: type, parent: ?*const Node) Node {
        key.require(KeyType);

        return .{
            .parent = parent,
            .kind = .mask,
            .key_id = keyId(KeyType),
            .value_ptr = null,
            .value_clone_fn = null,
            .flat_values = null,
            .deadline = null,
            .cancel_state = null,
        };
    }

    pub fn initDeadline(parent: ?*const Node, deadline: deadline_mod.Deadline) Node {
        return .{
            .parent = parent,
            .kind = .deadline,
            .key_id = null,
            .value_ptr = null,
            .value_clone_fn = null,
            .flat_values = null,
            .deadline = deadline,
            .cancel_state = null,
        };
    }

    pub fn initCancel(parent: ?*const Node, state: *const cancel_mod.CancelState) Node {
        return .{
            .parent = parent,
            .kind = .cancel,
            .key_id = null,
            .value_ptr = null,
            .value_clone_fn = null,
            .flat_values = null,
            .deadline = null,
            .cancel_state = state,
        };
    }

    pub fn initFlatten(values: []const FlatValue, deadline: ?deadline_mod.Deadline, cancel_state: ?*const cancel_mod.CancelState) Node {
        return .{
            .parent = null,
            .kind = .flatten,
            .key_id = null,
            .value_ptr = null,
            .value_clone_fn = null,
            .flat_values = values,
            .deadline = deadline,
            .cancel_state = cancel_state,
        };
    }

    pub fn hasBinding(self: *const Node) bool {
        return switch (self.kind) {
            .attach => self.key_id != null and self.value_ptr != null,
            .flatten => self.flat_values != null and self.flat_values.?.len > 0,
            else => false,
        };
    }

    pub fn matchesKey(self: *const Node, comptime KeyType: type) bool {
        key.require(KeyType);
        return self.key_id != null and self.key_id.? == keyId(KeyType);
    }

    pub fn getImmediate(self: *const Node, comptime KeyType: type) ?KeyType.Value {
        return switch (self.kind) {
            .attach => blk: {
                if (!self.matchesKey(KeyType)) break :blk null;
                const ptr = self.value_ptr orelse break :blk null;
                const typed_ptr: *const KeyType.Value = @ptrCast(@alignCast(ptr));
                break :blk typed_ptr.*;
            },
            .flatten => blk: {
                const values = self.flat_values orelse break :blk null;
                const wanted = keyId(KeyType);
                for (values) |entry| {
                    if (entry.key_id != wanted) continue;
                    const typed_ptr: *const KeyType.Value = @ptrCast(@alignCast(entry.value_ptr));
                    break :blk typed_ptr.*;
                }
                break :blk null;
            },
            else => null,
        };
    }

    pub fn flattenEntryCount(self: *const Node) usize {
        const values = self.flat_values orelse return 0;
        return values.len;
    }

    fn keyId(comptime KeyType: type) *const anyopaque {
        key.require(KeyType);
        return &struct {
            const Key = KeyType;
            var id_token: u8 = 0;
        }.id_token;
    }

    fn cloneFn(comptime KeyType: type) CloneValueFn {
        key.require(KeyType);
        return struct {
            fn cloneValue(allocator: std.mem.Allocator, src: *const anyopaque) std.mem.Allocator.Error!*const anyopaque {
                const typed_src: *const KeyType.Value = @ptrCast(@alignCast(src));
                const out = try allocator.create(KeyType.Value);
                out.* = typed_src.*;
                return @ptrCast(out);
            }
        }.cloneValue;
    }
};
