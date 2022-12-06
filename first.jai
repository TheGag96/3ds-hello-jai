#import "Basic";
#import "Compiler";

OPTIMIZED_BUILD :: false;

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

  set_build_options(target_options, w);

  compiler_begin_intercept(w);
  add_build_file(tprint("%/hello.jai", #filepath), w);
  hacky_inline_asm_removal(w);
  compiler_end_intercept(w);

  set_build_options_dc(.{do_output = false});
}

hacky_inline_asm_removal :: (w: Workspace) {
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

      case .COMPLETE; {
        break;
      }
    }
  }
}

#run build();
