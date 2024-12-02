from pathlib import Path
import numpy as np
import pandas as pd
from mostlyai import qa

path = Path('data')

rows = []
for dataset in ['adult', 'bank-marketing', 'credit-default', 'online-shoppers']:
    fns = list(path.glob(f'{dataset}*mostlyai*'))
    for fn in fns:
        trn_tgt_df = pd.read_csv(path / f'{dataset}_trn.csv.gz').head(100)
        hol_tgt_df = pd.read_csv(path / f'{dataset}_hol.csv.gz').head(100)
        html, metrics = qa.report(
            syn_tgt_data = pd.read_csv(fn).head(100),
            trn_tgt_data = trn_tgt_df,
            hol_tgt_data = hol_tgt_df,
        )
        row = pd.json_normalize(metrics.model_dump())
        row.columns = [c.split('.')[1] for c in row.columns]
        row.insert(0, 'file', str(fn.name))
        row.insert(1, 'dataset', dataset)
        row.insert(2, 'TRAIN', np.nan)
        row.insert(3, 'GENERATE', np.nan)
        rows += [row]

df = pd.concat(rows)
df.to_csv('mostly.csv', index=False)
