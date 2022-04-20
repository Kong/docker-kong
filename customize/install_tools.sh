#!/bin/bash

if command -v apk &> /dev/null
then
    apk add unzip wget curl
fi

if command -v apt &> /dev/null
then
    apt-get update && apt-get install -y unzip wget curl
fi

if command -v yum &> /dev/null
then
    yum install -y unzip wget curl
fi
