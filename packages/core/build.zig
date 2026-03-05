const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Library options
    const lib_options = b.addOptions();
    lib_options.addOption(bool, "enable_websocket", true);
    lib_options.addOption(bool, "enable_channel_system", true);
    lib_options.addOption(bool, "enable_type_generation", true);

    // Main library
    const lib = b.addStaticLibrary(.{
        .name = "zephyr",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib.addOptions("build_options", lib_options);

    // Install library
    b.installArtifact(lib);

    // Module definitions for better organization
    const zephyr_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .imports = &.{},
    });

    // Expose module for use in other packages
    const zephyr_module_option = b.addModule("zephyr", .{
        .root_source_file = b.path("src/main.zig"),
        .imports = &.{},
    });

    // WebAssembly specific target
    const wasm_target = b.resolveTargetQuery(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
        .abi = .musl,
    });

    // WASM library for browser use
    const wasm_lib = b.addSharedLibrary(.{
        .name = "zephyr-wasm",
        .root_source_file = b.path("src/wasm/root.zig"),
        .target = wasm_target,
        .optimize = .ReleaseSmall, // Small size is critical for WASM
    });
    wasm_lib.rdynamic = true;
    wasm_lib.entry = .disabled;

    // Install WASM library
    const install_wasm = b.addInstallArtifact(wasm_lib, .{
        .dest_dir = .{ .override = .{ .custom = "wasm" } },
    });

    // Development server executable
    const dev_exe = b.addExecutable(.{
        .name = "zephyr-dev",
        .root_source_file = b.path("src/dev_server.zig"),
        .target = target,
        .optimize = optimize,
    });
    dev_exe.linkLibrary(lib);
    b.installArtifact(dev_exe);

    // Test step
    const main_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    main_tests.addOptions("build_options", lib_options);
    main_tests.linkLibrary(lib);

    const run_main_tests = b.addRunArtifact(main_tests);

    // Unit tests for specific modules
    const router_tests = b.addTest(.{
        .root_source_file = b.path("src/router.zig"),
        .target = target,
        .optimize = optimize,
    });
    router_tests.addOptions("build_options", lib_options);
    router_tests.linkLibrary(lib);

    const run_router_tests = b.addRunArtifact(router_tests);

    const channel_tests = b.addTest(.{
        .root_source_file = b.path("src/channel.zig"),
        .target = target,
        .optimize = optimize,
    });
    channel_tests.addOptions("build_options", lib_options);
    channel_tests.linkLibrary(lib);

    const run_channel_tests = b.addRunArtifact(channel_tests);

    // Test step that runs all tests
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_main_tests.step);
    test_step.dependOn(&run_router_tests.step);
    test_step.dependOn(&run_channel_tests.step);

    // Build step for WASM
    const build_wasm_step = b.step("build-wasm", "Build WebAssembly library");
    build_wasm_step.dependOn(&install_wasm.step);

    // Examples
    const examples = .{
        "hello-world",
        "todo-app",
        "real-time-chat",
    };

    for (examples) |example| {
        const example_exe = b.addExecutable(.{
            .name = example,
            .root_source_file = b.path(b.fmt("examples/{s}/main.zig", .{example})),
            .target = target,
            .optimize = optimize,
        });
        example_exe.linkLibrary(lib);

        const install_example = b.addInstallArtifact(example_exe, .{
            .dest_dir = .{ .override = .{ .custom = "examples" } },
        });

        const example_step = b.step(b.fmt("example-{s}", .{example}), b.fmt("Build {s} example", .{example}));
        example_step.dependOn(&install_example.step);
    }

    // Development dependencies
    const exe_unit = b.option(bool, "exe", "Build executable for testing") orelse false;
    if (exe_unit) {
        const exe = b.addExecutable(.{
            .name = "zephyr-unit",
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        });
        exe.linkLibrary(lib);
        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the application");
        run_step.dependOn(&run_cmd.step);
    }

    // Lint step using zig fmt
    const fmt_step = b.step("fmt", "Format source code with zig fmt");
    const fmt_cmd = b.addSystemCommand(&.{ "zig", "fmt", "--check", "src/", "examples/", "build.zig" });
    fmt_step.dependOn(&fmt_cmd.step);

    // Benchmark step (placeholder for now)
    const bench_step = b.step("bench", "Run benchmarks");
    const bench_cmd = b.addSystemCommand(&.{ "echo", "Benchmarks not yet implemented" });
    bench_step.dependOn(&bench_cmd.step);
}
