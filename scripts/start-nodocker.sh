#!/bin/bash

confluent destroy
jps | grep KafkaMusicExampleDriver | awk '{print $1;}' | xargs kill -9

[[ -d $CONFLUENT_HOME/ui ]] || mkdir -p "$CONFLUENT_HOME/ui"
[[ -f "$CONFLUENT_HOME/ui/ksql-experimental-ui-0.1.war" ]] || wget --directory-prefix="$CONFLUENT_HOME/ui" https://s3.amazonaws.com/ksql-experimental-ui/ksql-experimental-ui-0.1.war

echo "auto.offset.reset=earliest" >> $CONFLUENT_HOME/etc/ksql/ksql-server.properties
echo "ksql.ui.enabled=false" >> $CONFLUENT_HOME/etc/ksql/ksql-server.properties
confluent start ksql-server

#mvn clean package -DskipTests
java -cp target/kafka-streams-examples-4.0.0-standalone.jar io.confluent.examples.streams.interactivequeries.kafkamusic.KafkaMusicExampleDriver &>/dev/null &

echo -e "\n\nksql http://localhost:8088"
