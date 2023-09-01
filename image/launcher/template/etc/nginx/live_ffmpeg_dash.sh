#!/bin/bash
set -o errexit

on_die() {
    pkill -KILL -P $$
    rm -rf "$outputDir"
}

trap 'on_die' TERM

name="$1"
outputDir="/tmp/ffmpeg-dash/$name"
rm -rf "$outputDir"
mkdir -p "$outputDir"

{% if LIVE_FFMPEG_DASH_OPTS is defined %}
{% for opts in LIVE_FFMPEG_DASH_OPTS %}
mkdir -p "$outputDir/{{ '%03d' % loop.index }}"
ffmpeg -i "rtmp://localhost:{{LIVE_RTMP_PORT}}/live/$name" -f dash -extra_window_size 10 {{ opts }} "$outputDir/{{ '%03d' % loop.index }}/manifest.mpd" &
{% endfor %}
{% endif %}
wait
