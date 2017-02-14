## Class Project for Coursera "Getting and Cleaning Data"

## Initial housekeeping: load packages. Your path(s) may vary.
library("data.table", lib.loc="~/R/win-library/3.3")
library("DBI", lib.loc="~/R/win-library/3.3")
library("dplyr", lib.loc="~/R/win-library/3.3")
library("readr", lib.loc="~/R/win-library/3.3")

## Task 1: Merge the training and the test sets to create one data set.

## Original data obtained from
##      https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
## Reference: Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz.
##      Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine.
##      International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

## Download and unzip data.
destzip <- "UCIHARDataset.zip"
srcurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(srcurl, destzip)          # defaults work well
unzip(destzip, junkpaths = TRUE)        # set junkpaths = TRUE to get all files in the same (working) directory

## After consulting the "README.txt," determine that only 7 files are needed here:
##      "activity_labels.txt" contains a table matching activity IDs with activity labels
##      "subject_test.txt" contains subject IDs for the test data
##      "y_test.txt" contains activity IDs for the test data
##      "X_test.txt" conatins measurements comprising the test data
##      "subject_train.txt" contains subject IDs for the training data
##      "y_train.txt" contains activity IDs for the training data
##      "X_train.txt" conatins measurements comprising the training data
activitytable <- fread("activity_labels.txt")
stest <- fread("subject_test.txt")
ytest <- fread("y_test.txt")
xtest <- fread("X_test.txt")
strain <- fread("subject_train.txt")
ytrain <- fread("y_train.txt")
xtrain <- fread("X_train.txt")

## Merge test and train datasets, in that order.
sDS <- rbind(stest, strain)
yDS <- rbind(ytest, ytrain)
xDS <- rbind(xtest, xtrain)

## More housekeeping: clean up workspace by removing intermediate data tables.
rm("stest", "ytest", "xtest", "strain", "ytrain", "xtrain")

## End Task 1.

## Task 2: Extract only the measurements on the mean and standard deviation for each measurement.

## By consulting "features_info.txt" and "features.txt" we get the columns that contain
##      mean and standard deviation measurements. (66 variables in all)

msdcolumns <- c(1:6, 41:46, 81:86, 121:126, 161:166, 201:202, 214:215, 227:228, 240:241, 253:254, 266:271, 345:350, 424:429, 503:504, 516:517, 529:530, 542:543)
xDS <- select(xDS, msdcolumns)  # select only the columns with mean or standard deviation measurements

## End Task 2.

## Task 3: Use descriptive activity names to name the activities in the data set.

## Clean up activity labels a bit before including them with the measurements.
activitytable$V2 <- tolower(activitytable$V2)           # stop SHOUTing
activitytable$V2 <- gsub("_", "", activitytable$V2)     # remove underscores
names(activitytable) <- c("activityID", "activity")     # add column names for later matching on
names(yDS) <- "activityID"                              # add column name for matching
actlabels <- left_join(yDS, activitytable)              # create a table with activity labels that match the order from yDS;
                                                        #       automatically joins by "activityID," which is what we want

## Add subject IDs and activity labels to dataset for completeness, and use in Task 5.
names(sDS) <- "subjectID"                               # label subject ID column first
xDS <- cbind(actlabels$activity, sDS, xDS)              # add columns to the left of data in table, for ease in Task 5.

## End Task 3.

## Task 4: Appropriately label the data set with descriptive variable names.

## Set up names, using "features.txt" as a guide.
features <- fread("features.txt")                       # read in original variable names
features <- select(features, 2)                         # keep only variable names
features <- slice(features, msdcolumns)                 # select variable names for the mean and standard deviation columns

names(xDS)[3:68] <- features$V2                         # name the columns
names(xDS)[1] <- "activity"                             # column name did not follow over from actlabels$activity
varnames <- names(xDS)                                  # put names of variables into a character vector
varnames <- data.frame(varnames, stringsAsFactors = FALSE)  # make the character vector into a data frame
names(varnames) <- "variablename"                       # name the column

## Write dataset components to text files so they may be read by others.
write.table(activitytable, "activitytable.txt", row.names = FALSE)
write.table(varnames, "variablestable.txt", quote = FALSE, row.names = TRUE)  # provide a listing of variable names
write.table(sDS, "subjectIDtable.txt", row.names = FALSE)       # included for completeness only; already incorporated into data table
write.table(yDS, "activityIDtable.txt", row.names = FALSE)
write.table(xDS, "datasettable.txt", row.names = FALSE)         # contains activity labels, subject IDs, and measurements

## End Task 4.

## Task 5: From the data set in step 4, create a second, independent tidy data set
##      with the average of each variable for each activity and each subject.
##      (Interpreted as obtaining the average for each subject within each activity.)

## Make a copy of the dataset from Task 4.
xDSmsd <- xDS

## Replace activity labels with activity IDs for next step.
xDSmsd <- select(xDSmsd, -1)                    # remove activity labels column
xDSmsd <- cbind(yDS, xDSmsd)                    # add activity ID column

## It's possible that every subject did not have measurements for every activity. Allow for variability.
kcol1 <- length(unique(xDSmsd$activityID))      # get number of unique activities
kcol2 <- length(unique(xDSmsd$subjectID))       # get number of unique subjects

xmeans <- data.frame()                          # set up for later use
xmcol1 <- vector()                              # set up for later use
xmcol2 <- vector()                              # set up for later use
lprev <- 0                                      # set up for later use

## Calculate means for measurements. Note: I'm not sure averaging standard deviations is a statistically valid
##      operation, but it's the task.

for(i in 1:kcol1) {
        l <- 0
        for(j in 1:kcol2) {
                l <- l + 1
                means <- colMeans(xDSmsd[xDSmsd$activityID == i & xDSmsd$subjectID == j,3:68])  # don't average ID columns
                xmeans <- rbind(xmeans, means)             # add calculated means as row to xmeans matrix
        }
        xmcol2[(lprev + 1):(lprev + l)] <- 1:l             # populate subjectID column
        xmcol1[(lprev + 1):(lprev + l)] <- i               # populate activityID column
        lprev <- lprev + l                                 # increment lprev
}

xmcol1 <- data.frame(xmcol1)                            # turn col1 into a data frame
xmcol2 <- data.frame(xmcol2)                            # turn col2 into a data frame
xmeans <- data.frame(xmeans)                            # turn xmeans back into a data frame
names(xmcol1) <- "activityID"                           # label activity ID column
names(xmcol2) <- "subjectID"                            # label subject ID column
actlabelsmsd <- left_join(xmcol1, activitytable)        # create a table with activity labels that match the order from xmcol1;
                                                        #       automatically joins by "activityID," which is what we want

xmeans <- cbind(actlabelsmsd, xmcol2, xmeans)           # put the dataset back together
xmeans <- select(xmeans, -1)                            # remove activityID column
featm <- gsub("^t", "Avgt", features$variablename)      # modify names by putting "Avg" at beginning of variable names - time domain
featm <- gsub("^f", "Avgf", featm)                      # modify names by putting "Avg" at beginning of variable names - freq domain
names(xmeans)[3:68] <- featm                            # add the names to the measurement columns
varnamesmsd <- names(xmeans)                            # put names of variables into a character vector
varnamesmsd <- data.frame(varnamesmsd, stringsAsFactors = FALSE)  # make the character vector into a data frame
names(varnamesmsd) <- "variablename"                       # name the column

## The data frame "xmeans" now contains the tidy data set, including renamed measurement columns and activity labels.

## Write dataset components to text files so they may be read by others.
write.table(activitytable, "activitytable-means.txt", row.names = FALSE)  # unchanged from Task 4
write.table(varnamesmsd, "variablestable-means.txt", quote = FALSE, row.names = TRUE)  # provide a listing of variable names
write.table(xmcol2, "subjectIDtable-means.txt", row.names = FALSE)        # included for completeness only; already incorporated into data table
write.table(actlabelsmsd, "activityIDtable-means.txt", row.names = FALSE) # contains both activity ID and activity label for means
write.table(xmeans, "datasettable-means.txt", row.names = FALSE)          # contains activity labels, subject IDs, and measurements

## End Task 5.
