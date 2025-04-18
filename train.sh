#!/bin/sh
seed_max=1
log_level="NOTICE"

export DEBUG=0
export TRAIN=1
export EVAL=0

scenario="A"
accelerate=1200  # 1 step = 0.02 * 1200 = 24 s
n_training_threads=24
n_rollout_threads=2
num_env_steps=$((25200 * 500))  # steps_per_episode * episodes
experiment="check"

algo="mappo"
gamma=0.99
gain=0.01
lr=5e-4
critic_lr=$lr
value_loss_coef=1
ppo_epoch=10
num_mini_batch=32
max_sleep=1
level=4

w_qos=30
w_xqos=0.005

log_interval=1

wandb_user="qichenw"
wandb_api_key="e4bee9a24174f0daabc173c5384733a60c1ea981"

echo "algo is ${algo}, traffic scenario is ${scenario}, max seed is ${seed_max}"
for seed in `seq ${seed_max}`;
do
    echo "seed is ${seed}:"
    CUDA_VISIBLE_DEVICES=0 python train.py -l ${level} --use_wandb --max_sleep ${max_sleep} --algorithm_name ${algo} --experiment_name ${experiment} --scenario ${scenario} --accelerate ${accelerate} --seed ${seed} --n_training_threads ${n_training_threads} --n_rollout_threads ${n_rollout_threads} --num_mini_batch ${num_mini_batch} --num_env_steps ${num_env_steps} --ppo_epoch ${ppo_epoch} --gain ${gain} --gamma ${gamma} --lr ${lr} --critic_lr ${critic_lr} --value_loss_coef ${value_loss_coef} --user_name ${wandb_user} --log_level ${log_level} --log_interval ${log_interval} --w_qos ${w_qos} --w_xqos ${w_xqos} $@
done
