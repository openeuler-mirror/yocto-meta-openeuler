#!/bin/bash
root_path=$1
tarball_path=$2
output_path=$3

if [ "$output_path" == "" ]; then
    echo "tips:"
    echo "./ros2recipe.sh root_path tarball_path output_path"
    echo "example: ./ros2recipe.sh ./originbot originbot/v1.0.2.tar.gz ./bbout "
    echo "note!!!: '../' is not support, tarball_path is the relative path under yocto-embedded-tools/ros_depends_humble(dev-ros branch)"
else
    xmls=`find $root_path -name package.xml`
    for xml in $xmls
    do
        python3 ros2recipe.py $xml $tarball_path > ./ros2recipe_tmp
        bbname=$output_path"/"`cat ./ros2recipe_tmp | head -n1 | awk -F '/' '{print $NF}'`
        echo $bbname
        mkdir -p $output_path
        mv ros2recipe_tmp $bbname
    done
fi

