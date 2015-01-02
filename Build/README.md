#Build Scripts

This directory contains a series of build scripts to be run at different intervals during the build process. 

Scripts prefixed with `before_` are intended to be run before the build process in order to setup any dependencies, scripts prefixed with `after_` are intended to be run after the build process to do any post-build reporting and scripts without a decerning prefix are intended to be run as part of the actual build process.

All of these scripts are intended to be run from the root directory of this source code repository, e.g. as `./Build/<build-script>.sh`.

The `./build.sh` script can be used in the top-level directory to run the whole build process, otherwise the build should be