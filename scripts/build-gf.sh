#!/bin/bash

GIT_BRANCH=""
CPACK_PACKAGE_SUFFIX=""

# Go to home
cd

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

if [ -z "$CPACK_PACKAGE_SUFFIX" ]
then
  echo "Missing package suffix"
  exit 1
fi

git clone --depth 1 --branch "$GIT_BRANCH" --recursive https://github.com/ahugeat/gf.git

if [ "$OS_NAME" = "ubuntu" ]
then
  echo "Patch SDL2 usage for ubuntu..."
  cat gf/library/CMakeLists.txt | sed 's/SDL2::SDL2/\$\{SDL2_LIBRARIES\}/' | tee gf/library/CMakeLists.txt > /dev/null
  echo 'include_directories(SYSTEM ${SDL2_INCLUDE_DIRS})' >> gf/library/CMakeLists.txt
fi

# Build runtime deb
rm -rf build-runtime/
cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DGF_BUILD_GAMES=OFF -DGF_BUILD_EXAMPLES=OFF -DGF_BUILD_DOCUMENTATION=OFF -DBUILD_TESTING=OFF -DGF_DEV_PACKAGE=OFF -DGF_PACKAGE_SUFFIX="$CPACK_PACKAGE_SUFFIX" -S gf -B build-runtime
cmake --build build-runtime --parallel $(nproc)
cpack --config build-runtime/CPackConfig.cmake -D CPACK_DEBIAN_RUNTIME_PACKAGE_NAME="gf" -D CPACK_DEBIAN_PACKAGE_RUNTIME_CONFLICTS="gf-dev"
mv *.deb packages/

# Build dev deb
# rm -rf build-dev/
# cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DGF_BUILD_GAMES=OFF -DGF_BUILD_EXAMPLES=OFF -DGF_BUILD_DOCUMENTATION=OFF -DBUILD_TESTING=OFF -DGF_DEV_PACKAGE=ON -DGF_PACKAGE_SUFFIX="$CPACK_PACKAGE_SUFFIX" -S gf -B build-dev
# cmake --build build-dev --parallel $(nproc)
# cpack --config build-dev/CPackConfig.cmake -D CPACK_DEBIAN_PACKAGE_CONFLICTS="gf"
# mv *.deb packages/
