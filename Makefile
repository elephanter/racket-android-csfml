SHELL := /bin/bash

export NDK := /home/danil/Android/Sdk/ndk/21.1.6352462
ifeq ($(shell uname -s),Darwin)
	export TOOLCHAIN:=${NDK}/toolchains/llvm/prebuilt/darwin-x86_64
else
	export TOOLCHAIN:=${NDK}/toolchains/llvm/prebuilt/linux-x86_64
endif

#export TARGET:=aarch64-linux-android
export CURRENT_ABI:=armeabi-v7a
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
export LIBSFML := dist/sfml
export LIBCSFML := dist/csfml
export LIBFFIPATH:=$(shell pwd)/${LIBFFI}
export LIBSFMLPATH := $(shell pwd)/${LIBSFML}/build/${CURRENT_ABI}
export LIBCSFMLPATH := $(shell pwd)/${LIBCSFML}

RACKETDIR=dist/racket-master/racket
LIBRACKET=${RACKETDIR}/lib/libracket3m.a
LIBRKTIO=${RACKETDIR}/src/build/rktio/librktio.a
RACKETINCLUDE=${RACKETDIR}/include
JNI=project/app/src/main/jni
RACKETDEST=${JNI}/racket

build_all: ${RACKETDEST} ${JNI}/racket_app.c ${RACKETDEST}/racket-vm.3m.c ${RACKETDEST}/libracket3m.a ${RACKETDEST}/librktio.a ${RACKETDEST}/libffi.a ${RACKETDEST}/include ${NDK}/sources/third_party/csfml

clean:
	find rkt -name compiled | xargs rm -fr
	rm -f ${RACKETDEST}/racket_app.c ${RACKETDEST}/racket-vm.3m.c ${RACKETDEST}/*.a

${JNI}/racket_app.c: rkt/app.rkt ${RACKETDEST}
	raco ctool --c-mods $@ $<

${RACKETDEST}/racket-vm.3m.c: ${RACKETDEST}/../racket-vm.c ${RACKETDEST}
	raco ctool --xform $<
	mv -f ${RACKETDEST}/../racket-vm.3m.c ${RACKETDEST}/racket-vm.3m.c
	mv -f ${JNI}/racket_app.c ${RACKETDEST}/racket_app.c

${RACKETDEST}/libracket3m.a: ${LIBRACKET}
	cp $< $@

${RACKETDEST}/librktio.a: ${LIBRKTIO}
	cp $< $@

${RACKETDEST}/libffi.a:
	cp ${LIBFFI}/lib/libffi.a $@

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
	CFLAGS="-I${LIBFFIPATH}/include" \
	CPPFLAGS="-fPIC -I${LIBFFIPATH}/include" \
	LDFLAGS="-L${LIBFFIPATH}/lib" \
        ../configure --host=${TARGET} --enable-racket=auto && $(MAKE) && $(MAKE) plain-install

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
	CFLAGS="-g" \
	CPPFLAGS="-fPIC -g" \
	../configure --host=${TARGET} --prefix=${LIBFFIPATH} --enable-debug --enable-portable-binary && make && make install

dist/racket-master: dist/racket-master.zip
	unzip $^ -d dist
	mv dist/racket-7.7 dist/racket-master
	cd dist/racket-master && patch -p1 < ../../rktio.patch
	touch $@

dist/racket-master.zip:
	wget https://github.com/racket/racket/archive/v7.7.zip -O $@ || rm -f $@
	

${NDK}/sources/third_party/csfml: ${LIBCSFML} ${NDK}/sources/third_party/sfml
	mkdir -p dist/csfml/build/armeabi-v7a && cd dist/csfml/build/armeabi-v7a && \
	cmake -DANDROID_ABI=${CURRENT_ABI} -DANDROID_PLATFORM=android-24 -DCMAKE_TOOLCHAIN_FILE=${NDK}/build/cmake/android.toolchain.cmake -DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=clang -DCMAKE_SYSTEM_NAME=Android -DCMAKE_ANDROID_NDK=${NDK} -DCMAKE_ANDROID_STL_TYPE=c++_static -DCMAKE_BUILD_TYPE=Debug -DSFML_DIR=${LIBSFMLPATH} -G "Unix Makefiles" ../.. && make && sudo make install

${LIBCSFML}:
	git clone --single-branch --branch android_support https://github.com/elephanter/CSFML.git dist/csfml

${NDK}/sources/third_party/sfml: ${LIBSFML}
	mkdir -p dist/sfml/build/armeabi-v7a && cd dist/sfml/build/armeabi-v7a && \
	cmake -DANDROID_ABI=${CURRENT_ABI} -DANDROID_PLATFORM=android-24 -DCMAKE_TOOLCHAIN_FILE=${NDK}/build/cmake/android.toolchain.cmake -DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=clang -DCMAKE_SYSTEM_NAME=Android -DCMAKE_ANDROID_NDK=${NDK} -DCMAKE_ANDROID_STL_TYPE=c++_static -DCMAKE_BUILD_TYPE=Debug -G "Unix Makefiles" ../.. && make && sudo make install

${LIBSFML}:
	git clone https://github.com/acsbendi/SFML dist/sfml

.INTERMEDIATE: ${LIBFFI} ${RACKETINCLUDE} ${LIBRACKET}
