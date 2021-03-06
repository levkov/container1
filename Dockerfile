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
#------------------------------------ansible-------------------------------------
RUN apt-get update && apt-get install software-properties-common -y && apt-add-repository ppa:ansible/ansible -y && apt-get update && \
    apt-get install ansible -y && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
#--------------------------------S3 Tools-----------------------------------------
RUN wget -O- -q http://s3tools.org/repo/deb-all/stable/s3tools.key | sudo apt-key add - && \
    wget -O/etc/apt/sources.list.d/s3tools.list http://s3tools.org/repo/deb-all/stable/s3tools.list && \
    apt-get update && apt-get -y install s3cmd && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
EXPOSE 6080
# -----------------------------Dev Tools------------------------------------------
RUN apt-get update && apt-get -y install lua5.2 golang jython git libmysqlclient-dev && \
    apt-get install -y python-pip python-dev bpython && \
    pip install Flask boto awscli redis MySQL-python && \
    pip install rq rq-dashboard rq-scheduler gunicorn && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
#--------------------------------Servers------------------------------------------
RUN apt-get update && apt-get -y install mysql-server-5.5 redis-server && \
    rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*
ADD conf/mysql.conf /etc/supervisor/conf.d/
ADD conf/redis.conf /etc/supervisor/conf.d/
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

# ----------------------------Consul-----------------------------------------------
RUN apt-get update &&\
    apt-get install -y unzip
RUN cd /tmp && wget https://releases.hashicorp.com/consul/0.6.3/consul_0.6.3_linux_amd64.zip && \
    unzip consul_0.6.3_linux_amd64.zip && mv consul /usr/local/bin
RUN cd /tmp && wget https://releases.hashicorp.com/consul-template/0.13.0/consul-template_0.13.0_linux_amd64.zip && \
    unzip consul-template_0.13.0_linux_amd64.zip && mv consul-template /usr/local/bin
# ---------------------------Keybox-------------------------------------------------
RUN cd /opt/ && \
    wget https://github.com/skavanagh/KeyBox/releases/download/v2.85.01/keybox-jetty-v2.85_01.tar.gz && \
    tar zxvf keybox-jetty-v2.85_01.tar.gz && \
    rm -rf keybox-jetty-v2.85_01.tar.gz
EXPOSE 8443
