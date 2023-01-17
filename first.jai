#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "Process";
#import "Sort";
#import "String";

PROJECT_NAME    :: "hello";
OPTIMIZED_BUILD :: false;

APP_NAME        :: "Hello World in Jai";
APP_DESCRIPTION :: "An example Jai program for the 3DS";
APP_AUTHOR      :: "A Jai developer";

// @TODO: Use environment variables for this
#if OS == .WINDOWS {
  DEVKITPRO :: "C:/devkitPro";
} else #if (OS == .LINUX) || (OS == .MACOS) {
  DEVKITPRO :: "/opt/devkitpro";
}

build :: () {
  w := compiler_create_workspace(name = "3DS");
  if !w {
    print("oops\n");
    return;
  }

  target_options := get_build_options(w);

  target_options.backend                             = .LLVM;
  target_options.output_type                         = .OBJECT_FILE;
  target_options.output_flags                        = .INCLUDE_SYSTEM_ENTRY_POINT_IN_NON_EXECUTABLE_OUTPUT;
  target_options.output_executable_name              = "3ds";
  target_options.os_target                           = .NN_3DS;
  target_options.cpu_target                          = .ARM32;
  target_options.backtrace_on_crash                  = .OFF;
  target_options.llvm_options.target_system_triple   = "arm-none-eabi";
  target_options.llvm_options.target_system_cpu      = "mpcorenovfp";
  target_options.llvm_options.target_system_features = "+vfp2";
  target_options.llvm_options.command_line           = string.["llvm", "--float-abi=hard"];
  target_options.llvm_options.output_bitcode         = true;
  target_options.llvm_options.enable_split_modules   = false;

  #if OPTIMIZED_BUILD {
    target_options.optimization_level                       = .RELEASE;
    target_options.llvm_options.code_gen_optimization_level = 3;
    target_options.llvm_options.enable_tail_calls           = true;
    target_options.llvm_options.enable_loop_unrolling       = true;
    target_options.llvm_options.enable_slp_vectorization    = true;
    target_options.llvm_options.enable_loop_vectorization   = true;
    target_options.llvm_options.disable_inlining            = false;
  }

  import_paths: [..] string;
  array_add(*import_paths, ..target_options.import_path);
  array_add(*import_paths, "modules");

  target_options.import_path = import_paths;
  set_build_options(target_options, w);

  set_build_options_dc(.{do_output = false});

  cmd :: (args: ..string, fail_string: string) {
    process_result, output_string, error_string, timeout_reached := run_command(
      ..args,
      print_captured_output = true
    );
    if process_result.exit_code != 0  compiler_report(fail_string);
  }



  //
  // Build shaders and output bindings
  //
  {
    shader_files: [..] string;

    visitor :: (info: *File_Visit_Info, user_data: *[..] string) {
      if !ends_with(info.full_name, ".v.pica") && !ends_with(info.full_name, ".g.pica")  return;
      if path_filename(info.full_name).count < "a.v.pica".count  return;
      array_add(user_data, copy_string(info.full_name));
    }

    visit_files(
      "shaders", recursive = true, user_data = *shader_files, proc = visitor, visit_directories = false,
      follow_symlinks = true
    );

    quick_sort(shader_files, compare);

    // Assumed both files end in ".x.pica" already
    same_base :: (a: string, b: string) -> bool {
      if a.count != b.count  return false;

      return slice(a, 0, a.count-".v.pica".count) == slice(b, 0, a.count-".v.pica".count);
    }

    it := 0;
    while it < shader_files.count {
      file := shader_files[it];

      shbin_file := tprint(".build/%.shbin", slice(file, 0, file.count - ".v.pica".count));
      make_directory_if_it_does_not_exist(path_strip_filename(shbin_file), recursive = true);

      if it < shader_files.count-1 && same_base(file, shader_files[it+1]) {
        cmd("picasso", file, shader_files[it+1], "-o", shbin_file, fail_string = "Couldn't assemble shaders!");
        it += 1;
      }
      else {
        cmd("picasso", file, "-o", shbin_file, fail_string = "Couldn't assemble shader!");
      }

      it += 1;
    }
  }

  //
  // Build texture atlases and output to romfs folder
  //
  {
    t3s_files: [..] string;

    visitor :: (info: *File_Visit_Info, user_data: *[..] string) {
      if ends_with(info.full_name, ".t3s")  {
        array_add(user_data, copy_string(info.full_name));
      }
    }

    visit_files(
      "gfx", recursive = true, user_data = *t3s_files, proc = visitor, visit_directories = false,
      follow_symlinks = true
    );

    for t3s_files {
      t3x_path := tprint("romfs/%.t3x", path_strip_extension(it));
      make_directory_if_it_does_not_exist(path_strip_filename(t3x_path), recursive = true);
      cmd("tex3ds", "-i", it, "-o", t3x_path, fail_string = "Couldn't generate textures atlas!");
    }
  }

  compiler_begin_intercept(w);

  // Allow program to easily grab shader binaries as byte arrays
  add_build_string(#string DONE
    SHADER_GET :: (s: string) -> [] u8 {
      #import "File";
      #import "Basic";
      return xx read_entire_file(tprint(".build/shaders/%.shbin", s));
    }
  DONE, w);

  add_build_file("src/main.jai", w);
  obj_files := hacky_inline_asm_removal(w);

  compiler_end_intercept(w);

  // I'm assuming this will happen if compilation fails
  if !obj_files.count return;

  //
  // Link and create .3dsx
  //
  {
    // All of the architecture args are important! You'll get an error about 3dsx_crt0.o if you don't include them all.
    ARCH_FLAGS :: string.["-specs=3dsx.specs", "-march=armv6k", "-mtune=mpcore", "-mfloat-abi=hard", "-mtp=soft"];
    LIB_DIRS   :: string.[#run tprint("-L%/libctru/lib", DEVKITPRO)];
    LIBS       :: string.["-lcitro3d", "-lctru", "-lm", "lib/stb_sprintf.o"];

    elf_name   := tprint("%.elf",  PROJECT_NAME);
    smdh_name  := tprint("%.smdh", PROJECT_NAME);
    _3dsx_name := tprint("%.3dsx", PROJECT_NAME);
    // cia_name   := tprint("%.cia",  PROJECT_NAME); // @TODO CIA output

    link_args: [..] string;
    array_add(*link_args, "arm-none-eabi-gcc");
    array_add(*link_args, ..ARCH_FLAGS);
    array_add(*link_args, ..obj_files);
    array_add(*link_args, ..LIB_DIRS);
    array_add(*link_args, ..LIBS);
    array_add(*link_args, "-o", elf_name);

    cmd(
      "smdhtool", "--create", APP_NAME, APP_DESCRIPTION, APP_AUTHOR, "resources/48x48.png", smdh_name,
      fail_string = "Failed to create SMDH!"
    );

    cmd(
      ..link_args,
      fail_string = "Failed to link!"
    );

    cmd(
      "3dsxtool", elf_name, _3dsx_name, tprint("--smdh=%", smdh_name), "--romfs=romfs",
      fail_string = "Failed to create 3dsx!"
    );
  }
}

// Thanks to tsoding! https://github.com/tsoding/jai-wasm/blob/master/first.jai#L31-L77
// Will remove when inline assembly situation is improved.
hacky_inline_asm_removal :: (w: Workspace) -> [] string {
  resulting_object_files: [] string;

  while true {
    message := compiler_wait_for_message();

    if message.kind == {
      case .TYPECHECKED; {
        typechecked := cast(*Message_Typechecked) message;

        for typechecked.procedure_bodies {
          contains_asm := false;

          for it.subexpressions {
            if it.kind == .ASM {
              compiler_report("ASM DETECTED!!!", make_location(it), .WARNING);
              contains_asm = true;
            }
          }

          if contains_asm {
            body := it.expression;

            compiler_report(tprint("Removing whole body of the function % DON'T USE IT!!!", body.header.name), make_location(body), .WARNING);

            new_statements : [..] *Code_Node;
            body.block.statements = new_statements;
            compiler_modify_procedure(w, body);
          }
        }
      }

      case .PHASE; {
        phase := cast(*Message_Phase) message;

        if phase.phase == .POST_WRITE_EXECUTABLE {
          resulting_object_files = phase.compiler_generated_object_files;
        }
      }

      case .COMPLETE; {
        break;
      }
    }
  }

  return resulting_object_files;
}

#run build();
