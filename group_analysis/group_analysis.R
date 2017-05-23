# James Lynch
# 5/16/17
# Group-Level Analysis of wtw-work/task7 data

# Install 'rmatio' (https://github.com/stewid/rmatio) in order to read in .mat files
install.packages('rmatio')
library(rmatio)


# --- READ IN DATA FILES AND INITIALIZE VARIABLES ---
#taskName <- readline(prompt = "Enter task name: ")
taskName <- "task7"  # just use this for now to save hassle of always having to enter 'task7'
path <- sprintf("/Users/cdlab_admin/Documents/wtw_work/analysis/%s/data", taskName) # establish path to data
setwd(path) # set this path as the working directory

# Assign subjects results to data frame
subjects <- c(160:199) # subID's for this experiment are '160' to '199'

# Initialize vectors for the different data parameters
blockNum <- NULL
trialNum <- NULL
initialTime <-NULL
itiKeyPresses <- NULL
designatedWait <- NULL
rwdOnsetTime <- NULL
latency <- NULL
outcomeTime <- NULL
payoff <- NULL
totalEarned <- NULL 

# Initialize vector of subject ID names
subID_names <- NULL
for (i in 1:length(subjects)) {
  subID <- toString(subjects[i])
  subID_names <- append(subID_names, subID)
}

# Fill in 'blockNum'
for (i in 1:length(subjects)) {
  subID <- toString(subjects[i])
  filename <- sprintf("wtw-work-7_%s_1.mat", subID)
  sub_data <- read.mat(filename)
  sub_data <- sub_data[2]
  blockNum_individ <- sub_data$trialData$blockNum
  blockNum_individ <- t(blockNum_individ)
  blockNum <- append(blockNum, blockNum_individ)
}






