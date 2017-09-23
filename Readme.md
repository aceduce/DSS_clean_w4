# Readme
***
This file explains how the code achieve it's goal to clean the dataset. 

The output `tidy_data.txt`  contains the average and standard deviations of the measurment variables organized by activities and subjects. 

In the code, I did following actions:

1. Download and unzip the date file from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

2. Read the feature file and activity labels. When reading the feature file, I choose only "mean" and "std" by `grep`, since we're only interested in those parameters.

3. Read the training and test data separately and combine them to achieve one data set. 

4. Merge the combined dataset with the activity label information, as we need "descriptive activites" rather than numerical form for the final ouput to show the activities. 

5. Summarize the dataset with the functions from `reshape2` library, with `melt` and `decast` functions. 

6. The appropriate labels are used for column names.

7. Output the clean data into `txt` file.
