.PHONY: all dependencies update_clang clang linux

all:
	@echo "WORLD = $(WORLD)"
	@echo "CLANG_PATH = $(CLANG_PATH)"

dependencies:
	@cd $(WORLD) ;\
	rm -rf chromium/clang ;\
	mkdir -p chromium/clang ;\
	git clone https://chromium.googlesource.com/chromium/src/tools/clang chromium/clang ;\
	rm -rf linux-stable ;\
	git clone --depth 1 --branch v5.2-rc4  git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git ;\
	rm -rf docker-to-linux ;\
	git clone https://github.com/akshithg/docker-to-linux

# Installs clang from chromium, uses only the update script from the above repo
# Instruction from http://llvm.org/docs/LibFuzzer.html
clang:
	chromium/clang/scripts/update.py

update_clang:
	cd $(WORLD)/clang ;\
	git pull ;\
	cd .. ;\
	chromium/clang/scripts/update.py

linux:
	cd linux-stable ;\
	make CC=$(CLANG_PATH)/clang defconfig ;\
	make CC=$(CLANG_PATH)/clang -j`nproc` 2>&1 | tee build.log

# TODO linux.img qemu
