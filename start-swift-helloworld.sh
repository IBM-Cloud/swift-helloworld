#!/bin/bash

##
# Copyright IBM Corporation 2016
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##

# This script clones the Swift Sample Starter App and builds it (using the Swift
# Package Manager). It also starts the sample server after a successful
# compilation of the package.

# If any commands fail, we want the shell script to exit immediately.
set -e

# Run sample server
cd /root/swift-helloworld && .build/debug/Server
