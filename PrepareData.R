                                        # import train and test datasets
train <- read.csv("train.csv")
test <- read.csv("test.csv")


                                        # Join together the train and test sets for easier feature engineering
test$Survived <- NA
combi <- rbind(train, test)


                                        # Convert to a string
combi$Name <- as.character(combi$Name)

combi$Title <- sapply(combi$Name,
                      FUN=function(x) {strsplit(x, split="[,.]")[[1]][2]})
combi$Title <- sub(" ", "", combi$Title)

combi$Title[combi$Title %in% c("Mme", "Mlle")] <- "Mlle"
combi$Title[combi$Title %in% c("Don", "Capt", "Sir", "Major")] <- "Sir"
combi$Title[combi$Title %in% c("Dona", "Lady", "the Countess", "Jonkheer")] <- "Lady"

combi$Title <- factor(combi$Title)


                                        # Engineered variable: Family Size
combi$FamilySize <- combi$SibSp + combi$Parch + 1

combi$Surname <- sapply(combi$Name, FUN=function(x) {strsplit(x, split="[,.]")[[1]][1]})
combi$FamilyID <- paste(as.character(combi$FamilySize), combi$Surname, sep="")

combi$FamilyID[combi$FamilySize <= 2] <- "small"


                                        # Delete erroneous family IDs
famIDs <- data.frame(table(combi$FamilyID))
famIDs <- famIDs[famIDs$Freq <= 2,]
combi$FamilyID[combi$FamilyID %in% famIDs$Var1] <- 'Small'

                                        # Convert to a factor
combi$FamilyID <- factor(combi$FamilyID)


                                        # Convert Age to a factor
combi$Age[is.na(combi$Age)] <- mean(combi$Age, na.rm = TRUE)

combi$Age[combi$Age < 18] <- 1
combi$Age[combi$Age >= 18 & combi$Age < 30] <- 2
combi$Age[combi$Age >= 30 & combi$Age < 40] <- 3
combi$Age[combi$Age >= 40 & combi$Age < 50] <- 4
combi$Age[combi$Age >= 50 & combi$Age < 60] <- 5
combi$Age[combi$Age >= 60] <- 6

                                        # Convert Fare to a factor
combi$Fare[combi$Fare < 10] <- 1
combi$Fare[combi$Fare < 20 & combi$Fare >= 10] <- 2
combi$Fare[combi$Fare < 30 & combi$Fare >= 20] <- 3
combi$Fare[combi$Fare >= 30] <- 4

                                        # Convert other columns to categories
combi$Survived <- as.factor(combi$Survived)
combi$Pclass <- as.factor(combi$Pclass)
combi$Age <- as.factor(combi$Age)
combi$Fare <- as.factor(combi$Fare)


keeps <- c("PassengerId", "Survived", "Pclass", "Sex",
          "Age", "Fare", "Embarked", "Title", "FamilyID")

combi <- combi[keeps]

combi <- data.frame(data.matrix(combi))

normalize <- function(x, na.rm = TRUE) {
    ranx <- range(x, na.rm = na.rm)
    (x - ranx[1]) / diff(ranx)
}

PassengerId <- combi$PassengerId
combi2 <- apply(combi[, 2:9], 2, normalize)

combi <- cbind(PassengerId, combi2)
head(combi, n = 20)

                                        # Split back into test and train sets
train <- combi[1:891,]
test <- combi[892:1309,]

write.csv(train, file = "engineered-train.csv", row.names = FALSE)
write.csv(test, file = "engineered-test.csv", row.names = FALSE)
