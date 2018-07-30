FROM ruby:2.5-stretch

ENTRYPOINT /bin/bash

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y \
    build-essential \
    chrpath \
    libssl-dev \
    libxft-dev \
    libfreetype6-dev \
    libfreetype6 \
    libfontconfig1-dev \
    libfontconfig1 \
    memcached
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share/
RUN ln -s /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/
RUN rm phantomjs-2.1.1-linux-x86_64.tar.bz2
