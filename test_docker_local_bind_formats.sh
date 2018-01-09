#!/bin/sh

opts="/d/test '/d/test' //d/test '//d/test' D:/test 'D:/test' D:\test 'D:\test' d:/test 'd:/test' d:\test 'd:\test'"

echo "Without setting MSYS2_ARG_CONV_EXCL"

for j in 0 1; do
  for i in $opts; do
    echo "$i"
    docker run --rm -v "$i":/test alpine ls -R test
    echo ""
    docker run --rm -v "$i"://test alpine ls -R test
    echo ""
    echo ""
  done
  export MSYS2_ARG_CONV_EXCL='*'
  echo "After setting MSYS2_ARG_CONV_EXCL"
done
