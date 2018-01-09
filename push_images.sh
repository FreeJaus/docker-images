#! /bin/sh

set -e

if [ $# -lt 1 ]; then
  echo "At least one argument is required, e.g.:"
  echo "$0 <Dockerfile> <Dockerfile> ...";
  echo "$0 all";
  exit 1
fi

if [ "$1" = "all" ]; then
  for tag in `echo $(docker images freejaus/* | awk -F ' ' '{print $1 ":" $2}') | cut -d ' ' -f2-`; do
      if [ "$tag" = "REPOSITORY:TAG" ]; then break; fi
      t="`echo $tag | grep -oP 'btdi/\K.*'`"
      printf "\n[DOCKER push] ${tag}\n\n"
      docker push $tag
  done
else
  for f in $@; do
    for tag in `sed -e 's/FROM.*AS do-//;tx;d;:x' $f | sed -e 's/__/:/g'`; do
      printf "\n[DOCKER push] freejaus/${tag}\n\n"
      docker push "freejaus/$tag"
    done
  done
fi
