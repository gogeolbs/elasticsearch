#
# ElasticSearch Dockerfile
#
# https://github.com/dockerfile/elasticsearch
# using version 1.4.2 with head plugin
 
# Pull base image.
FROM dockerfile/java

ENV ES_VERSION 1.4.2
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

RUN git clone http://github.com/jpetazzo/pipework /opt/pipework


ADD run.sh $ES_DIR/run.sh

RUN chmod +x $ES_DIR/run.sh

# Define mountable directories.
VOLUME ["/elasticsearch/data", "/logs"]

# Define working directory.
WORKDIR /elasticsearch

RUN \
  /elasticsearch/bin/plugin -install mobz/elasticsearch-head

EXPOSE 9200 9300

# Define default command.
CMD ["./run.sh"]

# Expose ports.
#   - 9200: HTTP
#   - 9300: transport
