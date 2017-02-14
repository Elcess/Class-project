## Code book for Class Project

This code book modifies and updates text files made available with the original dataset, obtained from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip (Reference: Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012)

The original data used came from 8 files:
 1. "activity_labels.txt" linked the class labels (IDs) with their activity names.
 2. "subject_test.txt" listed the subject ID for the subject who performed the activity for each window sample in the test set. Its range was 1 to 30.
 3. "subject_train.txt" listed the subject ID for the subject who performed the activity for each window sample in the training set. Its range was 1 to 30.
 4. "y_test.txt" provided activity IDs for each window sample in the test set. Its range was 1 to 6.
 5. "y_train.txt" provided activity IDs for each window sample in the training set. Its range was 1 to 6.
 6. "X_test.txt" provided measurements for a vector of 561 features in the test set. Each measurement was normalized and bounded within [-1, 1].
 7. "X_train.txt" provided measurements for a vector of 561 features in the training set. Each measurement was normalized and bounded within [-1, 1].
 8. "features.txt" provided variable names for each of the 561 features in the dataset.

=====================================================================

New data files were produced in the course of executing the Class Project, Tasks 1 through 4 (producing a tidy data set containing only measurements for means and standard deviations from the original dataset, with test and training sets merged to create a single dataset). The output files for these tasks are:
 1. "activitytable.txt" links the activity IDs with their activity names. Its dimensions are 6 rows by 2 columns.
 2. "subjectIDtable.txt" lists the subject ID for the subject who performed the activity for each window sample in the merged dataset. Its range is 1 to 30.
 3. "activityIDtable.txt" provides the activity ID for each window sample in the merged dataset. Its range is 1 to 6.
 4. "datasettable.txt" contains a data table with the activity, subject ID, and 66 variables selected from the original dataset. Each measurement was normalized and bounded within [-1, 1]. Its dimensions are 10299 rows by 68 columns.
 5. "variablestable.txt" provides variable names for each of the 68 columns in the dataset, including the activity, the subject ID, and 66 measurements (features or variables). This file is available in Appendix A of this code book.

All processing of the data was done in R and is documented in the R script "run_analysis.R" Prior to beginning the tasks, basic housekeeping was performed. A working directory was selected to received the data and several packages for working with data and data tables were loaded, along with their dependencies. Packages "data.table," "DBI," "dplyr," and "readr" were used; other choices could have been made.

To obtain the data for the first four tasks, the datafile was downloaded as  a .zip file using download.file(), and unzipped using unzip() with the "junkpaths = TRUE" option to place all the files in the same (working) directory. Test and train data tables were read from the corresponding text files using fread(). The data tables were merged individually row-wise using rbind() to create a single dataset from the test and training sets of the original data.

After consulting the "features_info.txt" and "features.txt" files, the columns containing means and standard deviations were identified and loaded into a selection vector, "msdcolumns." The 66 of the 561 original feature columns containing mean and standard deviation measurements were retained using the select() function.

Activity names were changed to lowercase using tolower(), and underscores in activity names were removed using gsub(). Names were added to the "y" data table and the activitytable for use in joining. Activity IDs were replaced by activity names using a join() operation on the "y" dataset with the activitytable. A name was also added to the subject ID ("s") data table. The measurement dataset was then updated using cbind() to add columns for the activity names and the subject IDs.

Names for the remaining columns were obtained by reading "features.txt" into a data table ("features"), selecting only the second column of "features" (containing the feature names), and selecting only the features of interest by using slice() with the msdcolumns selector. The resulting character vector was used to set the names of columns 3 to 68 of the "x" data table. Variable names, including the activity and subjectID as well as the feature names, were assigned to a character vector. Data was written to text files using write.table() to produce the five output tables mentioned previously.

=====================================================================

Task 5 of the Class Project was to create a second, independent tidy data set with the average of each variable for each activity and each subject. This was interpreted as meaning that for each activity-subject ID pair a mean was to be taken of all 66 remaining measurements, and the results stored in a data table along with corresponding activity names and subject IDs.

After making a copy of the "x" dataset at the end of Task 4, and to facilitate the use of a loop, the (character) "activity" column was replaced by an (integer) "activityID" column. Although the number of distinct activities and subjects was known, the R code allows for a variable number of each. The range for the subjectID (inner) loop was determined by taking the length of the vector of unique subjectIDs, while that for the activityID (outer) loop was obtained in a similar manner using the unique activityIDs. A tracking variable was set to obtain the number of times the inner loop executed for each value of the outer loop in case not all subjects had entries for all activities. Averages for the measurements were calculated by using the colMeans() function for the selection of observations for which both the activityID and the subject ID matched those for the observation. [Note: It is not clear that averaging standard deviations is a statistically valid operation. Nevertheless, that was the task.] Each pass through the inner loop produced a row vector which was added to the "xmeans" matrix using rbind(). The tracking variable was used to add subjectIDs and activityIDs to separate columns.

At the end of the loop, the index column vectors and the "xmeans" matrix were reclassified as data frames using data.frame(). The activity and subject ID columns were named and activity names recovered using a join() operation. The full dataset was obtained by using cbind() to add the activity and subjectID columns to the calculated variables. Feature (variable) names were modified to reflect that an average had been taken by prefixing "Avg" to each of the original variable names using gsub(). The dataset was named using the new variable names and the new variable names were added to a character vector.

Although the data frame "xmeans" contains the complete dataset, five text files were output for consistency with Task 4. They are:
 1. "activitytable-means.txt" links the activity IDs with their activity names. Its dimensions are 6 rows by 2 columns.
 2. "subjectIDtable-means.txt" lists the subject ID for the subject who performed the activity for each row in the calculated dataset. Its range is 1 to 30.
 3. "activityIDtable-means.txt" provides the activity ID and activity name for row in the calculated dataset. Its dimensions are 180 rows by 2 columns.
 4. "datasettable-means.txt" contains a data table with the activity, subject ID, and 66 variables selected from the calculated dataset. Its dimensions are 180 rows by 68 columns.
 5. "variablestable-means.txt" provides variable names for each of the 68 columns in the dataset, including the activity, the subject ID, and 66 measurements (features or variables). This file is available in Appendix B of this code book.

## Appendix A: Variable names for the data frame at the end of Task 4

From "variablestable.txt"

variablename

1 activity

2 subjectID

3 tBodyAcc-mean()-X

4 tBodyAcc-mean()-Y

5 tBodyAcc-mean()-Z

6 tBodyAcc-std()-X

7 tBodyAcc-std()-Y

8 tBodyAcc-std()-Z

9 tGravityAcc-mean()-X

10 tGravityAcc-mean()-Y

11 tGravityAcc-mean()-Z

12 tGravityAcc-std()-X

13 tGravityAcc-std()-Y

14 tGravityAcc-std()-Z

15 tBodyAccJerk-mean()-X

16 tBodyAccJerk-mean()-Y

17 tBodyAccJerk-mean()-Z

18 tBodyAccJerk-std()-X

19 tBodyAccJerk-std()-Y

20 tBodyAccJerk-std()-Z

21 tBodyGyro-mean()-X

22 tBodyGyro-mean()-Y

23 tBodyGyro-mean()-Z

24 tBodyGyro-std()-X

25 tBodyGyro-std()-Y

26 tBodyGyro-std()-Z

27 tBodyGyroJerk-mean()-X

28 tBodyGyroJerk-mean()-Y

29 tBodyGyroJerk-mean()-Z

30 tBodyGyroJerk-std()-X

31 tBodyGyroJerk-std()-Y

32 tBodyGyroJerk-std()-Z

33 tBodyAccMag-mean()

34 tBodyAccMag-std()

35 tGravityAccMag-mean()

36 tGravityAccMag-std()

37 tBodyAccJerkMag-mean()

38 tBodyAccJerkMag-std()

39 tBodyGyroMag-mean()

40 tBodyGyroMag-std()

41 tBodyGyroJerkMag-mean()

42 tBodyGyroJerkMag-std()

43 fBodyAcc-mean()-X

44 fBodyAcc-mean()-Y

45 fBodyAcc-mean()-Z

46 fBodyAcc-std()-X

47 fBodyAcc-std()-Y

48 fBodyAcc-std()-Z

49 fBodyAccJerk-mean()-X

50 fBodyAccJerk-mean()-Y

51 fBodyAccJerk-mean()-Z

52 fBodyAccJerk-std()-X

53 fBodyAccJerk-std()-Y

54 fBodyAccJerk-std()-Z

55 fBodyGyro-mean()-X

56 fBodyGyro-mean()-Y

57 fBodyGyro-mean()-Z

58 fBodyGyro-std()-X

59 fBodyGyro-std()-Y

60 fBodyGyro-std()-Z

61 fBodyAccMag-mean()

62 fBodyAccMag-std()

63 fBodyBodyAccJerkMag-mean()

64 fBodyBodyAccJerkMag-std()

65 fBodyBodyGyroMag-mean()

66 fBodyBodyGyroMag-std()

67 fBodyBodyGyroJerkMag-mean()

68 fBodyBodyGyroJerkMag-std()

## Appendix B: Variable names for the data frame at the end of Task 5

From "variablestable-means.txt"

variablename

1 activity

2 subjectID

3 AvgtBodyAcc-mean()-X

4 AvgtBodyAcc-mean()-Y

5 AvgtBodyAcc-mean()-Z

6 AvgtBodyAcc-std()-X

7 AvgtBodyAcc-std()-Y

8 AvgtBodyAcc-std()-Z

9 AvgtGravityAcc-mean()-X

10 AvgtGravityAcc-mean()-Y

11 AvgtGravityAcc-mean()-Z

12 AvgtGravityAcc-std()-X

13 AvgtGravityAcc-std()-Y

14 AvgtGravityAcc-std()-Z

15 AvgtBodyAccJerk-mean()-X

16 AvgtBodyAccJerk-mean()-Y

17 AvgtBodyAccJerk-mean()-Z

18 AvgtBodyAccJerk-std()-X

19 AvgtBodyAccJerk-std()-Y

20 AvgtBodyAccJerk-std()-Z

21 AvgtBodyGyro-mean()-X

22 AvgtBodyGyro-mean()-Y

23 AvgtBodyGyro-mean()-Z

24 AvgtBodyGyro-std()-X

25 AvgtBodyGyro-std()-Y

26 AvgtBodyGyro-std()-Z

27 AvgtBodyGyroJerk-mean()-X

28 AvgtBodyGyroJerk-mean()-Y

29 AvgtBodyGyroJerk-mean()-Z

30 AvgtBodyGyroJerk-std()-X

31 AvgtBodyGyroJerk-std()-Y

32 AvgtBodyGyroJerk-std()-Z

33 AvgtBodyAccMag-mean()

34 AvgtBodyAccMag-std()

35 AvgtGravityAccMag-mean()

36 AvgtGravityAccMag-std()

37 AvgtBodyAccJerkMag-mean()

38 AvgtBodyAccJerkMag-std()

39 AvgtBodyGyroMag-mean()

40 AvgtBodyGyroMag-std()

41 AvgtBodyGyroJerkMag-mean()

42 AvgtBodyGyroJerkMag-std()

43 AvgfBodyAcc-mean()-X

44 AvgfBodyAcc-mean()-Y

45 AvgfBodyAcc-mean()-Z

46 AvgfBodyAcc-std()-X

47 AvgfBodyAcc-std()-Y

48 AvgfBodyAcc-std()-Z

49 AvgfBodyAccJerk-mean()-X

50 AvgfBodyAccJerk-mean()-Y

51 AvgfBodyAccJerk-mean()-Z

52 AvgfBodyAccJerk-std()-X

53 AvgfBodyAccJerk-std()-Y

54 AvgfBodyAccJerk-std()-Z

55 AvgfBodyGyro-mean()-X

56 AvgfBodyGyro-mean()-Y

57 AvgfBodyGyro-mean()-Z

58 AvgfBodyGyro-std()-X

59 AvgfBodyGyro-std()-Y

60 AvgfBodyGyro-std()-Z

61 AvgfBodyAccMag-mean()

62 AvgfBodyAccMag-std()

63 AvgfBodyBodyAccJerkMag-mean()

64 AvgfBodyBodyAccJerkMag-std()

65 AvgfBodyBodyGyroMag-mean()

66 AvgfBodyBodyGyroMag-std()

67 AvgfBodyBodyGyroJerkMag-mean()

68 AvgfBodyBodyGyroJerkMag-std()

