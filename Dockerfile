FROM joseba/rasp-base

RUN apt-get update && \
apt-get install -yqq \
openssh-server \
rsync \
git-core \
net-tools \
wget \
unzip

RUN groupadd git && \
useradd -g git -s /bin/bash -m git

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN sed 's@UsePrivilegeSeparation yes@UsePrivilegeSeparation no@' -i /etc/ssh/sshd_config

RUN sed 's@#RSAAuthentication yes@RSAAuthentication yes@' -i /etc/ssh/sshd_config
RUN sed 's@#PubkeyAuthentication yes@PubkeyAuthentication yes@' -i /etc/ssh/sshd_config

RUN echo "export VISIBLE=now" >> /etc/profile
RUN echo "PermitUserEnvironment yes" >> /etc/ssh/sshd_config

# prepare data
ENV GOGS_CUSTOM /data/gogs
RUN echo "export GOGS_CUSTOM=/data/gogs" >> /etc/profile && \
mkdir /gogits

WORKDIR /gogits

RUN wget https://github.com/gogits/gogs/releases/download/v0.9.113/raspi2.zip --no-check-certificate && unzip raspi2.zip

ADD start.sh /gogits/gogs/
RUN chmod a+x /gogits/gogs/start.sh

WORKDIR /gogits/gogs

EXPOSE 22
EXPOSE 3000
ENTRYPOINT []
CMD ["./start.sh"]