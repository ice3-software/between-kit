#!/bin/bash

xctool -workspace Tests/BetweenKit.xcworkspace  			\
	-scheme BetweenKitTests 					\
	-sdk iphonesimulator						\
	-arch i386							\
	-reporter pretty					 	\
	-reporter json-compilation-database:compile_commands.json 	\
	test	 							\
	ONLY_ACTIVE_ARCH=NO 						\
	TEST_AFTER_BUILD=YES 						\
	TEST_HOST= 							\
	GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES 				\
	GCC_GENERATE_TEST_COVERAGE_FILES=YES