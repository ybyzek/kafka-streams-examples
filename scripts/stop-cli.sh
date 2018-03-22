#!/bin/bash

jps | grep KafkaMusicExampleDriver | awk '{print $1;}' | xargs kill -9
confluent destroy
rm -fr /tmp/kafka-streams
