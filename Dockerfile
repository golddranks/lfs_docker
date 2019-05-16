# Docked Linux From Scratch - a host environment for bootsrapping in Docker
# By Pyry Kontio
# MIT licensed
#
# This dockerfile is inspired by the Linux From Scratch website:
# http://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html
#
# And this docker image that automatically builds an ISO image for LFS:
# https://github.com/reinterpretcat/lfs/


from debian:stretch


# Install the packages for the host system required to build LFS.
# The host system requirements are listed here:
# http://www.linuxfromscratch.org/lfs/view/stable/chapter02/hostreqs.html

RUN apt-get update && apt-get install -y \
    build-essential                      \
    bison                                \
    gawk                                 \
    texinfo                              \
    wget                                 \
    sudo                                 \
    python3                              \
 && apt-get -q -y autoremove             \
 && rm -rf /var/lib/apt/lists/*


# The debian default shell points to dash,
# but LFS supports officially bash, so reset it.

RUN rm /bin/sh && ln -s /bin/bash /bin/sh


# Set the LFS variable that points to the LFS filesystem mount point as described here:
# http://www.linuxfromscratch.org/lfs/view/stable/chapter02/aboutlfs.html

ENV LFS /mnt/lfs


# Create the mount point itself.

RUN mkdir -pv $LFS


# Set a working directory to save the scripts into.

WORKDIR /workdir

# Copy the scripts inside the docker.

COPY *.sh /workdir/


# Run the docker image with commands:
# docker build --tag lfs .
# docker run -it --privileged lfs
#
# The --privileged flag is needed for mount to work inside the container
#
# After starting the container, you can check that the host system is all
# right by running the version-check.sh script.
#
# Next, run init-filesystem.sh to configure the temporary system
# for building LFS.

ENTRYPOINT /bin/bash
