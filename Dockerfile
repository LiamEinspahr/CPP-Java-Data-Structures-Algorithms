# Filename: C++ Dockerfile / Blueprint
# ===STAGE: os===
FROM ubuntu:24.04 as os 

FROM os as create-working-dir
# Create a working project directory
WORKDIR /usr/src/app/cpp

# Install gcc (C compiler, it is what g++ is built on so its a dependency)
# Install g++ (C++ compiler to translate .cpp source into machine code)
# Install make (A build tool to read makefiles and recompile on what changes have occured since the last build)

# \ is used as a line continuation character — to break a single line into readable segments
    # without \ it looks like this:
    # RUN apt-get update && apt-get install -y --no-install-recommends build-essential gdb && rm -rf /var/lib/apt/lists/*
# && is used to tell the instruction: "Only run the next thing if the previous thing succeeds"

FROM create-working-dir AS os-update-install-requirements
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    # after updating, run the installs
    && apt-get install -y --no-install-recommends \
    # meta-build tool for c++ compiling
    cmake \
    # build-essential installs the entire tool chain
    build-essential \
    # used to debug c++ code
    gdb \
    # used to create tests for C++ code
    libgtest-dev \
    # library for compiling and running java --headless to drop the GUI libraries
    openjdk-21-jdk-headless \
    # build tool and dependency manager
    maven \
    # https certs for maven
    ca-certificates \
    # deletes the cached package index files downloaded by apt-get update, reducing your Docker image size once package installation succeeds.
    && rm -rf /var/lib/apt/lists/*
