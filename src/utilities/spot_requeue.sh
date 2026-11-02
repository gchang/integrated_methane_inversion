#!/bin/bash

# Description:
#   SIGTERM handler for Slurm jobs on EC2 Spot capacity. If EC2 reports a
#   pending Spot interruption for this instance, requeue the job (at most 5
#   times) so Slurm reruns it on another node. Any other SIGTERM (time limit,
#   scancel) or a non-EC2 system: the job just exits.
# Usage (in a job script, right after its #SBATCH lines):
#   source <IMI directory>/src/utilities/spot_requeue.sh

spot_requeue() {
    local imds=http://169.254.169.254/latest token
    token=$(curl -s -m 2 -X PUT "$imds/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
    if [[ -n "$token" ]] && ((${SLURM_RESTART_COUNT:-0} < 5)) &&
        curl -sf -m 2 -H "X-aws-ec2-metadata-token: $token" "$imds/meta-data/spot/instance-action" >/dev/null; then
        echo "Spot interruption on $(hostname): requeueing job ${SLURM_JOB_ID}"
        scontrol requeue "${SLURM_JOB_ID}"
    else
        echo "Job ${SLURM_JOB_ID} got SIGTERM (not a Spot interruption, or requeued 5 times): not requeueing"
    fi
    exit 143
}

if [[ -n "${SLURM_JOB_ID}" ]]; then
    trap spot_requeue SIGTERM
fi
