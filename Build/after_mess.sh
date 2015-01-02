#!/bin/bash

./Build/external/OCLint/bin/oclint-json-compilation-database 	\
	-exclude Tests 						\
	-- -report-type html -o mess_report.html