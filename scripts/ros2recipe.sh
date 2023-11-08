#!/bin/bash
root_path=$1
repo_local_name=$2
output_path=$3

if [ "$output_path" == "" ]; then
    echo "tips:"
    echo "./ros2recipe.sh root_path repo_local_name output_path"
    echo "example: ./ros2recipe.sh ./originbot originbot ./bbout "
    echo "note!!!: '../' is not support"
else
    xmls=`find $root_path -name package.xml`
    for xml in $xmls
    do
        python3 ros2recipe.py $xml $repo_local_name > ./ros2recipe_tmp
        bbname=$output_path"/"`cat ./ros2recipe_tmp | head -n1 | awk -F '/' '{print $NF}'`
        echo $bbname
        mkdir -p $output_path
        mv ros2recipe_tmp $bbname
    done
fi

