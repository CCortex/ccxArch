#
#  █▀▀ █▀  █ ▀  ▄▀▄ █▀▄ ▄▀▀ █▄█    █▄ ▄█ ▄▀▄ █ █ ██▀ █▀ █ █   ██▀
#  █▄  █▄▄ ▄▀▄  █▀█ █▀▄ ▀▄▄ █ █    █ ▀ █ █▀█ █▀▄ █▄▄ █▀ █ █▄▄ █▄▄
#


# variable

OUT_DIR		= out
PROFILE_DIR	= ccx
WORK_DIR	= /tmp/ccxArchiso-tmp

# rule

build:
	mkarchiso -v -w ${WORK_DIR} -o ${OUT_DIR} ${PROFILE_DIR}

test:
	run_archiso -i ${OUT_DIR}/*.iso

test-uefi:
	run_archiso -u -i ${OUT_DIR}/*.iso

clean:
	rm -rf ${WORK_DIR} ${OUT_DIR}

.PHONY: build test test-uefi clean
