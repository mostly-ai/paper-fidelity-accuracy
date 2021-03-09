
library(data.table)

split_dt <- function(dt, ratio) {
  set.seed(123)
  trn_idx <- sample(1:nrow(dt), round(nrow(dt) * ratio))
  val_idx <- setdiff(1:nrow(dt), trn_idx)
  list(trn = dt[trn_idx, ],
       val = dt[val_idx, ])
}

# Online Shoppers
dt <- fread('https://archive.ics.uci.edu/ml/machine-learning-databases/00468/online_shoppers_intention.csv')
dts <- split_dt(dt, ratio=0.5)
fwrite(dts$trn, 'data/online-shoppers_trn.csv')
fwrite(dts$val, 'data/online-shoppers_val.csv')

# Marketing
fn <- file.path(tempdir(), 'marketing.zip')
download.file('https://archive.ics.uci.edu/ml/machine-learning-databases/00222/bank.zip', fn)
dt <- fread(unzip(fn, files='bank-full.csv', exdir = dirname(fn)))
dts <- split_dt(dt, ratio=0.5)
fwrite(dts$trn, 'data/marketing_trn.csv')
fwrite(dts$val, 'data/marketing_val.csv')

# Adult
cols <- c('age', 'workclass', 'fnlwgt', 'education', 'education-num', 
          'marital-status', 'occupation', 'relationship', 'race', 'sex',
          'capital-gain', 'capital-loss', 'hours-per-week', 'native-country', 
          'income')
dt1 <- fread('http://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.data')
dt2 <- fread('http://archive.ics.uci.edu/ml/machine-learning-databases/adult/adult.test', skip = 1)
dt2[, V15 := gsub('\\.', '', V15)]
dt <- rbind(dt1, dt2)
names(dt) <- cols
dts <- split_dt(dt, ratio=0.5)
fwrite(dts$trn, 'data/adult_trn.csv')
fwrite(dts$val, 'data/adult_val.csv')

# Credit Default
library(readxl)
library(data.table)
data_uri <- 'https://archive.ics.uci.edu/ml/machine-learning-databases/00350/default%20of%20credit%20card%20clients.xls'
tmp_fn <- file.path(tempdir(), 'data.xls')
download.file(data_uri, tmp_fn)
dt <- setDT(read_xls(tmp_fn, skip = 1))
dt[, ID := NULL]
dts <- split_dt(dt, ratio=0.5)
fwrite(dts$trn, 'data/credit-default_trn.csv')
fwrite(dts$val, 'data/credit-default_val.csv')
