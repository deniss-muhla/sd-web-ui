ARG UBUNTU_VERSION=22.04

FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu${UBUNTU_VERSION} as base
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},display

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
        mesa-utils \
        build-essential \
        sudo \
        cmake \
        libgtk2.0-dev \
        libgtk-3-dev \
        libavcodec-dev \
        libavformat-dev \
        libswscale-dev \
        libfreetype6-dev \
        libhdf5-serial-dev \
        unzip \
        zip \
        libzmq3-dev \
        libtbb2 \
        libtbb-dev \
        libjpeg-dev \
        libpng-dev \
        libtiff-dev \
        libeigen3-dev \
        libdc1394-dev \
        pkg-config \
        software-properties-common \
        unzip \
        zip \
        wget \
        git \
        vim \
        curl \
        libssl-dev \
        lldb \
        procps \
        lsb-release \
        x11-xserver-utils \
        libmagick++-dev \
        python3-dev \
        python3-tk \
        python3.10-venv

# I'm not sure about --allow-change-held-packages
RUN apt install -y --allow-change-held-packages libnccl2 \
        libnccl-dev \ 
        libyaml-dev

# GStreamer
RUN apt-get install -y --no-install-recommends \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-good1.0-dev \
    libgstreamer-plugins-bad1.0-dev \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    libgstrtspserver-1.0-dev \
    libgstreamer1.0-0 \
    gstreamer1.0-libav \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 \
    gstreamer1.0-pulseaudio \
    gtk-doc-tools
    
ARG USERNAME=dockeruser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && mkdir -p /home/$USERNAME/.vscode-server /home/$USERNAME/.vscode-server-insiders \
    && chown ${USER_UID}:${USER_GID} /home/$USERNAME/.vscode-server* \
    && chown ${USER_UID}:${USER_GID} /opt* \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && usermod -a -G audio,video $USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME
ENV HOME /home/$USERNAME
WORKDIR $HOME

# Pip from installation script to install the lastest version
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN sudo python3 get-pip.py

#Activate venv
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

#Pytorch
RUN pip install torch torchvision xformers triton

WORKDIR $HOME/kohya
COPY packages/kohya-webui/kohya/requirements.txt packages/kohya-webui/kohya/setup.py ./
RUN pip install --use-pep517 --upgrade -r requirements.txt

RUN accelerate config default --mixed_precision bf16

#source /opt/venv/bin/activate
#python3 ./kohya_gui.py
