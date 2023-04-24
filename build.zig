const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "amoeba",
        .root_source_file = .{ .path = "amoeba.c" },
        .target = target,
        .optimize = optimize,
    });
    lib.installHeader("./amoeba.h", "amoeba.h");
    lib.addIncludePath(".");
    lib.linkLibC();
    b.installArtifact(lib);

    // Run c test harness

    const c_tests = b.addExecutable(.{
        .name = "amoeba-test",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });
    c_tests.addCSourceFile("test.c", &.{"-g"});
    c_tests.linkLibC();

    const run_c_tests = b.addRunArtifact(c_tests);

    const c_test_step = b.step("c-test", "Run library tests written in c");
    c_test_step.dependOn(&run_c_tests.step);

    // Run main tests

    const main_tests = b.addTest(.{
        .root_source_file = .{ .path = "test.zig" },
        .target = target,
        .optimize = optimize,
    });
    main_tests.linkLibrary(lib);
    main_tests.step.dependOn(&lib.step);

    const run_main_tests = b.addRunArtifact(main_tests);

    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build test`
    // This will evaluate the `test` step rather than the default, which is "install".
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}
