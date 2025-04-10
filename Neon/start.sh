#!/bin/bash

killall conky
sleep 1s
		
conky -c ~/.config/conky/Neon/conky_neon.conf &> /dev/null &

exit
