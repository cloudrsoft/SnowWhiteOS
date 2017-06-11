arch ?= x86_64
boot := build/boot.bin build/loader.bin
bootsector := build/boot.bin
loader := build/loader.bin
kernel := build/kernel.bin
img := build/os-$(arch).img
linker_script := src/boot/arch/$(arch)/linker.ld

img_edit := tools/img_edit
#os_helper := build/tools/os_helper
#read_boot := build/tools/read_boot
#set_boot := build/tools/set_boot
#fat16_test := build/tools/fat16_test

CC := gcc
AS := nasm
CXX := g++

CXXFLAGS := -ffreestanding -O2 -nostdlib

cpp_source_files := $(wildcard src/kernel/*.cpp)
cpp_object_files := $(patsubst src/kernel/%.cpp, \
	build/kernel/%.o, $(cpp_source_files))

.PHONY: all clean clean_tools run img tools

all: $(boot) $(kernel) $(img)

clean:
	@rm -r build

clean_tools:
	@rm -r tools

run: $(img)
	@qemu-system-x86_64 $(img)

img: $(img)

$(img): $(boot) $(kernel)
	@mkdir -p $(shell dirname $@)
	@tools/img_edit create $(img) $(bootsector)
	@tools/img_edit add $(img) $(loader)
	@tools/img_edit add $(img) $(kernel)

# compile boot files
$(boot):
	@mkdir -p build
	@$(AS) -fbin src/boot/arch/$(arch)/boot.asm -o $(bootsector)
	@$(AS) -fbin src/boot/arch/$(arch)/loader.asm -o $(loader)

# compile kernel files
$(kernel): $(cpp_object_files) $(linker_script)
	@$(AS) -felf64 src/kernel/entry.s -o build/kernel/entry.o
	@ld -n -T $(linker_script) -o $(kernel) build/kernel/entry.o $(cpp_object_files)

build/kernel/%.o: src/kernel/%.cpp
	@mkdir -p $(shell dirname $@)
	@$(CXX) -o $@ $^ $(CXXFLAGS)

# compile tools files
tools: $(img_edit)
	@echo "This tools is by pdoane by github https://github.com/pdoane/osdev"

$(img_edit): src/tools/img_edit.c src/tools/fat16.c
	@mkdir -p $(shell dirname $@)
	$(CC) -o $@ $^

