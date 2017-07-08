FROM ubuntu:16.04

MAINTAINER Tobias Schneck "tobias.schneck@consol.de"
ENV REFRESHED_AT 2017-07-04

RUN apt-get update && apt-get install -y httping && apt-get clean -y

## ADD is only need due to docker-in-docker jenkins can`t currently mount volumens
ADD wait-for-server.sh /start/wait-for-server.sh
RUN chmod -R a+rwx /start
CMD /start/wait-for-server.sh