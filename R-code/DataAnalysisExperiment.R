library(tidyverse)
import::from(psycho, analyze)
import::from(lmerTest,lmer,anova)
import::from(multcomp, glht, mcp, contrMat)
library(plyr)
library(dplyr)

# Read file with all participants.
data <- read.csv("../data/CollectedData.csv",stringsAsFactors=FALSE)

### PREPROCESSING
# Sign slope
data <- transform(data, m= m * sign)

# Calculate error and absolute error
data$error <- data$m - data$answer
data$unsignedError <- abs(data$error)

#Rename column and adjust data types
colnames(data)[1] <- "id"
data <- data %>% mutate(type = as.factor(type),
                        graphtype = as.factor(graphtype),                        
                        m = as.factor(m),
                        id = as.factor(id),
                        sigma = as.factor(sigma))

# Remove all participants whose validations have an average unsigned error >= 0.2
data$isValidation[is.na(data$isValidation)] <- 0
validations <- data[ which(data$isValidation=='1'), ]
avg_errors_validation <- group_by(validations,id) %>%
  dplyr::summarise(average=mean(unsignedError))
invalid = (avg_errors_validation[ which(avg_errors_validation$average>='0.2'), ])$id
data <- data[!(data$id %in% invalid),] 

# Removing validations
data = data[data$isValidation == 0,]
aov 

# Graph displaying within subject variation 
data %>% 
  ggplot(aes(x = id, y = unsignedError)) +
  geom_boxplot()+
  theme_bw()


#### HYPOTHESIS 1
data %>% 
  ggplot(aes(x = sigma, y = unsignedError))+
  stat_summary(fun.y = mean, geom = "point")+
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0)+
  coord_flip()

m_regression2 <- lmer(unsignedError ~ sigma * graphtype * type + (1|id) + m, data = data)
anova_m_full2 <-anova(m_regression2)
results_anova2 <- analyze(anova_m_full2)
print(results_anova2) # APA text output
summary(results_anova2) # summary table

r2<-ddply(data, .(sigma), summarize, mean=mean(unsignedError, 0.25))
r2

#### HYPOTHESIS 2
m_main <-  update(m_regression2, .~. - sigma:graphtype:type - sigma:graphtype - sigma:type - graphtype:type)  
pairwise_main <- 
 glht(m_main,
  linfct = mcp(graphtype = "Tukey"))
summary(pairwise_main)
# plot for the Tukey confidence intervals
plot(pairwise_main)


g= data[ (data$unsignedError > quantile(data$unsignedError , 0.25 )) & (data$unsignedError < quantile(data$unsignedError , 0.75 )) , ]
g %>%
  ggplot(aes(x = type, y = unsignedError))+
  stat_summary(fun.y = mean, geom = "point")+
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0) +
  expand_limits(x = 0, y = 0) +
  coord_flip() 

r2<-ddply(data, .(type), summarize, mean=mean(unsignedError, 0.25))
r2

#### HYPOTHESIS 3
mean(data$error)
t.test(data$error, mu=0, conf.level=0.99)