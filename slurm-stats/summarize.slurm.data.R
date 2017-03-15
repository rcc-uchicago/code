# TO DO: Explain here what this script does, and how to use it.
library(ggplot2)

# LOAD SLURM DATA
# ---------------
cat("Reading in SLURM data.\n")
slurm <- read.table("jobs.txt",sep = " ",header = TRUE,
                    as.is = "JobID",quote = "")

# Convert ReqMem so that it is expressed as memory per node (Gn),
# rather than memory per core (Gc).
slurm                <- transform(slurm,NCPUsPerNode = NCPUS/NNodes)
rows                 <- which(slurm$MemUnits == "Gc")
slurm[rows,"ReqMem"] <- slurm[rows,"ReqMem"] * slurm[rows,"NCPUsPerNode"]

# Plot total memory against number of CPUs, separately for each
# partition.
dotplot
  

