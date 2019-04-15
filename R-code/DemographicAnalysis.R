library(tidyverse)
import::from(cowplot, plot_grid)

# Loading the original demographics file and the demographics file from during the experiment
data_original <- read_csv('Desktop/Demographics_Original.csv')
data <- read_csv('Desktop/Demographics.csv')

# Comparison of Gender distributions
gender_bar_original <- ggplot(data_original, aes(Gender)) +
  geom_bar()
gender_bar <- ggplot(data, aes(Gender)) +
  geom_bar()
plot_grid(gender_bar_original, gender_bar, nrow = 1)

# Comparison of Education distributions
education_bar_original <- ggplot(data_original, aes(Education)) +
  geom_bar()
education_bar <- ggplot(data, aes(Education)) +
  geom_bar()
plot_grid(education_bar_original, education_bar, nrow = 1)

# Comparison of Education distributions
experience_bar_original <- ggplot(data_original, aes(ExperienceGraphsCharts)) +
  geom_bar()
experience_bar <- ggplot(data, aes(ExperienceGraphsCharts)) +
  geom_bar()
plot_grid(experience_bar_original, experience_bar, nrow = 1)

#Density comparison of age
age_density_original <- ggplot(data_original,aes(Age)) +
  geom_histogram()
age_density <- ggplot(data_original,aes(Age)) +
  geom_histogram()
plot_grid(age_density_original, age_density, nrow = 1)

age_density <- ggplot(data_original,aes(Age)) +
  geom_density() +
  facet_grid(. ~ Gender) + 
age_density

# T test to compare means of the two demographics
original_mean_age = mean(data_original$Age)
t.test(data$Age, mu=original_mean_age, conf.level=0.99)
