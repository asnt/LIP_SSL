#!/bin/bash

## MODIFY PATH for YOUR SETTING
ROOT_DIR=$(dirname $0)

pushd ${ROOT_DIR}

CAFFE_DIR=${ROOT_DIR}/code/build/install
CAFFE_BIN=${CAFFE_DIR}/bin/caffe

DEV_ID=0

EXP=human

if [ "${EXP}" = "human" ]; then
    NUM_LABELS=20
    DATA_ROOT=${ROOT_DIR}/${EXP}/data/
else
    NUM_LABELS=0
    echo "Wrong exp name"
fi

## Specify which model to train
########### voc12 ################
NET_ID=attention
#NET_ID=vgg16

## Variables used for weakly or semi-supervisedly training
TRAIN_SET_SUFFIX=
TRAIN_SET_STRONG=train

## Create dirs
CONFIG_DIR=${ROOT_DIR}/${EXP}/config/${NET_ID}
MODEL_DIR=${ROOT_DIR}/${EXP}/model/${NET_ID}
LOG_DIR=${ROOT_DIR}/${EXP}/log/${NET_ID}
export GLOG_log_dir=${LOG_DIR}
LIST_DIR=${ROOT_DIR}/${EXP}/list
DATA_DIR=${ROOT_DIR}/${EXP}/data

mkdir -p $MODEL_DIR
mkdir -p $LOG_DIR
mkdir -p $LIST_DIR
mkdir -p $DATA_DIR

run_test() {
    TEST_SET=val

    # Generate the list of input image paths and id's.
    images=($(ls ${DATA_DIR}/images))

    # Ensure image paths are relative to DATA_DIR which is the root data dir
    # defined in the caffe model config.
    image_paths=(${images[@]/#/images\/})

    printf "%s\n" "${image_paths[@]}" > ${LIST_DIR}/val.txt
    ids=(${images[@]%.png})
    printf "%s\n" "${ids[@]}" > ${LIST_DIR}/val_id.txt

    TEST_ITER=$(cat ${LIST_DIR}/${TEST_SET}.txt | wc -l)
    MODEL=${MODEL_DIR}/test.caffemodel

    echo "Using model ${MODEL}"
    echo "Testing net ${EXP}/${NET_ID}"

    FEATURE_DIR=${ROOT_DIR}/${EXP}/features/${NET_ID}
    mkdir -p ${FEATURE_DIR}/${TEST_SET}/fc8_mask
    sed "$(eval echo $(cat ${ROOT_DIR}/sub.sed))" \
        ${CONFIG_DIR}/test.prototxt \
        > ${CONFIG_DIR}/test_${TEST_SET}.prototxt
    CMD="${CAFFE_BIN} test \
        --model=${CONFIG_DIR}/test_${TEST_SET}.prototxt \
        --weights=${MODEL} \
        --gpu=${DEV_ID} \
        --iterations=${TEST_ITER}"
    echo Running ${CMD} && ${CMD}
}

case $1 in
    test) run_test ;;
    *) echo "usage: $0 test"; exit 1 ;;
esac

popd
