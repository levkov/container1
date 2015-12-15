FROM ubuntu:14.04
MAINTAINER levkov
ENV DEBIAN_FRONTEND noninteractive
ENV NOTVISIBLE "in users profile"
RUN locale-gen en_US.UTF-8

RUN apt-get update && apt-get upgrade -y &&\
    apt-get install apt-transport-https -y &&\
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#------------------------------------------------------------------------------
RUN apt-get install - y supervisor
EXPOSE 9001
CMD ["/usr/bin/supervisord"]
# -----------------------------------Java--------------------------------------
RUN apt-get update && apt-get install software-properties-common -y && add-apt-repository ppa:webupd8team/java -y &&  apt-get update && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
    apt-get install oracle-java8-installer -y && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
#------------------------------------------------------------------------------    
