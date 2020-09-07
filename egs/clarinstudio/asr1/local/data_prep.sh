#!/bin/bash

# Copyright 2020 Jim O'Regan
#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

if [ $# -ne 1 ]; then
  echo "Usage: $0 <data-base>"
  exit 0;
fi

data=$1

if [ ! -d $data/audio ]; then
    echo "$data directory does not contain audio/ directory"
    exit 0;
fi

for i in train test dev; do
    mkdir $data/$i
done

for i in train test dev; do
    cat local/$i.sessions|while read j; do
        spk=$(cat $data/audio/$j/spk.txt|sed -e 's/^\xEF\xBB\xBF//')
        for k in $data/audio/$j/*.wav; do
            base=$(basename $k '.wav')
            id=${j}_${base}
            echo "$id $k" >> $data/$i/wav.scp
            txtfile=$(echo $k|sed -e 's/\.wav$/.txt/')
            text=$(cat $txtfile|sed -e 's/^\xEF\xBB\xBF//')
            echo "$id $text" >> $data/$i/text
            echo "$id $spk" >> $data/$i/utt2spk
        done
    done
done