#!/bin/sh
seed_max=1
log_level="NOTICE"

export DEBUG=1
export TRAIN=1
export EVAL=0

scenario="A"
accelerate=1200  # 1 step = 0.02 * 1200 = 24 s
n_training_threads=42
n_rollout_threads=8
num_env_steps=$((25200 * 400))  # steps_per_episode * episodes
experiment="check"

algo="dqn"
gamma=0.99
lr=3e-4

w_qos=60
w_xqos=0.005

log_interval=1

wandb_user="qichenw"
wandb_api_key="e3662fa8db0f243936c7514a1d0c69f2374ce721"

echo "algo is ${algo}, traffic scenario is ${scenario}, max seed is ${seed_max}"
for seed in `seq ${seed_max}`;
do
    echo "seed is ${seed}:"
    CUDA_VISIBLE_DEVICES=0 python train.py --algorithm_name ${algo} --experiment_name ${experiment} --scenario ${scenario} --accelerate ${accelerate} --seed ${seed} --n_training_threads ${n_training_threads} --n_rollout_threads ${n_rollout_threads} --num_env_steps ${num_env_steps} --gamma ${gamma} --learning-rate ${lr} --user_name ${wandb_user} --log_level ${log_level} --log_interval ${log_interval} --w_qos ${w_qos} --w_xqos ${w_xqos} $@
done
