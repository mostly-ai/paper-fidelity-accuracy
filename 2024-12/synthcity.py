from synthcity.plugins import Plugins
import pandas as pd
import time

for dataset in ['adult', 'credit-default', 'bank-marketing', 'online-shoppers']:
    print(dataset)
    df = pd.read_csv(f'{dataset}_trn.csv.gz')
    plugins = ["ctgan", "ddpm", "bayesian_network", "arf", "nflow"]
    for p in plugins:
      m = Plugins().get(p)
      t0 = time.time()
      try:
        m.fit(df)
      except Exception as e:
        print(e)
        continue
      tt = time.time() - t0
      t0 = time.time()
      s = m.generate(count=df.shape[0]).dataframe()
      gt = time.time() - t0
      fn = f'{dataset}_synthcity-{p}.csv.gz'
      print(f'{fn} {tt:.3f} {gt:.3f}')
      s.to_csv(fn, index=False)

# FILE                                                 TRAIN  GENERATE
# adult_synthcity-ctgan.csv.gz                        1230.6       0.2
# adult_synthcity-ddpm.csv.gz                          601.6     162.1
# adult_synthcity-bayesian_network.csv.gz               30.2       5.5
# adult_synthcity-arf.csv.gz                           628.9      79.9
# adult_synthcity-nflow.csv.gz                        1304.5      14.0

# credit-default_synthcity-ctgan.csv.gz               1980.6       0.2
# credit-default_synthcity-bayesian_network.csv.gz     103.0     153.2
# credit-default_synthcity-arf.csv.gz                  715.2     105.2

# bank-marketing_synthcity-bayesian_network.csv.gz      28.5       8.1
# bank-marketing_synthcity-arf.csv.gz                  339.4      95.7

# online-shoppers_synthcity-bayesian_network.csv.gz     14.7       9.6
# online-shoppers_synthcity-arf.csv.gz                 152.0      37.2
