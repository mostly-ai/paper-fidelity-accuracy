
# conda create -y -n sdv python==3.7.7
# conda activate sdv
# pip install sdv==0.7.0

import pandas as pd
import numpy as np
import torch
import time
from sdv.single_table import CTGANSynthesizer
from sdv.metadata import SingleTableMetadata

#datasets = ['adult', 'bank-marketing', 'online-shoppers', 'credit-default']
datasets = ['online-shoppers', 'credit-default']

start = time.time()

for dataset in datasets:
    print('CTGAN ' + dataset)
    np.random.seed(0)
    torch.manual_seed(0)
    data = pd.read_csv('../data/' + dataset + '_trn.csv.gz')
# the SDV metadata generator overrides these dtypes
#    if dataset == 'credit-default':
#        data = data.astype({'SEX': 'object', 'EDUCATION': 'object', 'MARRIAGE': 'object'})
    metadata = SingleTableMetadata()
    metadata.detect_from_dataframe(data=data) 
    if dataset == 'credit-default':
        # we need to set SEX, EDUCATION and MARRIAGE to categorical manually here
        for col in ['SEX', 'EDUCATION', 'MARRIAGE']:
            metadata.update_column(
                column_name=col,
                sdtype='categorical'
            )
    model = CTGANSynthesizer(metadata)
    model.fit(data)
    samples = model.sample(50000)
    samples.to_csv('../data_new/' + dataset + '_ctgan.csv.gz', index=False)

end = time.time()
elapsed = end - start
print('The CTGAN synthetic data generation took ' + str(elapsed) + 'seconds.')