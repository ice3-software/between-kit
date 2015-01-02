#!/bin/bash

./Build/Vendor/Coveralls/coveralls.rb --extension m 	\
	--exclude-folder Tests 				\
	--exclude-folder Use Cases 			\
	—-exclude-folder Legacy

