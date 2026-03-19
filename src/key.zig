//! Comptime typed-key contract for the public Context API.

const std = @import("std");

/// Backward-compatible placeholder export from M01/M02.
pub const Key = struct {};

/// Validation failures surfaced by policy helpers.
pub const KeyValidationError = error{
    MissingValueDeclaration,
    StringKeysForbidden,
};

/// Returns whether a candidate key type matches the M03 key contract.
pub fn isValid(comptime Candidate: type) bool {
    if (isStringLikeType(Candidate)) return false;
    return hasValueDeclaration(Candidate);
}

/// Runtime-friendly validation helper used by tests and contract entrypoints.
///
/// String-like key types are forbidden because they reintroduce name-based
/// identity and collisions, which violates the architecture's typed-key model.
pub fn validate(comptime Candidate: type) KeyValidationError!void {
    if (isStringLikeType(Candidate)) return error.StringKeysForbidden;
    if (!hasValueDeclaration(Candidate)) return error.MissingValueDeclaration;
}

/// Compile-time contract gate for APIs that require a valid key shape.
pub fn require(comptime Candidate: type) void {
    comptime {
        if (isStringLikeType(Candidate)) {
            @compileError("context keys must be comptime types and cannot be string-like");
        }
        if (!hasValueDeclaration(Candidate)) {
            @compileError("context key type must declare `pub const Value` payload type");
        }
    }
}

/// Resolves the payload type declared by a valid key.
pub fn ValueType(comptime Candidate: type) type {
    require(Candidate);
    return Candidate.Value;
}

fn hasValueDeclaration(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .@"struct", .@"enum", .@"union", .@"opaque" => @hasDecl(T, "Value"),
        else => false,
    };
}

fn isStringLikeType(comptime T: type) bool {
    return switch (@typeInfo(T)) {
        .pointer => |p| p.child == u8,
        .array => |a| a.child == u8,
        else => false,
    };
}

test "valid key shape passes validation" {
    const RequestID = struct { pub const Value = u128; };

    try validate(RequestID);
    try std.testing.expect(isValid(RequestID));
}

test "missing Value key is rejected" {
    const BadKey = struct {};

    try std.testing.expectError(error.MissingValueDeclaration, validate(BadKey));
    try std.testing.expect(!isValid(BadKey));
}

test "string-like key types are rejected" {
    try std.testing.expectError(error.StringKeysForbidden, validate([]const u8));
    try std.testing.expect(!isValid([]const u8));
}
