#!/bin/bash

# how?xD:     90% stolen from https://github.com/kaihendry/graphsloc
# Dependency: gnuplot, git
# Usage:      make sure to be at the top of the git project

gitrepo=$(pwd)


# https://github.com/fearside/ProgressBar/blob/master/progressbar.sh
ProgressBar() {
_progress=$((($1*100/$2*100)/100))
_done=$((_progress*4/10))
_left=$((40-_done))
# Build progressbar string lengths
_done=$(printf "%${_done}s")
_left=$(printf "%${_left}s")
printf "\rProgress : [${_done// /#}${_left// /-}] ${_progress}%%"
}

fn=$(basename "$gitrepo")-$(git --git-dir=$gitrepo/.git describe --always).csv


mapfile -t revs < <(git --git-dir=$gitrepo/.git rev-list master)
len=${#revs[@]}
echo $len git commits
total=0

for (( i=$len -1; i >= 0; i-- ));
do
	set -- $(git --git-dir=$gitrepo/.git show --numstat --format="%ct" ${revs[$i]} |awk 'NR==1{print;next} NF==3 {plus+=$1; minus+=$2} END {print(plus-minus)}')
	time=$1
	count=$2
	#echo $time $count
	total=$((total + count))
	#echo Total $total
	echo $time $total >> $fn
	ProgressBar $((len-i)) $len
done

echo "lol"

gnuplot -p <<- EOF
set title "$1 "
set xdata time
set xtics rotate by 45 right
set timefmt "%s"
set format y '%.0s %c'
set ylabel "Source lines of code"
unset key
set tic scale 0
set grid ytics
set format x '%Y-%m-%d'
set bmargin at screen 0.2
plot "$fn" u 1:2 w lines
EOF


# cleaning csv
rm $fn
