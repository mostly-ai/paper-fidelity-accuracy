
# combine privacy + fidelity into single file for plots

priv <- fread('privacy_c100.csv')
fid <- fread('fidelity.csv.gz')[k==3, .(tvd = mean(tvd)), by = .(dataset, synthesizer)]
fid_val <- fid[synthesizer == 'val', .(dataset, tvd_val = tvd)]
fid <- merge(fid, fid_val, by = 'dataset')
fid[, tvd_ratio := tvd / tvd_val]
dt <- merge(priv, fid, by = c('dataset', 'synthesizer'))
dt[, dcr_ratio := dists_trn_mean / dists_val_mean]
dt[, share_ratio := share / (1-share)]

syn_labels <- data.table(synthesizer = c('trn', 'val', 'gretel', 'ctgan', 'copulagan', 'gaussian_copula', 'tvae', 'synthpop',
                                         'mostly', 'mostly_e1', 'mostly_e2', 'mostly_e4', 'mostly_e8', 'mostly_e16', 
                                         paste0('flip', c('10', '20', '30', '40', '50', '60', '70', '80', '90'))),
                         syn_label = c('Training', 'Holdout', 'Gretel', 'CTGAN', 'CopulaGAN', 'Gaussian Copula', 'TVAE', 'synthpop',
                                       'MOSTLY', 'MOSTLY e1', 'MOSTLY e2', 'MOSTLY e4', 'MOSTLY e8', 'MOSTLY e16',
                                       paste0('Flip ', c('10', '20', '30', '40', '50', '60', '70', '80', '90'), '%')))
dt <- merge(dt, syn_labels, by = 'synthesizer')

fwrite(dt[, .(dataset, synthesizer=syn_label, tvd, share, share_ratio, dcr_ratio, tvd_ratio)], 'tradeoff.csv')
