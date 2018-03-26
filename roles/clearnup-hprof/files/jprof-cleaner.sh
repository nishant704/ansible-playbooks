#!/bin/bash
if [ -e /elasticsearch/log/java_pid* ]
then
	echo "File detected"
	sudo rm -rf /elasticsearch/log/java_pid*
	sudo service elasticsearch restart
else
	echo "No file detected"

fi
