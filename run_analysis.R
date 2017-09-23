rm(list = ls())
#set working directory
setwd("PLACE HOLDER")
getwd()
if(!file.exists("data")) {
    dir.create("data")
}


library(data.table)
library(reshape2)

#download and unzip, file handling

fileURL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile="./data/rawdata.zip")
fileloc<-paste(getwd(),"/data/rawdata.zip",sep="")
##outdir<-paste(getwd(),"/unzip",sep="")
s<-unzip(fileloc,list=F,exdir = getwd(), overwrite = T)
traindir<-paste(getwd(),"/UCI HAR Dataset/train",sep="")
testdir<-paste(getwd(),"/UCI HAR Dataset/test",sep="")
featuredir<-paste(getwd(),"/UCI HAR Dataset",sep="")

#read feature
str<-fread(paste(featuredir,"/features.txt",sep=""))
str_act<-fread(paste(featuredir,"/activity_labels.txt",sep=""))

#obtain list for the test and training directory
filelist1 = list.files(path=traindir,pattern = ".*.txt")
filelist2 = list.files(path=testdir,pattern = ".*.txt")

#select columns with only "mean" and "std"

#######2. Extracts only the measurements on the mean and standard deviation for each measurement. 

sel<-c(grep("mean",str$V2),grep("std",str$V2))
sel<-sort(sel)
str$V2 <- gsub('[-()]', '', str$V2)

#read the training and test data
#f.train[1]: subject_train.txt, subject who did the training
#f.train[2]: X_train.txt, training data set, w 561 features for each subject
#f.train[3]: y_train.txt, activity involved, walking, etc
#f.test is similar to f.train

f.train <- lapply(paste(traindir,filelist1,sep="/"),fread)
f.test<-lapply(paste(testdir,filelist2,sep="/"),fread)

#read the inertia data
#f.train_inertial[1]body_acc_x_train.txt
#f.train_inertial[2]body_acc_y_train.txt
#f.train_inertial[3]body_acc_z_train.txt
#....
#f.train_inertial[9]total_acc_z_train.txt

traindir1<-paste(traindir,"/Inertial Signals/",sep="")
testdir1<-paste(testdir,"/Inertial Signals/",sep="")

filelist3 = list.files(path=traindir1,pattern = ".*.txt")
filelist4 = list.files(path=testdir1,pattern = ".*.txt")

f.train_inertial<-lapply(paste(traindir1,filelist3,sep="/"),fread)
f.test_inertial<-lapply(paste(testdir1,filelist4,sep="/"),fread)

#clean the data
m_train<-matrix(unlist(f.train[2]),ncol=561)
df_train<-data.frame(f.train[1],f.train[3],m_train[,sel])
names(df_train)<-c("sub","acti",str$V2[sel])

m_test<-matrix(unlist(f.test[2]),ncol=561)
df_test<-data.frame(f.test[1],f.test[3],m_test[,sel])



names(df_test)<-c("sub","acti",str$V2[sel])

#####1. Merges the training and the test sets to create one data set

df_combine<-rbind(df_train,df_test)

#####3. Uses descriptive activity names to name the activities in the data set

df<-merge(df_combine,str_act,by.x='acti',by.y = "V1",sort=F)
#reorgnize the data frame
df<-df[,c(2,ncol(df),3:(ncol(df)-1))]

######4. Appropriately labels the data set with descriptive variable names. 

names(df)<-c("subject","acti_d",str$V2[sel])



#last part, create a separte dataset w average by subject, activity
#library(plyr)
#ddply(df_final,.(subject),summarize,mean_value = mean(descrip act)))

#summarize by subjects

######5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

df$acti_d <- as.factor(df$acti_d)
df$subject <- as.factor(df$subject)
df.melted <- melt(df, id = c("subject", "acti_d"))
df.mean <- dcast(df.melted, subject + acti_d ~ variable, mean)

#fwrite(df.mean,paste(getwd(),"/tidy_data.txt",sep = ""))
write.table(df.mean, "tidy_data.txt", row.names = FALSE, quote = FALSE)
