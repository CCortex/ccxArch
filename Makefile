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
	sudo mkarchiso -v -w ${WORK_DIR} -o ${OUT_DIR} ${PROFILE_DIR}

deploy:
	cp ${OUT_DIR}/*.iso /media/sf_public

test:
	run_archiso -i ${OUT_DIR}/*.iso

test-uefi:
	run_archiso -u -i ${OUT_DIR}/*.iso

clean:
	sudo rm -rf ${WORK_DIR} ${OUT_DIR}

.PHONY: build deploy test test-uefi clean
