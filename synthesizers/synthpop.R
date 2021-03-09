
library(data.table)
library(synthpop)
set.seed(123)

# adult
trn <- fread('data/adult_trn.csv.gz')
syn <- setDT(syn(trn, k = 50000)$syn)
fwrite(syn, 'data/adult_synthpop.csv.gz')

# bank-marketing
trn <- fread('data/bank-marketing_trn.csv.gz')
syn <- setDT(syn(trn, k = 50000)$syn)
fwrite(syn, 'data/bank-marketing_synthpop.csv.gz')

# credit-default
trn <- fread('data/credit-default_trn.csv.gz')
syn <- setDT(syn(trn, k = 50000)$syn)
fwrite(syn, 'data/credit-default_synthpop.csv.gz')

# online-shoppers
trn <- fread('data/online-shoppers_trn.csv.gz')
trn[, Weekend := as.factor(Weekend)]
trn[, Revenue := as.factor(Revenue)]
syn <- setDT(syn(trn, k = 50000)$syn)
fwrite(syn, 'data/online-shoppers_synthpop.csv.gz')
