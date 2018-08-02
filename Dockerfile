FROM ubuntu:14.04
#FROM golang:1.10
# test ZoKRate building...

MAINTAINER JacobEberhardt <jacob.eberhardt@tu-berlin.de>, Dennis Kuhnert <mail@kyroy.com>

ARG RUST_TOOLCHAIN=nightly-2018-06-04
ARG LIBSNARK_COMMIT=f7c87b88744ecfd008126d415494d9b34c4c1b20
ENV LIBSNARK_SOURCE_PATH=/root/libsnark-$LIBSNARK_COMMIT

WORKDIR /root/

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    libboost-all-dev \
    libgmp3-dev \
    libprocps3-dev \
    libssl-dev \
    pkg-config \
    python-markdown \
    git

RUN curl https://sh.rustup.rs -sSf | \
    sh -s -- --default-toolchain $RUST_TOOLCHAIN -y

ENV PATH=/root/.cargo/bin:$PATH

RUN git clone https://github.com/scipr-lab/libsnark.git $LIBSNARK_SOURCE_PATH
WORKDIR $LIBSNARK_SOURCE_PATH
RUN git checkout $LIBSNARK_COMMIT
RUN git submodule update --init --recursive

WORKDIR /root/

COPY . ZoKrates

RUN cd ZoKrates \
    && cargo build --release
    
#-------Extra Added----------------    

RUN apt-get update && apt-get install -y vim \
    && apt-get install -y tree
    
COPY vimrc /root/.vimrc
#-------solidity syntax highlightning----
RUN mkdir -p /root/.vim/bundle \
    && git clone https://github.com/tomlion/vim-solidity.git /root/.vim/bundle/vim-solidity \
    && cp -r /root/.vim/bundle/vim-solidity/* /root/.vim/

# RUN mkdir -p /root/multiSigWallet \
#  && cd /root/multiSigWallet \
#  && git clone https://github.com/gnosis/MultiSigWallet.git

#------ install Golang 1.8.x ----------
RUN mkdir -p /root/go-setup \
    && cd /root/go-setup/ 
    # && wget https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz \
ADD https://storage.googleapis.com/golang/go1.8.3.linux-amd64.tar.gz /root/go-setup/
RUN cd /root/go-setup \
    && tar -xvf go1.8.3.linux-amd64.tar.gz \
    && mv go /usr/local \
    && mkdir /go

#set golang environment variables
ENV GOROOT /usr/local/go  
ENV GOPATH /go
#ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH
ENV PATH $GOPATH/bin:$GOROOT/bin:/root/ZoKrates/target/release:$PATH

# set go vim syntax highlightning  
# RUN wget https://storage.googleapis.com/golang/go1.3.3.src.tar.gz \
ADD https://storage.googleapis.com/golang/go1.3.3.src.tar.gz /root/go-setup/ 
RUN cd /root/go-setup \
    && tar -zxvf go1.3.3.src.tar.gz \
    && cp -r go/misc/vim/syntax/ go/misc/vim/ftplugin/ go/misc/vim/indent/ go/misc/vim/compiler/ go/misc/vim/ftdetect/ /usr/share/vim/vim74/ 

WORKDIR /root/
