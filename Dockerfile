FROM ubuntu:14.04
MAINTAINER levkov
ENV DEBIAN_FRONTEND noninteractive
ENV NOTVISIBLE "in users profile"
RUN locale-gen en_US.UTF-8

RUN apt-get update && apt-get upgrade -y &&\
    apt-get install apt-transport-https -y &&\
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
#------------------------------Supervisor------------------------------------------------
RUN apt-get update && apt-get install -y supervisor && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN mkdir -p /var/log/supervisor    
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 9001
CMD ["/usr/bin/supervisord"]
#---------------------------SSH---------------------------------------------------------
RUN apt-get update && apt-get install -y openssh-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN mkdir -p /var/run/sshd    
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
COPY conf/sshd.conf /etc/supervisor/conf.d/sshd.conf

RUN echo 'root:ContaineR' | chpasswd
# -----------------------------------Java--------------------------------------
RUN apt-get update && apt-get install software-properties-common -y && add-apt-repository ppa:webupd8team/java -y &&  apt-get update && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections && \
    apt-get install oracle-java8-installer -y && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
#------------------------------------Juju----------------------------------------    
RUN apt-get update && apt-get install software-properties-common -y && add-apt-repository ppa:juju/stable -y && apt-get update && \
    apt-get install juju-quickstart -y && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
