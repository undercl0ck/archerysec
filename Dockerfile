#Ubuntu base OS
FROM ubuntu:18.04
LABEL MAINTAINER="Anand Tiwari"

ENV DJANGO_SETTINGS_MODULE=archerysecurity.settings.base

# Update & Upgrade Ubuntu. Install packages
RUN \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --quiet --yes --fix-missing \
    make \
    default-jre \
    postgresql-client-10 \
    sslscan \
    nikto \
    nmap \
    python \
    wget \
    curl \
    unzip \
    git \
    python-pip \
    && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get autoremove --purge -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create archerysec user and group
RUN groupadd -r archerysec && useradd -r -m -g archerysec archerysec

# Set user to archerysec to execute rest of commands
USER archerysec

# Create archerysec folder.
RUN mkdir /home/archerysec/app

# Set archerysec as a work directory.
WORKDIR /home/archerysec/app

# Copy all file to archerysec folder.
COPY . .

RUN mkdir nikto_result

RUN wget https://github.com/zaproxy/zaproxy/releases/download/2.7.0/ZAP_2.7.0_Linux.tar.gz

RUN tar -xvzf ZAP_2.7.0_Linux.tar.gz

RUN mkdir zap

RUN cp -r ZAP_2.7.0/* /home/archerysec/app/zap

COPY zap_config/policies /home/archerysec/app/zap

COPY zap_config/ascanrulesBeta-beta-24.zap /home/archerysec/app/zap/plugin/ascanrulesBeta-beta-24.zap

RUN rm -rf ZAP_2.7.0_Linux.tar.gz && \
    rm -rf ZAP_2.7.0

# Install requirements
RUN pip install --no-cache-dir -r requirements.txt && \
    rm -rf /home/archerysec/.cache

# Exposing port.
EXPOSE 8000

# Include init script
ADD ./docker-files/init.sh /usr/local/bin/init.sh

# UP & RUN application.
CMD ["/usr/local/bin/init.sh"]
