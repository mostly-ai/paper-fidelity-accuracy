
library(ggplot2)
library(scales)
library(cowplot)
library(forcats)

# original

trn <- fread('data/adult_trn.csv.gz')
val <- fread('data/adult_val.csv.gz')
dt <- rbind(trn, val)
dt[, `marital-status` := factor(`marital-status`)]

## univariate

p1 <- ggplot(dt, aes(x=age)) + 
  geom_histogram(binwidth=1, fill='#444444', color='#444444', alpha=1) +
  theme_minimal() + ggtitle('[adult] age') + xlab('') + ylab('') +
  theme(plot.title = element_text(size=15, hjust = 0.5)) +
  scale_x_continuous(breaks=c(17, seq(30, 90, 10)), minor_breaks = c())

p2 <- ggplot(dt, aes(x=`hours-per-week`)) + 
  geom_histogram(binwidth=1, fill='#444444', color='#444444', alpha=1) +
  theme_minimal() + ggtitle('[adult] hours-per-week') + xlab('') + ylab('') +
  theme(plot.title = element_text(size=15, hjust = 0.5)) +
  scale_x_continuous(breaks=seq(0, 100, 10), minor_breaks = c())

p3 <- ggplot(dt, aes(x=`fnlwgt`)) + 
  geom_histogram(binwidth=20000, fill='#444444', color='#444444', alpha=1) +
  theme_minimal() + ggtitle('[adult] fnlwgt') + xlab('') + ylab('') +
  scale_x_continuous(labels = label_number(suffix = "k", scale = 1e-3), breaks=c(0, 500000, 1000000)) +
  theme(plot.title = element_text(size=15, hjust = 0.5))

p4 <- ggplot(dt, aes(x=`capital-gain`)) + 
  geom_histogram(binwidth=1000, fill='#444444', color='#444444', alpha=1) +
  theme_minimal() + ggtitle('[adult] capital-gain') + xlab('') + ylab('') +
  scale_x_continuous(labels = label_number(suffix = "k", scale = 1e-3), breaks=c(0, 25000, 50000, 75000)) +
  theme(plot.title = element_text(size=15, hjust = 0.5))

p5 <- ggplot(dt[, .N, by = .(`marital-status`)][, share := N/sum(N)], aes(x = share, y = `marital-status`)) + 
  geom_col(fill='#444444', color='#444444', alpha=1) + ylab('') +
  theme_minimal() + ggtitle('[adult] marital-status') + xlab('') +
  theme(plot.title = element_text(size=15, hjust = 0.5)) +
  scale_x_continuous(labels = percent_format(accuracy=1))

p6 <- ggplot(dt[, .N, by = .(`occupation`)][, share := N/sum(N)], aes(x = share, y = `occupation`)) + 
  geom_col(fill='#444444', color='#444444', alpha=1) + ylab('') +
  theme_minimal() + ggtitle('[adult] occupation') + xlab('') +
  theme(plot.title = element_text(size=15, hjust = 0.5)) +
  scale_x_continuous(labels = percent_format(accuracy=1))

plot_grid(plotlist=list(p1, p2, p3, p4, p5, p6), 
          ncol=3, byrow=F)
ggsave('plots/adult_univariate.png', width=12, height=6.5)

## bivariate

stats <- dt[, .N, by = .(`marital-status`, relationship)]
stats[, share := N/sum(N)]
rg <- range(stats$share, na.rm = TRUE)
stats[, share_alpha := (share - rg[1]) / (rg[2] - rg[1])]
stats[, label := percent(share, accuracy=0.1, suffix='%')]
p1 <- ggplot(stats, aes(y=`marital-status`, x=relationship)) + 
  geom_tile(aes(alpha = share_alpha), fill = '#444444') +
  geom_text(aes(label = label), size = 3) + 
  theme_dark() +
  theme(plot.title = element_text(size=15, hjust=0.5),
        panel.background = element_rect(fill = "white"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1),
        strip.background = element_rect(fill = "white"),
        strip.text = element_text(colour = "black", size = 8)) +
  guides(fill = FALSE, alpha = FALSE) + xlab('') + ylab('') +
  ggtitle('[adult] relationship vs. marital-status')
p1

stats <- dt[, .N, by = .(`education`, occupation)]
stats[, share := N/sum(N)]
stats[, label := percent(share, accuracy=0.1, suffix='%')]
rg <- range(stats$share, na.rm = TRUE)
stats[, share_alpha := (share - rg[1]) / (rg[2] - rg[1])]
p2 <- ggplot(stats, aes(x=`education`, y=`occupation`)) + 
  geom_tile(aes(alpha = share_alpha), fill = '#444444') +
  geom_text(aes(label = label), size = 2) + 
  theme_dark() +
  theme(plot.title = element_text(size=15, hjust=0.5),
        panel.background = element_rect(fill = "white"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text.x = element_text(angle = 45, hjust = 1),
        strip.background = element_rect(fill = "white"),
        strip.text = element_text(colour = "black", size = 8)) +
  guides(fill = FALSE, alpha = FALSE) + xlab('') + ylab('') +
  ggtitle('[adult] occupation vs. education')

stats <- dt[, .N, by = .(`relationship`, age = age)][, share := N/sum(N), by = .(`relationship`)]
p3 <- ggplot(stats, aes(x=age, y=share)) + facet_grid(. ~ `relationship`) +
  geom_bar(stat='identity', color='#444444', fill='#444444', alpha=0.9) +
  theme_minimal() + 
  ggtitle('[adult] age by relationship') + xlab('') + ylab('') +
  theme(plot.title = element_text(size=15, hjust=0.5)) +
  scale_x_continuous(breaks=seq(20, 80, 10), minor_breaks = c()) +
  scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
  guides(fill = FALSE)

top <- plot_grid(p1, p2, ncol=2)
plot_grid(top, p3, nrow=2)
ggsave('plots/adult_bivariate.png', width=10, height=6)


# benchmarks

fidelity <- fread('fidelity.csv.gz')
syn_labels <- data.table(synthesizer = c('trn', 'val', 'gretel', 'ctgan', 'copulagan', 'gaussian_copula', 'tvae', 'mostly', 'mostly_e1', 'mostly_e2', 'mostly_e4', 'mostly_e8', 'mostly_e16', 'synthpop', 'flip10', 'flip90'),
                         syn_label = c('Training', 'Holdout', 'Gretel', 'CTGAN', 'CopulaGAN', 'Gaussian Copula', 'TVAE', 'MOSTLY', 'MOSTLY e1', 'MOSTLY e2', 'MOSTLY e4', 'MOSTLY e8', 'MOSTLY e16', 'synthpop', 'Flip 10%', 'Flip 90%'))
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

split_colors <- c('#444444', '#AAAAAA', '#FFAE00', 
                  '#24A400', '#C066D9', '#5752F4', 
                  '#69cec3', '#F43EF7', 
                  '#FF5E65', 
                  '#92A7BA', '#6B7A99')

## univariate

fns <- file.path('data/',
                 c('adult_trn.csv.gz',
                   'adult_val.csv.gz',
                   'adult_copulagan.csv.gz',
                   'adult_ctgan.csv.gz',
                   'adult_gaussian_copula.csv.gz',
                   'adult_gretel.csv.gz',
                   'adult_mostly.csv.gz',
                   'adult_synthpop.csv.gz',
                   'adult_tvae.csv.gz',
                   'adult_flip10.csv.gz',
                   'adult_flip90.csv.gz'))
adult <- rbindlist(lapply(fns, function(fn) {
  fread(fn)[, split := gsub('\\.csv\\.gz', '', basename(fn))]
  }))
adult[, split := fct_inorder(split)]
adult[, idx := 1:.N, by = split]
adult[, fnlwgt := as.numeric(fnlwgt)]

# age
stats <- adult[, .N, by = .(split, `age`)][, share := N/sum(N), by = split]
labels_dt <- fidelity[dataset=='adult' & k==1 & dim1=='age'][, .(split, label)]
p1 <- ggplot(stats, aes(x=`age`, y=share, fill=split, color=split)) + 
  facet_wrap(split ~ ., ncol=11, labeller = get_labeller(labels_dt)) +
  geom_bar(stat='identity', alpha=1) +
  theme_minimal() + xlab('') + ylab('') + ggtitle('[adult] age') +
  theme(plot.title = element_text(size=15)) +
  scale_fill_manual(values = split_colors) +
  scale_color_manual(values = split_colors) +
  scale_x_continuous(breaks=seq(20, 80, 10), minor_breaks = c()) +
  scale_y_continuous(labels = percent_format()) +
  coord_cartesian(xlim=c(15, 95), ylim=c(0, 0.04)) +
  guides(fill = FALSE, color = FALSE)

# fnlwgt
stats <- adult[, .N, by = .(split, fnlwgt = 20000 * (fnlwgt %/% 20000))][, share := N/sum(N), by = split]
labels_dt <- fidelity[dataset=='adult' & k==1 & dim1=='fnlwgt'][, .(split, label)]
p2 <- ggplot(stats, aes(x=`fnlwgt`, y=share, fill=split, color=split)) + 
  facet_wrap(split ~ ., ncol=11, labeller = get_labeller(labels_dt)) +
  geom_bar(stat='identity', alpha=1) +
  theme_minimal() + xlab('') + ylab('') + ggtitle('[adult] fnlwgt') +
  theme(plot.title = element_text(size=15)) +
  scale_fill_manual(values = split_colors) +
  scale_color_manual(values = split_colors) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) +
  scale_x_continuous(labels = label_number(suffix = "k", scale = 1e-3), breaks=c(0, 500000, 1000000)) +
  coord_cartesian(xlim=c(0, 1200000)) +
  guides(fill = FALSE, color = FALSE)

# relationship
stats <- adult[, .N, by = .(split, `relationship`)][, share := N/sum(N), by = split]
labels_dt <- fidelity[dataset=='adult' & k==1 & dim1=='relationship'][, .(split, label)]
p3 <- ggplot(stats, aes(x=`relationship`, y=share, fill=split)) + 
  facet_wrap(split ~ ., ncol=11, labeller = get_labeller(labels_dt)) +
  scale_fill_manual(values = split_colors) +
  geom_bar(stat='identity', alpha=1) +
  theme_minimal() + xlab('') + ylab('') + ggtitle('[adult] relationship') +
  theme(plot.title = element_text(size=15),
        axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_y_continuous(labels = percent_format(accuracy=1)) +
  guides(fill = FALSE, color = FALSE)

plot_grid(plotlist=list(p1, p2, p3), ncol=1)
ggsave('plots/adult_bench_univariate.png', width=16, height=9)

#### bivariate
stats <- adult[, .N, by = .(split, `relationship`, age = 5 * (age %/% 5))][, share := N/sum(N), by = .(`relationship`, split)]
labels_dt <- fidelity[dataset=='adult' & k==2 & dim1=='age' & dim2=='relationship'][, .(split, label)]
ggplot(stats, aes(x=age, y=share, fill=split, color=split)) + 
  facet_grid(`relationship` ~ split, switch='y', labeller = get_labeller(labels_dt)) +
  geom_bar(stat='identity', alpha=1) +
  theme_minimal() + 
  theme(strip.text.y.left = element_text(angle = 0), 
        axis.text.y=element_blank()) +
  scale_fill_manual(values = split_colors) +
  scale_color_manual(values = split_colors) +
  ggtitle('[adult] age by relationship') + xlab('') + ylab('') +
  theme(plot.title = element_text(size=15)) +
  scale_x_continuous(breaks=seq(20, 80, 20), minor_breaks = c()) +
  scale_y_continuous(labels = scales::percent_format()) +
  coord_cartesian(xlim=c(15, 95), ylim=c(0, 0.45)) +
  guides(fill = FALSE, color = FALSE)
ggsave('plots/adult_bench_bivariate.png', width=16, height=8)

#### three-way
stats <- adult[, .N, by = .(split, `relationship`, `income`, age = 5 * (age %/% 5))][, share := N/sum(N), by = .(`relationship`, `income`, split)]
labels_dt <- fidelity[dataset=='adult' & k==3 & dim1=='age' & dim2=='income' & dim3=='relationship'][, .(split, label)]
ggplot(stats, aes(x=age, y=share, fill=split, color=split)) + 
  facet_grid(relationship + income ~ split, switch='y', labeller = get_labeller(labels_dt)) +
  geom_bar(stat='identity', alpha=1) +
  theme_minimal() + 
  theme(strip.text.y.left = element_text(angle = 0), 
        axis.text.y=element_blank()) +
  scale_fill_manual(values = split_colors) +
  scale_color_manual(values = split_colors) +
  ggtitle('[adult] age by relationship by income') + xlab('') + ylab('') +
  theme(plot.title = element_text(size=15)) +
  scale_x_continuous(breaks=seq(20, 80, 20), minor_breaks = c()) +
  scale_y_continuous(labels = scales::percent_format()) +
  coord_cartesian(xlim=c(15, 95), ylim=c(0, 0.45)) +
  guides(fill = FALSE, color = FALSE)
ggsave('plots/adult_bench_threeway.png', width=18, height=12)
