#!/bin/bash
# Run this after a new release to update dependencies

venv_dir=~/.electrumfair-venv
contrib=$(dirname "$0")

which virtualenv > /dev/null 2>&1 || { echo "Please install virtualenv" && exit 1; }

rm $venv_dir -rf
virtualenv $venv_dir

source $venv_dir/bin/activate

echo "Installing dependencies"

pushd $contrib/..
python3 setup.py install
popd

pip3 freeze | sed '/^ElectrumFair/ d' > $contrib/requirements.txt

echo "Updated requirements"
