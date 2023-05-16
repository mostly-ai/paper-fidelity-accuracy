
# conda create -y -n synthcity python==3.9
# conda activate synthcity
# pip install synthcity

import pandas as pd
from synthcity.plugins import Plugins
import pandas as pd
import time

for dataset in ['adult', 'credit-default', 'bank-marketing', 'online-shoppers']:
    print(dataset)
    df = pd.read_csv(f'../data/{dataset}_trn.csv.gz')
    #df = df.head(100)[list(df.columns)[:3]]
    m = Plugins().get("rtvae")
    t0 = time.time()
    m.fit(df)
    print(f'trained in {time.time()-t0}')
    t0 = time.time()
    s = m.generate(count=50_000).dataframe()
    print(f'generated in {time.time()-t0}')
    s.to_csv(f'../data/{dataset}_synthcity-rtvae.csv.gz', index=False)


# NVIDIA V100
# adult:           train 32min, gen 4s
# credit-default:  train 18min, gen 4s
# bank-marketing:  train 24min, gen 4s
# online-shoppers: train  8min, gen 4s
