//! Deadline representation and helpers.

const std = @import("std");

/// Monotonic deadline timestamp in nanoseconds.
///
/// The core package stores deadline values as monotonic-time points to avoid
/// wall-clock jumps affecting propagation semantics.
pub const Deadline = struct {
    nanos: u64,

    pub fn init(nanos: u64) Deadline {
        return .{ .nanos = nanos };
    }

    pub fn min(a: Deadline, b: Deadline) Deadline {
        return if (a.nanos <= b.nanos) a else b;
    }
};

pub const TimeoutError = error{TimeoutOverflow};

pub fn fromTimeout(now_nanos: u64, duration_nanos: u64) TimeoutError!Deadline {
    const deadline_nanos = std.math.add(u64, now_nanos, duration_nanos) catch return error.TimeoutOverflow;
    return Deadline.init(deadline_nanos);
}

/// Applies the narrowing invariant: child deadlines cannot extend parent deadlines.
pub fn narrow(parent: ?Deadline, requested: Deadline) Deadline {
    return if (parent) |p| Deadline.min(p, requested) else requested;
}
