//! Cancellation state, source, and token.

const std = @import("std");

/// Shared cancellation state with optional parent linkage.
///
/// Parent linkage allows downward propagation: if an ancestor state is cancelled,
/// descendant observers report cancelled as well.
pub const CancelState = struct {
    parent: ?*const CancelState,
    cancelled: std.atomic.Value(bool),

    pub fn init(parent: ?*const CancelState) CancelState {
        return .{
            .parent = parent,
            .cancelled = std.atomic.Value(bool).init(false),
        };
    }

    pub fn isCancelled(self: *const CancelState) bool {
        if (self.cancelled.load(.acquire)) return true;

        var cursor = self.parent;
        while (cursor) |p| : (cursor = p.parent) {
            if (p.cancelled.load(.acquire)) return true;
        }
        return false;
    }
};

/// Write-capable cancellation owner.
pub const CancelSource = struct {
    state: ?*CancelState = null,

    pub fn token(self: CancelSource) CancelToken {
        return .{ .state = self.state };
    }

    /// Idempotent cancel signal.
    pub fn cancel(self: CancelSource) void {
        const s = self.state orelse return;
        s.cancelled.store(true, .release);
    }

    pub fn isCancelled(self: CancelSource) bool {
        return self.token().isCancelled();
    }
};

/// Read-only cancellation observer.
pub const CancelToken = struct {
    state: ?*const CancelState = null,

    pub fn isCancelled(self: CancelToken) bool {
        const s = self.state orelse return false;
        return s.isCancelled();
    }
};
