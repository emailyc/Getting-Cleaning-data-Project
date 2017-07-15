# Getting-Cleaning-data-Project
The script does the following (in order).

step 5 to 13 are within a function expression.
step 14 executes the function
It's done this way so the intermitten variables aren't saved in memory once the combined data frame is made.


1. Check wether the folder containing the data sets exists in the working directory.
2. If not then see whether the zip file exist. If not then download it and un-zip it. Meanwhile checks your system to ensure the correct download method.
3. If the zip exists then just un-zip it. 
4. Load dplyr
5. Creates a function which makes a combined data frame
6. Load activity_labels.txt
7. Make the labels factor variable + assign labels with desired levels.
8. Load features.txt
9. Load X_train.txt and X_test.txt. Row bind them. Select only variables with mean and SD, excluding meanFrequency.
10. Load y_train.txt and y_test.txt. Row bind them.
11. Load subject_train.txt and subject_test.txt. Row bind them.
12. Add activity labels according to the numbers in y$V1
13. Column bind all data frames to make the combined data frame.
14. A call to the method which actually makes the combined data frame. Call it p
15. Give the df variable names. Seperate words with dots.
16. Group by Subject Number and Activity
17. Create average of each variable for each subject/activity group.
18. Gather features into a single column
19. Export the tidy data frame into .txt file
20. Delete the downloaded files.
