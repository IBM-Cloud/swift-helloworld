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

# Dockerfile to build a Docker image for running the Swift Sample Starter App
# inside an IBM Container on Bluemix.

FROM ibmcom/swift-ubuntu:latest
MAINTAINER IBM Swift Engineering at IBM Cloud
LABEL Description="Image to run the swift-helloworld sample application inside an IBM Container on Bluemix."

EXPOSE 8090

RUN mkdir /root/swift-helloworld

ADD Sources /root/swift-helloworld
ADD Package.swift /root/swift-helloworld
ADD LICENSE /root/swift-helloworld
ADD .swift-version /root/swift-helloworld

# Build Swift Started App
RUN cd /root/swift-helloworld && swift build

USER root
CMD ["/root/swift-helloworld/.build/debug/Server"]
