#!/bin/bash
set -o errexit

on_die() {
    echo "kill [$name] at $(date +'%F %T %Z')" >>/tmp/ffmpeg-dash.log
    pkill -KILL -P $$
    # 仅清理文件不清理目录
    rm -rf $outputDir/*/*
}

trap 'on_die' TERM

name="$1"
echo "start [$name] at $(date +'%F %T %Z')" >>/tmp/ffmpeg-dash.log

outputDir="/tmp/ffmpeg-dash/$name"
rm -rf "$outputDir"
mkdir -p "$outputDir"

{% if LIVE_FFMPEG_DASH_OPTIONS is defined %}
{% for opts in LIVE_FFMPEG_DASH_OPTIONS %}
{% if opts == '@deprecated' %}
# generate {{ '%03d' % loop.index }} is deprecated
{% else %}
outputSubDir="$outputDir/{{ '%03d' % loop.index }}"
mkdir -p "$outputSubDir"
ffmpeg -i "rtmp://localhost:{{LIVE_RTMP_PORT}}/live/$name" -f dash {{ opts }} "$outputSubDir/manifest.mpd" >$outputSubDir/ffmpeg.log 2>&1 &
{% endif %}
{% endfor %}
{% endif %}
wait
