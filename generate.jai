// This file generates the bindings for libclang, which is used by the bindings generator itself.
// If you are interested in USING the bindings generator yourself, look at "module.jai" instead.

// Since compile-time debugging is still tricky, it can sometimes be useful to compile this script into a binary and run that instead of generating the bindings at compile-time.
AT_COMPILE_TIME :: true;

CLANG_PATH :: "clang-c";

#if AT_COMPILE_TIME {
    #run {
        set_build_options_dc(.{do_output=false});
        if !generate_bindings() {
            compiler_set_workspace_status(.FAILED);
        }
    }
} else {
    #import "System";

    main :: () {
        set_working_directory(path_strip_filename(get_path_of_running_executable()));
        if !generate_bindings() {
            exit(1);
        }
    }
}

generate_bindings :: () -> bool {
    output_filename := "3ds_out.jai";

    opts: Generate_Bindings_Options;
    {
        using opts;

        array_add(*libpaths,      "/opt/devkitpro/libctru/lib");
        array_add(*libnames,      "libctru", "libcitro3d", "libcitro2d");
        // array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);
        array_add(*system_include_paths, "/opt/devkitpro/devkitARM/arm-none-eabi/include", "/opt/devkitpro/devkitARM/lib/gcc/arm-none-eabi/12.2.0/include");
        array_add(*include_paths, "/opt/devkitpro/libctru/include");
        array_add(*source_files,  "/opt/devkitpro/libctru/include/3ds.h", "/opt/devkitpro/libctru/include/citro3d.h", "/opt/devkitpro/libctru/include/citro2d.h");
        array_add(*extra_clang_arguments, "-x", "c", "-fshort-enums", "--target=armv6k-none-eabi", "-march=armv6k", "-mtune=mpcore", "-mfloat-abi=hard", "-mtp=soft"); //, "-DWIN32_LEAN_AND_MEAN");
        mimic_spacing_flags = Mimic_Spacing_Flags.GLOBAL;
        alias_original_enum_names = false;
        generate_compile_time_struct_checks = false;

        // visitor = clang_visitor;
    }

    output_filename2 := "libc_out.jai";
    opts2: Generate_Bindings_Options;
    {
        using opts2;

        array_add(*libpaths,      "/opt/devkitpro/devkitARM/arm-none-eabi/lib");
        array_add(*libnames,      "libc", "libm");
        // array_add(*system_include_paths, GENERATOR_DEFAULT_SYSTEM_INCLUDE_PATH);
        array_add(*system_include_paths, "/opt/devkitpro/devkitARM/arm-none-eabi/include", "/opt/devkitpro/devkitARM/lib/gcc/arm-none-eabi/12.2.0/include");
        array_add(*include_paths, "/opt/devkitpro/devkitARM/arm-none-eabi/include", "/opt/devkitpro/devkitARM/lib/gcc/arm-none-eabi/12.2.0/include");
        array_add(
            *source_files,
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/_types.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/reent.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/_timeval.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/_stdint.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/_intsup.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/_tz_structs.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/_locale.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/_sigset.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/_timespec.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/_default_fcntl.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/types.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/lock.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/_pthreadtypes.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/dirent.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/syslimits.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/utime.h",
            // "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/custom_file.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/iosupport.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/signal.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/features.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/wait.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/timespec.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/errno.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/stdio.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/select.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/dir.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/string.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/cdefs.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/queue.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/config.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/time.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/iconvnls.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/fenv.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/stat.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/file.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/fcntl.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/resource.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/sched.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/unistd.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/times.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/statvfs.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/tree.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/param.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/complex.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/dirent.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/argz.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/ftw.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/getopt.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/grp.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/reent.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/wchar.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/utime.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/stdint.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/locale.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/ctype.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/assert.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/types.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/_endian.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/malloc.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/_types.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/ieeefp.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/acle-compat.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/time.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/endian.h",
            // "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/setjmp-dj.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/termios.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/fastmath.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/ieee.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/_time.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/_arc4random.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/stdlib.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/ansi.h",
            // "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/setjmp.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/param.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/machine/_default_types.h",
            // "/opt/devkitpro/devkitARM/arm-none-eabi/include/limits.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/signal.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/newlib.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/envlock.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/search.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/glob.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/alloca.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/cpio.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/pwd.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/tar.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/envz.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/ssp/wchar.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/ssp/stdio.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/ssp/string.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/ssp/strings.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/ssp/unistd.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/ssp/ssp.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/ssp/stdlib.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/malloc.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/errno.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/inttypes.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/stdio.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/unctrl.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/stdio_ext.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/ieeefp.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/elf.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/string.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/_syslist.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/strings.h",
            // "/opt/devkitpro/devkitARM/arm-none-eabi/include/regdef.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/_ansi.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/wordexp.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/iconv.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/time.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/fenv.h",
            // "/opt/devkitpro/devkitARM/arm-none-eabi/include/utmp.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/pthread.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/fcntl.h",
            // "/opt/devkitpro/devkitARM/arm-none-eabi/include/threads.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sys/timeb.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/ndbm.h",
            // "/opt/devkitpro/devkitARM/arm-none-eabi/include/termios.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/sched.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/langinfo.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/unistd.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/_newlib_version.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/paths.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/tgmath.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/regex.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/fnmatch.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/fastmath.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/ar.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/devctl.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/libgen.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/stdlib.h",
            // "/opt/devkitpro/devkitARM/arm-none-eabi/include/setjmp.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/memory.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/math.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/wctype.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/stdatomic.h",
            "/opt/devkitpro/devkitARM/arm-none-eabi/include/spawn.h",
        );
        array_add(*extra_clang_arguments, "-x", "c", "-fshort-enums", "--target=armv6k-none-eabi", "-march=armv6k", "-mtune=mpcore", "-mfloat-abi=hard", "-mtp=soft"); //, "-DWIN32_LEAN_AND_MEAN");
        mimic_spacing_flags = Mimic_Spacing_Flags.GLOBAL;
        alias_original_enum_names = false;
        generate_compile_time_struct_checks = false;

        // visitor = clang_visitor;
    }

    result := true;
    // result &&= generate_bindings(opts, output_filename);
    result &&= generate_bindings(opts2, output_filename2);

    return result;
}

#import "Basic";
#import "Bindings_Generator";
#import "Compiler";
#import "File";
#import "String";
