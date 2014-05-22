README
========================================================

run_analysis.R does the following:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive activity names. 
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

How it Works
-------------------------
The script is broken into four large steps: 

### Step 1. Get the Raw Data Files
If the files do not exist in the user's working directory they are downloaded and unzipped.  The raw data will be in the "UCI HAR Dataset" directory found in the working directory.

### Step 2. Combine & Transform the Raw Data Files
The script combines 8 text files into a data frame called data.

The following image show how the raw data files relate to the data object created by the run_analysis.R script:
![Data Layout](http://coursera-forum-screenshots.s3.amazonaws.com/d3/2e01f0dc7c11e390ad71b4be1de5b8/Slide2.png)

Underscores were removed from the activity labels (found in activity_labels.txt) and they were put into lower case letters.

In naming the variables I followed the guidelines in the [Google R style guide](https://google-styleguide.googlecode.com/svn/trunk/Rguide.xml).

The variable names found in features.txt were "scrubbed" using the scrubber function found in run_analysis.R.  It creates human readable descriptive variable names.  For a full description of the variables I would refer you to the CodeBook.md file.

Since we only wanted to extract the mean and the standard deviation variables, and they were denoted in features.txt by mean() and std(), the script identifies them using grep.  Variables with meanFreq in thier name were exclude.

Once this step is complete data should have 10,299 observations and 69 variables.

### Step 3. Create the Tidy Data Set
Once the data was scrubbed, a tidy data set was created with the average of each variable for each activity and each subject.

```{r}
tidy.data <- aggregate(.~ subject.id + activity, data = data, FUN = mean)
```
The activity.id variable is dropped from the tidy data set.

Once this step is complete tidy.data should have 180 observations and 68 variables.

### Step 4. Export the Tidy Data Set
Once this is accomplished the file is exported at a tab deliminated file.

```{r}
write.table(tidy.data, "tidydata.txt", sep="\t")
```