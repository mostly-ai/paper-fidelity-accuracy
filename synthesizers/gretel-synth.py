
# conda create -y -n gretel python==3.8
# conda activate gretel
# git clone https://github.com/gretelai/gretel-synthetics
# cd gretel-synthetics
# git checkout bf7aa643e7fc0bd7a06e07da3609c4ae59cd79e1
### for CPU
# pip install -r requirements.txt
# pip install -U .
### for GPU
# bash ./setup-utils/setup-gretel-synthetics-tensorflow24-with-gpu.sh


from pathlib import Path
import os
import pandas as pd
from gretel_synthetics.batch import DataFrameBatch

datasets = ['adult', 'credit-default', 'bank-marketing', 'online-shoppers']
for dataset in datasets:
    print('GRETEL ' + dataset)
    data = pd.read_csv('../data_new/' + dataset + '_trn.csv.gz')
    model_dir = str(Path.cwd() / "models" / "gretel" / dataset)
    if not os.path.exists(model_dir):
        os.makedirs(model_dir)
    config_template = {
            "field_delimiter": ",",
            "overwrite": True,
            "checkpoint_dir": model_dir
    }
    batcher = DataFrameBatch(df=data, config=config_template)
    batcher.create_training_data()
    batcher.train_all_batches()
    batcher.generate_all_batch_lines(num_lines=50000, max_invalid=50000, parallelism=0)
    samples = batcher.batches_to_df()
    samples.to_csv('../data_new/' + dataset + '_gretel.csv', index=False)
