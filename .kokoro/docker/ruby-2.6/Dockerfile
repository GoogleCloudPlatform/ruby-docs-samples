FROM ruby:2.6-buster

ENTRYPOINT /bin/bash

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
    build-essential \
    chrpath \
    freetds-bin \
    freetds-dev \
    libssl-dev \
    libxft-dev \
    libfreetype6-dev \
    libfreetype6 \
    libfontconfig1-dev \
    libfontconfig1 \
    memcached \
    nodejs
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share/
RUN ln -s /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/
RUN rm phantomjs-2.1.1-linux-x86_64.tar.bz2

# Set this to get phantomjs to work in Debian 10
ENV OPENSSL_CONF /etc/ssl/