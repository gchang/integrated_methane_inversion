#!/bin/bash
echo "running {END} jacobian simulations" >> {InversionPath}/imi_output.log

# remove error status file if present
rm -f .error_status_file.txt

if [[ $SchedulerType = "slurm" || $SchedulerType = "tmux" ]]; then
    sbatch --array={START}-{END}{JOBS} --mem $StageMemory \
        -c $StageCPUs \
        -N 1 \
        -t $StageTime \
        -p $StagePartition \
        -o imi_output.tmp \
        --open-mode=append \
        -W run_jacobian_simulations.sh
elif [[ $SchedulerType = "PBS" ]]; then
    qsub -J {START}-{END}{JOBS} \
        -lselect=1:ncpus=$StageCPUs:mem="$StageMemory":model=ivy \
        -l walltime=$StageTime \
        -l site=needed=$SitesNeeded \
        -o imi_output.tmp \
        -Wblock=True run_jacobian_simulations.sh
fi

cat imi_output.tmp >> {InversionPath}/imi_output.log
rm imi_output.tmp
