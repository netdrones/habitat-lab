#!/bin/bash

# TO PLOT RESULTS SEE RUN `python method/plot_bench.py`
mkdir -p data/profile
NUM_STEPS=200
set -e

export OMP_NUM_THREADS=2
export MAGNUM_LOG=quiet
export HABITAT_SIM_LOG=quiet


#py-spy record --native --idle --function --subprocesses --rate 50 --output pyspy_profile.speedscope --format speedscope -- /private/home/alexclegg/.conda/envs/hab2_bench/bin/python scripts/hab2_benchmark.py --cfg configs/tasks/rearrange/benchmark/idle.yaml --n-steps 200 --n-procs 1 --out-name "render_psypy" "SIMULATOR.STEP_PHYSICS" False "SIMULATOR.UPDATE_ROBOT" False

NO_SLEEP=("SIMULATOR.AUTO_SLEEP" False)
NO_CONCUR=("SIMULATOR.CONCUR_RENDER" False)
NO_PHYSICS=("SIMULATOR.STEP_PHYSICS" False)
NO_ROBOT_UPDATE=("SIMULATOR.UPDATE_ROBOT" False)
#NO_OBJS=("SIMULATOR.LOAD_ART_OBJS" False "SIMULATOR.LOAD_OBJS" False)

#number of processes
# shellcheck disable=SC2043
for j in 1
do
  #number of trials
  for i in {0..10}
  do
    # # Ours
    python scripts/hab2_benchmark.py --cfg configs/tasks/rearrange/benchmark/idle.yaml --n-steps "$NUM_STEPS" --n-procs "$j" --out-name "all_$i"

    # # Ours (-Concur Render)
    python scripts/hab2_benchmark.py --cfg configs/tasks/rearrange/benchmark/idle.yaml --n-steps "$NUM_STEPS" --n-procs "$j" --out-name "noconcur_$i" "${NO_CONCUR[@]}"

    # # Ours (-Auto sleep)
    python scripts/hab2_benchmark.py --cfg configs/tasks/rearrange/benchmark/idle.yaml --n-steps "$NUM_STEPS" --n-procs "$j" --out-name "nosleep_$i" "${NO_SLEEP[@]}"

    # # Ours (NO_PHYSICS)
    python scripts/hab2_benchmark.py --cfg configs/tasks/rearrange/benchmark/idle.yaml --n-steps "$NUM_STEPS" --n-procs "$j" --out-name "nophys_$i" "${NO_PHYSICS[@]}"

    # # Ours (NO_ROBOT_UPDATE)
    python scripts/hab2_benchmark.py --cfg configs/tasks/rearrange/benchmark/idle.yaml --n-steps "$NUM_STEPS" --n-procs "$j" --out-name "norobupdate_$i" "${NO_ROBOT_UPDATE[@]}"

    # # Ours (RENDER_ONLY)
    python scripts/hab2_benchmark.py --cfg configs/tasks/rearrange/benchmark/idle.yaml --n-steps "$NUM_STEPS" --n-procs "$j" --out-name "render_$i" "${NO_PHYSICS[@]}" "${NO_ROBOT_UPDATE[@]}"

    # # Ours (no rigid or articulated objects)
    #python scripts/hab2_benchmark.py --cfg configs/tasks/rearrange/benchmark/idle.yaml --n-steps "$NUM_STEPS" --n-procs "$j" --out-name "noobjs_$i" "${NO_OBJS[@]}"
  done
done
