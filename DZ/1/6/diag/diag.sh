#!/bin/bash


f_word=$1

f_log=$2

diag_log=$3



for ((;;)) {

	tail -200 $f_log | grep $f_word >> $diag_log

	sleep 30
} 
