# 3DS Homebrew Hello World Example in Jai

Unfortunately, this repo won't really work yet (as of beta v0.1.047) until the following are implemented in the compiler:

* Ability to specify equivalents of `-mfloat-abi` and `-mtp` (coming in next beta)
* Genreal support for compiling on 32-bit architectures (pointer sizes are wrong)

But otherwise, this does contain what would be a minimal homebrew app for the 3DS, written in Jai, plus bindings for libctru, citro3d, and citro2d!

## Major to do:

* Bindings for NewlibC

## Thanks to...

* [DevkitPro](https://devkitpro.org/)
* The devs of [libctru](https://github.com/smealum/ctrulib)
* The devs of [citro3d](https://github.com/fincs/citro3d)
* [Jonathan Blow](https://thekla.com) and the rest of the people on the Jai team
* The Jai Beta Discord