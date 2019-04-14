library(tidyverse)
import::from(psycho, analyze)

data <- read_csv("exp1.csv") 


data <- data %>% mutate(type = as.factor(type),
                       graphtype = as.factor(graphtype),
                       m = sign*m)

#H1

# We are doing an ANOVA regression on Unsiged Error, with the variables Bandwidth (sigma), Graph type, Type 
# (whether linear, quadradtic, or trigonometric), ID, and m (slope of OLS). We created interaction terms between sigma, graphtype and type.

#fm <- aov(unsignedError~id+m+sigma*graphtype*type, data = data)
#summary(fm)

m_regression <- aov(unsignedError~sigma*graphtype*type+id+m, data = data)
anova_m_full <- anova(m_regression)
anova_m_full
results_anova <- analyze(anova_m_full)
print(results_anova) # APA text output
summary(results_anova) # summary table

# we only have an F value of 927 compared to 950 of sigma in the paper
# Question: what variables to use and what are missing? Do we use the same regression for H2?

data %>% 
  ggplot(aes(x = sigma, y = unsignedError))+
  stat_summary(fun.y = mean, geom = "point")+
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0)+
  coord_flip()

# Similar to the paper


#H2

#Follows a similar ANOVA regression, yet the variable of focus is type. We currently exclude graphtype. 

#fm2 <- aov(unsignedError ~ type*id*m*sigma, data = data)
#summary(fm2)

m_regression2 <- aov(unsignedError~type*id*m*sigma, data = data)
anova_m_full2 <- anova(m_regression2)
anova_m_full2
results_anova2 <- analyze(anova_m_full2)
print(results_anova2) # APA text output
summary(results_anova2) # summary table

# Added more variables and am quite close with F value 2.48 compared to 2.6. However, doesn't seem like a logical strategy
# Question: what variables to use and what are missing

# Running a Tukey's Honest Significant Difference test to check for between group difference.
import::from(multcomp, glht, mcp, contrMat)
m_main <-  update(m_regression, .~. - sigma:graphtype:type)  
pairwise_main <- 
  glht(m_regression,
       linfct = mcp(
         sigma = "Tukey",
         graphtype = "Tukey",
         type = "Tukey"))

summary(pairwise_main)

#None are significant, the same as the study



g= data[ (data$unsignedError > quantile(data$unsignedError , 0.25 )) & (data$unsignedError < quantile(data$unsignedError , 0.75 )) , ]


g %>%
  ggplot(aes(x = type, y = unsignedError))+
  stat_summary(fun.y = mean, geom = "point")+
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0) +
  expand_limits(x = 0, y = 0) +
  coord_flip() 

# The variable in question is the interquartile mean, so the data is cut to remove the outer quartiles

# checking the interquarile means

library(plyr)
r2<-ddply(data, .(type), summarize, mean=mean(unsignedError, 0.25))
r2


#H3

# Check the average signed error and run a T-test to check if difference in negative and positive trends

mean(data$error)

t.test(data$error, mu=0, conf.level=0.99)

#Both are identical to the study, t test of t = 0.39 and p=0.7, no significant difference
