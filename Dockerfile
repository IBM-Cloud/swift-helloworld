##
# Copyright IBM Corporation 2016,2017
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

# Dockerfile to build a Docker image for running the Swift Sample Starter App
# inside an IBM Container on Bluemix.

FROM ibmcom/swift-ubuntu:4.1.1
MAINTAINER IBM Swift Engineering at IBM Cloud
LABEL Description="Image to run the swift-helloworld sample application inside an IBM Container on Bluemix."

EXPOSE 8080

RUN mkdir /swift-helloworld

ADD Sources /swift-helloworld/Sources
ADD Package.swift /swift-helloworld
ADD Package.resolved /swift-helloworld
ADD LICENSE /swift-helloworld
ADD .swift-version /swift-helloworld

# Build Swift Started App
RUN cd /swift-helloworld && swift build

USER root
CMD ["/swift-helloworld/.build-ubuntu/x86_64-unknown-linux/debug/Server"]
