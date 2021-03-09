
## Empirical Sensitivity Analysis of Metrics

# Idea: Calculate the statistical distance between a random 50/50 split of a dataset.
# Repeat this n-times, and check variation of distance measures across all variables.
source('fidelity.R')
dt <- fread('data/adult_trn.csv.gz')
n <- 100
out <- rbindlist(lapply(1:n, function(i) {
  cat(i)
  ids <- sample(nrow(dt), nrow(dt)/2)
  dt1 <- dt[ids]
  dt2 <- dt[-ids]
  fidelity(dt1, dt2, k = 1, c = 100)[, idx := i]
}))

out2 <- out[, .(tvd = mean(tvd), mae = mean(mae), l1d = mean(l1d), l2d = mean(l2d), hellinger = mean(hellinger), jensen_shannon = mean(jensen_shannon)), by = idx]
sort(sapply(out2[, -1], function(x) round(sd(x) / mean(x), 3)))
# hellinger            tvd            l1d jensen_shannon            l2d            mae 
#     0.060          0.078          0.078          0.090          0.133          0.220 

q50 <- function(x) quantile(x, 0.50)
out2 <- out[, .(tvd = q50(tvd), mae = q50(mae), l1d = q50(l1d), l2d = q50(l2d), hellinger = q50(hellinger), jensen_shannon = q50(jensen_shannon)), by = idx]
sort(sapply(out2[, -1], function(x) round(sd(x) / mean(x), 3)))
# hellinger            mae            tvd            l1d            l2d jensen_shannon 
#     0.125          0.171          0.181          0.181          0.193          0.259 

q95 <- function(x) quantile(x, 0.95)
out2 <- out[, .(tvd = q95(tvd), mae = q95(mae), l1d = q95(l1d), l2d = q95(l2d), hellinger = q95(hellinger), jensen_shannon = q95(jensen_shannon)), by = idx]
sort(sapply(out2[, -1], function(x) round(sd(x) / mean(x), 3)))
# hellinger            tvd            l1d jensen_shannon            l2d            mae 
#     0.055          0.071          0.071          0.106          0.148          0.416 

# -> Hellinger distance has lowest coefficient of variation in these empirical tests


## Simulate various binomial distributions

sim <- rbindlist(lapply(1:100, function(i) {
  cat(i)
  n <- 1000
  dt1 <- data.table(p02 = as.character(rbinom(n, size = 1, prob = 0.02)),
                    p05 = as.character(rbinom(n, size = 1, prob = 0.05)),
                    p10 = as.character(rbinom(n, size = 1, prob = 0.10)),
                    p20 = as.character(rbinom(n, size = 1, prob = 0.20)),
                    p33 = as.character(rbinom(n, size = 1, prob = 0.33)),
                    p50a = as.character(rbinom(n, size = 1, prob = 0.50)),
                    p50b = as.character(rbinom(n, size = 2, prob = 0.50)),
                    p50c = as.character(rbinom(n, size = 3, prob = 0.50)),
                    p50d = as.character(rbinom(n, size = 4, prob = 0.50)),
                    p50e = as.character(rbinom(n, size = 5, prob = 0.50)),
                    p50f = as.character(rbinom(n, size = 6, prob = 0.50)))
  dt2 <- data.table(p02 = as.character(rbinom(n, size = 1, prob = 0.02)),
                    p05 = as.character(rbinom(n, size = 1, prob = 0.05)),
                    p10 = as.character(rbinom(n, size = 1, prob = 0.10)),
                    p20 = as.character(rbinom(n, size = 1, prob = 0.20)),
                    p33 = as.character(rbinom(n, size = 1, prob = 0.33)),
                    p50a = as.character(rbinom(n, size = 1, prob = 0.50)),
                    p50b = as.character(rbinom(n, size = 2, prob = 0.50)),
                    p50c = as.character(rbinom(n, size = 3, prob = 0.50)),
                    p50d = as.character(rbinom(n, size = 4, prob = 0.50)),
                    p50e = as.character(rbinom(n, size = 5, prob = 0.50)),
                    p50f = as.character(rbinom(n, size = 6, prob = 0.50)))
  fidelity(dt1, dt2, k = 1, c = 100)
}))

sim
sim[, id := col1]
ggplot(sim, aes(x=hellinger, color=col1)) + geom_density()
ggplot(sim, aes(x=jensen_shannon, color=id)) + geom_density()
ggplot(sim, aes(x=tvd, color=id)) + geom_density()
ggplot(sim, aes(x=mae, color=id)) + geom_density()
ggplot(sim, aes(x=l1d, color=id)) + geom_density()
ggplot(sim, aes(x=l2d, color=id)) + geom_density()
