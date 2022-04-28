Hendy Test - R Notebook
================

This is an [R Markdown](http://rmarkdown.rstudio.com) Notebook. If you
download it, open it in RStdudio and execute code within the notebook,
the results appear beneath the code (they should match the results on
this page).

Some basic information will appear when you create a new R Notebook in
the RStudio IDE (like the bit just above). I’ve left those in, and added
some of my own, including the comments from the raw R script.

Background: Like the python notebook, the R Notebook provides an
interactive view of your code, while also allowing you to easily publish
a report from it. I’ve also provided the raw R Script (ending in .R), if
you run the script directly in RStudio, the output will appear in the
‘console’ and ‘plots’ windows.

The command ‘setwd’ tells R where to look for files. You could
alternatively just give R the full path for the file you want to import.
You’ll need to replace the ‘\~/Dropbox/R\_on\_git/R\_Speleothem’, below,
with the directory where your data file is stored.

You’ll have noticed already there are differences in the R command names
the standards for setting up the R environment (i.e., importing
packages). I’ve commented out the ‘install.packages’ line above, but you
can highlight that code and press ‘command+enter’ to run just the
highlighted code. You’ll only need to do this if the ‘library’ command
says the package is not installed. Tidyverse is a collection of
libraries that are very useful for data import, manipulation, export,
plotting and and other things (<https://www.tidyverse.org/>).

Try executing this chunk. If you’re using the .RMD file in RStudio, by
clicking the *Run* button in the top right hand corner of the chung, or
by placing your cursor inside the chunk and pressing *Cmd+Shift+Enter*.
You can also copy/paste the chunk into the console or run this section
of in script by highlighting it and pressing *Cmd+Shift+Enter*.

``` r
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
#highlight the 'install.packages' commands (without the #) and run them if the next one tells you the package is not installed

#install.packages("tidyverse") 
library(tidyverse)
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.0 ──

    ## ✓ ggplot2 3.3.5     ✓ purrr   0.3.4
    ## ✓ tibble  3.1.6     ✓ dplyr   1.0.8
    ## ✓ tidyr   1.2.0     ✓ stringr 1.4.0
    ## ✓ readr   1.4.0     ✓ forcats 0.5.1

    ## Warning: package 'tidyr' was built under R version 4.0.5

    ## Warning: package 'dplyr' was built under R version 4.0.5

    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## x dplyr::filter() masks stats::filter()
    ## x dplyr::lag()    masks stats::lag()

``` r
#install.packages("tidymodels")
library(tidymodels)
```

    ## Warning: package 'tidymodels' was built under R version 4.0.5

    ## ── Attaching packages ────────────────────────────────────── tidymodels 0.2.0 ──

    ## ✓ broom        0.8.0     ✓ rsample      0.1.1
    ## ✓ dials        0.1.1     ✓ tune         0.2.0
    ## ✓ infer        1.0.0     ✓ workflows    0.2.6
    ## ✓ modeldata    0.1.1     ✓ workflowsets 0.2.1
    ## ✓ parsnip      0.2.1     ✓ yardstick    0.0.9
    ## ✓ recipes      0.2.0

    ## Warning: package 'dials' was built under R version 4.0.5

    ## Warning: package 'parsnip' was built under R version 4.0.5

    ## Warning: package 'recipes' was built under R version 4.0.5

    ## Warning: package 'tune' was built under R version 4.0.5

    ## Warning: package 'workflows' was built under R version 4.0.5

    ## Warning: package 'workflowsets' was built under R version 4.0.5

    ## ── Conflicts ───────────────────────────────────────── tidymodels_conflicts() ──
    ## x scales::discard() masks purrr::discard()
    ## x dplyr::filter()   masks stats::filter()
    ## x recipes::fixed()  masks stringr::fixed()
    ## x dplyr::lag()      masks stats::lag()
    ## x yardstick::spec() masks readr::spec()
    ## x recipes::step()   masks stats::step()
    ## • Learn how to get started at https://www.tidymodels.org/start/

``` r
#Read in data from delimited text file (i.e., csv)

dat<-read_csv("stable.csv") #read csv to tbl, also notice the assignment operator
```

    ## 
    ## ── Column specification ────────────────────────────────────────────────────────
    ## cols(
    ##   age = col_double(),
    ##   depth = col_double(),
    ##   d13C = col_double(),
    ##   d18O = col_double()
    ## )

``` r
mode(dat$age)#already in numeric vectors, notice column reference syntax
```

    ## [1] "numeric"

``` r
#Basic QC
unique(is.na(dat)) #check each column for missing values
```

    ##        age depth  d13C  d18O
    ## [1,] FALSE FALSE FALSE FALSE

``` r
print(dat) #print a preview of the tbl (behaves differently from print for dataframes)
```

    ## # A tibble: 617 × 4
    ##      age depth   d13C   d18O
    ##    <dbl> <dbl>  <dbl>  <dbl>
    ##  1  11.7  1.21 -10.6   -9.66
    ##  2  11.7  1.26 -10.4  -10.4 
    ##  3  11.7  1.30  -9.65  -9.90
    ##  4  11.7  1.35  -9.99 -10.6 
    ##  5  11.8  1.45 -10.2  -10.1 
    ##  6  11.8  1.49 -10.6  -10.0 
    ##  7  11.8  1.54 -10.5   -9.51
    ##  8  11.9  1.59 -10.8  -10.3 
    ##  9  11.9  1.64  -9.91  -9.57
    ## 10  11.9  1.68 -10.1  -10.1 
    ## # … with 607 more rows

Notice the syntax for storing a variable is ‘&lt;-’ rather than ‘=’,
which does something a little different in R.

Because I imported the data using tidyr’s read\_csv, it automatically
detected the data type in each column. It also detected the column
headers. These can both overridden and assigned manually. This means
that each column is already has a name, and is a numeric vector that can
be used in downstream computations. I checked this with the ‘mode’
command. Also notice that I used the ‘$’ operator to reference a named
column of the tbl.

It’s always a good idea to visually check the data structures (called a
tbl, tibble, or data frame in this case) after import to avoid
downstream errors, which can sometimes be a big nuisance. I’ve done two
quality checks here, looking for ‘NAs’ in the data, which are missing
values, and simply printing the data.

Exporatory Analysis: It is also a good idea to visually check your data
using some basic plots, like those below. Look out for any unexpected
values that might indicate data did not import correctly. Also, are the
data distributed in a way you would expect? Are they normally
distributed?

``` r
#Basic exploratory data anlysis and QC, these will just be output, and not saves
ggplot(data=dat)+geom_point(aes(x=d13C, y=d18O)) #make a scatterplot
```

![](hendy_v1_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

``` r
ggplot(data=dat)+geom_histogram(aes(x=d13C),bins = 50) #histogram of C
```

![](hendy_v1_files/figure-gfm/unnamed-chunk-3-2.png)<!-- -->

``` r
ggplot(data=dat)+geom_histogram(aes(x=d18O), bins = 50) #histogram of O
```

![](hendy_v1_files/figure-gfm/unnamed-chunk-3-3.png)<!-- -->

Breaking the time series down into time intervals can be done using
higher level (more developed) functions in R. This is effectively the
same process as ‘binning’ data, as you would in making a histogram. R
has a function called ‘cut’ that does it automatically, or using custom
interval breaks and names. I’m doing this ahead of time to save us from
repeating code below, you’ll see why in a second.

``` r
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
```

Now, lets plot each whole time series (raw observations) and save plot.
Note that there are plotting functions that come with base R (i.e., not
ggplot2) that function very much like those in python, but i’m going to
stick with ggplot2 as it requires a slightly different approach to
format the data correctly. Specifically we are going to reshape the data
so that each row represents an observation (rather than two observations
at the same depth). We’ll use ‘pivot\_longer’ from tidyr (a tidyverse
package). This ‘cheat sheet’ has some visual examples of pivot\_longer
and pivot\_wider
(<https://github.com/rstudio/cheatsheets/blob/main/tidyr.pdf>)

``` r
#Create and save figures of time series
#first 'lengthen' data

colnames(dat) #remind ourselves of the names so we can copy paste, and avoid errors
```

    ## [1] "age"      "depth"    "d13C"     "d18O"     "interval"

``` r
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
```

    ## # A tibble: 1,234 × 5
    ## # Groups:   interval, isotope [14]
    ##      age depth interval                        isotope signature
    ##    <dbl> <dbl> <fct>                           <chr>       <dbl>
    ##  1  11.7  1.21 "Younger Dryas\n(11.6-12.7 ka)" d13C       -10.6 
    ##  2  11.7  1.21 "Younger Dryas\n(11.6-12.7 ka)" d18O        -9.66
    ##  3  11.7  1.26 "Younger Dryas\n(11.6-12.7 ka)" d13C       -10.4 
    ##  4  11.7  1.26 "Younger Dryas\n(11.6-12.7 ka)" d18O       -10.4 
    ##  5  11.7  1.30 "Younger Dryas\n(11.6-12.7 ka)" d13C        -9.65
    ##  6  11.7  1.30 "Younger Dryas\n(11.6-12.7 ka)" d18O        -9.90
    ##  7  11.7  1.35 "Younger Dryas\n(11.6-12.7 ka)" d13C        -9.99
    ##  8  11.7  1.35 "Younger Dryas\n(11.6-12.7 ka)" d18O       -10.6 
    ##  9  11.8  1.45 "Younger Dryas\n(11.6-12.7 ka)" d13C       -10.2 
    ## 10  11.8  1.45 "Younger Dryas\n(11.6-12.7 ka)" d18O       -10.1 
    ## # … with 1,224 more rows

``` r
#We can use the new variable 'isotope' in 'dat_long' to automatically group observations by isotope type
#an overview of ggplot2 usage can be found here, #(https://github.com/rstudio/cheatsheets/blob/main/data-visualization-2.1.pdf)
#also (https://cran.r-project.org/web/packages/egg/vignettes/Ecosystem.html)
#ggplot is a very useful tool for data visualization, and some analyses

ggplot(data = dat_long)+geom_line(aes(x=age, y=signature, color=isotope))+ 
  #you can also break up commands connected by '+' operators onto separate lines 
  facet_grid(isotope~.,scales = "free_y")+
  theme_minimal()
```

![](hendy_v1_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

``` r
#the 'ggplot' command sends output to the screen and not to a file, unless the output
#is saved (see below).
```

To save plots to a file, first store the plot in a variable ‘p’, and use
the separate command ‘ggsave’ to save graphics with screen- or
print-appropriate resolutions usually 300 dpi is a good start. You can
specify where the file should go by adding ‘path = /where/it/goes’as an
argument to ’ggsave’

Note I’ve added some ‘theme’ elements to update and hopefully improve
the axes, labels, colors and text size, though it’s still not
publication ready.

``` r
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
```

We can also use ggplot to separate intervals into a grid and fit linear
(or other) models.. here are some examples.

``` r
#view linear models fit to each isotope dataset as a whole
ggplot(data = dat_long, aes(x=age, y=signature))+
  geom_point(aes(color=isotope),size=0.5)+
  geom_smooth(method = "lm", se=FALSE, color="black")+
  facet_grid(isotope~.,scales = "free_y")+
  theme_minimal()+
  scale_color_manual(values=c("black","red"))+
  theme(legend.position = 'none',axis.title.y = element_blank())
```

    ## `geom_smooth()` using formula 'y ~ x'

![](hendy_v1_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

``` r
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
        strip.text.x = element_text(size =6))#
```

    ## `geom_smooth()` using formula 'y ~ x'

![](hendy_v1_files/figure-gfm/unnamed-chunk-7-2.png)<!-- -->

``` r
pS <- ggplot(data = dat_long, aes(x=age, y=signature))+
  geom_smooth(method = "lm", se=FALSE, color="black")
```

Unfortunately, and as far as I could find, its not possible to pull the
parameters of these sub-models out of the ggplot object (pS), if you
should figure out how let me know!!!

Now let’s dive into the statistical analysis: detrend and calculate
correlation for whole time series.

``` r
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

#just the correlation coefficient, also takes other methods
cor(dat$notrend_d13C,dat$notrend_d18O)
```

    ## [1] 0.6091559

``` r
#with significanc and other methods, (kendall and spearman are non-parametric, ok for non-normal data)
cor.test(dat$notrend_d13C,dat$notrend_d18O, method="spearman")
```

    ## 
    ##  Spearman's rank correlation rho
    ## 
    ## data:  dat$notrend_d13C and dat$notrend_d18O
    ## S = 16124330, p-value < 2.2e-16
    ## alternative hypothesis: true rho is not equal to 0
    ## sample estimates:
    ##       rho 
    ## 0.5881125

``` r
#total time series isotopes are correlated
```

It’s worth mentioning that these are not ‘vanilla’ z-scores, as they are
also de-trended. I will refer to them as such because they share the two
most important properties of z-scores: they are centered and
standardized. That is, the mean of the de-trended z-scores is zero, and
they are in the unit of standard deviations.

Let’s see if it made a difference by plotting the z-scores as a time
series and histograms.

``` r
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
```

![](hendy_v1_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

``` r
#histogram
ggplot()+geom_histogram(data=z_dat_long, aes(x=signature, color=isotope))+
    theme_minimal()+scale_color_manual(values = c("black","red"))
```

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](hendy_v1_files/figure-gfm/unnamed-chunk-9-2.png)<!-- -->

Subintervals!!

Now to do it again but for each interval separately Sometimes you have
to use loops, if for no other reason than you can’t work out the
vectorized (etc.) version. But see below the loops.

I’m going to build my loop step by step to show you how I do it. First
I’ll get the looping conditions right using a prototype and reporters.
In addition to the for loop syntax, this will require a few of new
functions: *paste()/paste0() are variations of a concatenation function,
that take one or more variables, force them to string type and paste
them together (concatenate them) *print() …. yep *length() gives the
length of an object, different values depending on the input type (e.g.,
for vectors gives the number of elements, but for dataframes gives the
number of columns) *unique() gives the unique elements, usually most
useful for vectors (again output depends on input type) but generally
outputs a list, which is a new data structure \*

``` r
##'by the numbers'
#most basic loop with most basic reporter
for (i in 1:10) {
  print(i)
}
```

    ## [1] 1
    ## [1] 2
    ## [1] 3
    ## [1] 4
    ## [1] 5
    ## [1] 6
    ## [1] 7
    ## [1] 8
    ## [1] 9
    ## [1] 10

``` r
#NOTE that when given integers the : operator is equivalent to the seq() function with 'by = 1'

#but we want to iterate across the sub-intervals, how many are there?
length(unique(dat$interval))
```

    ## [1] 7

``` r
#we can incorporate this directly into the loop, so if we add another sub-interval later, the code will still work
for (i in 1:length(unique(dat$interval))) {
  print(i)
  print(unique(dat$interval)[i])
}
```

    ## [1] 1
    ## [1] Younger Dryas\n(11.6-12.7 ka)
    ## 7 Levels: Younger Dryas\n(11.6-12.7 ka) ... Last Glacial Maximum\n(17.5-20 ka)
    ## [1] 2
    ## [1] Allerod\n(12.7-13.5 ka)
    ## 7 Levels: Younger Dryas\n(11.6-12.7 ka) ... Last Glacial Maximum\n(17.5-20 ka)
    ## [1] 3
    ## [1] Older Dryas\n(13.5-14.5 ka)
    ## 7 Levels: Younger Dryas\n(11.6-12.7 ka) ... Last Glacial Maximum\n(17.5-20 ka)
    ## [1] 4
    ## [1] Bolling\n(14.5-15 ka)
    ## 7 Levels: Younger Dryas\n(11.6-12.7 ka) ... Last Glacial Maximum\n(17.5-20 ka)
    ## [1] 5
    ## [1] Big Wet\n(15-16.2 ka)
    ## 7 Levels: Younger Dryas\n(11.6-12.7 ka) ... Last Glacial Maximum\n(17.5-20 ka)
    ## [1] 6
    ## [1] Big Dry\n(16.2-17.5 ka)
    ## 7 Levels: Younger Dryas\n(11.6-12.7 ka) ... Last Glacial Maximum\n(17.5-20 ka)
    ## [1] 7
    ## [1] Last Glacial Maximum\n(17.5-20 ka)
    ## 7 Levels: Younger Dryas\n(11.6-12.7 ka) ... Last Glacial Maximum\n(17.5-20 ka)

``` r
#to remind me of what our intervals look like (again)
t_ints 
```

    ## [1] 11.6 12.7 13.5 14.5 15.0 16.2 17.5 20.0

``` r
t_int_names 
```

    ## [1] "Younger Dryas\n(11.6-12.7 ka)"      "Allerod\n(12.7-13.5 ka)"           
    ## [3] "Older Dryas\n(13.5-14.5 ka)"        "Bolling\n(14.5-15 ka)"             
    ## [5] "Big Wet\n(15-16.2 ka)"              "Big Dry\n(16.2-17.5 ka)"           
    ## [7] "Last Glacial Maximum\n(17.5-20 ka)"

``` r
#to look at what we get by using our index on these arrays, i've added some more reporters here (there are other ways to do this besides print statements), each group should match in terms of names and numbers
for (i in 1:length(unique(dat$interval))) {
  print(i)
  print(unique(paste0(dat$interval))[i])#the paste0 command forces the input to a string type, it could take multiple inputs and will concatenate them with no separator (thus the zero), i've done this to clean up the output by avoiding the reminder R gives us about the factor levels for the interval column
  print(paste(t_ints[i],t_ints[i+1],sep = '-')) #paste converts other types to a string, the default seperator is a space, i'm using a dash so it looks exactly the same as the intervals in the corresponding name
  print(t_int_names[i])
}
```

    ## [1] 1
    ## [1] "Younger Dryas\n(11.6-12.7 ka)"
    ## [1] "11.6-12.7"
    ## [1] "Younger Dryas\n(11.6-12.7 ka)"
    ## [1] 2
    ## [1] "Allerod\n(12.7-13.5 ka)"
    ## [1] "12.7-13.5"
    ## [1] "Allerod\n(12.7-13.5 ka)"
    ## [1] 3
    ## [1] "Older Dryas\n(13.5-14.5 ka)"
    ## [1] "13.5-14.5"
    ## [1] "Older Dryas\n(13.5-14.5 ka)"
    ## [1] 4
    ## [1] "Bolling\n(14.5-15 ka)"
    ## [1] "14.5-15"
    ## [1] "Bolling\n(14.5-15 ka)"
    ## [1] 5
    ## [1] "Big Wet\n(15-16.2 ka)"
    ## [1] "15-16.2"
    ## [1] "Big Wet\n(15-16.2 ka)"
    ## [1] 6
    ## [1] "Big Dry\n(16.2-17.5 ka)"
    ## [1] "16.2-17.5"
    ## [1] "Big Dry\n(16.2-17.5 ka)"
    ## [1] 7
    ## [1] "Last Glacial Maximum\n(17.5-20 ka)"
    ## [1] "17.5-20"
    ## [1] "Last Glacial Maximum\n(17.5-20 ka)"

``` r
#now we can use either the intervals names or the index numbers to get what we need
```

We can use these values to compare to those in our dataframe.

So we’ve seen how our loop can run thru those data structures (atomic
vectors, numeric with ages, and string with names). I’m going to use
those to pull out sub-intervals from the main dataset. But we need to
figure out how to subset the dataset itself using those strings or
numbers. This is going to involve the which() function and usage of the
\[\] index syntax.

``` r
#time to subset our dataset, the which command subsets by either numerical or logical criteria
#it takes a 'test', and returns *indexes*
#by the names we've already set up, test is string equality
which(dat$interval=="Younger Dryas\n(11.6-12.7 ka)")
```

    ##  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
    ## [26] 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41

``` r
#by interval range requires a compound test, which is a numerical inequality
which(dat$age>=t_ints[1] & dat$age<t_ints[2])
```

    ##  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
    ## [26] 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41

``` r
#brackets "[i,j]" treat the data frame like a matrix, if you leave one blank it takes everything.
#using the which command inside the brackets will give a set of indexes to the [] and return rows or columns for just those indexes (i.e. a subset)

#so lets keep all columns and only the rows for a test interval, say the first, using the name
dat[which(dat$interval=="Younger Dryas\n(11.6-12.7 ka)"),]
```

    ## # A tibble: 41 × 12
    ##      age depth   d13C   d18O interval      ky_t0 fitted_d18O notrend_d18O z_d18O
    ##    <dbl> <dbl>  <dbl>  <dbl> <fct>         <dbl>       <dbl>        <dbl>  <dbl>
    ##  1  11.7  1.21 -10.6   -9.66 "Younger Dry… -7.76       -9.72       0.0604  0.103
    ##  2  11.7  1.26 -10.4  -10.4  "Younger Dry… -7.74       -9.72      -0.710  -1.21 
    ##  3  11.7  1.30  -9.65  -9.90 "Younger Dry… -7.71       -9.72      -0.180  -0.306
    ##  4  11.7  1.35  -9.99 -10.6  "Younger Dry… -7.69       -9.72      -0.860  -1.46 
    ##  5  11.8  1.45 -10.2  -10.1  "Younger Dry… -7.63       -9.72      -0.381  -0.648
    ##  6  11.8  1.49 -10.6  -10.0  "Younger Dry… -7.61       -9.72      -0.281  -0.479
    ##  7  11.8  1.54 -10.5   -9.51 "Younger Dry… -7.58       -9.72       0.219   0.372
    ##  8  11.9  1.59 -10.8  -10.3  "Younger Dry… -7.56       -9.72      -0.582  -0.990
    ##  9  11.9  1.64  -9.91  -9.57 "Younger Dry… -7.53       -9.73       0.158   0.269
    ## 10  11.9  1.68 -10.1  -10.1  "Younger Dry… -7.51       -9.73      -0.333  -0.567
    ## # … with 31 more rows, and 3 more variables: fitted_d13C <dbl>,
    ## #   notrend_d13C <dbl>, z_d13C <dbl>

``` r
#this returns a new dataframe that is a subset of the last

#put the generalized version (t_int_names[i]) in a loop
for (i in 1:length(unique(dat$interval))) {
  #i'll use the interval names to subset 
  temp<-dat[which(dat$interval==t_int_names[i]),]
  print(head(temp,n = 1))#take a look ^^
}
```

    ## # A tibble: 1 × 12
    ##     age depth  d13C  d18O interval         ky_t0 fitted_d18O notrend_d18O z_d18O
    ##   <dbl> <dbl> <dbl> <dbl> <fct>            <dbl>       <dbl>        <dbl>  <dbl>
    ## 1  11.7  1.21 -10.6 -9.66 "Younger Dryas\… -7.76       -9.72       0.0604  0.103
    ## # … with 3 more variables: fitted_d13C <dbl>, notrend_d13C <dbl>, z_d13C <dbl>
    ## # A tibble: 1 × 12
    ##     age depth  d13C  d18O interval         ky_t0 fitted_d18O notrend_d18O z_d18O
    ##   <dbl> <dbl> <dbl> <dbl> <fct>            <dbl>       <dbl>        <dbl>  <dbl>
    ## 1  12.7  3.44 -7.86 -9.82 "Allerod\n(12.7… -6.69       -9.76      -0.0620 -0.106
    ## # … with 3 more variables: fitted_d13C <dbl>, notrend_d13C <dbl>, z_d13C <dbl>
    ## # A tibble: 1 × 12
    ##     age depth  d13C  d18O interval         ky_t0 fitted_d18O notrend_d18O z_d18O
    ##   <dbl> <dbl> <dbl> <dbl> <fct>            <dbl>       <dbl>        <dbl>  <dbl>
    ## 1  13.5  6.21 -9.94 -9.34 "Older Dryas\n(… -5.92       -9.78        0.440  0.750
    ## # … with 3 more variables: fitted_d13C <dbl>, notrend_d13C <dbl>, z_d13C <dbl>
    ## # A tibble: 1 × 12
    ##     age depth  d13C  d18O interval         ky_t0 fitted_d18O notrend_d18O z_d18O
    ##   <dbl> <dbl> <dbl> <dbl> <fct>            <dbl>       <dbl>        <dbl>  <dbl>
    ## 1  14.5  11.0 -8.53 -9.48 "Bolling\n(14.5… -4.91       -9.82        0.339  0.578
    ## # … with 3 more variables: fitted_d13C <dbl>, notrend_d13C <dbl>, z_d13C <dbl>
    ## # A tibble: 1 × 12
    ##     age depth  d13C  d18O interval         ky_t0 fitted_d18O notrend_d18O z_d18O
    ##   <dbl> <dbl> <dbl> <dbl> <fct>            <dbl>       <dbl>        <dbl>  <dbl>
    ## 1  15.0  12.3 -7.44 -9.36 "Big Wet\n(15-1… -4.41       -9.84        0.476  0.811
    ## # … with 3 more variables: fitted_d13C <dbl>, notrend_d13C <dbl>, z_d13C <dbl>
    ## # A tibble: 1 × 12
    ##     age depth  d13C  d18O interval         ky_t0 fitted_d18O notrend_d18O z_d18O
    ##   <dbl> <dbl> <dbl> <dbl> <fct>            <dbl>       <dbl>        <dbl>  <dbl>
    ## 1  16.2  13.7 -8.87 -9.35 "Big Dry\n(16.2… -3.21       -9.88        0.527  0.898
    ## # … with 3 more variables: fitted_d13C <dbl>, notrend_d13C <dbl>, z_d13C <dbl>
    ## # A tibble: 1 × 12
    ##     age depth  d13C  d18O interval         ky_t0 fitted_d18O notrend_d18O z_d18O
    ##   <dbl> <dbl> <dbl> <dbl> <fct>            <dbl>       <dbl>        <dbl>  <dbl>
    ## 1  17.5  17.5 -7.26 -9.80 "Last Glacial M… -1.92       -9.92        0.123  0.209
    ## # … with 3 more variables: fitted_d13C <dbl>, notrend_d13C <dbl>, z_d13C <dbl>

Scroll thru those to see if they match your expectations.

Now lets actually do some calculations, they’ll look the same as the
overall correlations above, but for each subinterval

``` r
for (i in 1:length(unique(dat$interval))) {
  #i'll use the interval names to subset 
  sub<-dat[which(dat$interval==t_int_names[i]),]
  #perform the test on a subinterval
  sub_test<-cor.test(sub$d13C,sub$d18O, method="pearson")
  #the output of cor.test is a new data structure, a list, i'll talk about below
  #but thats the reason for the new [[]] syntax
  
  #cat is has some features of both paste and print (and not others)
  #they key thing is that it evalueates the escape sequences i've added (e.g.,\n for a newline)
  # plot(sub$d13C,type = "l") #too look at plots
  cat(paste(t_int_names[i],sub_test$estimate[[1]],sub_test$p.value,"\n", collapse = '\t'))
}
```

    ## Younger Dryas
    ## (11.6-12.7 ka) 0.274877509325455 0.0819777622979314 
    ## Allerod
    ## (12.7-13.5 ka) 0.467708824462376 1.07033265162938e-05 
    ## Older Dryas
    ## (13.5-14.5 ka) 0.486435099214966 1.83210452109097e-10 
    ## Bolling
    ## (14.5-15 ka) 0.788257503009881 2.12928311931121e-10 
    ## Big Wet
    ## (15-16.2 ka) 0.558027648086811 5.59166831538501e-05 
    ## Big Dry
    ## (16.2-17.5 ka) 0.544954071386326 1.29057292947572e-09 
    ## Last Glacial Maximum
    ## (17.5-20 ka) 0.563408283012058 1.61452096989132e-13

It looks like there are a couple of main culprits in our correlation
because I didn’t de-trend each separately (yet) (This script is
unfinished, if you are interested in seeing the rest of this analysis in
R please let me know)
