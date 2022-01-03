*------------------------
* Lab 1 
* 401-1-Lab1.do 
* 12/20/2021
* Ewurama Okai, Northwestern University
* Rose Werth, Northwestern University 
* 
* Topics: Data cleaning review 
*------------------------


*------------------------
* Set Up Environment
*------------------------

cd "/Users/srwerth/Documents/Work_Research/Regression_Labs"
* Set your current working directory (folder you want to import from/export to)

clear all
* Clear the environment before starting a new task

capture log close 
* If there's a previous log set up, close it

log using Lab1.smcl, replace
/* Sets up a log file (a file that tracks all the code you run in the session 
it is opened for). */

version 17
/* Tells Stata what version you wrote this .do file in, in case you are running
it in a different version later. Sometimes commands can change between versions. 
This prevents any inconsistencies between versions from causing errors. */

set linesize 80
/* The linesize limit makes output more readable. It prevents tables from being
too wide*/ 

use "data_raw/SOC401_W21_Billionaires.dta"
* This is the data we'll be using. This command opens the .dta file in STATA

/* 
VARIABLES OF INTEREST
wealthworthinbillions
demographicsage
demographicsgender2
wealthhowinherited2
wealthtype2
wealthhowcategory2
locationregion2
*/


*------------------------
* Exploring your data 
*------------------------

* Look at a summary of the dataset 
	describe 

* Summary of specific variable
	describe demographicsgender2
	
* You can also look at your dataset in a spreadsheet format in the data pane

* Missing variables 
/*Stata doesn't have a great command to look at missing data, so we have to 
install one. You only  have to do this once per .do file. */ 
ssc install mdesc
* Now you can look at missing values per variables
mdesc

* Or missing for a specific variables
mdesc companyname


*------------------------
* Descriptive Statistics 
*------------------------
/* Descriptive Statistics of a continuous variable (means, sd, range)
	If you include "detail", you can see additional descriptive statistics, 
	including skew, variance and quartiles. */
	summarize demographicsage
	summarize demographicsage, detail

/* Frequency distributions for ordinal/categorical variables
		If you include "nolabel" , it shows you the variable with their 
		numeric value. 
		If you include "missing", it shows you if there are any values 
		left as missing */	
	tabulate demographicsgender2
	tabulate demographicsgender2, nolabel
	tabulate demographicsgender2, missing



*------------------------
* Cleaning Variables
*------------------------
* INDEPENDENT VARIABLE - Gender (Categorical)
	* Let's lok at the gender variable again. 
		tabulate demographicsgender2
		
	/* I notice a few things you will want to change about that variable: 
		a) The variable name is tedious to type 
		b) We want this to be a dummy variable where 1 is female and 0 is not 
			female (in this binary, male). 
		c) We have three married couples in our data set coded as 3
	Let's get this variable in shape */

* Option 1 using recode command 

		gen female = demographicsgender2
	* Create a new variable named female with the same values as the old variable

		label variable female "Female (recoded)"
	* Renaming the variable label that appears

		recode female (3 = 0) (2 = 0) (1 = 1) 
	* Option 1: Recoding the data so 0 is "Not Female" and 1 is "Female" 

		label define gender 0 "Not Female" 1 "Female"
		label values female gender
	* Labeling each value in the data
	
		tab female demographicsgender2 // Checking the variable

* Option 2 using replace commands

		gen female2 = . 
		label variable female "Female (Male/Female)"
	* Create a new variable named female2 and set to missing and label. 
	
		replace female2 = 0 if demographicsgender2 == 2 
		replace female2 = 1 if demographicsgender2 == 1
	* Use replace to recode male and female, leaving 3 as missing. 
	
		label define gender2 0 "Male" 1 "Female"
		label values female2 gender2
	* Labeling each value in the data
		
		tab female2 demographicsgender2, missing
	* Check the new variable 


* INDEPENDENT VARIABLE - Age (Continuous)
	* Let's take a look at the age variable before we work with it. 
		tab demographicsage, missing
		
	/* The major concern is that there are some numbers that seem unreasonable. 
		Age is not negative, and 0 is an unlikely age for a person in a 
		billionaire dataset.Let's recode those variables to missing (.) 
		for now.*/
		
		generate age = demographicsage
		label variable age "Age (recoded)"
	* Create a new varaible named age with the same values as the old variable. 
	* Label it. 
		
		replace age = . if age <= 0
	* Replace any values 0 or below as missing. 
	
		summarize age 
	* Use summarize to check the new range. 
	
		mdesc age
	* Use mdesc to check the new number of missing values. 


*------------------------
* Basic Graphs 
*------------------------

* Histograms for continuous variables
	histogram age
	
	histogram age, bin(10)
	* Change the number of bins 
	
* Box plots for continouous variables
	graph box age
	
	graph box age, over (female2)
	* Create two side by side box plots of age for male and female 

* For categorical/ordinal variables 
	graph bar, over (female)
	
	
*------------------------
* Subsetting and Saving Data 
*------------------------

	keep year age female2
* Subset to specific variables

	describe
* Check the new dataset 

	drop female2
* Drop a specific variable

	drop if age < 30  
* Drop observations where age is greater than or equal to 30 years. 

	summarize age 
* Check the new range of age and number of observations overall. 

	save "data_work/mysubset.dta", replace
* Save your new subset in stata format 

	export delimited using data_work/mysubset.csv, replace 
* Save your subset in csv format 



*------------------------
* Closing Environment
*------------------------

log close
translate Lab1.smcl Lab1.pdf, replace



