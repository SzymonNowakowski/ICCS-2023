# ICCS-2023

Supplementary material to *Improving Group Lasso for high-dimensional categorical data* submitted to International Conference on Computational Science 2023.

Contents of this repository:

- supplement to the submitted paper (`supplement.pdf`)

- the code to reproduce the simulation results

## Authors

- Szymon Nowakowski

  Institute of Applied Mathematics and Mechanics, University of Warsaw, Banacha 2, 02-097
  Warsaw, Poland 
  
  Faculty of Physics, University of Warsaw, Pasteura 5, 02-093 Warsaw, Poland

- Piotr Pokarowski

  Institute of Applied Mathematics and Mechanics, University of Warsaw, Banacha 2, 02-097
  Warsaw, Poland 

- Wojciech Rejchel

  Faculty of Mathematics and Computer Science, Nicolaus Copernicus University, Chopina 12/18,
  87-100, Torun, Poland

- Agnieszka Sołtys

  Institute of Applied Mathematics and Mechanics, University of Warsaw, Banacha 2, 02-097
  Warsaw, Poland 

## Synthetic experiments 

To reproduce synthetic experiment results:

1. Enter into `synthetic_experiments` directory:
   ```{bash}
   cd synthetic_experiments
   ```

2. Update `run_synthetic.slurm` file to match your computation cluster settings

3. To get synthetic experiment results computed, run:
   ```{bash}
   ./run_synthetic.sh
   ```

4. After computations has finished, which may take up to a few days, run `postscripts.R` script to generate resulting plots and computation time statistics, with a command:
   ```{bash}
   Rscript postscripts.R
   ```

   `postscripts.R`script reads the contents of `results_iccs` directory (where all the result files of synthetic numeric simulations get written to), prints out median wall times and produces two plots: `ICCS_RMSE.ps` and `ICCS_MD.ps`.  

## Real data experiments

After having completed numeric simulations for all data sets (all sections below) which may take up to a few days, run `postscripts.R`script from `real_data_experiments` directory to generate the resulting plot, with commands:

```{bash}
cd real_data_experiments
Rscript postscripts.R
```

`postscripts.R`script reads the contents of `results` directory (where all the result files of numeric simulations with real data get written to) and produces a `pic_full_names.ps` plot. 

### Airbnb data set

To preprocess the data, follow instructions from [Kalehbasti et al. GitHub](https://github.com/PouyaREZ/AirBnbPricePrediction) (I have mirrored and then updated/fixed some of their GitHub files)

1.  Enter into `real_data_experiments/airbnb_preprocess` directory:
    ```{bash}
    cd real_data_experiments/airbnb_preprocess
    ```

2.  ```{bash}
    mkdir ../Data
    ```

3.  Download the two data files (files `listings.csv` and `reviews_original.csv`) into the `Data` directory created in the previous step [from this link](https://drive.google.com/drive/folders/1xk5RyR-UgF6M-ddhn11SXHEWJeB0fQo5?usp=sharing)

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

10. To get the Airbnb results computed, run:
    ```{bash}
    mkdir results
    Rscript airbnb.R
    ```
    or, alternatively, run the distributed computations (making sure the `run_something.slurm` file matches your computation cluster settings) with:
    ```{bash}
    ./run_airbnb.sh
    ```
    this last command runs `run_something.sh` script with appropriate parameters, which in turn creates a SLURM job with `run_something.slurm` file.

11. In case of a cluster-based distributed computations, one must manually concatenate the 20 result files 
    


### Antigua data set

To get the Antigua results computed, run:
```{bash}
cd real_data_experiments
mkdir results
Rscript antigua.R
```

There is no parallel distributed computation runner, as the computation time is relatively short.

### Insurance data set

1.  Enter `real_data_experiments` directory:
    ```{bash}
    cd real_data_experiments
    ```

2.  Create all necessary subdirectories:
    ```{bash}
    mkdir results
    mkdir data_insurance
    ```

3.  Download the `test.csv` into the `data_insurance` directory created in a previous step from [this Kaggle link](https://www.kaggle.com/c/prudential-life-insurance-assessment/data)

4.  To get the Insurance results computed, run:
    ```{bash}
    Rscript insurance.R
    ```
    or, alternatively, run the distributed computations (making sure the `run_something.slurm` file matches your computation cluster settings) with:
    ```{bash}
    ./run_insurance.sh
    ```
    this last command runs `run_something.sh` script with appropriate parameters, which in turn creates a SLURM job with `run_something.slurm` file.

5. In case of a cluster-based distributed computations, one must manually concatenate the 20 result files 



### Adult data set

1.  To get the Adult results computed, run:
    ```{bash}
    cd real_data_experiments
    mkdir results
    Rscript adult.R
    ```
    or, alternatively, run the distributed computations (making sure the `run_something.slurm` file matches your computation cluster settings) with:
    ```{bash}
    cd real_data_experiments
    ./run_adult.sh
    ```
    this last command runs `run_something.sh` script with appropriate parameters, which in turn creates a SLURM job with `run_something.slurm` file.

2. In case of a cluster-based distributed computations, one must manually concatenate the 20 result files 

### Promoter data set

1.  To get the Promoter results computed, run:
    ```{bash}
    cd real_data_experiments
    mkdir results
    Rscript promoter.R
    ```
    or, alternatively, run the distributed computations (making sure the `run_something.slurm` file matches your computation cluster settings) with:
    ```{bash}
    cd real_data_experiments
    ./run_promoter.sh
    ```
    this last command runs `run_something.sh` script with appropriate parameters, which in turn creates a SLURM job with `run_something.slurm` file.

2. In case of a cluster-based distributed computations, one must manually concatenate the 50 result files 
