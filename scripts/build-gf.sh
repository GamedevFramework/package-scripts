#!/bin/bash

RUNTIME_BUILD=1
CPACK_DEPENDENCIES=""
CPACK_PACKAGE_SUFFIX=""

while [ $# -gt 1 ]
do
	case "$1" in
	"--devel")
		RUNTIME_BUILD=0
		shift
		;;
	"--dependencies")
		if [ $# -gt 2 ]
		then
			CPACK_DEPENDENCIES="$2"
			shift 2
		else
			echo "Missing dependencies list"
			exit 1
		fi
		;;
	"--package-suffix")
		if [ $# -gt 2 ]
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

if [ $# -ne 1 ]
then
	echo "Missing branch or tag name"
	exit 1
fi

if [ $RUNTIME_BUILD -eq 1 ] && [ -z "$CPACK_DEPENDENCIES" ]
then
	echo "No dependencies provided"
	exit 1
fi

if [ $RUNTIME_BUILD -eq 1 ] && [ -z "$CPACK_PACKAGE_SUFFIX" ]
then
	echo "Missing package suffix"
	exit 1
fi

GIT_BRANCH="$1"

git clone --depth 1 --branch "$GIT_BRANCH" --recursive https://github.com/GamedevFramework/gf.git

rm -rf build/

if [ $RUNTIME_BUILD -eq 1 ]
then
	PACKAGE_NAME="gf-${GIT_BRANCH:1}${CPACK_PACKAGE_SUFFIX}"
	cmake -DCMAKE_BUILD_TYPE=Release -DGF_BUILD_GAMES=OFF -DGF_BUILD_EXAMPLES=OFF -DGF_BUILD_DOCUMENTATION=OFF -DGF_SINGLE_COMPILTATION_UNIT=ON -DBUILD_TESTING=OFF -S gf -B build
	cmake --build build
	cpack --config build/CPackConfig.cmake -D CPACK_DEBIAN_PACKAGE_DEPENDS="$CPACK_DEPENDENCIES" -D CPACK_DEBIAN_PACKAGE_NAME="gf" -D CPACK_PACKAGE_FILE_NAME="$PACKAGE_NAME"
else
	PACKAGE_NAME="gf-dev-${GIT_BRANCH:1}${CPACK_PACKAGE_SUFFIX}"
	cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DGF_BUILD_GAMES=OFF -DGF_BUILD_EXAMPLES=OFF -DGF_BUILD_DOCUMENTATION=OFF -DGF_SINGLE_COMPILTATION_UNIT=ON -DBUILD_TESTING=OFF -S gf -B build
	cmake --build build
	cpack --config build/CPackConfig.cmake -D CPACK_PACKAGE_FILE_NAME="$PACKAGE_NAME"
fi

cp "$PACKAGE_NAME.deb" packages/
