# Script originally written by Barbara Wortham (unkown date)
# Data first published in: Oster et al. (2015) (DOI: https://doi.org/10.1016/j.quascirev.2015.07.027)
# Python script modified by Sophia Macarewich & ported to R by Will Matthaeus April 2022 for Montanez lab group 
#
# This script showcases:
# - Importing CSV file & extracting speleothem isotope timeseries
# - Plotting panels of histograms
# - Plotting panel of d18O and d13C timeseries
# - Testing d18O and d13C for Hendy test criteria #2
# Hendy Test Criteria 2: No simultaneous enrichments (aka correlation) of d18O and d13C speleothem calcite
# Dorale & Liu (2009)


#one nice thing about the RStudio IDE is that you can lookup functions easily, 
#and the IDE will try to autocomplete functions, paths and variables when you start typing their names.
#place your cursor next to 'setwd' and press F1. look in the bottom right window of the IDE
#the 'help' tab has opened, giving you infomration on the command
setwd("~/Dropbox/R_on_git/R_Speleothem")
#setwd("XXXX")#you will have to replace XXXX with the path to your file. try out autocomplete here. 
#start typing the name of the folder, press Tab, and the IDE will show you some options in a dropdown.
#install.packages("tidyverse") #highlight this command and run it if the next one tells you the package is not installed
library(tidyverse)

#install.packages("tidymodels")
library(tidymodels)

#Read in data from delimited text file (i.e., csv)
dat<-read_csv("stable.csv") #read csv to tbl, also notice the assignment operator

mode(dat$age)#already in numeric vectors, notice column reference syntax

#Basic QC
unique(is.na(dat)) #check each column for missing values

print(dat) #print a preview of the tbl (behaves differently from print for dataframes)

#Basic exploratory data anlysis and QC, these will just be output, and not saves
ggplot(data=dat)+geom_point(aes(x=d13C, y=d18O)) #make a scatterplot

ggplot(data=dat)+geom_histogram(aes(x=d13C),bins = 50) #histogram of C

ggplot(data=dat)+geom_histogram(aes(x=d18O), bins = 50) #histogram of O

#Define time intervals, and names. I'm taking a slightly different approach here.
#this part is the same
t_ints <- as.numeric(c(11.6, 12.7, 13.5, 14.5, 15.0, 16.2, 17.5, 20.0))
t_int_names <- c('Younger Dryas\n(11.6-12.7 ka)',
                'Allerod\n(12.7-13.5 ka)',
                'Older Dryas\n(13.5-14.5 ka)',
                'Bolling\n(14.5-15 ka)',
                'Big Wet\n(15-16.2 ka)',
                'Big Dry\n(16.2-17.5 ka)',
                'Last Glacial Maximum\n(17.5-20 ka)')
#now use cut to create a categorical variable that distinguishes the rows according to the intervals defined in 't_ints'
dat$interval<-cut(dat$age,breaks = t_ints, labels=t_int_names)

#Create and save figures of time series
#first 'lengthen' data
colnames(dat) #remind ourselves of the names so we can copy paste, and avoid errors

#Note i'm splitting this command onto multiple lines to improve readability, in R you can just split up 
#comma separated inputs (i.e., function(,,,,)) in this way.
dat_long <- pivot_longer(data=dat, 
                         cols=c( "d13C" , "d18O" ),
                         names_to = "isotope",
                         values_to = "signature"
                         ) 
#tell R that itnervals and isotopes should be treated separately
dat_long<-dat_long%>%group_by(interval, isotope)#note the new operater '%>%' which is equivalent to a pipe, 
#by passing the tbl to the standard input of the 'group_by' function
dat_long#take a look

#We can use the new variable 'isotope' in 'dat_long' to automatically group observations by isotope type
#an overview of ggplot2 usage can be found here, (https://github.com/rstudio/cheatsheets/blob/main/data-visualization-2.1.pdf)
#ggplot is a very useful tool for data visualization, and some analyses

ggplot(data = dat_long)+geom_line(aes(x=age, y=signature, color=isotope))+ 
  #you can also break up commands connected by '+' operators onto separate lines 
  facet_grid(isotope~.,scales = "free_y")+
  theme_minimal()

#the 'ggplot' command sends output to the screen and not to a file, unless the output
#is saved (see below).

#store plot to variable, update formatting and save to file with defined size and resolution
p<-ggplot(data = dat_long)+geom_line(aes(x=age, y=signature, color=isotope))+
  facet_grid(isotope~.,scales = "free_y")+
  theme_minimal()+
  scale_color_manual(values=c("black","red"))+
  labs(x="Age (Ka)")+
  scale_y_continuous(position = "right")+
  theme(text= element_text(size=22),legend.position = 'none',
        strip.placement.y = "outside", strip.text.y = element_text(angle=45),
        axis.title.y = element_blank())
  

ggsave("rawIsotopeSignatures.png", plot = p, device = "png", 
       scale = 1, height = 5, width = 8, units = c("in"),
       dpi = 300, limitsize = TRUE)

#view linear models fit to each isotope dataset as a whole
ggplot(data = dat_long, aes(x=age, y=signature))+
  geom_point(aes(color=isotope),size=0.5)+
  geom_smooth(method = "lm", se=FALSE, color="black")+
  facet_grid(isotope~.,scales = "free_y")+
  theme_minimal()+
  scale_color_manual(values=c("black","red"))+
  theme(legend.position = 'none',axis.title.y = element_blank())

#view linear models fit to each isotope dataset separately for each interval
#adding interval as grid dimension is interesting
#but it introduces labeling problems
#because there is less space for the age labels
#and because the interval names are long (this is why i added '\n' to them before)
#there's still one big problem here... maybe you can fix it
ggplot(data = dat_long, aes(x=age, y=signature))+
  geom_point(aes(color=isotope),size=0.5)+
  geom_smooth(method = "lm", se=FALSE, color="black")+
  facet_grid(isotope~interval,scales = "free" )+
  theme_minimal()+
  scale_color_manual(values=c("black","red"))+
  theme(legend.position = 'none',axis.title.y = element_blank(),
        text = element_text(size=15),
        axis.text.x = element_text(angle = 75),
        title = element_text(angle=75),

pS <- ggplot(data = dat_long, aes(x=age, y=signature))+
  geom_smooth(method = "lm", se=FALSE, color="black")

#detrending the dataset, just use a linear model
t0 <- max(dat$age)  
dat$ky_t0<-dat$age-t0 #calculate a new time variable, thousands of years from start

p_d18O <- lm(data = dat, formula = d18O ~ ky_t0)   #fit linear model
#use 'augment' from package 'broom' to look at model fit to calculate fit values automatically
#which are stored in the new column .fitted by default
dat$fitted_d18O<-augment(p_d18O)$.fitted
dat$notrend_d18O<-dat$d18O-dat$fitted_d18O
#ggplot()+geom_line(data=dat, aes(x=age, y=notrend_d18O))  #centered on zero
sd_d18O<-sd(dat$notrend_d18O)
dat$z_d18O<-dat$notrend_d18O/sd_d18O
#ggplot()+geom_line(data=dat, aes(x=age, y=z_d18O)) #the units are now 1SD 

p_d13C <- lm(data = dat, formula = d13C ~ ky_t0) 
dat$fitted_d13C<-augment(p_d13C)$.fitted
dat$notrend_d13C<-dat$d13C-dat$fitted_d13C
#ggplot()+geom_line(data=dat, aes(x=age, y=notrend_d13C)) #centered on zero
sd_d13C<-sd(dat$notrend_d13C)
dat$z_d13C<-dat$notrend_d13C/sd_d13C

#make long z-data to faclitate ploting
z_dat_long <- pivot_longer(data=dat, 
                         cols=c( "z_d13C", "z_d18O"  ),
                         names_to = "isotope",
                         values_to = "signature"
                         ) 
#since the units are now comparable, we can plot them on the same scale
#time series 
ggplot()+geom_line(data=z_dat_long, aes(x=age, y=signature,color=isotope))+
  theme_minimal()+scale_color_manual(values = c("black","red"))

#histogram
ggplot()+geom_histogram(data=z_dat_long, aes(x=signature, color=isotope))+
    theme_minimal()+scale_color_manual(values = c("black","red"))

print("i'm empty :(")
