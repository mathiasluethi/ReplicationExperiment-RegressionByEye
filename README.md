## State of the project 13/05/19 22:47
R code is done
Plots in dark theme are added
Needs to be done: add the p4 fixed csv file and (possibly, needs to be checked) p11
## State of the software 16/04/19 22:21
Screen order is done. All the functions work properly. Bootstrap added for the ease of coding. 
To access the main experiment, choose the participant number, then click button "Start the practice", then click the button "Start" (it is a temporal solution, real practice tasks need to be added).  
## Function  
Line: y = 0.5 + sliderValue * (x - 0.5)   
Quad: y = 0.5 + sliderValue * x^2 - 0.5 * sliderValue  
Trig: y = 0.5 - 0.5 * cos(x * \pi) * sliderValue  
sliderValue is the participant's answer in range from -1 to 1
