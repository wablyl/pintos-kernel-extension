FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and QEMU
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    gcc-multilib \
    make \
    perl \
    qemu-system-x86 \
    gdb \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set up working directory
WORKDIR /pintos

# Copy source tree
COPY src/ /pintos/src/

# Add pintos utilities to PATH
ENV PATH="/pintos/src/utils:${PATH}"

# Build squish-pty and squish-unix (needed by pintos test harness)
RUN cd /pintos/src/utils && \
    gcc -o squish-pty squish-pty.c && \
    gcc -o squish-unix squish-unix.c

# Verify tools
RUN command -v qemu-system-i386 && \
    command -v gcc && \
    echo "All tools verified."

# Default to bash
CMD ["/bin/bash"]
