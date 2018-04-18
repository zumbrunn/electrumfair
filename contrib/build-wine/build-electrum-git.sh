#!/bin/bash

NAME_ROOT=electrumfair
PYTHON_VERSION=3.5.4

if [ "$#" -gt 0 ]; then
    VERSION="$1"
else
    echo "please provide version number to build"
    exit 1
fi

# These settings probably don't need any change
export WINEPREFIX=/opt/wine64
export PYTHONDONTWRITEBYTECODE=1
export PYTHONHASHSEED=22

PYHOME=c:/python$PYTHON_VERSION
PYTHON="wine $PYHOME/python.exe -OO -B"


# Let's begin!
# cd `dirname $0`
set -e

if [ -d "tmp" ]; then
    rm -rf tmp
fi

mkdir tmp
cd tmp

echo -n "Downloading latest release..."
wget -cq "https://download.faircoin.world/electrum/ElectrumFair-$VERSION.tar.gz"
echo "done."
tar xvf ElectrumFair-$VERSION.tar.gz
cd ElectrumFair-$VERSION

cp -r lib/locale $WINEPREFIX/drive_c/electrumfair/lib
cp gui/qt/icons_rc.py $WINEPREFIX/drive_c/electrumfair/gui/qt
cp -r packages $WINEPREFIX/drive_c/electrumfair

cd ../..

# Install frozen dependencies
$PYTHON -m pip install -r contrib/requirements.txt

cd $WINEPREFIX/drive_c/electrumfair
$PYTHON setup.py install

rm -rf tmp
rm -rf dist

# build standalone and portable versions
wine "C:/python$PYTHON_VERSION/scripts/pyinstaller.exe" --noconfirm --ascii --name $NAME_ROOT-$VERSION -w $WINEPREFIX/drive_c/electrumfair/contrib/build-wine/deterministic.spec

# build NSIS installer
# $VERSION could be passed to the electrum.nsi script, but this would require some rewriting in the script iself.
wine "$WINEPREFIX/drive_c/Program Files (x86)/NSIS/makensis.exe" /DPRODUCT_VERSION=$VERSION C:\\electrumfair\\contrib\\build-wine\\electrum.nsi

echo "the final build is in the 'dist' folder"
