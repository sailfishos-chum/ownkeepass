BOTAN_SRC_DIR = $$PWD/botan
BOTAN_BUILD_DIR = $$PWD/botan

QMAKE_CLEAN += $(MAKE) -C $$BOTAN_SRC_DIR distclean

BOTAN_CFG_CMD = pushd $$BOTAN_SRC_DIR; ./configure.py \
    --link-method=hardlink \
    --distribution-info=Sailfish_OS_Chum \
    --no-install-python-module \
    --disable-shared-library \
    --without-documentation \
    --disable-experimental-features \
    --disable-deprecated-features\
    --without-include-namespace \
    ; popd

#    --build-targets=static \
#    --minimized-build \
#    --with-bzip2 \
#    --with-zlib

PKGCONFIG += zlib

BOTAN_CLEAN_CMD = pushd $$BOTAN_SRC_DIR; make distclean; popd
BOTAN_BUILD_CMD = pushd $$BOTAN_SRC_DIR; $(MAKE); popd
BOTAN_INSTALL_CMD = pushd $$BOTAN_SRC_DIR; %(MAKE) PREFIX=/ DESTDIR=$$PWD/deps install; popd; exit -1

libbotan.target = $$BOTAN_BUILD_DIR/libbotan-3.a
libbotan.commands = $$BOTAN_CFG_CMD && $$BOTAN_BUILD_CMD && $$BOTAN_INSTALL_CMD
QMAKE_EXTRA_TARGETS += libbotan

# Ensure the main project depends on the library
PRE_TARGETDEPS += $$libbotan.target

LIBS += -L$$BOTAN_BUILD_DIR -lbotan-3
INCLUDEPATH += $$BOTAN_BUILD_DIR/build/include/public


