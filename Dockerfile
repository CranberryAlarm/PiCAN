FROM python:3.9-buster

WORKDIR /app

# Apt-get stuff.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    can-utils && \
    rm -rf /var/lib/apt/lists/*

# Set up the application, building the dependencies before copying source code,
# to maximize Docker layer caching
COPY requirements.txt ./
RUN pip3 install -r requirements.txt

# RUN modprobe vcan
# ip link add dev vcan0 type vcan
# ip link set vcan0 up

# Set up the entrypoint script
# COPY docker-entry.sh .
# ENTRYPOINT ["/app/docker-entry.sh"]
