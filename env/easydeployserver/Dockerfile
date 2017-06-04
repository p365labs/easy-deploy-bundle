# This image is the base image for the Elastica development and includes all parts which rarely change
# PHP 7 Docker file with Composer installed
FROM php:7.1


RUN apt-get update && \
    apt-get install git unzip openssh-server net-tools -y && \
    mkdir /var/run/sshd && \
    mkdir -p ~root/.ssh /etc/authorized_keys /etc/ssh && chmod 700 ~root/.ssh/ && \
#    echo 's@^AuthorizedKeysFile.*@@g' >> /etc/ssh/sshd_config  && \
#    echo -e "AuthorizedKeysFile\t.ssh/authorized_keys /etc/authorized_keys/%u" >> /etc/ssh/sshd_config && \
#    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
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

RUN docker-php-ext-install sockets xsl

RUN rm -r /var/lib/apt/lists/*

# Xdebug for coverage report
RUN pecl install xdebug-2.4.0

## PHP Configuration

RUN echo "memory_limit=1024M" >> /usr/local/etc/php/conf.d/memory-limit.ini
RUN echo "date.timezone=UTC" >> /usr/local/etc/php/conf.d/timezone.ini
RUN echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20151012/xdebug.so" >> /usr/local/etc/php/conf.d/xdebug.ini

# Install and setup composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
ENV COMPOSER_HOME /root/composer

# Add composer bin to the environment
ENV PATH=/root/composer/vendor/bin:$PATH

COPY composer.json /root/composer/

# Install development tools, prefer source removed as automatic fallback now
RUN composer global install
