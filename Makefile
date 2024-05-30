
CC=gcc
CROSS?=arm-none-eabi-
CFLAGS?= -mcpu=cortex-m0plus -g3

FF=-Wall -Wextra -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,--print-gc-sections

direct: m1.c isatty.c exit.c
	$(CROSS)$(CC) $(CFLAGS) $(FF) -Wl,-Map=direct.map -o $@ $^

%.o: %.c
	$(CROSS)$(CC) $(CFLAGS) $(FF) -o $@ -c $<

viaobjs: m1.o isatty.o exit.o
	$(CROSS)$(CC) $(CFLAGS) $(FF) -Wl,-Map=viaobjs.map -o $@ $^

liblol.a: isatty.o exit.o
	$(CROSS)$(AR) rcs $@ $^

vialib: m1.o liblol.a
	$(CROSS)$(CC) $(CFLAGS) $(FF) -Wl,-Map=vialib.map -o $@ m1.o -L. -llol


all: direct viaobjs vialib

clean:
	$(RM) direct viaobjs vialib
	$(RM) *.o
	$(RM) liblol.a
	$(RM) *.map
