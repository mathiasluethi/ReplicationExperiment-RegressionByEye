library(tidyverse)
library(dplyr)
import::from(cowplot, plot_grid)

# Read all required files
data <- read.csv("../data/CollectedData.csv",stringsAsFactors=FALSE)
demographics <- read.csv("../data/Demographics.csv",stringsAsFactors=FALSE)
data_original <- read_csv('../data/Demographics_Original.csv')

# Calculate error and absolute error
data$error <- data$m - data$answer
data$unsignedError <- abs(data$error)
colnames(data)[1] <- "id"

#Append errors to demographics from experiment
avg_unsigned <- group_by(data,id) %>%
  dplyr::summarise(average=mean(unsignedError))
avg_signed <- group_by(data,id) %>%
  dplyr::summarise(average=mean(error))
demographics$AvgUnsigned = avg_unsigned$average
demographics$AvgSigned = avg_signed$average

# Removing word degree from education to improve look on graph
require("tm")
data_original$Education <- removeWords(data_original$Education,"degree")

#Changing F to Female and M to Male
demographics$Gender <- ifelse(demographics$Gender=="F", 
                        "Female", "Male")


#Plotting gender
gender_bar_original <- ggplot(data_original, aes(Gender)) +
  geom_bar()
gender_bar <- ggplot(demographics, aes(Gender)) +
  geom_bar()
plot_grid(gender_bar_original, gender_bar, nrow = 1)

#Plotting education
education_bar_original <- ggplot(data_original, aes(Education)) +
  geom_bar()
education_bar <- ggplot(demographics, aes(Level)) +
  geom_bar()
faculty_bar <- ggplot(demographics, aes(Faculty)) +
  geom_bar()
faculty_bar <- ggplot(demographics, aes(Faculty)) +
  geom_bar()
plot_grid(education_bar_original, education_bar, faculty_bar,nrow = 1)


#Plotting age distributions
age_density_original <- ggplot(data_original,aes(Age)) +
  geom_histogram()
age_density <- ggplot(demographics,aes(Age)) +
  geom_histogram()
plot_grid(age_density_original, age_density, nrow = 1)
#T test for mean of age
original_mean_age = mean(data_original$Age)
experiment_age = mean(demographics$Age)
t.test(demographics$Age, mu=original_mean_age, conf.level=0.99)

#Plotting graph experience
graph_experience_original <- ggplot(data_original, aes(ExperienceGraphsCharts)) +
  geom_bar()
graph_experience <- ggplot(demographics, aes(Graphs)) +
  geom_bar()
plot_grid(graph_experience_original, graph_experience, nrow = 1)


