FROM ubuntu:latest

ENTRYPOINT /bin/bash

# Set the locale
RUN apt-get update && apt-get install -y --no-install-recommends locales && rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install dependencies
RUN apt-get update && apt-get install -y git curl autoconf bison build-essential libssl1.0-dev \
    libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev wget lsb-release
RUN apt-get -y autoclean

# Install rbenv
RUN git clone https://github.com/rbenv/rbenv.git /root/.rbenv
RUN cd /root/.rbenv && src/configure && make -C src

ENV PATH /root/.rbenv/bin:$PATH
ENV PATH /root/.rbenv/shims:$PATH

RUN echo 'eval "$(rbenv init -)"' >> /etc/profile
RUN echo 'eval "$(rbenv init -)"' >> .bashrc

# Install ruby-build
RUN mkdir -p "$(rbenv root)"/plugins
RUN git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build


# Install ruby
ENV RUBY_CONFIGURE_OPTS --disable-install-doc
RUN echo 'gem: --no-rdoc --no-ri' >> /.gemrc
RUN rbenv install 2.3.8 && rbenv global 2.3.8 && gem install bundler --version 1.17.3
RUN rbenv install 2.4.5 && rbenv global 2.4.5 && gem install bundler --version 1.17.3
RUN rbenv install 2.5.3 && rbenv global 2.5.3 && gem install bundler --version 1.17.3
RUN rbenv install 2.6.0 && rbenv global 2.6.0 && gem install bundler --version 1.17.3

# Install PhantomJS
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN tar xvjf phantomjs-2.1.1-linux-x86_64.tar.bz2 -C /usr/local/share/
RUN ln -s /usr/local/share/phantomjs-2.1.1-linux-x86_64/bin/phantomjs /usr/local/bin/
RUN rm phantomjs-2.1.1-linux-x86_64.tar.bz2

# Install Cloud SDK
RUN echo "deb http://packages.cloud.google.com/apt cloud-sdk-bionic main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update && apt-get install -y google-cloud-sdk

RUN apt-get -y autoremove && apt-get -y autoclean