INPUT := img/fw.img
SECTIONS := 0x10700000 0x10800000 0x8120000 0x5000000 0x5100000 0x8140000 0x4000000 0x5060000 0xE0000000
BSS_SECTIONS := 0x5074000 0x8150000
INPUT_SECTIONS := $(addprefix patches/sections/, $(addsuffix .bin, $(SECTIONS)))
PATCHED_SECTIONS := $(addprefix patches/patched_sections/, $(addsuffix .bin, $(SECTIONS)))

ifeq ($(OS),Windows_NT)
	ARMIPS := armips.exe
else
	ARMIPS := armips
endif

.PHONY: all clean wupserver/wupserver.bin

all: fw.img

extract: $(INPUT_SECTIONS)

patch: $(PATCHED_SECTIONS)

img/fw.img:
	@python2 scripts/verify-keys.py
	@mkdir -p img
	@python2 scripts/getfwimg.py

wupserver/wupserver.bin:
	@cd wupserver && make

patches/sections/%.bin: $(INPUT)
	@mkdir -p patches/sections
	@python2 scripts/anpack.py -in $(INPUT) -e $*,$@

patches/patched_sections/%.bin: patches/sections/%.bin patches/%.s wupserver/wupserver.bin
	@mkdir -p patches/patched_sections
	@echo patches/$*.s
	$(ARMIPS) patches/$*.s

fw.img: $(INPUT) $(INPUT_SECTIONS) $(PATCHED_SECTIONS)
	@python2 scripts/anpack.py -in $(INPUT) -out $@ $(foreach s,$(SECTIONS),-r $(s),patches/patched_sections/$(s).bin) $(foreach s,$(BSS_SECTIONS),-b $(s),patches/patched_sections/$(s).bin)

clean:
	@make -C wupserver clean
	@rm -rf fw.img patches/patched_sections/ patches/sections/ img/

