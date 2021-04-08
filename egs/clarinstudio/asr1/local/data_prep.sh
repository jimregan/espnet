#!/bin/bash

# Copyright 2020 Jim O'Regan
#  Apache 2.0  (http://www.apache.org/licenses/LICENSE-2.0)

if [ $# -ne 2 ]; then
  echo "Usage: $0 <data-base> <download-base>"
  exit 0;
fi

data=$1
download=$2

if [ ! -d $download/audio ]; then
    echo "$download directory does not contain audio/ directory"
    exit 0;
fi

if [ ! -d $data ]; then
    mkdir $data
fi

for i in train test dev; do
    mkdir $data/$i
done

for i in train test dev; do
    cat local/$i.sessions|while read j; do
        spk=$(cat $download/audio/$j/spk.txt|sed -e 's/^\xEF\xBB\xBF//')
        for k in $download/audio/$j/*.wav; do
            base=$(basename $k '.wav')
            id=${j}_${base}
            echo "$id $k" >> $data/$i/wav.scp
            txtfile=$(echo $k|sed -e 's/\.wav$/.txt/')
            text=$(cat $txtfile|sed -e 's/^\xEF\xBB\xBF//')
            echo "$id $text" >> $data/$i/text
            echo "$id $spk" >> $data/$i/utt2spk
        done
    done
    perl utils/utt2spk_to_spk2utt.pl $data/$i/utt2spk > $data/$i/spk2utt
done
