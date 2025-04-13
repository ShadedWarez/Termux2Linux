TERMUX_PKG_HOMEPAGE=https://elinux.org/Android_aapt
TERMUX_PKG_DESCRIPTION="Android Asset Packaging Tool"
TERMUX_PKG_LICENSE="Apache-2.0"
_TAG_VERSION=7.1.2
_TAG_REVISION=33
TERMUX_PKG_VERSION=${_TAG_VERSION}.${_TAG_REVISION}
TERMUX_PKG_REVISION=7
TERMUX_PKG_SKIP_SRC_EXTRACT=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="libc++, libexpat, libpng, libzopfli, zlib"

termux_step_pre_configure() {
	# Certain packages are not safe to build on device because their
	# build.sh script deletes specific files in $TERMUX_PREFIX.
	if $TERMUX_ON_DEVICE_BUILD; then
		termux_error_exit "Package '$TERMUX_PKG_NAME' is not safe for on-device builds."
	fi
}

termux_step_make_install() {
	# FIXME: We would like to enable checksums when downloading
	# tar files, but they change each time as the tar metadata
	# differs: https://github.com/google/gitiles/issues/84

	local _TAGNAME=${_TAG_VERSION}_r${_TAG_REVISION}

	SYSTEM_CORE_INCLUDE_TARFILE=$TERMUX_PKG_CACHEDIR/system_core_include_${_TAGNAME}.tar.gz
	test ! -f $SYSTEM_CORE_INCLUDE_TARFILE && termux_download \
		"https://android.googlesource.com/platform/system/core/+archive/android-$_TAGNAME/include.tar.gz" \
		$SYSTEM_CORE_INCLUDE_TARFILE \
		SKIP_CHECKSUM

	ANDROIDFW_INCLUDE_TARFILE=$TERMUX_PKG_CACHEDIR/androidfw_include_${_TAGNAME}.tar.gz
	test ! -f $ANDROIDFW_INCLUDE_TARFILE && termux_download \
		"https://android.googlesource.com/platform/frameworks/base/+archive/android-$_TAGNAME/include/androidfw.tar.gz" \
		$ANDROIDFW_INCLUDE_TARFILE \
		SKIP_CHECKSUM

	ANDROID_BASE_INCLUDE_TARFILE=$TERMUX_PKG_CACHEDIR/android_base_include_${_TAGNAME}.tar.gz
	test ! -f $ANDROID_BASE_INCLUDE_TARFILE && termux_download \
		"https://android.googlesource.com/platform/system/core/+archive/android-$_TAGNAME/base/include/android-base.tar.gz" \
		$ANDROID_BASE_INCLUDE_TARFILE \
		SKIP_CHECKSUM

	local AOSP_INCLUDE_DIR=$TERMUX_PREFIX/include/aosp
	mkdir -p $AOSP_INCLUDE_DIR
	cd $AOSP_INCLUDE_DIR
	rm -Rf *
	tar xf $SYSTEM_CORE_INCLUDE_TARFILE
	mkdir -p androidfw
