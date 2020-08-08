# /bin/bash

signal=""
terminate="terminate"
terminating="Terminating"
terminated="terminated"
killtip="You might want to try stopping with -kill to terminate non-gracefully."

if [ $# -eq 1 ] && ([ $1 == "-k" ] || [ $1 == "-kill" ]); then
	signal="-9"
	terminate="kill"
	terminating="Killing"
	terminated="Killed"
	killtip=""
elif [ $# -eq 0 ]; then
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
pidsCount=`ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | wc -l`

if [ $pidsCount -eq 0 ]; then
	echo "Kafka is not running."
else
	pids=`ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print$1}'`
	kill $signal $pids	

	echo -n "$terminating Kafka on pid(s) [${pids//$'\n'/, }] ..."
	for i in {1..60}; do
		for pid in $pids; do
			running=`ps ax | grep $pid | grep -v grep | wc -l`

			if [ $running -eq 0 ]; then
				echo -en "\nKafka on pid [$pid] $terminated."
				pids=`grep -v $pid <<< $pids`
			fi
		done

		if [ "$pids" == "" ]; then
			echo ""
			exit 0
		fi

		sleep 1
		echo -n "."
	done


	echo -e "\nFailed to $terminate pid(s) on [${pids//$'\n'/, }]. $killtip"
	exit 1
fi

