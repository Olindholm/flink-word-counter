# /bin/bash

if [ $# -eq 0 ]; then
	: # OK
else
	echo "Illegal input arguments!"
	exit 1
fi

# Make sure we're in workdir
cd $(dirname "$BASH_SOURCE")

# Get version
version=`cat version.txt`
kafka="kafka_$version"

#
installed=`ls | grep $kafka | wc -l`
if [ $installed -gt 0 ]; then
	echo "Kafka v. $version is already installed!"
	exit 0
fi

# This will ensure if any of sub-shells fail,
# this shell will fail too (thus not continue).
set -e

url="http://apache.mirrors.spacedump.net/kafka/$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' <<< $version)/kafka_$version.tgz"
wget $url

tar -xvf "kafka_$version.tgz"
rm "kafka_$version.tgz"

echo "Successfully installed at './kafka_$version'"

