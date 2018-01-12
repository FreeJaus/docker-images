#!/bin/sh

set -e

if [ "$OS" = "Windows_NT" ]; then
  [ "$XMING_PATH" = "" ]     &&     XMING_PATH="/c/Program\ Files\ \(x86\)/Xming/Xming.exe"
  [ "$DOCKER_DISPLAY" = "" ] && DOCKER_DISPLAY="`ipconfig | grep 'IPv4' | grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*' | grep "^10\.0\.*"`:0"
else
  [ "$DOCKER_DISPLAY" = "" ] && DOCKER_DISPLAY=unix$DISPLAY
fi

check_c() { r="1"; if [ -n "$(docker container inspect $1 2>&1 | grep "Error:")" ]; then r="0"; fi; echo "$r"; }
rm_c() {
  echo ""
  echo "Removing container $1"
  if [ "$(check_c $1)" = "1" ]; then docker rm -f "$1"; fi;
}

test_xdpyinfo() { docker run --rm -t $GUIAPP freejaus/xdpyinfo sh -c 'xdpyinfo'; }

echo "[DOCKER GUIAPP] Set envvars for X11"

XSOCK="//tmp/.X11-unix"
XAUTH="//tmp/.docker.xauth"
if [ -z "$DOCKER_DISPLAY" ]; then
  echo "[DOCKER GUIAPP] <DOCKER_DISPLAY> not set!"
  exit 1
fi
if [ `command -v xauth` ]; then
  xauth nlist "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge -
fi

GUIAPP="-v $XSOCK:$XSOCK -v $XAUTH:$XAUTH -e XAUTHORITY=$XAUTH -e DISPLAY=$DOCKER_DISPLAY"

if [ -z "$SKIP_DISP" ]; then
  if [ -z $(docker images -q freejaus/xdpyinfo 2> /dev/null) ]; then
    echo "[DOCKER GUIAPP] Build freejaus/xdpyinfo from alpine:latest"
    docker pull alpine:latest
    docker run --name xdpyinfo -t alpine:latest sh -c 'sed -i -e ''s/v[0-9]\.[0-9]/edge/g'' /etc/apk/repositories && apk add -U --no-cache xdpyinfo'
    docker commit xdpyinfo freejaus/xdpyinfo
    rm_c xdpyinfo
  fi

  echo "[DOCKER GUIAPP] Test freejaus/xdpyinfo"
  set +e
  xdpyinfo_resp=$(test_xdpyinfo)
  set -e
  if [ -z "$(echo \"$xdpyinfo_resp\" | grep 'unable')" ]; then
    echo "OK"
  else
    echo "$xdpyinfo_resp"
    echo "Can't connect to X server on $DOCKER_DISPLAY."
    if [ "$OS" = "Windows_NT" ]; then
      read -r -p "This is Windows. Do you want to init XMING? [y/n] " doxming
      case "$doxming" in
        [yY][eE][sS]|[yY])
          if [ -z "$XMING_PATH" ]; then
            echo "[DOCKER GUIAPP] <XMING_PATH> not set!"
            exit 1
          else
            eval "$XMING_PATH -ac -multiwindow -clipboard" 1> /tmp/xming_log.log 2>&1 &
                test_xdpyinfo
          fi
      ;;
      esac
    fi
  fi
fi

echo "[DOCKER GUIAPP] Run $(command -v winpty) docker run $GUIAPP $@"

$(command -v winpty) docker run $GUIAPP $@
