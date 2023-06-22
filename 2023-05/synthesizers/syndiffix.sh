dotnet run ~/github/paper-fidelity-accuracy/2023-05/data/adult_trn.csv --columns age:i workclass:s fnlwgt:i education:s education-num:i marital-status:s occupation:s relationship:s race:s sex:s capital-gain:i capital-loss:i hours-per-week:i native-country:s income:s --verbose > ~/github/paper-fidelity-accuracy/2023-05/data/adult_syndiffix.csv
dotnet run ~/github/paper-fidelity-accuracy/2023-05/data/bank-marketing_trn.csv --columns age:i job:s marital:s education:s default:s balance:i housing:s loan:s contact:s day:i month:s duration:i campaign:i pdays:i previous:i poutcome:s y:s --verbose > ~/github/paper-fidelity-accuracy/2023-05/data/bank-marketing_syndiffix.csv
dotnet run ~/github/paper-fidelity-accuracy/2023-05/data/credit-default_trn.csv --columns LIMIT_BAL:r SEX:i EDUCATION:i MARRIAGE:i AGE:i PAY_0:i PAY_2:i PAY_3:i PAY_4:i PAY_5:i PAY_6:i BILL_AMT1:i BILL_AMT2:r BILL_AMT3:r BILL_AMT4:r BILL_AMT5:r BILL_AMT6:r PAY_AMT1:r PAY_AMT2:r PAY_AMT3:r PAY_AMT4:r PAY_AMT5:r PAY_AMT6:r default_payment_next_month:i --verbose > ~/github/paper-fidelity-accuracy/2023-05/data/credit-default_syndiffix.csv
dotnet run ~/github/paper-fidelity-accuracy/2023-05/data/online-shoppers_trn.csv --columns Administrative:i Administrative_Duration:r Informational:i Informational_Duration:r ProductRelated:i ProductRelated_Duration:r BounceRates:r ExitRates:r PageValues:r SpecialDay:r Month:s OperatingSystems:i Browser:i Region:i TrafficType:i VisitorType:s Weekend:b Revenue:b --verbose > ~/github/paper-fidelity-accuracy/2023-05/data/online-shoppers_syndiff.csv