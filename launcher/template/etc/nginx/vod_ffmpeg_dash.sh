#!/bin/bash
set -o errexit

name="$1"
file="$2"
if [ ! -f "$file" ]; then
    echo "file not found: $file"
    exit 1
fi

outputDir="/vod-res/ffmpeg-dash/$name"
rm -rf "$outputDir"
mkdir -p "$outputDir"

{% if VOD_FFMPEG_DASH_OPTIONS is defined %}
{% for opts in VOD_FFMPEG_DASH_OPTIONS %}
{% if opts == '@deprecated' %}
echo "generate {{ '%03d' % loop.index }} is deprecated"
{% else %}
echo "generate to $outputDir/{{ '%03d' % loop.index }}"
mkdir -p "$outputDir/{{ '%03d' % loop.index }}"
ffmpeg -i "$file" -f dash {{ opts }} "$outputDir/{{ '%03d' % loop.index }}/manifest.mpd"
{% endif %}
{% endfor %}
{% endif %}

echo "done"
