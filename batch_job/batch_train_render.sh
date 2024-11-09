#!/bin/bash

# SCENES=$(ls -d data/kitti/*/*/dust3r_2_views)
# SCENES=$(ls -d data/kubric/*/*/dust3r_2_views)

# print the number of scenes
echo "Number of scenes: $(echo "$SCENES" | wc -l)"

# get the dataset name by taking the second part of the path
DATASET=$(echo "$SCENES" | head -n 1 | cut -d'/' -f2)

# take a subset of SCENES
# SCENES=$(echo "$SCENES" | head -n 1)

for SCENE in $SCENES
do
    # take the second and third to the last parts of the path and replace "/" with "_"
    EXP_NAME=$DATASET/$(echo $SCENE | rev | cut -d'/' -f2,3 | rev | sed 's/\//_/g')

    while true; do
        PORT=$(( ( RANDOM % 64511 ) + 1024 ))
        if ! lsof -i:$PORT &>/dev/null; then
            # echo "Available port: $PORT"
            break
        fi
    done
    
    
    CMD_TRAIN="python train_gui.py --source_path $SCENE --model_path outputs/$EXP_NAME --deform_type node --node_num 512 --hyper_dim 8 --eval --local_frame --W 800 --H 800"
    # echo $CMD_TRAIN
    # $CMD_RENDER

    CMD_RENDER="python render.py --model_path outputs/${EXP_NAME}_node --skip_train --deform_type node"
    # echo $CMD_RENDER
    # $CMD_RENDER

    CMD="/home/wiss/qis/local/usr/bin/isbatch.sh $EXP_NAME $CMD_TRAIN && $CMD_RENDER"
    # echo $CMD
    $CMD
done
