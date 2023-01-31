import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import random
from sklearn.model_selection import train_test_split
from sklearn import preprocessing
#caller.set_index('key').join(other.set_index('key'))


random.seed(13)


def normalize(X_train, X_val, X_test):
    X_train_normalized = X_train.values.astype(float)
    min_max_scaler = preprocessing.MinMaxScaler()

    # Create an object to transform the data to fit minmax processor
    x_scaled = min_max_scaler.fit_transform(X_train_normalized)

    # Run the normalizer on the dataframe
    x = pd.DataFrame(x_scaled, columns=X_train.columns)

    X_val_normalized = X_val.values.astype(float)
    min_max_scaler = preprocessing.MinMaxScaler()

    # Create an object to transform the data to fit minmax processor
    x_val_scaled = min_max_scaler.fit_transform(X_val_normalized)

    # Run the normalizer on the dataframe
    x_v = pd.DataFrame(x_val_scaled, columns=X_val.columns)

    X_test_normalized = X_test.values.astype(float)
    min_max_scaler = preprocessing.MinMaxScaler()

    # Create an object to transform the data to fit minmax processor
    x_test_scaled = min_max_scaler.fit_transform(X_test_normalized)

    # Run the normalizer on the dataframe
    x_t = pd.DataFrame(x_test_scaled, columns=X_test.columns)
    return x, x_v, x_t



def split(dataset, val_frac=0.10, test_frac=0.10):
    X = dataset.loc[:, dataset.columns != 'price']
    X = X.loc[:, X.columns != 'id']
    X = X.loc[:, X.columns != 'host_id']
    X = X.loc[:, X.columns != 'country']
    X = X.loc[:, X.columns != 'street']
    X = X.loc[:, X.columns != 'neighbourhood']
    X = X.loc[:, X.columns != 'Unnamed: 0']

    y = dataset['price']

    h = dataset[['host_id', 'country', 'street', 'neighbourhood']]

    X_train, X_test, y_train, y_test, h_train, h_test = train_test_split(X, y, h, test_size=(val_frac+test_frac), random_state=1)
    X_test, X_val, y_test, y_val, h_test, h_val = train_test_split(X_test, y_test, h_test, test_size=val_frac/(val_frac+test_frac), random_state=1)

    return X_train, y_train, h_train, X_val, y_val, h_val, X_test, y_test, h_test


if __name__ == "__main__":

    dataset = pd.read_csv('../Data/data_cleaned.csv')

    X_train, y_train, h_train, X_val, y_val, h_val, X_test, y_test, h_test = split(dataset)
    
    X_train, X_val, X_test = normalize(X_train, X_val, X_test)

    X_train.reset_index(drop=True, inplace=True)
    X_val.reset_index(drop=True, inplace=True)
    X_test.reset_index(drop=True, inplace=True)
    h_train.reset_index(drop=True, inplace=True)
    h_val.reset_index(drop=True, inplace=True)
    h_test.reset_index(drop=True, inplace=True)

    X_train = pd.concat([h_train, X_train], axis=1)
    X_val = pd.concat([h_val, X_val], axis=1)
    X_test = pd.concat([h_test, X_test], axis=1)

    X_train.to_csv('../Data/data_cleaned_train_comments_X.csv', header=True, index=False)
    y_train.to_csv('../Data/data_cleaned_train_y.csv', header=True, index=False)
    
    X_val.to_csv('../Data/data_cleaned_val_comments_X.csv', header=True, index=False)
    y_val.to_csv('../Data/data_cleaned_val_y.csv', header=True, index=False)

    X_test.to_csv('../Data/data_cleaned_test_comments_X.csv', header=True, index=False)
    y_test.to_csv('../Data/data_cleaned_test_y.csv', header=True, index=False)

    pass
