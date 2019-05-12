library(tidyverse)
import::from(cowplot, plot_grid)

# Loading the original demographics file and the demographics file from during the experiment
d_data_original <- read_csv('Demographics_Original.csv')
d_data <- read_csv('Demographics.csv')

# Removing word degree from education to improve look on graph
require("tm")
d_data_original$Education <- removeWords(d_data_original$Education,"degree")

#Changing F to Female and M to Male
d_data$Gender <- ifelse(d_data$Gender=="F", 
                           "Female", "Male")

# Comparison of Gender distributions
gender_bar_original <- ggplot(d_data_original, aes(Gender)) +
  geom_bar()
gender_bar <- ggplot(d_data, aes(Gender)) +
  geom_bar()
plot_grid(gender_bar_original, gender_bar, nrow = 1)

# Comparison of Education distributions
education_bar_original <- ggplot(d_data_original, aes(Education)) +
  geom_bar()
education_bar <- ggplot(d_data, aes(Level)) +
  geom_bar()
plot_grid(education_bar_original, education_bar, nrow = 1)


# Comparison of Education distributions
experience_bar_original <- ggplot(d_data_original, aes(ExperienceGraphsCharts)) +
  geom_bar()
experience_bar <- ggplot(d_data, aes(Graphs)) +
  geom_bar()
plot_grid(experience_bar_original, experience_bar, nrow = 1)

#Density comparison of age
age_density_original <- ggplot(d_data_original,aes(Age)) +
  geom_histogram()
age_density <- ggplot(d_data,aes(Age)) +
  geom_histogram()
plot_grid(age_density_original, age_density, nrow = 1)


age_density_original_g <- ggplot(d_data_original,aes(Age)) +
  geom_density() +
  facet_grid(. ~ Gender) + 
plot_grid(age_density)

# T test to compare means of the two demographics
original_mean_age = mean(d_data_original$Age)
t.test(d_data$Age, mu=original_mean_age, conf.level=0.99)
