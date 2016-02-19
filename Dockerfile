#
# ElasticSearch Dockerfile
#
# https://github.com/dockerfile/elasticsearch
# using version 1.4.2 with head plugin
 
# Pull base image.
FROM java:7u79-jre

ENV ES_VERSION 1.7.3
ENV ES_DIR /elasticsearch
 
# Install ElasticSearch.
RUN wget -q https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-$ES_VERSION.tar.gz -O - | tar zxvf - && \
    mv elasticsearch-$ES_VERSION $ES_DIR && \
    rm $ES_DIR/lib/sigar/*freebsd* && \
    rm $ES_DIR/lib/sigar/*macosx* && \
    rm $ES_DIR/lib/sigar/*solaris* && \
    rm $ES_DIR/lib/sigar/*winnt* && \
    rm $ES_DIR/bin/*.exe

# ------------------------------------------------------- #
#                                                         #
#                        Pipework                         #
#                                                         #
# ------------------------------------------------------- #

RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/jpetazzo/pipework.git /opt/pipework

ADD run.sh $ES_DIR/run.sh

RUN chmod +x $ES_DIR/run.sh

# Define mountable directories.
VOLUME ["/elasticsearch/data", "/logs"]

# Define working directory.
WORKDIR /elasticsearch

RUN \
  /elasticsearch/bin/plugin -install mobz/elasticsearch-head

RUN /elasticsearch/bin/plugin -install elasticsearch/elasticsearch-cloud-gce/2.7.0

EXPOSE 9200 9300

# Define default command.
CMD ["./run.sh"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
