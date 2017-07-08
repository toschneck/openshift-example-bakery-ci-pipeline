FROM ubuntu:16.04

MAINTAINER Tobias Schneck "tobias.schneck@consol.de"
ENV REFRESHED_AT 2017-07-04

RUN apt-get update && apt-get install -y httping && apt-get clean -y

## ADD is only need due to docker-in-docker jenkins can`t currently mount volumens
ADD wait-for-server.sh /root/wait-for-server.sh
RUN chmod +x /root/wait-for-server.sh
CMD /root/wait-for-server.sh