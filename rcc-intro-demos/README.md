# Demos for "Introduction to the Research Computing Center" workshop

The `pi_reduce` example is meant to illustrate the following concepts:
(1) loading modules on the compute cluster; (2) compile C code; and (3)
allocating computational resources using SLURM.

To compile the code, run:

```bash
module load intelmpi
mpicc -o pi_reduce pi_reduce.c -lm
```

To submit a request ("job") to the SLURM scheduler, then check that it
is running, do the following:

```bash
sbatch ./pi_reduce.sbatch
squeue --user=<cnet-id>
```
