
flip <- function(dt, n = nrow(dt), prob = 0.1) {
  if (n > nrow(dt)) {
    idx <- sample(1:nrow(dt), n, replace = TRUE)
    out <- dt[idx]
  } else {
    idx <- 1:n
  }
  out <- dt[idx]
  for (col in names(dt)) {
    flips <- rbinom(n = nrow(out), size = 1, prob = prob)
    vals <- sample(dt[[col]], sum(flips), replace = TRUE)
    set(out, i = which(flips==1), j = col, value = vals)
  }
  return(out)
}

set.seed(123)
datasets <- c('adult', 'credit-default', 'marketing', 'online-shoppers')
nil <- lapply(datasets, function(dataset) {
  fn_trn <- file.path('data', paste0(dataset, '_trn.csv.gz'))
  dt_trn <- fread(fn_trn)
  fwrite(flip(dt_trn, n=50000, prob=0.10), file.path('data', paste0(dataset, '_flip10.csv.gz')))
  fwrite(flip(dt_trn, n=50000, prob=0.20), file.path('data', paste0(dataset, '_flip20.csv.gz')))
  fwrite(flip(dt_trn, n=50000, prob=0.30), file.path('data', paste0(dataset, '_flip30.csv.gz')))
  fwrite(flip(dt_trn, n=50000, prob=0.40), file.path('data', paste0(dataset, '_flip40.csv.gz')))
  fwrite(flip(dt_trn, n=50000, prob=0.50), file.path('data', paste0(dataset, '_flip50.csv.gz')))
  fwrite(flip(dt_trn, n=50000, prob=0.60), file.path('data', paste0(dataset, '_flip60.csv.gz')))
  fwrite(flip(dt_trn, n=50000, prob=0.70), file.path('data', paste0(dataset, '_flip70.csv.gz')))
  fwrite(flip(dt_trn, n=50000, prob=0.80), file.path('data', paste0(dataset, '_flip80.csv.gz')))
  fwrite(flip(dt_trn, n=50000, prob=0.90), file.path('data', paste0(dataset, '_flip90.csv.gz')))
})
