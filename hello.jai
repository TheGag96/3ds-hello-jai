/*
  Hello World example made by Aurelio Mannara for ctrulib
  Ported to Jai by TheGag96
*/

#load "3ds.jai";

libc :: #foreign_system_library,no_dll "libc";
printf :: (fmt: *u8, va_args: .. Any) -> s32 #foreign libc;

main :: () {
  gfxInitDefault();

  //Initialize console on top screen. Using null as the second argument tells the console library to use the internal console structure as current one
  consoleInit(gfxScreen_t.TOP, null);

  //Move the cursor to row 15 and column 19 and then prints "Hello World!"
  //To move the cursor you have to print "\x1b[r;cH", where r and c are respectively
  //the row and column where you want your cursor to move
  //The top screen has 30 rows and 50 columns
  //The bottom screen has 30 rows and 40 columns

  printf("\x1b[16;20HHello World!");

  printf("\x1b[30;16HPress Start to exit.");

  // Main loop
  while aptMainLoop() {
    //Scan all the inputs. This should be done once for each frame
    hidScanInput();

    //hidKeysDown returns information about which buttons have been just pressed (and they weren't in the previous frame)
    kDown: KEY = hidKeysDown();
    if (kDown & KEY.START) break; // break in order to return to hbmenu

    // Flush and swap framebuffers
    gfxFlushBuffers();
    gfxSwapBuffers();

    //Wait for VBlank
    gspWaitForVBlank();
  }

  gfxExit();
}