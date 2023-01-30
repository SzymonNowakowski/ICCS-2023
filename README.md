# ICCS-2023
The code to reproduce the results from *Improving Group Lasso for high-dimensional categorical data*.

## Real datasets

### Airbnb dataset

To preprocess the data, follow instructions from [Kalehbasti et al. GitHub](https://github.com/PouyaREZ/AirBnbPricePrediction) (I have mirrored and then updated/fixed some of their GitHub files) 

1. `cd airbnb_preprocess`
2. `mkdir ../Data`
3. download the datasets (files `listings.csv` and `reviews_original.csv`) into the `Data` directory [from this link](https://drive.google.com/drive/folders/1xk5RyR-UgF6M-ddhn11SXHEWJeB0fQo5?usp=sharing)
4. ```
   python3 -m venv ~/venv/airbnb
   source ~/venv/airbnb/bin/activate
   pip install -r requirements.txt
   ```
5. Generate a file with review sentiment: `python sentiment_analysis.py` (creates `reviews_cleaned.csv`)
6. Clean the data: `python data_cleanup.py` (creates `data_cleaned.csv`)
7. Normalize and split the data: `python data_preprocessing_reviews.py` 
   (it creates 6 `data_cleaned_*_comments_X.csv` and `data_cleaned_*_y.csv` files)
8. `cd ..`
9. Create the `data_airbnb` folder & move the 6 final data files into `data_airbnb` folder
10. Source `airbnb.R` in `R` to get the airbnb results computed.

