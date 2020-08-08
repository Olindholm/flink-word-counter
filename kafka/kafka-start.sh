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

# Logging
logfile="./logs/kafka_$(date +'%Y-%m-%d_%H:%M:%S').log"

# 
pidsCount=`ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | wc -l`

if [ $pidsCount -gt 0 ]; then
	pids=`ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print$1}'`
	echo "Kafka already running on pid(s) [${pids//$'\n'/, }]"
else
	# Create logdir if non-existant
	(mkdir -p "$(dirname '$logfile')" && touch "$logfile") > /dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo "Bad log file! '$logfile' is not allowed!"
		exit 1
	fi

	(nohup ./$kafka/bin/kafka-server-start.sh ./kafka.properties > "$logfile" 2>&1) &
	pid=$!

	echo -n "Attempting to start Kafka on pid [$pid] ..."
	for i in {1..10}; do
		running=`ps ax | grep $pid | grep -v grep | wc -l`

		if [ $running -eq 0 ]; then
			echo -n " "
			echo "Failed to start Kafka!"
			echo ""
			tail -n 30 "$logfile"
			echo ""
			echo "See full log at '$logfile'"
			exit 1
		fi

		sleep 1
		echo -n "."
	done

	echo -n " "
	echo "Success!"
fi

