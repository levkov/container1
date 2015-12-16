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
#--------------------------------Cloudera-------------------------------------------
RUN apt-get update && apt-get install -y curl
RUN wget http://archive.cloudera.com/director/ubuntu/trusty/amd64/director/cloudera-director.list -O /etc/apt/sources.list.d/cloudera-director.list && \
    curl -s http://archive.cloudera.com/director/ubuntu/trusty/amd64/director/archive.key | sudo apt-key add -
RUN apt-get update && \
    apt-get install cloudera-director-client -y && \
    cp /usr/lib/cloudera-director/client/aws.reference.conf /root/aws.conf && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*    
#------------------------------------ansible-------------------------------------
RUN apt-get update && apt-get install software-properties-common -y && apt-add-repository ppa:ansible/ansible -y && apt-get update && \ 
    apt-get install ansible -y && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*    
#--------------------------------S3 Tools-----------------------------------------
RUN wget -O- -q http://s3tools.org/repo/deb-all/stable/s3tools.key | sudo apt-key add - && \
    wget -O/etc/apt/sources.list.d/s3tools.list http://s3tools.org/repo/deb-all/stable/s3tools.list && \
    apt-get update && apt-get -y install s3cmd && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
# -----------------------------Dev Tools------------------------------------------
RUN apt-get update && apt-get -y install lua5.2 golang jython && \ 
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
#--------------------------------Servers------------------------------------------
RUN apt-get update && apt-get -y install mysql-server-5.5 redis-server && \ 
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
# -------------------------------C9-----------------------------------------------    
RUN apt-get update &&\
    apt-get install -y build-essential g++ curl libssl-dev apache2-utils git libxml2-dev sshfs
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs
RUN git clone https://github.com/c9/core.git /cloud9
WORKDIR /cloud9
RUN scripts/install-sdk.sh
RUN sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js 
ADD conf/cloud9.conf /etc/supervisor/conf.d/
