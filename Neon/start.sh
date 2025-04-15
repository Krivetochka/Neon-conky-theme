#!/bin/bash

killall conky
sleep 1s
		
conky -c $PWD/conky_neon.conf &> /dev/null &

exit
