FROM ubuntu:18.04
ENV WORKDIR /home/
RUN apt update -y && apt install curl openjdk-11-jdk git maven -y
RUN adduser --disabled-password --gecos ”” jenkins
RUN curl -fsSL https://get.docker.com/ | sh