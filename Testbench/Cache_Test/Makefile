ifndef CROSS_COMPILE
CROSS_COMPILE = mipsel-linux-
endif

SOURCE = test.S
TARGET = test_ram

CC = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
OBJDUMP = $(CROSS_COMPILE)objdump

OBJECTS = $(TARGET).o

export CROSS_COMPILE

all: $(TARGET).data

$(TARGET).o: $(SOURCE)
	$(CC) -mips32 $< -o $@

$(TARGET).elf: ram.ld $(TARGET).o
	$(LD) -T ram.ld $(TARGET).o -o $@
	$(OBJDUMP) -alD $@ > $(TARGET).s

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).data: $(TARGET).bin
	../Bin2Mem/Bin2Mem-LE.exe -f $< -o $@

clean:
	-rm -f *.o *.elf *.bin *.data *.s
