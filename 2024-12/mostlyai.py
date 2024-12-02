from mostlyai import MostlyAI

mostly = MostlyAI()

for dataset in ['adult', 'bank-marketing', 'credit-default', 'online-shoppers']:
    fn = f'/Users/mplatzer/github/paper-fidelity-accuracy/2024-12/data/{dataset}_trn.csv.gz'
    for dp in [True, False]:
        g = mostly.train(config={
            'name': f'{dataset} DP={dp}',
            'tables': [
                {
                    'name': dataset,
                    'data': fn,
                    'model_configuration': {
                        'max_training_time': 60,
                        'differential_privacy': {} if dp else None
                    }
                }
            ]
        }, wait=False)
        sd = mostly.generate(g, wait=False)
