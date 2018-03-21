#!/bin/bash

confluent destroy
jps | grep KafkaMusicExampleDriver | awk '{print $1;}' | xargs kill -9

echo "auto.offset.reset=earliest" >> $CONFLUENT_HOME/etc/ksql/ksql-server.properties
confluent start ksql-server

#mvn clean package -DskipTests
java -cp target/kafka-streams-examples-4.0.0-standalone.jar io.confluent.examples.streams.interactivequeries.kafkamusic.KafkaMusicExampleDriver &>/dev/null &

echo -e "\n\nksql http://localhost:8088"
