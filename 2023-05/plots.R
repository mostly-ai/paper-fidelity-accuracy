
library(ggplot2)
library(scales)
library(cowplot)
library(forcats)

# benchmarks

fidelity <- fread('fidelity.csv.gz')
syn_labels <- data.table(synthesizer = c('trn', 'val', 'gretel', 'ctgan', 'copulagan', 'gaussian_copula', 'tvae', 'mostly', 'synthpop'),
                         syn_label = c('TRAINING', 'HOLDOUT', 'gretel', 'ctgan', 'copulagan', 'gaussian_copula', 'tvae', 'MOSTLY AI', 'synthpop'))
fidelity <- merge(fidelity, syn_labels, all.x=TRUE)
library(scales)
fidelity[, label := paste0(syn_label, ' (', percent(tvd, accuracy=0.1), ')')]
fidelity[, split := paste0(dataset, '_', synthesizer)]

## helper

get_labeller <- function(labels_dt) {
  labels_dt <- rbind(labels_dt, data.table(split='adult_trn', label = 'Training'))
  labels <- labels_dt$label
  names(labels) <- labels_dt$split
  ggplot2::labeller('split' = labels)
}

split_colors <- c('#AAAAAA', '#444444', 
                  '#05A6B0', '#AAAAAA', '#AAAAAA',
                  '#AAAAAA', '#AAAAAA', '#AAAAAA', 
                  '#AAAAAA', '#AAAAAA', '#AAAAAA'
                  )


## univariate

fns <- file.path('2023-05/data/',
                 c(#'adult_trn.csv.gz',
                   'adult_synthpop.csv.gz',
                   'adult_val.csv.gz',
                   'adult_mostly.csv.gz',
                   'adult_gretel.csv.gz',
                   'adult_tvae.csv.gz',
                   'adult_ctgan.csv.gz',
                   'adult_copulagan.csv.gz'
                   ))
adult <- rbindlist(lapply(fns, function(fn) {
  fread(fn)[, split := gsub('\\.csv\\.gz', '', basename(fn))]
  }))
adult[, split := fct_inorder(split)]
adult[, idx := 1:.N, by = split]
adult[, fnlwgt := as.numeric(fnlwgt)]

#### bivariate
stats <- adult[, .N, by = .(split, `marital-status`, age = 5 * (age %/% 5))][, share := N/sum(N), by = .(`marital-status`, split)]
stats <- stats[`marital-status`!='Married-AF-spouse']
labels_dt <- fidelity[dataset=='adult' & k==2 & dim1=='age' & dim2=='marital-status'][, .(split, label)]
ggplot(stats, aes(x=age, y=share, fill=split, color=split)) + 
  facet_grid(split ~ `marital-status`, switch='y', labeller = get_labeller(labels_dt)) +
  geom_bar(stat='identity', alpha=1) +
  theme_minimal() + 
  theme(strip.text.y.left = element_text(angle = 0), 
        axis.text.y=element_blank()) +
  scale_fill_manual(values = split_colors) +
  scale_color_manual(values = split_colors) +
  ggtitle('[adult] age by marital-status') + xlab('') + ylab('') +
  theme(plot.title = element_text(size=15)) +
  scale_x_continuous(breaks=seq(20, 80, 20), minor_breaks = c()) +
  scale_y_continuous(labels = scales::percent_format()) +
  coord_cartesian(xlim=c(15, 95), ylim=c(0, 0.45)) +
  guides(fill = FALSE, color = FALSE)
ggsave('2023-05/adult_bench_bivariate.png', width=10, height=8)
