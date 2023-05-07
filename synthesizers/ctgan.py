
# conda create -y -n sdv python==3.7.7
# conda activate sdv
# pip install sdv==0.7.0

import pandas as pd
import numpy as np
import torch
from sdv.tabular import CTGAN

datasets = ['adult', 'marketing', 'online-shoppers', 'credit-default']

for dataset in datasets:
    print('CTGAN ' + dataset)
    np.random.seed(0)
    torch.manual_seed(0)
    data = pd.read_csv('../data_new/' + dataset + '_trn.csv.gz')
    if dataset == 'credit-default':
        data = data.astype({'SEX': 'object', 'EDUCATION': 'object', 'MARRIAGE': 'object'})
    model = CTGAN(verbose=True)
    model.fit(data)
    samples = model.sample(50000)
    samples.to_csv('../data_new/' + dataset + '_ctgan.csv', index=False)
