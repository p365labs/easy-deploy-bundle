# PHP 7 Docker file with Composer installed
FROM php:7.1

# Install depdencies
WORKDIR /easydeploy

# Copy composer file first as this only changes rarely
COPY composer.json /easydeploy/

ENV EASYDEPLOY_DEV true

# Set empty environment so that Makefile commands inside container do not prepend the environment
ENV RUN_ENV " "

# Commands are taken from Makefile. Everytime the makefile is updated, this commands is rerun
RUN mkdir -p \
	./build/code-browser \
	./build/docs \
	./build/logs \
	./build/pdepend \
	./build/coverage

#install and setup sshd
#    apt-get install openssh-server -y && \
#RUN apk update && \
#     apk add bash git openssh
RUN apt-get update && \
    apt-get install git unzip openssh-server net-tools -y && \
    mkdir /var/run/sshd && \
    mkdir -p ~root/.ssh /etc/authorized_keys /etc/ssh && chmod 700 ~root/.ssh/ && \
#    echo 's@^AuthorizedKeysFile.*@@g' >> /etc/ssh/sshd_config  && \
#    echo -e "AuthorizedKeysFile\t.ssh/authorized_keys /etc/authorized_keys/%u" >> /etc/ssh/sshd_config && \
#    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
#    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin without-password" >> /etc/ssh/sshd_config && \
    echo "RSAAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "AllowUsers root" >> /etc/ssh/sshd_config && \
#    echo -e "Port 22\n" >> /etc/ssh/sshd_config && \
    cp -a /etc/ssh /etc/ssh.cache && \
    rm -rf /var/cache/apt/* && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer install && \
    composer dump-autoload

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# Prefer source removed as automatic fallback now
#RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
#RUN composer install
#RUN composer dump-autoload

#Copy keys also to built-in images

COPY src /easydeploy/src
COPY tests /easydeploy/tests
COPY Makefile /easydeploy/
COPY keys /root/.ssh/
COPY phpunit.xml.dist /easydeploy/

COPY docker-entrypoint.sh /entrypoint.sh
EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-f", "/etc/ssh/sshd_config"]

