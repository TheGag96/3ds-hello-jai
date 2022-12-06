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
    opts: Generate_Bindings_Options;
    {
        using opts;

        array_add(*libpaths,       "/opt/devkitpro/libctru/lib");
        array_add(*libnames,      "libctru");
        array_add(*system_include_paths, "/opt/devkitpro/devkitARM/arm-none-eabi/include", "/opt/devkitpro/devkitARM/lib/gcc/arm-none-eabi/12.2.0/include");
        array_add(*include_paths, "working/libctru/libctru/include/");
        array_add(*extra_clang_arguments, "-x", "c", "-fshort-enums", "--target=armv6k-none-eabi", "-march=armv6k", "-mtune=mpcore", "-mfloat-abi=hard", "-mtp=soft", "-D__3DS__"); //, "-DWIN32_LEAN_AND_MEAN");
        mimic_spacing_flags = Mimic_Spacing_Flags.GLOBAL;
        alias_original_enum_names = false;
        generate_compile_time_struct_checks = false;
    }

    result := true;

    array_copy(*opts.source_files, CTRU_FILES);
    result &&= generate_bindings(opts, "libctru.jai");

    array_copy(*opts.source_files, CITRO3D_FILES);
    array_add(*opts.system_include_paths, opts.include_paths[0]);
    opts.include_paths[0] = "working/citro3d/include";
    array_add(*opts.libnames, "libcitro3d");
    result &&= generate_bindings(opts, "citro3d.jai");

    array_copy(*opts.source_files, CITRO2D_FILES);
    array_add(*opts.system_include_paths, opts.include_paths[0]);
    opts.include_paths[0] = "working/citro2d/include";
    array_add(*opts.libnames, "libcitro2d");
    result &&= generate_bindings(opts, "citro2d.jai");

    return result;
}

#import "Basic";
#import "Bindings_Generator";
#import "Compiler";
#import "File";
#import "String";


BindingFile :: struct {
    header, output_filename: string;
}

CTRU_FILES :: string.[
    "working/libctru/libctru/include/netdb.h",
    "working/libctru/libctru/include/netinet/tcp.h",
    "working/libctru/libctru/include/netinet/in.h",
    "working/libctru/libctru/include/sys/socket.h",
    "working/libctru/libctru/include/sys/select.h",
    "working/libctru/libctru/include/sys/ioctl.h",
    "working/libctru/libctru/include/3ds.h",
    "working/libctru/libctru/include/arpa/inet.h",
    "working/libctru/libctru/include/poll.h",
    "working/libctru/libctru/include/3ds/errf.h",
    "working/libctru/libctru/include/3ds/ipc.h",
    "working/libctru/libctru/include/3ds/romfs.h",
    "working/libctru/libctru/include/3ds/applets/error.h",
    "working/libctru/libctru/include/3ds/applets/swkbd.h",
    "working/libctru/libctru/include/3ds/applets/miiselector.h",
    "working/libctru/libctru/include/3ds/srv.h",
    "working/libctru/libctru/include/3ds/gfx.h",
    "working/libctru/libctru/include/3ds/allocator/linear.h",
    "working/libctru/libctru/include/3ds/allocator/vram.h",
    "working/libctru/libctru/include/3ds/allocator/mappable.h",
    "working/libctru/libctru/include/3ds/types.h",
    "working/libctru/libctru/include/3ds/thread.h",
    "working/libctru/libctru/include/3ds/exheader.h",
    "working/libctru/libctru/include/3ds/svc.h",
    "working/libctru/libctru/include/3ds/mii.h",
    "working/libctru/libctru/include/3ds/font.h",
    "working/libctru/libctru/include/3ds/gpu/gpu.h",
    "working/libctru/libctru/include/3ds/gpu/shbin.h",
    "working/libctru/libctru/include/3ds/gpu/shaderProgram.h",
    "working/libctru/libctru/include/3ds/gpu/enums.h",
    "working/libctru/libctru/include/3ds/gpu/registers.h",
    "working/libctru/libctru/include/3ds/gpu/gx.h",
    "working/libctru/libctru/include/3ds/services/apt.h",
    "working/libctru/libctru/include/3ds/services/nfc.h",
    "working/libctru/libctru/include/3ds/services/pmdbg.h",
    "working/libctru/libctru/include/3ds/services/dsp.h",
    "working/libctru/libctru/include/3ds/services/fsreg.h",
    "working/libctru/libctru/include/3ds/services/ptmu.h",
    "working/libctru/libctru/include/3ds/services/frd.h",
    "working/libctru/libctru/include/3ds/services/ndm.h",
    "working/libctru/libctru/include/3ds/services/mvd.h",
    "working/libctru/libctru/include/3ds/services/loader.h",
    "working/libctru/libctru/include/3ds/services/ns.h",
    "working/libctru/libctru/include/3ds/services/ps.h",
    "working/libctru/libctru/include/3ds/services/cfgnor.h",
    "working/libctru/libctru/include/3ds/services/fs.h",
    "working/libctru/libctru/include/3ds/services/qtm.h",
    "working/libctru/libctru/include/3ds/services/ptmsets.h",
    "working/libctru/libctru/include/3ds/services/csnd.h",
    "working/libctru/libctru/include/3ds/services/boss.h",
    "working/libctru/libctru/include/3ds/services/fspxi.h",
    "working/libctru/libctru/include/3ds/services/pmapp.h",
    "working/libctru/libctru/include/3ds/services/sslc.h",
    "working/libctru/libctru/include/3ds/services/pxidev.h",
    "working/libctru/libctru/include/3ds/services/news.h",
    "working/libctru/libctru/include/3ds/services/mcuhwc.h",
    "working/libctru/libctru/include/3ds/services/ptmgets.h",
    "working/libctru/libctru/include/3ds/services/irrst.h",
    "working/libctru/libctru/include/3ds/services/y2r.h",
    "working/libctru/libctru/include/3ds/services/pxipm.h",
    "working/libctru/libctru/include/3ds/services/gspgpu.h",
    "working/libctru/libctru/include/3ds/services/nwmext.h",
    "working/libctru/libctru/include/3ds/services/ir.h",
    "working/libctru/libctru/include/3ds/services/ac.h",
    "working/libctru/libctru/include/3ds/services/hid.h",
    "working/libctru/libctru/include/3ds/services/ptmsysm.h",
    "working/libctru/libctru/include/3ds/services/am.h",
    "working/libctru/libctru/include/3ds/services/uds.h",
    "working/libctru/libctru/include/3ds/services/cfgu.h",
    "working/libctru/libctru/include/3ds/services/mic.h",
    "working/libctru/libctru/include/3ds/services/srvpm.h",
    "working/libctru/libctru/include/3ds/services/nim.h",
    "working/libctru/libctru/include/3ds/services/ampxi.h",
    "working/libctru/libctru/include/3ds/services/soc.h",
    "working/libctru/libctru/include/3ds/services/gsplcd.h",
    "working/libctru/libctru/include/3ds/services/httpc.h",
    "working/libctru/libctru/include/3ds/services/cam.h",
    "working/libctru/libctru/include/3ds/console.h",
    "working/libctru/libctru/include/3ds/os.h",
    "working/libctru/libctru/include/3ds/util/rbtree.h",
    "working/libctru/libctru/include/3ds/util/decompress.h",
    "working/libctru/libctru/include/3ds/util/utf.h",
    "working/libctru/libctru/include/3ds/archive.h",
    "working/libctru/libctru/include/3ds/env.h",
    "working/libctru/libctru/include/3ds/synchronization.h",
    "working/libctru/libctru/include/3ds/result.h",
    "working/libctru/libctru/include/3ds/gdbhio.h",
    "working/libctru/libctru/include/3ds/gdbhio_dev.h",
    "working/libctru/libctru/include/3ds/ndsp/ndsp.h",
    "working/libctru/libctru/include/3ds/ndsp/channel.h",
    "working/libctru/libctru/include/3ds/3dslink.h",
    // "working/libctru/libctru/include/3ds/asminc.h",
];

CITRO3D_FILES :: string.[
    "working/citro3d/include/citro3d.h",
    "working/citro3d/include/tex3ds.h",
    "working/citro3d/include/c3d/buffers.h",
    "working/citro3d/include/c3d/lightlut.h",
    "working/citro3d/include/c3d/base.h",
    "working/citro3d/include/c3d/effect.h",
    "working/citro3d/include/c3d/types.h",
    "working/citro3d/include/c3d/renderqueue.h",
    "working/citro3d/include/c3d/fog.h",
    "working/citro3d/include/c3d/mtxstack.h",
    "working/citro3d/include/c3d/framebuffer.h",
    "working/citro3d/include/c3d/proctex.h",
    "working/citro3d/include/c3d/texture.h",
    "working/citro3d/include/c3d/uniforms.h",
    "working/citro3d/include/c3d/attribs.h",
    "working/citro3d/include/c3d/light.h",
    "working/citro3d/include/c3d/maths.h",
    "working/citro3d/include/c3d/texenv.h",
];

CITRO2D_FILES :: string.[
    "working/citro2d/include/c2d/text.h",
    "working/citro2d/include/c2d/spritesheet.h",
    "working/citro2d/include/c2d/base.h",
    "working/citro2d/include/c2d/font.h",
    "working/citro2d/include/c2d/sprite.h",
    "working/citro2d/include/citro2d.h",
];