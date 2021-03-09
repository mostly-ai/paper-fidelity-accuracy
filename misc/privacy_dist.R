
# Nearest Neighbor based on Similarity Matches
nn_sm <- function(dt1, dt2, k = 1) {
  dt <- rbind(dt1, dt2)
  m <- do.call(cbind, lapply(dt, function(x) as.integer(as.factor(x))))
  m1 <- m[1:nrow(dt1),]
  m2 <- m[-c(1:nrow(dt1)),]
  scores <- sapply(1:nrow(m2), function(i) {
    if ((i %% 10) == 0) cat(i, nrow(m2), '\n')
    v <- m2[i,]
    m <- matrix(v, ncol=ncol(m2), nrow=nrow(m1), byrow=T)
    1 - apply(m1 == m, 1, mean)
  })
  list(nn.idx = apply(scores, 2, function(x) order(x))[1:k,],
       nn.dists = apply(scores, 2, function(x) sort(x))[1:k,])
}

# Nearest Neighbor based on Occurence Frequency (OF) Measure
nn_of <- function(dt1, dt2, k = 1) {
  dt <- rbind(dt1, dt2)
  m <- do.call(cbind, lapply(dt, function(x) as.integer(forcats::fct_inorder(as.character(x)))))
  m1 <- m[1:nrow(dt1),,drop=FALSE]
  m2 <- m[-c(1:nrow(dt1)),,drop=FALSE]
  zpad <- function(v, n) c(v, rep(0, n))[1:n]
  freq.abs <- do.call(cbind, lapply(1:ncol(m1), function(j) {
    zpad(unname(table(m1[, j])), max(m))
  }))
  m1f <- do.call(cbind, lapply(1:ncol(m1), function(j) freq.abs[m1[,j],j] ))
  m2f <- do.call(cbind, lapply(1:ncol(m2), function(j) freq.abs[m2[,j],j] ))
  scores <- sapply(1:nrow(m2), function(i) {
    if ((i %% 10) == 0) cat(i, nrow(m2), '\n')
    m2_i <- matrix(m2[i,], ncol=ncol(m2), nrow=nrow(m1), byrow=T)
    m1f_i <- copy(m1f)
    m2f_i <- matrix(m2f[i,], ncol=ncol(m2), nrow=nrow(m1), byrow=T)
    m1f_i[m1==m2_i] <- NA
    m2f_i[m1==m2_i] <- NA
    scores <- 1 / (1 + log(nrow(m1)/m1f_i) * log(nrow(m1)/m2f_i))
    scores[is.na(scores)] <- 1
    1 / apply(scores, 1, mean) - 1
  })
  list(nn.idx = apply(scores, 2, function(x) order(x))[1:k,],
       nn.dists = apply(scores, 2, function(x) sort(x))[1:k,])
}

## Nearest Neighbor Benchmarks
privacy_bench_nn <- function(datasets, synthesizers, c = 10, n = 1000, type='of') {
  rbindlist(lapply(datasets, function(dataset) {
    fn_trn <- paste0('data/', dataset, '_trn.csv.gz')
    fn_val <- paste0('data/', dataset, '_val.csv.gz')
    dt_trn <- fread(fn_trn)
    dt_val <- fread(fn_val)
    rbindlist(lapply(synthesizers, function(synthesizer) {
      fn_syn <- paste0('data/', dataset, '_', synthesizer, '.csv.gz')
      cat('read', fn_syn, '\n')
      dt_act <- rbind(dt_trn, dt_val)
      dt_syn <- fread(fn_syn)
      bin_cols(dt_act, dt_syn, c = c)
      dt_trn <- dt_act[1:nrow(dt_trn)]
      dt_val <- dt_act[-c(1:nrow(dt_trn))]
      n <- min(n, nrow(dt_syn))
      dt_syn <- dt_syn[1:n]
      if (type=='of') {
        dists_trn <- nn_of(dt_trn, dt_syn)$nn.dists
        dists_val <- nn_of(dt_val, dt_syn)$nn.dists
      } else if (type=='sm') {
        dists_trn <- nn_sm(dt_trn, dt_syn)$nn.dists
        dists_val <- nn_sm(dt_val, dt_syn)$nn.dists
      }
      share <- (sum(dists_trn < dists_val) + 0.5 * sum(dists_trn == dists_val)) / n
      list(dataset = dataset,
           synthesizer = synthesizer,
           dist_trn_mean = mean(dists_trn),
           dist_val_mean = mean(dists_val),
           dist_less = sum(dists_trn < dists_val),
           dist_equal = sum(dists_trn == dists_val),
           dist_more = sum(dists_trn > dists_val),
           share = share,
           pval = binom.test(round(share*n), n, p=0.5, alternative = 'greater')$p.value)
    }))
  }))
}

synthesizers <- c('gretel', 'mostly', 'mostly_e1')
datasets <- 'adult'

(x <- privacy_bench_nn(datasets, synthesizers, c = 10, n = 1000))
#    dataset synthesizer dist_trn_mean dist_val_mean dist_less dist_equal dist_more  share      pval
# 1:   adult      gretel    0.07549040    0.07543735       481         46       473 0.5040 0.4124131
# 2:   adult      mostly    0.06040585    0.06150348       480         81       439 0.5205 0.1087241
# 3:   adult   mostly_e1    0.08352919    0.08267899       481         23       496 0.4925 0.7045579
