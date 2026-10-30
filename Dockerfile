# Filename: C++ Dockerfile / Blueprint
FROM ubuntu:24.04

# Create a working project directory
WORKDIR /usr/src/app/cpp

# Install gcc (C compiler, it is what g++ is built on so its a dependency)
# Install g++ (C++ compiler to translate .cpp source into machine code)
# Install make (A build tool to read makefiles and recompile on what changes have occured since the last build)
# build-essentiall installs the entire tool chain
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        gdb \
    && rm -rf /var/lib/apt/lists/*