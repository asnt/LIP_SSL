FROM nvidia/cuda:7.5-cudnn4-devel-ubuntu14.04
LABEL maintainer https://github.com/asnt

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        wget \
        libatlas-base-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-serial-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libprotobuf-dev \
        libsnappy-dev \
        protobuf-compiler \
        libmatio-dev \
        python-dev \
        python-numpy \
        python-pip \
        python-setuptools \
        python-scipy \
   && rm -rf /var/lib/apt/lists/*

ENV LIPSSL_ROOT=/opt/lipssl
WORKDIR $LIPSSL_ROOT

RUN git clone -b custom-driver https://github.com/asnt/LIP_SSL . \
    && git config -f .gitmodules submodule.code.url ../caffe_ssl.git \
    && git submodule update --init --recursive

RUN cd code \
    && git checkout build-fixes
COPY FindMATIO.cmake code/cmake/Modules/

RUN pip install --upgrade pip \
    && cd code/python \
    && for req in $(cat requirements.txt) pydot; \
         do pip install $req; \
       done \
    && cd ../..

RUN cd code \
    && mkdir build \
    && cd build \
    && cmake -DUSE_CUDNN=1 .. \
    && make -j"$(nproc)" \
    && make install

ENV PYLIPSSL_ROOT $LIPSSL_ROOT/build/python
ENV PYTHONPATH $PYLIPSSL_ROOT:$PYTHONPATH
ENV PATH $LIPSSL_ROOT/build/tools:$PYLIPSSL_ROOT:$PATH
RUN echo "$LIPSSL_ROOT/build/lib" >> /etc/ld.so.conf.d/caffe.conf && ldconfig

COPY ../human/model/attention/test.caffemodel \
  human/model/attention/

WORKDIR $LIPSSL_ROOT
