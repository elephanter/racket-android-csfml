SHELL := /bin/bash

export NDK := /home/danil/Android/Sdk/ndk/21.1.6352462
ifeq ($(shell uname -s),Darwin)
	export TOOLCHAIN:=${NDK}/toolchains/llvm/prebuilt/darwin-x86_64
else
	export TOOLCHAIN:=${NDK}/toolchains/llvm/prebuilt/linux-x86_64
endif

#export TARGET:=aarch64-linux-android
export TARGET:=armv7a-linux-androideabi
export TARGET_S:=arm-linux-androideabi
#export TARGET:=i686-linux-android
#export TARGET:=x86_64-linux-android
# Set this to your minSdkVersion.
export API:=21
# Configure and build.

export AS := ${TOOLCHAIN}/bin/${TARGET_S}-as

export PATH := ${TOOLCHAIN}/bin:$(PATH)

export LIBFFI := dist/libffi
export LIBFFIPATH:=$(shell pwd)/${LIBFFI}

RACKETDIR=dist/racket-master/racket
LIBRACKET=${RACKETDIR}/lib/libracket3m.a
LIBRKTIO=${RACKETDIR}/src/build/rktio/librktio.a
RACKETINCLUDE=${RACKETDIR}/include
JNI=project/app/src/main/jni
RACKETDEST=${JNI}/racket

.PHONY: app
app: build_all
	cd project && ./gradlew installArmDebug

.PHONY: simulate
simulate: rkt/csd.rktd.gz
	ln -sf simulator.rkt rkt/tabulator.rkt
	raco make rkt/app.rkt
	racket -t rkt/app.rkt

.PHONY: build_all
build_all: ${RACKETDEST} ${RACKETDEST}/racket-vm.3m.c ${RACKETDEST}/racket_app.c ${RACKETDEST}/libracket3m.a ${RACKETDEST}/librktio.a ${RACKETDEST}/include

clean:
	find rkt -name compiled | xargs rm -fr
	find rkt/xprize/ -name compiled | xargs rm -fr
	rm -f ${RACKETDEST}/racket_app.c ${RACKETDEST}/racket-vm.3m.c

size: ${RACKETDEST}/racket_app.c
	du -hac $^ ./project/app/build/outputs/apk/app-arm-debug.apk
	tail $^

rkt/csd.rktd.gz: rkt/app-csd.rkt
	racket -t $^

${RACKETDEST}/racket_app.c: rkt/app.rkt rkt/csd.rktd.gz ${RACKETDEST}
	ln -sf tablet.rkt rkt/tabulator.rkt
	raco ctool --c-mods $@ $<

${RACKETDEST}/racket-vm.3m.c: ${RACKETDEST}/../racket-vm.c ${RACKETDEST}
	raco ctool --xform $<
	mv -f ${RACKETDEST}/../racket-vm.3m.c ${RACKETDEST}/racket-vm.3m.c

${RACKETDEST}/libracket3m.a: ${LIBRACKET}
	cp $< $@

${RACKETDEST}/librktio.a: ${LIBRKTIO}
	cp $< $@

${RACKETDEST}/include: ${RACKETINCLUDE}
	rsync -a --delete --progress $</ $@/

${RACKETDEST}:
	mkdir -p $@
	touch $@

${RACKETINCLUDE} ${LIBRACKET}: ${LIBFFI} dist/racket-master
	mkdir -p ${RACKETDIR}/src/build && cd ${RACKETDIR}/src/build && \
	AR=${TOOLCHAIN}/bin/${TARGET_S}-ar \
	CC=${TOOLCHAIN}/bin/${TARGET}${API}-clang \
	CXX=${TOOLCHAIN}/bin/$TARGET$API-clang++ \
	LD=${TOOLCHAIN}/bin/${TARGET_S}-ld \
	RANLIB=${TOOLCHAIN}/bin/${TARGET_S}-ranlib \
	STRIP=${TOOLCHAIN}/bin/${TARGET_S}-strip \
	CFLAGS="-fPIE -fPIC -I${LIBFFIPATH}/include" \
	CPPFLAGS="-I${LIBFFIPATH}/include" \
	LIBS="-lffi" \
	LDFLAGS="-pie" \
	LDFLAGS="-L${LIBFFIPATH}/lib" \
	../configure --host=${TARGET} --enable-racket=auto --enable-libs --enable-places --enable-foreign --enable-ffipoll --enable-libffi --enable-pthread && $(MAKE) && $(MAKE) plain-install

${LIBFFI}:
	git clone --single-branch --branch v3.3 https://github.com/libffi/libffi.git dist/libffi_src
	mkdir -p dist/libffi_src/build && cd dist/libffi_src && \
	./autogen.sh && cd build && \
	AR=${TOOLCHAIN}/bin/${TARGET_S}-ar \
	CC=${TOOLCHAIN}/bin/${TARGET}${API}-clang \
	CXX=${TOOLCHAIN}/bin/$TARGET$API-clang++ \
	LD=${TOOLCHAIN}/bin/${TARGET_S}-ld \
	RANLIB=${TOOLCHAIN}/bin/${TARGET_S}-ranlib \
	STRIP=${TOOLCHAIN}/bin/${TARGET_S}-strip \
	LDFLAGS="-pie" \
	../configure --host=${TARGET} --prefix=${LIBFFIPATH} && make && make install

dist/racket-master: dist/racket-master.zip
	unzip $^ -d dist
	mv dist/racket-7.6 dist/racket-master
	cd dist/racket-master && git apply ../../rktio.patch
	touch $@

dist/racket-master.zip:
	wget https://github.com/racket/racket/archive/v7.6.zip -O $@ || rm -f $@


.INTERMEDIATE: ${LIBFFI} ${RACKETINCLUDE} ${LIBRACKET}
