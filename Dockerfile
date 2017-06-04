FROM buildpack-deps:xenial-scm
SHELL ["/bin/bash", "-e", "-c"]

# install some apt tools
RUN apt-get update && apt-get install -y software-properties-common python-software-properties \
    apt-transport-https unzip vim

# install docker
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
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
    jq

# create some directories that we may expect to exist
RUN mkdir -p /opt/kairos \
  && mkdir -p /opt/kairos/etc \
  && mkdir -p /opt/kairos/log \
  && mkdir -p /opt/kairos/sbin \
  && mkdir -p /opt/kairos/bin \
  && mkdir -p /opt/kairos/build-home

# create an empty python virtual env for the build
RUN virtualenv -p `which python3` --prompt="(kairos-python3)" /opt/kairos/venv

RUN . /opt/kairos/venv/bin/activate \
  && pip install --upgrade pip setuptools twine wheel coverage credstash\
  && deactivate

COPY build_bin/ /opt/kairos/bin
RUN chmod -R 755 /opt/kairos/bin
ENV PATH /opt/kairos/bin:$PATH
ENV KAIROS_VENV /opt/kairos/venv
WORKDIR /opt/kairos/build-home

ENTRYPOINT  . $(which kairos_env_init) && /bin/bash
