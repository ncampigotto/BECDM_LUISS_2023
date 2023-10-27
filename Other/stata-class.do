////////////////////////////////////////////////////////////////////////////////
/////////////// BEHAVIORAL ECONOMICS AND CONSUMER DECISION MAKING //////////////
//////////////////////// STATA CLASS 26 SEPTEMBER 2023 /////////////////////////
////////////////////////////// Veronica Pizziol ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

********************************
* PREPARE ENVIRONMENT IN STATA *
********************************
* Useful commands: clear, set, cd, use, webuse, sysuse, import, describe, browse

**Prepare the environment in Stata
clear all				// This command removes everything from memory. Do it ALWAYS at the beginning of your do-file.
set more off			// This command ensures not to pause for "--more--" messages (messages from Stata telling you that it has something more to show you but that showing it to you will cause the information on the screen to scroll off)

**Set your working directory 
cd "C:\Users\veron\Documents\01_Research\10_Teaching\Luiss-2023\StataClass"

**Load the dataset (in this case with the "sysuse" command, if it is saved in your working directory, with the "use" command) 
sysuse auto2 // This dataset contains information about vintage 1978 automobiles sold in the US

**Describe the dataset
describe
des // You can use abbreviations of actual commands' names!

**Browse the dataset
browse

*******************
* UNDERSTAND DATA *
*******************
* Useful commands: describe, codebook, summarize, count, tabulate

**You can use describe also for specific variables
des price
des rep78
des foreign

/*
Codebook examines the variable names, labels, and data. Use it to better know your variables! Especially the numeric variables that in your dataset appear in blue: this means that they dispay the label (which is a string) but they are instead numeric (as in the case of "rep78" and "foreign" variables).
*/
codebook price
codebook rep78 
codebook foreign

**The command "summarize" displays a variety of summary statistics. The "detail" option displays additional stats (such as the percentiles).
summarize 
summarize price
sum price, detail
sum price, d

/* Let's explore how to use the "if" condition. The "if" at the end of a command means that the command is to use ONLY the data specified.
If you have OPTIONS specified after the comma (as the "d" option in this case) remember to put the "if" BEFORE the comma.
*/
sum price if price<5000 // I want to know the summary statistics for price for cars with price lower than 5000
sum price if price<5000, d // Same as before, but WITH option "details" after the comma
sum price if price<=5000 // The output is identical to the one before because there is NO observation with price exactly equal to 5000
sum price if price<=5079 // In this case the output is different because there is ONE car that has a price of 5079
sum price if rep78==2 // Remember, the if with an euqual conditions NEEDS a double equal sign

**Let's explore the count command
// Count the number of foreign automobiles
count if foreign==1 
// Count the number of domestic automobiles
count if foreign==0
// Count the number of cars at least "fair"
count if rep78>=2 
// Count the number of cars at least "average"
count if rep78>2 
count if rep78>=3 // This is an equivalent way to achieve the same as above. Why?

**Let's play with the "AND" and "OR" logical operators. Let's use "sum" as the main command (but this logics applies for any command)
sum price if price<5000 & rep==2 // "cheap" AND "fair"
sum price if price<5000 & rep==2, d // "cheap" AND "fair" + "details" option
sum price if price<5000 | rep==2 // "cheap" OR "fair"
sum price if price<5000 | rep>=3 // "cheap" OR "at least average"
sum price if price<5000 & foreign==1 | rep>=3 & foreign==1 // "cheap AND foreigner" OR "at least average AND foreigner"
sum price if price<5000 & rep==1 | price<5000 & rep==2 // "cheap AND poor" OR "cheap AND fair"
sum price if price<5000 & (rep==1 | rep==2) // This is an equivalent MORE COMPACT way to write the above!!!

**Tabulate: 
tabulate rep78
tab rep78
tab foreign
by foreign: tab rep78 // This gives you TWO outputs: one for the foreign cars (foreign = 1) and one for the domestic cars (foreign = 0)

***************
* MANAGE DATA *
***************
* Useful commands: order, sort, gsort, bysort, rename, gen, egen, replace, label var/define/values, drop, keep, encode, compress, save

**Relocate variables in the dataset
**Without specifying "before" or "after" options, order puts the variable as FIRST column in the dataset.
order foreign, after(rep78) // You can use the "after" option
order rep78 foreign, before(price) // You can use the "before" option. Also, you can always specify more variables to be relocated

**Sort variables
sort price // Arranges observations in ascending order based on price values
gsort -price // Arranges observations in descending order based on price 
gsort -make // It works also for "strings" variables. This arranges observations from Z to A
sort make // From A to Z
sort make rep78 // From A to Z "AND" from lowest to best condition... That is different from... 
sort rep78 make // So: the order matters!

**Bysort: produces the command (in this case "summarize") for each specified group separately (in this case "foreign" and "domestic" cars)
bysort foreign: summarize(mpg) 

**Rename variables
rename rep78 rep // Renames the "rep78" variable as "rep"
rename headroom space_above_head // DO NOT USE SPACES IN YOUR VARIABLES NAMES. If a variable is made of more words, connect them with "_"
rename turn turn_circle

**Generate new variables and replace values
gen domestic=. // Generates a new numeric variable named "domestic"
replace domestic=1 if foreign==0 // "domestic" assumes value "1" when "foreign" assumes value "0"
replace domestic=0 if foreign==1 // domestic = 0 only for those observations whose "foreign" variable is equal to 1
gen domestic_ = (foreign==0) // Another more compact way to achieve the same result is this one... But you can safely use the one above!

**Generate new labels
label var domestic "Car origin is US" // Attaches a label to a variable
label define domestic_lab 0 "No US" 1 "US" // Creates a set of numeric values and their corresponding labels
label values domestic domestic_lab // Attaches a value label (domestic_lab) to a var (domestic)

**Drop variables
drop domestic_

**But you can also drop OBSERVATIONS. BE CAREFUL ON WHAT YOU DROP! It's costly to come back to the original dataset every time.
**Let's drop observations from the super costly cars. Maybe, we can claim that they are outliers and for a specific type of analysis that we are doing, we don't need them.
drop if price>14000 

**You can also use "keep"
keep if price <14000 // This command line would achieve the same result as before. Now we have already dropped the 2 observations, so no actual dropping occurs

** You can also keep variables. 
keep _all // This keeps all variables in the dataset. If we wanted to keep only SOME, we should have specified which ones (e.g., keep make foreign rep price)

**Encode is useful to create a numeric variable for string variables
encode make, gen(id) // We specify the "generate" option to have a new variable "id" instead that replacing the "make" variable 
order id, after (make) // We move "id" close to "make" to compare them
sort id // We sort our data according to the main variable (the one that identifies each observation) because we are going to save soon our data and we want them neat and clean

**Use "compress" to reduce the amount of memory used by your data
/*Compress attempts to reduce the amount of memory used by your data. Stata will check whether there are variables that may need less computer space than is provided for in the storage type and will change the storage type accordingly.
*/
compress

**Store the new dataset currently in memory on disk.
save auto_new.dta, replace //If you don't specify the format, the default extension used is ".dta". Use the replace option to overwrite your data.

*****************
* DESCRIBE DATA *
*****************

/*
The "Tabstat" command displays summary statistics for a series of numeric variables in one table.
It allows you to specify the list of statistics to be displayed with the "statistics" (abbreviated in "s") option.
*/

tabstat price, s(mean) // This displays the mean of the price variable
tabstat price, s(mean sd) // This displays the mean and standard deviation of the price variable
tabstat price, s(mean sd p50) // This displays the mean, standard deviation, and median of the price variable
tabstat price, s(mean sd p50 min max) // This displays the mean, standard deviation, median, minimum and maximum values of the price variable
tabstat price, s(mean sd p50 min max N) // This displays the mean, standard deviation, median, minimum and maximum values, and number of observations of the price variable
tabstat price mpg rep weight, s(mean sd p50 min max N) // You can ask tabstat to show statistics for MORE variables 
tabstat price mpg rep weight, s(mean sd p50 min max N) by(foreign) // Use the BY option to display statistics for each group variable. In this case we will have two tables: one for foreign cars and one for domestic cars.

/*
In the assignments, you can just put the screenshot of the output in Stata. However, if you want a nice table to put in a .doc file, try the following command. 
The asdoc command has been programmed by a user, so we need first to install it if it's the first time we use it.
*/
ssc install asdoc, replace // This line installs the command "asdoc"
asdoc sum price mpg rep weight, save(summary_all.doc) title(Descriptive statistics) replace // This is Table 1 in the "Stata_Notes" file
asdoc sum price mpg rep weight, save(summary_by_origin.doc) title(Descriptive statistics by car origin) by(foreign) replace // This is Table 2 in the "Stata_Notes" file


******************
* VISUALIZE DATA *
******************

**Histograms. They are useful to get the distribution of a variable.
hist price
hist price, frequency
hist price, frequency kdensity
hist price, frequency kdensity color(stc1%70) lcolor(navy) kdenopts(lc(stc2)) title("Price distribution") name(hist_1, replace)

// Let's save our histogram in ".gph" format (the Stata format for graphs) and in a format that we can insert in a Word document, such as ".png"
graph save hist_1.gph, replace
graph export hist_1.png, replace

//Let's put foreign and domestic cars on the same histogram
twoway (hist price if foreign==0, frequency fcolor(none) lcolor(stc1)) (hist price if foreign==1, frequency fcolor(none) lcolor(stc2)), title("Price distribution") legend(lab(1 "US origin") lab(2 "Foreign origin"))

// Let's save our histogram in ".gph" format (the Stata format for graphs) and in a format that we can insert in a Word document, such as ".png"
graph save hist_2.gph, replace
graph export hist_2.png, replace


**Scatter plots. They are useful to investigate the relationship between two variables.
scatter mpg weight // Let's investigate the relationship between mileage and weight of a car
scatter mpg weight, title("Mileage vs. Vehicle Weight") name(scatter_1, replace) 

//Let's put foreign and domestic cars on the same graph
twoway (scatter mpg weight if foreign==0)(scatter mpg weight if foreign==1), title("Mileage vs. Vehicle Weight" "for foreign and domestic cars") legend(lab(1 "US origin") lab(2 "Foreign origin"))

//Let's save this scatter plot!
graph save scatter_2.gph, replace
graph export scatter_2.png, replace

/*Let's see what is the correlation between these two variables. This is not a graph, but a statistical analysis that will provide us with a number.
We can use this number, i.e., the correlation coefficient, to quantify the linear relationship between two variables on a scale between -1 and 1.
We can use this information to comment our previous scatter plot.
*/
corr mpg weight
pwcorr mpg weight, sig star(0.1) //If you need p-values for correlations and starts ONLY for the statistically significant correlations

// We can use the same command with more variables. The output will be a correlation matrix that shows the pairwise correlation between each pair of variables.
pwcorr mpg weight length space_above_head displacement price, sig star(0.1)

**Bar graphs: Use them to visualize mean values of a variable over a different variable. For instance, mean prices over the repair statuses.
graph bar (mean) price, over(rep, relabel(1 "One repair" 2 "Two repairs" 3 "Three repairs" 4 "Four repairs" 5 "Five repairs")) ytitle("Average Price ($)") title("Average price by number of repairs in 1978")

//Let's save our graphs, as usual
graph save graphbar_1.gph, replace
graph export graphbar_1.png, replace


**********************
* HYPOTHESIS TESTING *
**********************

/*
1) One sample t-test (a variable equal to a specific value).
Let's compare a variable to a specific value.
*/
ttest mpg == 30

/*
2)	Paired t-test (two variables being equal).

Let's compare two variables. For instance, let's imagine we have historical values of price: price_1 is price at year 2022 and price_2 is price at year 2023.
I will generate two new variables for creating this example. They have NO actual meaning in terms of real price.
YOU CAN FORGET ABOUT THE "SET SEED" AND "RUNUFORM" COMMAND FOR YOUR ASSIGNMENT. They are useful to me just to create the example.
You shoould just care about the t-test!
*/
set seed 54321
gen price_1 = runiform()

set seed 12345
gen price_2 = runiform()

ttest price_1 == price_2


/*
3)	Two sample t-test (a variable being equal across different groups).

Let's compare a variable across two groups
(for example across domestic and foreign cars).
*/

ttest mpg, by(foreign)

***************************************************
* EXTRA MATERIALS NOT NEEDED FOR THE ASSIGNMENTS! *
***************************************************

***LOOPS

/*
Foreach and forval loops.
They are very useful when you have big datasets.
You will NOT need them in the assignments, but it's good to know how they work.
*/

// Foreach loops + egen command
global varlist price mpg length weight
foreach var in $varlist { 
egen mean_`var' = mean(`var')
}
/* The var is treated as a local macro */

// Forval loops
forval i=1/5 {
gen rep_dummy`i'=1 if rep==`i'
recode rep_dummy`i' . = 0 
}


***OLS REGRESSION

/*
Again, NOT needed for the assignments.
Useful for those who want to pursue a more quantitative carrier.
They are used when we want to exploit the dataset to investigate the relationship between two variables more in depth and not just via correlations.
Let's for instance investigate the relationship between weight of a car and its miles per gallon.
OUTCOME OF INTEREST: mpg
VARIABLE OF INTEREST: weight
Potential control variables: lenght, trunk, gear_ratio
*/

**Model 1
regress mpg weight

**Model 2
regress mpg weight length trunk gear_ratio

/*
Now we write again the two models but this time we save them with the command outreg2.
This command gives the option to export regression output directly to Word.
We first need to install the command since it is a user-written command.
*/
ssc install outreg2

**Model 1
reg mpg weight
outreg2 using regression_table.doc, replace ctitle(Model 1)

**Model 2
reg mpg weight length trunk gear_ratio
outreg2 using regression_table.doc, append ctitle(Model 2) // By using "append" we are comining the results of the two models in a single table

**********************************************************************
* This is the end of the do-file!!! **********************************
* If you haven't yet, save if by clicking on the "floppy-disk" icon! *
**********************************************************************