# 3DS Homebrew Hello World Example in Jai

Unfortunately, **this repo won't really work yet** (as of beta v0.1.048) until the following are implemented in the compiler:

* A fix for a bug where `OS` does not get set to your `Build_Option`'s `os_target` (it just stays the host system's)
  - (Once this is fixed, I'll have to go and make a bunch of hacks in `Runtime_Support.jai` and elsewhere to get things playing nice with the 3DS.)
* General support for compiling on 32-bit architectures (pointer sizes are wrong)

Right now, I have compiling *and running* a version of this example, but I haven't committed it because it requires lots of hacks in Jai's `modules/` folder and other ugly stuff. Not even string literals work at the moment, probably because of the pointer size thing. At the very least, calling C functions, looping, and (probably) doing math is feasible.

But, otherwise, this does contain what would be a minimal homebrew app for the 3DS, written in Jai, plus bindings for libctru, citro3d, and citro2d! To build, ensure you have [devkitPro installed](https://devkitpro.org/wiki/Getting_Started) and in your `PATH`. Then, it should be as simple as:

```sh
jai first.jai
```

Right now, this just creates a `.obj` file in the `.build` folder and a `.smdh` file. Eventually a `.elf` and `.3dsx` file will be made too.

## Shaders

Just like the devkitPro example Makefiles, shaders can be automatically compiled by the metaprogram and made usable by the main source. For exampe, your `myshader.v.pica` and `myshader.g.pica` files in the `shaders` folder. Then, from your user code, you can use them as a `[] u8` by doing:

```jai
MY_SHADER :: #run SHADER_GET("myshader");
```

Note that the folder is searched recursively, so if you have a shader at `shaders/folder/someshader.v.pica`:

```jai
SOME_SHADER :: #run SHADER_GET("folder/someshader");
```

## Texture atlases

Again, like the devkitPro Makefiles, the metaprogram processes `.t3s` files found in `gfx` and converts them to `.t3x` files at the corresponding spot in `romfs/gfx`.

## Major to do:

* Bindings for NewlibC
* Output to `.cia` file

## Thanks to...

* [DevkitPro](https://devkitpro.org/)
* The devs of [libctru](https://github.com/smealum/ctrulib)
* The devs of [citro3d](https://github.com/fincs/citro3d)
* [Jonathan Blow](https://thekla.com) and the rest of the people on the Jai team
* The Jai Beta Discord