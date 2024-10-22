library(plyr)
library(tidyverse)
import::from(psycho, analyze)
#import::from(lmerTest,lmer,anova)
import::from(multcomp, glht, mcp, contrMat)
library(dplyr)
library(lmerTest)
library(gridExtra)
library(grid)
library(lattice)

# for the presentation
theme_black <-  function(base_size = 12, base_family = "") {
  theme_grey(base_size = base_size, base_family = base_family) %+replace%
    theme(
      # Specify axis options
      axis.line = element_blank(),  
      axis.text.x = element_text(size = base_size*0.8, color = "white", lineheight = 0.9),  
      axis.text.y = element_text(size = base_size*0.8, color = "white", lineheight = 0.9),  
      axis.ticks = element_line(color = "white", size  =  0.2),  
      axis.title.x = element_text(size = base_size, color = "white", margin = margin(0, 10, 0, 0)),  
      axis.title.y = element_text(size = base_size, color = "white", angle = 90, margin = margin(0, 10, 0, 0)),  
      axis.ticks.length = unit(0.3, "lines"),   
      # Specify legend options
      legend.background=element_blank(),
      legend.key = element_blank(),
      legend.key.size = unit(1.2, "lines"),  
      legend.key.height = NULL,  
      legend.key.width = NULL,      
      legend.text = element_text(size = base_size*0.8, color = "white"),  
      legend.title = element_text(size = base_size*0.8, face = "bold", hjust = 0, color = "white"),  
      legend.position = "right",  
      legend.text.align = NULL,  
      legend.title.align = NULL,  
      legend.direction = "vertical",  
      legend.box = NULL, 
      # Specify panel options
      panel.spacing = unit(0.5, "lines"),   
      panel.background = element_rect(fill = "black", colour = "black"),
      panel.border = element_blank(),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      # Specify facetting options
      strip.background = element_rect(fill = "grey80", color = "grey90"),  
      strip.text.x = element_text(size = base_size*0.8, color = "white"),  
      strip.text.y = element_text(size = base_size*0.8, color = "white",angle = -90),  
      # Specify plot options
      plot.background = element_rect(fill = "black"),
      plot.title = element_text(size = base_size*1.2, color = "white"),  
      plot.margin = unit(rep(1, 4), "lines")
    )
}

# Read file with all participants.
dat <- read.csv("collected_data/CollectedData.csv",stringsAsFactors=FALSE)

### PREPROCESSING
# Sign slope
dat <- transform(dat, m = m * sign)

# Calculate error, absolute error and sign of error
dat$error <- dat$m - dat$answer
dat$unsignedError <- abs(dat$error)
dat$signError <- sign(dat$error)
#Rename column and adjust data types
colnames(dat)[1] <- "id"
dat <- dat %>% mutate(type = as.factor(type),
                        graphtype = as.factor(graphtype),                        
                        m = as.factor(m),
                        id = as.factor(id),
                        sigma = as.factor(sigma))

# Remove all participants whose validations have an average unsigned error >= 0.2
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
dat %>% 
  ggplot(aes(x = id, y = unsignedError)) +
  geom_boxplot() +
  theme_bw() +
  labs(x = "Particpant ID",
       y = "Absolute Error", 
       title = "Figure 1: Errors per participant")  # change the figure number if possible

# Graph displaying within subject variation for the presentation
dat %>% 
  ggplot(aes(x = id, y = unsignedError)) +
  geom_boxplot(aes(colour=id)) +
  theme_bw() +
  labs(x = "Particpant ID",
       y = "Absolute Error", 
       title = "Errors per participant: within subject variation") +
  theme_black() +
  theme(legend.position = "none") 

#### HYPOTHESIS 1
mean(dat$error)
meanError <- toString(mean(dat$error))
t.test(dat$error, mu=0, conf.level=0.99)

##plot for the presentation
dat %>% 
  ggplot(aes(y = error, x = id)) +
  geom_jitter(aes(colour = as.factor(signError))) +
  stat_summary(fun.y = mean, geom = "point")+
  geom_hline(aes(linetype=meanError, yintercept = mean(dat$error)), color="orange", size=1)+
  theme_black()+
  labs(x = "Participant ID",
       y = "Error",
       title = "Hypothesis 1 - no over- or underestimation",
       linetype = "Mean of error",
       colour='Sign of the error') +
  scale_colour_manual(values = c("deepskyblue", "gold", "darkorchid1")) 

###plot for the report
dat %>% 
  ggplot(aes(y = error, x = id)) +
  geom_point(aes(colour = as.factor(signError))) +
  stat_summary(fun.y = mean, geom = "point")+
  theme_minimal()+
  geom_hline(aes(linetype=meanError, yintercept = mean(dat$error)), color="gray18", size=1)+
  labs(x = "Participant ID",
       y = "Error",
       title = "Hypothesis 1",
       linetype = "Mean of error",
       colour='Sign of the error') +
  scale_colour_manual(values = c("gray37", "gray87", "gray65")) 

#### HYPOTHESIS 2
# plot for the report
dat %>%
  ggplot(aes(x = sigma, y = unsignedError)) +
  stat_summary(fun.y = mean, geom = "point") +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0) +
  labs(x = "Absolute Error",
       y = "Bandwidth (sigma)",
       title = "Hypothesis 2") +
  coord_flip() +
  theme_bw() 

#plot for the presentation
dat %>%
  ggplot(aes(x = sigma, y = unsignedError, colour=sigma)) +
  stat_summary(fun.y = mean, geom = "point", size=3) +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0, size=1.5) +
  labs(x = "Absolute Error",
       y = "Bandwidth of Residuals",
       title = "Hypothesis 2 - the larger the residuals, the larger the error") +
  coord_flip() +
  theme_black() +
  theme(legend.position = "none") 


m_regression2 <- lmer(unsignedError ~ sigma * graphtype * type + (1|id) + m, data = dat)
anova_m_full2 <- anova(m_regression2)
results_anova2 <- analyze(anova_m_full2)
print(results_anova2)  # APA text output
summary(results_anova2)  # summary table

r2 <- ddply(dat, .(sigma), summarize, mean = mean(unsignedError))
r2

#### HYPOTHESIS 3
m_main <-  update(m_regression2, .~. - sigma:graphtype:type - sigma:graphtype - sigma:type - graphtype:type)  
pairwise_main <- 
 glht(m_main, linfct = mcp(graphtype = "Tukey"))
summary(pairwise_main)
# plot for the Tukey confidence intervals
plot(pairwise_main)

#plot for hypothesis 3 - errorbar - paper
dat %>%
  ggplot(aes(x = graphtype, y = unsignedError)) +
  stat_summary(fun.y = mean, geom = "point") +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0) +
  labs(x = "Trend Type",
       y = "Absolute Error",
       title = "Hypothesis 3") +
  expand_limits(x = 0.02, y = 0) +
  scale_x_discrete(breaks=c("line","quad","trig"),
                   labels=c("Linear", "Quadratic", "Trigonometric"))+
  coord_flip() +
  theme_bw()

#plot for hypothesis 3 - errorbar - presentation
dat %>%
  ggplot(aes(x = graphtype, y = unsignedError, colour = graphtype)) +
  stat_summary(fun.y = mean, geom = "point", size = 3) +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0, size = 1.5) +
  labs(y = "Absolute Error",
       x = "Trend Type",
       title = "Hypothesis 3 - no statistically significant effect of the trend type"
       ) +
  expand_limits(x = 0.02, y = 0) +
  scale_x_discrete(breaks=c("line","quad","trig"),
                   labels=c("Linear", "Quadratic", "Trigonometric"))+
  scale_colour_manual(values = c("gold", "deepskyblue", "darkorchid1")) +
  coord_flip() +
  theme_black() +
  theme(legend.position = "none") 
 

r2 <- ddply(dat, .(graphtype), summarize, mean = mean(unsignedError))
r2

####### ADDITIONAL PLOTS (NOT INCLUDED NOW) #################################################
# for the paper additional plots
# errors
ggplot(dat, aes(x = id, y = unsignedError)) +
  geom_boxplot() +
  theme_bw() +
  labs(x = "Participant ID",
       y = "Unsigned Error", 
       title = "Figure 1: Errors per participant")

plot1 <- dat %>%  # hyp 1
  ggplot(aes(x = sigma, y = unsignedError)) +
  stat_summary(fun.y = mean, geom = "point") +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0) +
  coord_flip() +
  labs(y = "Unsigned Error",
       x = "Bandwidth (sigma)",
       title = "Hypothesis 1") +
  theme_bw() 

plot2 <- dat %>%
  ggplot(aes(x = graphtype, y = unsignedError)) +
  stat_summary(fun.y = mean, geom = "point") +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0) +
  coord_flip() +
  labs(y = "Absolute Error", 
       x = "Chart Type",
       title = "Hypothesis 2") +
  expand_limits(x = 0, y = 0) +
  theme_bw()

grid.arrange(plot1, plot2, nrow = 1)


## presentation 
theme_black2 <-  function(base_size = 12, base_family = "") {
  theme_grey(base_size = base_size, base_family = base_family) %+replace%
    theme(
      # Specify axis options
      axis.line = element_blank(),  
      axis.text.x = element_text(size = base_size*0.8, color = "white", lineheight = 0.9),  
      axis.text.y = element_text(size = base_size*0.8, color = "white", lineheight = 0.9),  
      axis.ticks = element_line(color = "white", size  =  0.2),  
      axis.title.x = element_text(size = base_size, color = "white", margin = margin(0, 10, 0, 0)),  
      axis.title.y = element_text(size = base_size, color = "white", angle = 90, margin = margin(0, 10, 0, 0)),  
      axis.ticks.length = unit(0.3, "lines"),   
      # Specify legend options
      legend.background = element_rect(color = NA, fill = "grey50"),  
      legend.key = element_rect(color = "white",  fill = "grey50"),  
      legend.key.size = unit(1.2, "lines"),  
      legend.key.height = NULL,  
      legend.key.width = NULL,      
      legend.text = element_text(size = base_size*0.8, color = "white"),  
      legend.title = element_text(size = base_size*0.8, face = "bold", hjust = 0, color = "white"),  
      legend.position = "right",  
      legend.text.align = NULL,  
      legend.title.align = NULL,  
      legend.direction = "vertical",  
      legend.box = NULL, 
      # Specify panel options
      panel.background = element_rect(fill = "grey50", color  =  NA),  
      panel.border = element_rect(fill = NA, color = "white"),  
      panel.grid.major = element_line(color = "grey70"),  
      panel.grid.minor = element_line(color = "grey80"),  
      panel.spacing = unit(0.5, "lines"),   
      # Specify facetting options
      strip.background = element_rect(fill = "grey80", color = "grey90"),  
      strip.text.x = element_text(size = base_size*0.8, color = "white"),  
      strip.text.y = element_text(size = base_size*0.8, color = "white",angle = -90),  
      # Specify plot options
      plot.background = element_rect(color = "grey50", fill = "grey50"),  
      plot.title = element_text(size = base_size*1.2, color = "white"),  
      plot.margin = unit(rep(1, 4), "lines")
    )
}

dat %>% 
  ggplot(aes(x = sigma, y = unsignedError)) +
  stat_summary(fun.y = mean, geom = "point") +
  stat_summary(fun.data = mean_cl_normal, geom = "errorbar", width = 0) +
  coord_flip() +
  labs(y = "Unsigned Error",
       x = "Bandwidth (sigma)",
       title = "Hypothesis 1") +
  theme_black2() +
  facet_grid(dat$type ~ dat$sigma)

dat %>% 
  ggplot(aes(x = error, y = index)) +
  geom_point(aes(shape = type, colour = m)) +
  theme_black2()

#alternative for within subject comparison
dat %>% 
  ggplot(aes(x = id, y = unsignedError)) +
  geom_boxplot() +
  theme_black2() +
  labs(x = "Particpant ID",
       y = "Unsigned Error", 
       title = "Figure 1: Errors per participant")

