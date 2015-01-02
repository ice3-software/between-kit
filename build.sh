#!/bin/bash


./Build/before_install.sh
./Build/run_tests.sh
./Build/after_coverage.sh
./Build/after_mess.sh