#!/bin/bash

if [[ -z "$CONFLUENT_HOME" ]]; then
  echo "\$CONFLUENT_HOME is not defined. Run 'export CONFLUENT_HOME=/path/to/download' and try again"
  exit 1
fi

if [[ $(type confluent 2>&1) =~ "not found" ]]; then
  echo "'confluent' is not found. Run 'export PATH=\${CONFLUENT_HOME}/bin:\${PATH}' and try again"
  exit 1
fi

./scripts/stop-cli.sh

[[ -d $CONFLUENT_HOME/ui ]] || mkdir -p "$CONFLUENT_HOME/ui"
[[ -f "$CONFLUENT_HOME/ui/ksql-experimental-ui-0.1.war" ]] || wget --directory-prefix="$CONFLUENT_HOME/ui" https://s3.amazonaws.com/ksql-experimental-ui/ksql-experimental-ui-0.1.war

echo "auto.offset.reset=earliest" >> $CONFLUENT_HOME/etc/ksql/ksql-server.properties
confluent start ksql-server

mvn clean package -DskipTests
sleep 10

java -cp target/kafka-streams-examples-4.0.0-standalone.jar io.confluent.examples.streams.interactivequeries.kafkamusic.KafkaMusicExampleDriver &>/dev/null &

ksql http://localhost:8088 <<EOF
run script 'scripts/ksql.commands';
exit ;
EOF
sleep 5

cat <<EOF

=====================================================
KSQL UI: http://localhost:8088/index.html
EOF
