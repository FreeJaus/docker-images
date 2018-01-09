#! /bin/sh

set -e

if [ $# -lt 1 ]; then
  echo "At least one argument is required, e.g.:"
  echo "$0 <Dockerfile> <Dockerfile> ...";
  exit 1
fi

for f in $@; do
  for tag in `sed -e 's/FROM.*AS do-//;tx;d;:x' $f`; do
    printf "\n[DOCKER build] ${tag}\n\n"
    docker build -t "freejaus/`echo $tag | sed -e 's/__/:/g'`" --target "do-$tag" - < "$f"
  done
done
