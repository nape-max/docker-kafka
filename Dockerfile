FROM alpine AS builder

ARG KAFKA_VERSION=2.13-3.3.1

RUN apk add curl

WORKDIR /kafka-source

RUN curl https://archive.apache.org/dist/kafka/3.3.1/kafka_$KAFKA_VERSION.tgz --output kafka_$KAFKA_VERSION.tgz

RUN tar -xzf kafka_$KAFKA_VERSION.tgz

WORKDIR /kafka-source/kafka_$KAFKA_VERSION

FROM alpine

ARG KAFKA_VERSION=2.13-3.3.1

RUN apk add openjdk11 bash openrc

WORKDIR /kafka

COPY --from=builder /kafka-source/kafka_$KAFKA_VERSION .

COPY ./zookeeper /etc/init.d/zookeeper
COPY ./kafka /etc/init.d/kafka

RUN mkdir -p /run/openrc
RUN touch /run/openrc/softlevel

RUN chmod ugo+x /etc/init.d/zookeeper
RUN chmod ugo+x /etc/init.d/kafka

RUN rc-update add zookeeper
RUN rc-update add kafka

#RUN rc-status

#RUN rc-service zookeeper start
#RUN rc-service kafka start

RUN rc-status

#CMD ["/bin/bash", "-c", "bin/zookeeper-server-start.sh config/zookeeper.properties", "&", "bin/kafka-server-start.sh config/server.properties"]

ENV START_KAFKA_COMMAND="rc-service zookeeper start && rc-service kafka start"
ENV ZOOKEEPER_LOG_FILE="/var/log/zookeeper.log"
ENV KAFKA_LOG_FILE="/var/log/kafka.log"

CMD /bin/bash -c "${START_KAFKA_COMMAND} && tail -f $ZOOKEEPER_LOG_FILE $KAFKA_LOG_FILE"