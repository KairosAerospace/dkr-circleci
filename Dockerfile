FROM buildpack-deps:xenial-scm
SHELL ["/bin/bash", "-e", "-c"]

# install some apt tools
RUN apt-get update && apt-get install -y software-properties-common python-software-properties \
    apt-transport-https unzip vim

COPY dockerproject.gpg /root/dockerproject.gpg

# install docker
RUN apt-key add /root/dockerproject.gpg \
  && apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' \
  && apt-get update \
  && apt-get install -y docker-engine

# install  packer
RUN wget https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_linux_amd64.zip -O packer.zip \
  && unzip packer.zip \
  && mv packer /usr/bin \
  && rm packer.zip

# install the same system loadout as the kairos-base production image
RUN apt-get install -y \
    libgdal1-dev \
    nginx-full \
    python3 \
    python3-cairo-dev \
    python3.5 \
    ipython3-notebook \
    liblas-dev \
    libgfortran3 \
    liblapack-dev \
    gdal-bin \
    python-gdal \
    python3-gdal \
    exiftool \
    python-pip \
    python3-pip \
    python3-numpy \
    python3-tk \
    python-numpy \
    virtualenv \
    iftop \
    emacs \
    libfreetype6-dev \
    htop \
    ethstatus \
    python-tk \
    postgresql-client \
    libffi-dev \
    daemon \
    file \
    sudo \
    jq \
    less \
    manpages \
    man \
    vim \
    zip

# create some directories that we may expect to exist
RUN mkdir -p /opt/kairos \
  && mkdir -p /opt/kairos/etc \
  && mkdir -p /opt/kairos/log \
  && mkdir -p /opt/kairos/sbin \
  && mkdir -p /opt/kairos/bin \
  && mkdir -p /opt/kairos/config \
  && mkdir -p /opt/kairos/lib \
  && mkdir -p /opt/kairos/build-home

# install Spark
ENV SPARK_DIST spark-2.0.2-bin-hadoop2.7
ENV SPARK_ARCHIVE ${SPARK_DIST}.tgz
ENV SPARK_DOWNLOAD_URL https://d3kbcqa49mib13.cloudfront.net/${SPARK_ARCHIVE}
ENV SPARK_HOME /opt/kairos/lib/spark


RUN wget -q $SPARK_DOWNLOAD_URL -O $SPARK_ARCHIVE && \
    cat $SPARK_ARCHIVE | (cd /opt/kairos/lib ; tar xzvf -) && \
    mv /opt/kairos/lib/${SPARK_DIST} /opt/kairos/lib/spark

# add Spark to the python path - this exact path changes with each Spark version
ENV PYTHON_PATH ${SPARK_HOME}/python/lib/py4j-0.10.3-src.zip:${SPARK_HOME}/python/

RUN apt-get -y remove virtualenv && pip2 install virtualenv

# create an empty python virtual env for the build
RUN virtualenv -p `which python3` --prompt="(kairos-python3)" /opt/kairos/venv

RUN . /opt/kairos/venv/bin/activate \
  && pip install --upgrade pip setuptools twine wheel coverage credstash \
  && deactivate

RUN . /opt/kairos/venv/bin/activate \
  && pip install awscli \
  && aws configure set default.s3.signature_version s3v4

COPY build_bin/ /opt/kairos/bin
RUN chmod -R 755 /opt/kairos/bin
ENV PATH /opt/kairos/bin:$PATH
ENV KAIROS_VENV /opt/kairos/venv

COPY root.bashrc /root/.bashrc
COPY root.bashrc /opt/kairos/config/bashrc
RUN chmod -R 755 /opt/kairos/config
WORKDIR /opt/kairos/build-home

ENTRYPOINT /bin/bash
