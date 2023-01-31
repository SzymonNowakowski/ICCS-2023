# ICCS-2023

The code to reproduce the results from *Improving Group Lasso for high-dimensional categorical data*.

## Synthetic experiments

To reproduce synthetic experiment results:
1. enter into `synthetic_experiments` directory:
   ```{bash}
   cd synthetic_experiments
   ```
2. update `runme.slurm` file to match your computation cluster settings
3. `./runme.sh`
4. After computations are finished, which may take up to a few days, run `Rscript postscripts.R` to produce resulting plots and computation time statistics


## Real dataset experiments

### Airbnb dataset

To preprocess the data, follow instructions from [Kalehbasti et al. GitHub](https://github.com/PouyaREZ/AirBnbPricePrediction) (I have mirrored and then updated/fixed some of their GitHub files)

1.  ```{bash}
    cd real_data_experiments/airbnb_preprocess
    ```

2.  ```{bash}
    mkdir ../Data
    ```

3.  download the datasets (files `listings.csv` and `reviews_original.csv`) into the `Data` directory [from this link](https://drive.google.com/drive/folders/1xk5RyR-UgF6M-ddhn11SXHEWJeB0fQo5?usp=sharing)

4.  ```{bash}
       python3 -m venv ~/venv/airbnb
       source ~/venv/airbnb/bin/activate
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

9.  Create the `data_airbnb` folder & move the 6 final data files into `data_airbnb` folder

10. Run `Rscript airbnb.R` to get the airbnb results computed
