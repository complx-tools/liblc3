#!/bin/bash

# Stop on any error
set -e
 
if [ "$(id -u)" != "0" ]; then
	echo "Sorry, you are not root. Use the command sudo ./install.sh"
	exit 1
fi

if ! type apt-get >/dev/null 2>&1; then
	echo >&2 "APT required, perhaps you don't have a Debian variant installed?"
	exit 2
fi

echo >&2 "Installing package build-essential"
apt-get install -y build-essential > /dev/null
echo >&2 "Installing g++"
apt-get install -y g++ > /dev/null
echo >&2 "Installing CMake"
apt-get install -y cmake > /dev/null
echo >&2 "Installing Boost Tests"
apt-get install -y libboost-test-dev > /dev/null
echo >&2 "Creating build directory"
mkdir -p build
cd build
echo >&2 "Generating Makefile via cmake"
cmake ..
echo >&2 "Building program"
make
echo >&2 "Installing program"
make install
echo >&2 "Running ldconfig"
ldconfig
echo >&2 "Done, have a nice day!"
