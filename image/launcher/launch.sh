#!/bin/sh
set -o errexit

work_dir="$(dirname $(readlink -f $0))"
cd "$work_dir"

echo "setup"
python3 "$work_dir/setup.py"

echo "launch"
exec "nginx" "-g" "daemon off;"
