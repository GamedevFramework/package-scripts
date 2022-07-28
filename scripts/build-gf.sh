#!/bin/bash

GIT_BRANCH=""
CPACK_DEPENDENCIES=""
CPACK_PACKAGE_SUFFIX=""

while [ $# -gt 0 ]
do
	case "$1" in
	"--branch")
		if [ $# -ge 2 ]
		then
			GIT_BRANCH="$2"
			shift 2
		else
			echo "Missing branch/tag name"
			exit 1
		fi
		;;
	"--runtime-dependencies")
		if [ $# -ge 2 ]
		then
			CPACK_DEPENDENCIES="$2"
			shift 2
		else
			echo "Missing runtime dependencies list"
			exit 1
		fi
		;;
	"--package-suffix")
		if [ $# -ge 2 ]
		then
			CPACK_PACKAGE_SUFFIX="$2"
			shift 2
		else
			echo "Missing package suffix"
			exit 1
		fi
		;;
	*)
		echo "Unrecognized option: $1"
		exit 1
		;;
	esac
done

if [ -z "$GIT_BRANCH" ]
then
	echo "Missing branch or tag name"
	exit 1
fi

if [ -z "$CPACK_DEPENDENCIES" ]
then
	echo "No runtime dependencies provided"
	exit 1
fi

if [ -z "$CPACK_PACKAGE_SUFFIX" ]
then
	echo "Missing package suffix"
	exit 1
fi

git clone --depth 1 --branch "$GIT_BRANCH" --recursive https://github.com/GamedevFramework/gf.git

# Build runtime deb
PACKAGE_NAME="gf-${GIT_BRANCH:1}${CPACK_PACKAGE_SUFFIX}"
rm -rf build-runtime/
cmake -DCMAKE_BUILD_TYPE=Release -DGF_BUILD_GAMES=OFF -DGF_BUILD_EXAMPLES=OFF -DGF_BUILD_DOCUMENTATION=OFF -DGF_SINGLE_COMPILTATION_UNIT=ON -DBUILD_TESTING=OFF -S gf -B build-runtime
cmake --build build-runtime
cpack --config build-runtime/CPackConfig.cmake -D CPACK_DEBIAN_PACKAGE_DEPENDS="$CPACK_DEPENDENCIES" -D CPACK_DEBIAN_PACKAGE_NAME="gf" -D CPACK_PACKAGE_FILE_NAME="$PACKAGE_NAME"
cp "$PACKAGE_NAME.deb" packages/

# Build dev deb
PACKAGE_NAME="gf-dev-${GIT_BRANCH:1}${CPACK_PACKAGE_SUFFIX}"
rm -rf build-dev/
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DGF_BUILD_GAMES=OFF -DGF_BUILD_EXAMPLES=OFF -DGF_BUILD_DOCUMENTATION=OFF -DGF_SINGLE_COMPILTATION_UNIT=ON -DBUILD_TESTING=OFF -S gf -B build-dev
cmake --build build-dev
cpack --config build-dev/CPackConfig.cmake -D CPACK_PACKAGE_FILE_NAME="$PACKAGE_NAME"
cp "$PACKAGE_NAME.deb" packages/
