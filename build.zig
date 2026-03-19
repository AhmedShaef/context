const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const context_module = b.addModule("context", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const library_root = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const lib = b.addLibrary(.{
        .name = "context",
        .linkage = .static,
        .root_module = library_root,
    });
    b.installArtifact(lib);

    const test_step = b.step("test", "Run context package tests");

    const root_test_module = b.createModule(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    const root_tests = b.addTest(.{ .root_module = root_test_module });
    const run_root_tests = b.addRunArtifact(root_tests);
    test_step.dependOn(&run_root_tests.step);

    const test_files = [_][]const u8{
        "tests/context_smoke_test.zig",
        "tests/context_import_test.zig",
        "tests/context_root_test.zig",
        "tests/context_copy_test.zig",
    };
    for (test_files) |test_file| {
        const test_module = b.createModule(.{
            .root_source_file = b.path(test_file),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "context", .module = context_module }},
        });
        const t = b.addTest(.{ .root_module = test_module });
        const run_t = b.addRunArtifact(t);
        test_step.dependOn(&run_t.step);
    }

    const examples_step = b.step("examples", "Build context examples");
    const example_files = [_]struct { name: []const u8, path: []const u8 }{
        .{ .name = "basic_context", .path = "examples/basic_context.zig" },
        .{ .name = "deadline_context", .path = "examples/deadline_context.zig" },
        .{ .name = "cancellation_context", .path = "examples/cancellation_context.zig" },
        .{ .name = "clone_flatten_context", .path = "examples/clone_flatten_context.zig" },
    };

    for (example_files) |example| {
        const example_module = b.createModule(.{
            .root_source_file = b.path(example.path),
            .target = target,
            .optimize = optimize,
            .imports = &.{.{ .name = "context", .module = context_module }},
        });
        const exe = b.addExecutable(.{
            .name = example.name,
            .root_module = example_module,
        });
        b.installArtifact(exe);
        examples_step.dependOn(&exe.step);
    }
}