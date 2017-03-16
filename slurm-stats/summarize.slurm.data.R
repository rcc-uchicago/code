# Illustration of how to read SLURM data and generate visual summaries
# of these data in R. The "jobs.txt" can be copied from
# ~pcarbo/rcc.jobs.txt on midway.
library(lattice)

# LOAD SLURM DATA
# ---------------
slurm <- read.table("jobs.txt",sep = " ",header = TRUE,
                    as.is = "JobID",quote = "")
slurm <- transform(slurm,CPUTimeRAW = as.numeric(CPUTimeRAW))
                   
# Convert ReqMem so that it is expressed as memory per core (Gc),
# rather than memory per core (Gn).
slurm                <- transform(slurm,NCPUsPerNode = NCPUS/NNodes)
rows                 <- which(slurm$MemUnits == "Gn")
slurm[rows,"ReqMem"] <- slurm[rows,"ReqMem"] / slurm[rows,"NCPUsPerNode"]

# Plot the distribution of total requested memory against total
# computation time (CPU x hours) for the selected partitions.
trellis.par.set(par.main.text = list(cex = 0.75,font = 1),
                axis.text = list(cex = 0.65),
                .axis.text = list(cex = 0.65))
partitions <- c("broadwl","sandyb","bigmem","bigmem2")
n          <- length(partitions)
for (i in 1:n) {
  out    <- subset(slurm,Partition == partitions[i] & ReqMem < 50)
  bins   <- c(0:5,10,20,50)
  x      <- cut(out$ReqMem,bins)
  counts <- tapply(out$CPUTimeRAW,x,sum) / 360
  counts[is.na(counts)] <- 0
  print(barchart(counts,horizontal = FALSE,col = "navyblue",box.width = 0.6,
                 lwd = 0,scales = list(x = list(labels = bins[-1])),
                 xlab = "",ylab = "",main = partitions[i]),
        split = c(i,1,4,1),
        more = (i < n))
}

