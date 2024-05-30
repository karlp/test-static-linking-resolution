# TL;DR
It's linker ordering.  The entire .a gets thrown out if nothing needed it when it was encoutned in the command line order.


# WAT
I can't place methods in a static library and have them be found?  What am I missing?

We're compiling a plain main, which calls `isatty`  This goes into `_isatty_r()` inside newlib, whicih then looks for `_isatty()`
I provide that in a separate file, and then attempt to build that into a static library.

```
$ make direct
arm-none-eabi-gcc -mcpu=cortex-m0plus -g3 -Wall -Wextra -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,--print-gc-sections -Wl,-Map=direct.map -o direct m1.c isatty.c exit.c
/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/../../../../arm-none-eabi/bin/ld: removing unused section '.rodata.all_implied_fbits' in file '/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/thumb/v6-m/nofp/crtbegin.o'
/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/../../../../arm-none-eabi/bin/ld: removing unused section '.data.__dso_handle' in file '/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/thumb/v6-m/nofp/crtbegin.o'
/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/../../../../arm-none-eabi/bin/ld: removing unused section '.rodata.all_implied_fbits' in file '/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/thumb/v6-m/nofp/crtend.o'
$ make viaobjs
arm-none-eabi-gcc -mcpu=cortex-m0plus -g3 -Wall -Wextra -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,--print-gc-sections -o m1.o -c m1.c
arm-none-eabi-gcc -mcpu=cortex-m0plus -g3 -Wall -Wextra -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,--print-gc-sections -o isatty.o -c isatty.c
arm-none-eabi-gcc -mcpu=cortex-m0plus -g3 -Wall -Wextra -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,--print-gc-sections -o exit.o -c exit.c
arm-none-eabi-gcc -mcpu=cortex-m0plus -g3 -Wall -Wextra -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,--print-gc-sections -Wl,-Map=viaobjs.map -o viaobjs m1.o isatty.o exit.o
/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/../../../../arm-none-eabi/bin/ld: removing unused section '.rodata.all_implied_fbits' in file '/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/thumb/v6-m/nofp/crtbegin.o'
/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/../../../../arm-none-eabi/bin/ld: removing unused section '.data.__dso_handle' in file '/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/thumb/v6-m/nofp/crtbegin.o'
/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/../../../../arm-none-eabi/bin/ld: removing unused section '.rodata.all_implied_fbits' in file '/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/thumb/v6-m/nofp/crtend.o'
$ make vialib
arm-none-eabi-ar rcs liblol.a isatty.o exit.o
arm-none-eabi-gcc -mcpu=cortex-m0plus -g3 -Wall -Wextra -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,--print-gc-sections -Wl,-Map=vialib.map -o vialib m1.o -L. -llol
/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/../../../../arm-none-eabi/bin/ld: removing unused section '.rodata.all_implied_fbits' in file '/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/thumb/v6-m/nofp/crtbegin.o'
/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/../../../../arm-none-eabi/bin/ld: removing unused section '.data.__dso_handle' in file '/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/thumb/v6-m/nofp/crtbegin.o'
/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/../../../../arm-none-eabi/bin/ld: removing unused section '.rodata.all_implied_fbits' in file '/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/thumb/v6-m/nofp/crtend.o'
/home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/../../../../arm-none-eabi/bin/ld: /home/karlp/tools/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/../lib/gcc/arm-none-eabi/12.3.1/../../../../arm-none-eabi/lib/thumb/v6-m/nofp/libg.a(libc_a-sysisatty.o): in function `isatty':
sysisatty.c:(.text.isatty+0x2): undefined reference to `_isatty'
collect2: error: ld returned 1 exit status
make: *** [Makefile:21: vialib] Error 1

```
