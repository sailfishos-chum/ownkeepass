BOTAN_SRC_DIR = $$PWD/botan
BOTAN_BUILD_DIR = $$PWD/botan
BOTAN_LIB = $$BOTAN_BUILD_DIR/libbotan-3.a

QMAKE_CLEAN += $(MAKE) -C $$BOTAN_SRC_DIR distclean

BOTAN_CFG_CMD = python3 $$BOTAN_SRC_DIR/configure.py \
    --link-method=hardlink \
    --build-targets=static \
    --distribution-info=Sailfish_OS_Chum \
    --no-install-python-module \
    --disable-shared-library \
    --without-documentation \
    --minimized-build    \
    --disable-experimental-features \
    --disable-deprecated-features \
    --with-bzip2 \
    --with-zlib

BOTAN_CLEAN_CMD = $(MAKE) -C $$BOTAN_SRC_DIR distclean
BOTAN_BUILD_CMD = $(MAKE) -C $$BOTAN_SRC_DIR

botan.target = $$BOTAN_LIB
botan.commands = $$BOTAN_CFG_CMD && $$BOTAN_BUILD_CMD
QMAKE_EXTRA_TARGETS += botan

# Ensure the main project depends on the library
PRE_TARGETDEPS += $$botan.target

LIBS += -L$$BOTAN_BUILD_DIR -lbotan-3
INCLUDEPATH += $$BOTAN_BUILD_DIR/build/include/public


