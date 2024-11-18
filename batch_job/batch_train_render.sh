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
    # EXP_LABEL=""
    # EXP_LABEL="_lrScale0.1"
    # EXP_LABEL="_tRes-1_hyper2"
    EXP_LABEL="_tRes-1_hyper2_sh0_lr0.1x"

    # take the second and third to the last parts of the path and replace "/" with "_"
    EXP_NAME=${DATASET}${EXP_LABEL}/$(echo $SCENE | rev | cut -d'/' -f2,3 | rev | sed 's/\//_/g')
    # EXP_NAME=${DATASET}${EXP_LABEL}/$(echo $SCENE | rev | cut -d'/' -f2,3 | rev | sed 's/\//_/g')_hyper2
    # EXP_NAME=${DATASET}${EXP_LABEL}/$(echo $SCENE | rev | cut -d'/' -f2,3 | rev | sed 's/\//_/g')_tRes-1
    # EXP_NAME=${DATASET}${EXP_LABEL}/$(echo $SCENE | rev | cut -d'/' -f2,3 | rev | sed 's/\//_/g')_tRes-1_hyper2
    # replace "/" with "_"
    JOB_NAME=$(echo $EXP_NAME | sed 's/\//_/g')

    while true; do
        PORT=$(( ( RANDOM % 64511 ) + 1024 ))
        if ! lsof -i:$PORT &>/dev/null; then
            # echo "Available port: $PORT"
            break
        fi
    done
    
    
    # CMD_TRAIN="python train_gui.py --source_path $SCENE --model_path outputs/$EXP_NAME --deform_type node --node_num 512 --hyper_dim 2 --eval --local_frame --W 800 --H 800"
    # CMD_TRAIN="python train_gui.py --source_path $SCENE --model_path outputs/$EXP_NAME --deform_type node --node_num 512 --hyper_dim 2 --eval --local_frame --W 800 --H 800 --sh_degree 0"
    CMD_TRAIN="python train_gui.py --source_path $SCENE --model_path outputs/$EXP_NAME --deform_type node --node_num 512 --hyper_dim 2 --eval --local_frame --W 800 --H 800 --sh_degree 0 --position_lr_init 0.000016 --position_lr_final 0.00000016 --scaling_lr 0.0001"  # lr0.1x
    # echo $CMD_TRAIN
    # $CMD_TRAIN

    CMD_RENDER="python render.py --model_path outputs/${EXP_NAME}_node --skip_train --deform_type node"
    # echo $CMD_RENDER
    # $CMD_RENDER

    CMD="/home/wiss/qis/local/usr/bin/isbatch.sh scgs_${JOB_NAME} $CMD_TRAIN && $CMD_RENDER"
    # echo $CMD
    $CMD
done
