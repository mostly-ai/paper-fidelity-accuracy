
# conda create -y -n sdv python==3.7.7
# conda activate sdv
# pip install sdv==0.7.0

import pandas as pd
import numpy as np
import torch
from sdv.single_table import CopulaGANSynthesizer
from sdv.metadata import SingleTableMetadata


datasets = ['adult', 'credit-default', 'bank-marketing', 'online-shoppers']

for dataset in datasets:
    print('CopulaGAN ' + dataset)
    np.random.seed(0)
    torch.manual_seed(0)
    data = pd.read_csv('../data_new/' + dataset + '_trn.csv.gz')
    # if dataset == 'credit-default':
    #     data = data.astype({'SEX': 'object', 'EDUCATION': 'object', 'MARRIAGE': 'object'})
    metadata = SingleTableMetadata()
    metadata.detect_from_dataframe(data=data) 
    if dataset == 'credit-default':
        # we need to set SEX, EDUCATION and MARRIAGE to categorical manually here
        for col in ['SEX', 'EDUCATION', 'MARRIAGE']:
            metadata.update_column(
                column_name=col,
                sdtype='categorical'
            )
    # set model settings
    model = CopulaGANSynthesizer(metadata)
    model.fit(data)
    samples = model.sample(50000)
    samples.to_csv('../data_new/' + dataset + '_copulagan.csv', index=False)
