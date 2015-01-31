#!/bin/bash

sudo easy_install cpp-coveralls 
cd Tests
pod update
pod install
cd ../