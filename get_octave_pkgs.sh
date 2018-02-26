#! /bin/sh

if [ -d octave_pkgs ]; then rm -rf octave_pkgs; fi
mkdir -p octave_pkgs
cd octave_pkgs
wget -L https://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases/image-2.6.1.tar.gz
wget -L https://downloads.sourceforge.net/project/octave/Octave%20Forge%20Packages/Individual%20Package%20Releases/fuzzy-logic-toolkit-0.4.5.tar.gz
if [ -f "../pkg.inst" ]; then rm ../pkg.inst; fi
for f in *.tar.gz; do echo "pkg install $f" >> ../pkg.inst; done
mv ../pkg.inst ./
cd ..
tar zcvf octave_pkgs.tgz octave_pkgs
rm -rf octave_pkgs
