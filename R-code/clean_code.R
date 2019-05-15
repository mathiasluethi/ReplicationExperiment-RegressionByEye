### Libaries import
library(plyr)
library(tidyverse)
import::from(psycho, analyze)
import::from(multcomp, glht, mcp, contrMat)
library(dplyr)
library(lmerTest)
library(gridExtra)
library(grid)
library(lattice)

### PREPROCESSING #############################################################################
# Read file with data from all participants.
dat <- read.csv("../data/CollectedData.csv",stringsAsFactors=FALSE)
# Sign slope
dat <- transform(dat, m = m * sign)
# Calculate error, absolute error and sign of error
dat$error <- dat$m - dat$answer
dat$unsignedError <- abs(dat$error)
dat$signError <- sign(dat$error)
#Rename columns and adjust data types
colnames(dat)[1] <- "id"
dat <- dat %>% mutate(type = as.factor(type),
                      graphtype = as.factor(graphtype),                        
                      m = as.factor(m),
                      id = as.factor(id),
                      sigma = as.factor(sigma))
# Remove all participants whose validations have an average absolute error >= 0.2
dat$isValidation[is.na(dat$isValidation)] <- 0
validations <- dat[ which(dat$isValidation == '1'), ]
avg_errors_validation <- group_by(validations,id) %>%
  dplyr::summarise(average = mean(unsignedError))
invalid <- (avg_errors_validation[ which(avg_errors_validation$average >= '0.2'), ])$id
dat <- dat[!(dat$id %in% invalid),] 
# Removing validations
dat <- dat[dat$isValidation == 0,]
aov 
# Graph displaying within subject variation for the report
plot1 <- dat %>% 
  ggplot(aes(x = id, y = unsignedError)) +
  geom_boxplot() +
  theme_bw() +
  labs(x = "Particpant ID",
       y = "Unsigned Error", 
       title = "Figure 1: Errors per participant")  # change the figure number if possible
plot1
#### HYPOTHESIS 1 - there is no over- or under- estimation ####################################
mean(dat$error)
meanError <- toString(mean(dat$error))
### T-test
t.test(dat$error, mu=0, conf.level=0.99)

###plot for the report
plot2 <- dat %>% 
  ggplot(aes(y = error, x = id)) +
  geom_jitter(aes(colour = as.factor(signError))) +
  stat_summary(fun.y = mean, geom = "point")+
  theme_minimal()+
  geom_hline(aes(linetype=meanError, yintercept = mean(dat$error)), color="orange", size=1)+
  labs(x = "Participant ID",
       y = "Error",
       title = "Hypothesis 1 - no over- or underestimation",
       linetype = "Mean of error",
       colour='Sign of the error') +
  scale_colour_manual(values = c("deepskyblue", "gold", "darkorchid1")) 

plot2


