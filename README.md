# ICCS-2023

The code to reproduce the results from *Improving Group Lasso for high-dimensional categorical data*.

## Synthetic experiments

To reproduce synthetic experiment results:

1. Enter into `synthetic_experiments` directory:
   ```{bash}
   cd synthetic_experiments
   ```
2. Update `runme.slurm` file to match your computation cluster settings
3. To get synthetic experiment results computed, run:
   ```{bash}
   ./runme.sh
   ```
4. After computations has finished, which may take up to a few days, run `postscripts.R` script to generate resulting plots and computation time statistics, with a command:
   ```{bash}
   Rscript postscripts.R
   ```


## Real dataset experiments

After having completed calculations for all datasets (all sections below) which may take up to a few days, run `postscripts.R`script from `real_data_experiments` directory to generate resulting plot, with a command:

```{bash}
cd real_data_experiments
Rscript postscripts.R
```

### Airbnb dataset

To preprocess the data, follow instructions from [Kalehbasti et al. GitHub](https://github.com/PouyaREZ/AirBnbPricePrediction) (I have mirrored and then updated/fixed some of their GitHub files)

1.  Enter into `real_data_experiments/airbnb_preprocess` directory:
    ```{bash}
    cd real_data_experiments/airbnb_preprocess
    ```
2.  ```{bash}
    mkdir ../Data
    ```
3.  Download the datasets (files `listings.csv` and `reviews_original.csv`) into the `Data` directory created in the previous step [from this link](https://drive.google.com/drive/folders/1xk5RyR-UgF6M-ddhn11SXHEWJeB0fQo5?usp=sharing)
4.  ```{bash}
    mkdir ./venv
    python3 -m venv ./venv/airbnb
    source ./venv/airbnb/bin/activate
    pip install -r requirements.txt
    ```
5.  Generate a file with review sentiment (it creates `reviews_cleaned.csv`): 
    ```{bash}
    python sentiment_analysis.py
    ``` 
6.  Clean the data (it creates `data_cleaned.csv`): 
    ```{bash}
    python data_cleanup.py
    ``` 
7.  Normalize and split the data (it creates 6 `data_cleaned_*_comments_X.csv` and `data_cleaned_*_y.csv` files): 
    ```{bash}
    python data_preprocessing_reviews.py
    ```
8.  ```{bash}
    cd ..
    ```
9.  Create the `data_airbnb` folder & move the 6 final data files into `data_airbnb` folder:
    ```{bash}
    mkdir data_airbnb
    mv Data/data_cleaned_*.csv data_airbnb
    ```
10. To get the airbnb results computed, run:
    ```{bash}
    mkdir results
    Rscript airbnb.R
    ```
    or, alternatively, run the distributed computations (making sure the `run_something.slurm` file matches your computation cluster settings) with:
    ```{bash}
    ./run_airbnb.sh
    ```
    this last command runs `run_something.sh` script with appropriate parameters, which in turn creates a SLURM job with `run_something.slurm` file.
11. In case of a cluster distributed computations, one must manually concatenate the result files 
    


### Antigua dataset

To get the antigua results computed, run:
```{bash}
mkdir results
Rscript antigua.R
```

There is no parallel distributed computation runner, as the computation time is relatively short.

### Adult dataset

1.  To get the adult results computed, run:
    ```{bash}
    mkdir results
    Rscript adult.R
    ```
    or, alternatively, run the distributed computations (making sure the `run_something.slurm` file matches your computation cluster settings) with:
    ```{bash}
    ./run_adult.sh
    ```
    this last command runs `run_something.sh` script with appropriate parameters, which in turn creates a SLURM job with `run_something.slurm` file.
2. In case of a cluster distributed computations, one must manually concatenate the result files 
