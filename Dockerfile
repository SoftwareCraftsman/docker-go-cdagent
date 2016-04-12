FROM buildpack-deps:trusty-curl
MAINTAINER Software Craftsmen GmbH und CoKG <office@software-craftsmen.at>

# The go.cd package pulls in openjdk-7

RUN apt-get update && \
    echo "deb https://download.go.cd /" | sudo tee /etc/apt/sources.list.d/gocd.list && \
    apt-get install -y apt-transport-https python-software-properties software-properties-common && \
    wget -O - https://download.go.cd/GOCD-GPG-KEY.asc | sudo apt-key add - && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && \
    apt-get install -y go-agent git openjdk-8-jdk && \
    update-ca-certificates -f && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sed -i 's/DAEMON=Y/DAEMON=N/' /etc/default/go-agent

ADD docker-entrypoint.sh docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh
# Required for openjdk-8

# directory for placing go agent resource related configuration
RUN mkdir -p /var/go/.resources
RUN chown go:go /var/go/.resources
VOLUME /var/go/.resources

CMD ./docker-entrypoint.sh
