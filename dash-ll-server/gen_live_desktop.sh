#!/bin/bash

SERVER="${1}"
PORT="${2}"
FF="${3}"
INPUT="/dev/video0"
INPUT_FPS="24"
ID=live
VCODEC=h264_vaapi
VCODEC=libx264
COLOR=bt709

if [ "$SERVER" == "" -o "$PORT" == "" ]
then
    echo "Usage: $0 <SERVER> <PORT> [<FFMPEG>]"
    exit
else
    if [ "$FF" == "" ]
    then
        FF=ffmpeg
    fi

    PROTO=http
    HTTP_OPTS=""

    echo "Ingesting to: ${PROTO}://${SERVER}:${PORT}/${ID}/${ID}.mpd"
fi

echo ${FF} -h all | grep ldash

${FF} \
-re -f x11grab -i ":0.0" \
-c:v ${VCODEC} \
-b:v:0 200K -b:v:1 1000K -s:v:0 640x360 -s:v:1 1280x720 \
-map 0:v:0 -map 0:v:0 \
-use_timeline 0 \
-use_template 1 \
-frag_type every_frame \
-adaptation_sets "id=0,seg_duration=10,streams=0,1" \
-g:v 15 -keyint_min:v 15 -sc_threshold:v 0 -streaming 1 -ldash 1 -tune zerolatency \
-color_primaries ${COLOR} -color_trc ${COLOR} -colorspace ${COLOR} \
-f dash \
${HTTP_OPTS} \
${PROTO}://${SERVER}:${PORT}/${ID}/${ID}.mpd \
${TS_OUT_CMD}

