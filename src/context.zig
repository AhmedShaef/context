//! Core context handle and root context primitives.

/// Minimal placeholder for the future internal context chain representation.
pub const ContextNode = struct {
    parent: ?*const ContextNode = null,
};

const RootKind = enum(u2) {
    empty,
    background,
};

/// `Context` is a value type; copying this struct copies handle state deterministically.
pub const Context = struct {
    node: ?*const ContextNode = null,
    root: RootKind = .empty,

    /// Returns the empty root context.
    pub fn empty() Context {
        return .{
            .node = null,
            .root = .empty,
        };
    }

    /// Returns the background root context.
    pub fn background() Context {
        return .{
            .node = null,
            .root = .background,
        };
    }

    /// Indicates whether this context is the empty root.
    pub fn isEmpty(self: Context) bool {
        return self.node == null and self.root == .empty;
    }

    /// Indicates whether this context is the background root.
    pub fn isBackground(self: Context) bool {
        return self.node == null and self.root == .background;
    }
};