# 3DS Homebrew Hello World Example in Jai

Unfortunately, **this repo won't really work yet** (as of beta v0.1.050) until the following are implemented in the compiler:

* General support for compiling on 32-bit architectures (pointer sizes are wrong)

Not even string literals work at the moment, probably because of the pointer size thing. At the very least, calling C functions, looping, and (probably) doing math is feasible.

But, otherwise, this does contain what would be a minimal homebrew app for the 3DS, written in Jai, plus bindings for libctru, citro3d, and citro2d! To build, ensure you have [devkitPro installed](https://devkitpro.org/wiki/Getting_Started) and in your `PATH`.

Unfortunately, we need to hack up some of Jai's builtin modules right now to support some 3DS-related changes/bindings. I suggest you make a Git repo that contains each Jai beta release, so you can easily make a branch for hacks like this.

```sh
cd /path/to/jai/root
git apply /path/to/3ds-hello-jai/builtin-module-hacks.patch
```

Then finally, just do:

```sh
cd /path/to/3ds-hello-jai
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