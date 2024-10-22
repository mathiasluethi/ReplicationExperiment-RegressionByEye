# Experiment Replication - Regression by Eye: Estimating Trends in Bivariate Visualizations
This Project was done for the Quantitive Methods in HCI course during the spring semester 2019 at the University of Zurich.  

This repository contains the following resources:  
* The source code of the software used for gathering experiment data.
* The generated visualizations that were used in the experiment.
* The source code of the data analysis done on the experiment results.

## Software for gathering experiment data
![](https://github.com/mathiasluethi/ReplicationExperiment-RegressionByEye/blob/master/screenshot.PNG) 

Check out the deployed software: <https://regressiontesting.netlify.com/>  
If you want to run the software locally you have to open chrome from the command line with the following command:  
`chrome --allow-file-access-from-files`  
After that you can simply open the index.html file.  

## Contributors
* __Alexander -__ <https://github.com/Vollkorn01>
* __Alix -__ <https://github.com/dagostix>
* __Bianca -__ <https://github.com/bianca-stancu>
* __Mathias -__ <https://github.com/mathiasluethi>
* __Natasha -__ <https://github.com/natalia-obukhova>
* __Tim -__ <https://github.com/Tbrlan>

## Function  
The following formulas were used to generate the graphs on top of the visualization  
Linear trend: y = 0.5 + sliderValue * (x - 0.5)  
Quadratic trend: y = 0.5 + sliderValue * x^2 - 0.5 * sliderValue  
Trigonometric trend: y = 0.5 - 0.5 * cos(x * π) * sliderValue  
sliderValue is the participant's answer in range from -1 to 1
