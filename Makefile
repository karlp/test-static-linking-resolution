
CC=gcc
CROSS?=arm-none-eabi-
CFLAGS?= -mcpu=cortex-m0plus -g3

FF=-Wall -Wextra -ffunction-sections -fdata-sections -Wl,--gc-sections -Wl,--print-gc-sections

all: direct viaobjs vialib-group vialib-explicit-order vialib-implicit-order

direct: m1.c isatty.c exit.c
	$(CROSS)$(CC) $(CFLAGS) $(FF) -Wl,-Map=direct.map -o $@ $^

%.o: %.c
	$(CROSS)$(CC) $(CFLAGS) $(FF) -o $@ -c $<

viaobjs: m1.o isatty.o exit.o
	$(CROSS)$(CC) $(CFLAGS) $(FF) -Wl,-Map=viaobjs.map -o $@ $^

liblol.a: isatty.o exit.o
	$(CROSS)$(AR) crvs $@ $^

# this works
vialib-group: m1.o liblol.a
	$(CROSS)$(CC) $(CFLAGS) $(FF) -Wl,-Map=$@.map -o $@ m1.o -L. -Wl,--start-group -lm -lc -llol -Wl,--end-group

# this works, lc is found first
vialib-explicit-order: m1.o liblol.a
	$(CROSS)$(CC) $(CFLAGS) $(FF) -Wl,-Map=$@.map -o $@ m1.o -L. -lm -lc -llol

# This fails, liblol is discarded entirely as unnecessary before it gets to implicit libc
vialib-implicit-order: m1.o liblol.a
	$(CROSS)$(CC) $(CFLAGS) $(FF) -Wl,-Map=$@.map -o $@ m1.o -L. -llol

clean:
	$(RM) direct viaobjs vialib*
	$(RM) *.o
	$(RM) liblol.a
	$(RM) *.map
