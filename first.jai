#import "Basic";
#import "Compiler";
#import "Process";

COMPILER_FIXED :: false; // @TODO: Remove when compiler is fixed to let this project compile properly

PROJECT_NAME    :: "hello";
OPTIMIZED_BUILD :: false;

APP_NAME        :: "Hello World in Jai";
APP_DESCRIPTION :: "An example Jai program for the 3DS";
APP_AUTHOR      :: "A Jai developer";

build :: () {
  w := compiler_create_workspace(name = "3DS");
  if !w {
    print("oops\n");
    return;
  }

  target_options := get_build_options(w);

  target_options.backend                             = .LLVM;
  target_options.output_type                         = .OBJECT_FILE;
  target_options.os_target                           = .NONE;
  target_options.llvm_options.target_system_triple   = "arm-none-eabi";
  target_options.llvm_options.target_system_cpu      = "mpcorenovfp";
  target_options.llvm_options.target_system_features = "+vfp2";
  target_options.output_executable_name              = "3ds";
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

  compiler_begin_intercept(w);
  add_build_file("src/main.jai", w);
  obj_files := hacky_inline_asm_removal(w);
  compiler_end_intercept(w);

  // All of the architecture args are important! You'll get an error about 3dsx_crt0.o if you don't include them all.
  ARCH_FLAGS :: string.["-specs=3dsx.specs", "-march=armv6k", "-mtune=mpcore", "-mfloat-abi=hard", "-mtp=soft"];
  LIB_DIRS   :: string.["-L/opt/devkitpro/libctru/lib"];
  LIBS       :: string.["-lcitro3d", "-lctru", "-lm"];

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

  cmd :: (args: ..string, fail_string: string) {
    process_result, output_string, error_string, timeout_reached := run_command(
      ..args,
      print_captured_output = true
    );
    if process_result.exit_code != 0  compiler_report(fail_string);
  }

  cmd(
    "smdhtool", "--create", APP_NAME, APP_DESCRIPTION, APP_AUTHOR, "resources/48x48.png", smdh_name,
    fail_string = "Failed to create SMDH!"
  );

  #if COMPILER_FIXED {
    cmd(
      ..link_args,
      fail_string = "Failed to link!"
    );

    cmd(
      "3dstool", elf_name, _3dsx_name, tprint("--smdh=%", smdh_name), "--romfs=romfs",
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
