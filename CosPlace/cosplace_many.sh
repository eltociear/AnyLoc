# Run NetVLAD VPR
#
# Usage:
#   bash ./cosplace_many.sh
#
# Run this script from inside the `CosPlace` folder
#   - 
#

# Backup from Jay
# python3 -u eval.py --dataset_folder /ocean/projects/cis220039p/shared/datasets/vpr/datasets_vg --dataset_name laurel_caverns --wandb_proj=Unstructured --wandb_entity vpr-vl --wandb_group laurel_caverns --wandb_name CosPlace/laurel_caverns
# python3 -u eval.py --dataset_folder /ocean/projects/cis220039p/shared/datasets/vpr/datasets_vg --dataset_name hawkins_long_corridor --wandb_proj=Unstructured --wandb_entity vpr-vl --wandb_group hawkins_long_corridor --wandb_name CosPlace/hawkins_long_corridor
# python3 -u eval.py --dataset_folder /ocean/projects/cis220039p/shared/datasets/vpr/datasets_vg --dataset_name VPAir --wandb_proj=Unstructured --wandb_entity vpr-vl --wandb_group VPAir --wandb_name CosPlace/VPAir
# python3 -u eval.py --dataset_folder /ocean/projects/cis220039p/shared/datasets/vpr/datasets_vg --dataset_name GNSS_Tartan --wandb_proj=Unstructured --wandb_entity vpr-vl --wandb_group GNSS_Tartan --wandb_name CosPlace/GNSS_Tartan


# python3 -u eval.py --dataset_folder /ocean/projects/cis220039p/shared/datasets/vpr/datasets_vg --dataset_name eiffel #--wandb_proj=Unstructured --wandb_entity vpr-vl --wandb_group GNSS_Tartan --wandb_name NetVLAD/GNSS_Tartan

# Directory for storing experiment cache (not used)
cache_dir="/scratch/avneesh.mishra/vl-vpr/cache"
cache_dir+="/CosPlace_runs"
# Directory where the checkpoints are stored
ckpts_dir="/home2/avneesh.mishra/Documents/vl-vpr/models"
ckpts_dir+="/CosPlace"
ckpt_backbone="ResNet101"
ckpt_wandb_name="ResNet101_2048"
ckpt_file="${ckpts_dir}/resnet101_2048.pth"
# ckpt_backbone="ViT"
# ckpt_wandb_name="ViT-B-16_768"
# ckpt_file="${ckpts_dir}/vit_best_model.pth"
# Directory where the datasets are downloaded
# data_vg_dir="/ocean/projects/cis220039p/shared/datasets/vpr/datasets_vg"
data_vg_dir="/home2/avneesh.mishra/Documents/vl-vpr/datasets_vg/datasets"
# Datasets
gpu=${1:-0}
export CUDA_VISIBLE_DEVICES=$gpu
# datasets=("Oxford" "gardens" "17places" "baidu_datasets" "st_lucia" "pitts30k")
# datasets=("Tartan_GNSS_test_rotated" "Tartan_GNSS_test_notrotated" "Tartan_GNSS_rotated" "Tartan_GNSS_notrotated" "hawkins" "laurel_caverns" "eiffel" "VPAir")
# datasets=("Tartan_GNSS_rotated" "Tartan_GNSS_notrotated" "hawkins" "laurel_caverns")
# datasets=("Tartan_GNSS_test_rotated" "Tartan_GNSS_test_notrotated")
# datasets=("eiffel")
# datasets=("VPAir")
# datasets=("Oxford")
datasets=("17places")
# WandB parameters
wandb_entity="vpr-vl"
# wandb_project="Paper_Structured_Benchmarks"
# wandb_project="Paper_Unstructured_Benchmarks"
wandb_group="CosPlace_ViT"
wandb_project="Ablations"


num_datasets=${#datasets[@]}
total_runs=$(( num_datasets ))
echo "Total number of runs: $total_runs"
curr_run=0
start_time=$(date)
start_time_secs=$SECONDS
echo "Start time: $start_time"
for dataset in ${datasets[*]}; do
    # Header
    echo -ne "\e[1;93m"
    echo "--- => Dataset: $dataset ---"
    curr_run=$((curr_run+1))
    echo "Run: $curr_run/$total_runs"
    echo -ne "\e[0m"
    # wandb_group="${dataset}"
    wandb_name="CosPlace/${dataset}/$ckpt_wandb_name"
    python_cmd="python ./eval.py"
    python_cmd+=" --dataset_folder $data_vg_dir"
    python_cmd+=" --backbone $ckpt_backbone"
    python_cmd+=" --resume_model $ckpt_file"
    python_cmd+=" --dataset_name $dataset"
    # python_cmd+=" --use_wandb"
    python_cmd+=" --wandb_entity $wandb_entity"
    python_cmd+=" --wandb_proj $wandb_project"
    python_cmd+=" --wandb_group $wandb_group"
    python_cmd+=" --wandb_name $wandb_name"
    # python_cmd+=" --save_descs /scratch/avneesh.mishra/vl-vpr/cache/dataset_clusters/cosplace/${dataset}"
    echo -ne "\e[0;36m"
    echo $python_cmd
    echo -ne "\e[0m"
    run_start_time=$(date)
    echo "- Run start time: ${run_start_time} -"
    run_start_secs=$SECONDS
    $python_cmd
    run_end_time=$(date)
    echo "- Run end time: ${run_end_time} -"
    run_end_secs=$SECONDS
    # run_dur=$(echo $(date -d "$run_end_time" +%s) \
    #         - $(date -d "$run_start_time" +%s) | bc -l)
    run_dur=$(( $run_end_secs - $run_start_secs ))
    echo -n "---- Run finished in (HH:MM:SS): "
    echo "`date -d@$run_dur -u +%H:%M:%S` ----"
done
end_time=$(date)
end_time_secs=$SECONDS
# dur=$(echo $(date -d "$end_time" +%s) - $(date -d "$start_time" +%s) | bc -l)
dur=$(( $end_time_secs - $start_time_secs ))
_d=$(( dur/3600/24 ))
echo "---- Ablation took (d-HH:MM:SS): $_d-`date -d@$dur -u +%H:%M:%S` ----"
echo "Starting time: $start_time"
echo "Ending time: $end_time"

