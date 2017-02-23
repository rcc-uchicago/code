This folder contains two examples illustrating how to use a shell
(bash) script in combination with an sbatch script to submit multiple
SLURM jobs simulateously. This circumvents the "array job" interface
in SLURM, which is a little bit more work, but also gives more
flexibility.

The first example,
[gen_many_normal_datasets.sh](gen_many_normal_datasets.sh),
illustrates how to implement a bash script that takes a parameter
specifying the number of simultaneous SLURM jobs to submit.

The second example,
[gen_normal_datasets_by_filename.sh](gen_normal_datasets_by_filename.sh),
illustrates how to submit multiple SLURM jobs simultaneously according
to the argument names or a list of files.
