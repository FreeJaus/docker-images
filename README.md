This repository contains Dockerfiles, build scripts and deploy scripts related to the Docker images which are used in
FreeJaus projects. Docker [multi-stage](https://docs.docker.com/engine/userguide/eng-image/multistage-build/) builds are
used to group multiple related image descriptions in a single file. In order to automate build, push and run processes,
auxiliary shell scripts are provided.


# Use an image

All of the images available at [hub.docker.com/u/freejaus](https://hub.docker.com/u/freejaus/) are ready to use. Some of
them do not require any graphical interface, others do. In the latter, an auxiliary script is provided, [`run_guiapp.sh`](https://github.com/FreeJaus/docker-images/blob/master/run_guiapp.sh),
which sets `DISPLAY` variables in order to allow the container to communicate with an X server running on the host.

E.g., execute FreeCAD and bind the current path as `/src` inside the container with:

``` shell
run_guiapp.sh -v '$(wd)':/src freejaus/cad:freecad sh -c freecad
```

NOTE: if the required image is not available locally, it will be downloaded automatically. In order to ensure that the latest version of the image is being used, execute `docker pull freejaus/<repo:tag>` prior to using it.

NOTE: GNU/Linux platforms default to having a X window server, and the script will work without additional dependencies. However, in order to use GUI apps (such as FreeCAD, OpenSCAD, Blender...) on Windows, you need to install an X server. See [GUI docker apps on Windows](#gui-docker-apps-on-windows) below.

NOTE: `wd` is a workaround that replaces `pwd` to provide consistent behaviour in different platforms. It can be directly replaced with `pwd` on GNU/Linux. See [docker/for-win#1509](https://github.com/docker/for-win/issues/1509).


# Build and push a group of images

Instead of pulling images from the registry, you might want to build your own modified versions. In order to do so, just edit the corresponding `Dockerfile` and use [`build_images.sh`](https://github.com/FreeJaus/docker-images/blob/master/build_images.sh):

E.g., in order to build `freejaus/cad:openscad`, `freejaus/cad:freecad-base` and `freejaus/cad:freecad` at once, execute:

``` shell
build_images.sh dockerfiles/Dockerfile-cad
```

Then, you can use them either directly or with [`run_guiapp.sh`](https://github.com/FreeJaus/docker-images/blob/master/run_guiapp.sh) (as explained [above](#use-an-image)).

NOTE: [`build_images.sh`](https://github.com/FreeJaus/docker-images/blob/master/build_images.sh) can take multiple Dockerfiles as arguments, and all of them will be processed sequentially.

---

Shall you have write access to the corresponding registry repo, you can push all of them with:

``` shell
push_images.sh dockerfiles/Dockerfile-cad
```

NOTE: [`push_images.sh`](https://github.com/FreeJaus/docker-images/blob/master/push_images.sh) can take multiple Dockerfiles as arguments or a single `all`. The latter will push every `freejaus/*` image which is locally available but not found at [hub.docker.com/u/freejaus](https://hub.docker.com/u/freejaus/).


# GUI docker apps on Windows

When GUIs are to be used, an X display server is required. There are several approaches to allow so, such as using [VNC](https://en.wikipedia.org/wiki/Virtual_Network_Computing) or [SSH](https://en.wikipedia.org/wiki/Secure_Shell). However, sharing an [X server](https://en.wikipedia.org/wiki/X_Window_System) running on the host is the most straightforward solution.

The provided script ([`run_guiapp.sh`](https://github.com/FreeJaus/docker-images/blob/master/run_guiapp.sh)) expects
[Xming](https://sourceforge.net/projects/xming/) to be available at `XMING_PATH="/c/Program\ Files\ \(x86\)/Xming/Xming.exe"`,
which is the path format used in [MinGW-64](https://mingw-w64.org/doku.php) ([MSYS2](http://www.msys2.org/)). Shall it
be installed anywhere else, shall a different shell be used (say PowerShell or Cygwin), or shall a different X server be used (say
[vcxsrv](https://sourceforge.net/projects/vcxsrv)), adapt the script accordingly.

NOTE: [Docker](https://www.docker.com/) and [Xming](https://sourceforge.net/projects/xming/) are available through [chocolatey](https://chocolatey.org/).

---

Alternatively, you can skip [`run_guiapp.sh`](https://github.com/FreeJaus/docker-images/blob/master/run_guiapp.sh) and set display related parameters on your own. These are the steps to manually start an instance of [Xming](https://sourceforge.net/projects/xming/) and run a container which uses it:

- Ensure that docker binaries are in the PATH. If not, add them:

```
export PATH=$PATH:/c/Program\ Files/Docker/Docker/resources/bin
```

- Run the X server, with the following options:

```
XMing -ac -multiwindow -clipboard
```

- Now you can run any docker container setting the envvar `DISPLAY` to `<localIP>:<display>`. For example:

```
$(command -v winpty) docker run --rm -it -e DISPLAY=10.0.75.1:0 freejaus/cad:openscad
```

The example above corresponds to `Ethernet adapter vEthernet (DockerNAT)`, but any others such as `192.168.1.?` should also work. You can get the IP with `ipconfig`:

```
ipconfig | grep 'IPv4' | grep -o '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'
```

To take the first one:

```
$(command -v winpty) docker run --rm -it -e DISPLAY=$(ipconfig | grep 'IPv4' | grep -o -m 1 -h '[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*'):0 freejaus/cad:openscad
```

NOTE: [Issue](https://github.com/docker/docker/issues/12469) when using -it on windows, solution: prepend `winpty`.
