*------------------------
* Set Up Environment
*------------------------
clear
* Clear the environment before starting a new task

cd "/Users/ewuramaokai/Desktop/Northwestern/Winter 2021/[TA] SOC 401-1/[01.13.21] Lab1"
* Set your current working directory (folder you want to import from/export to)

log using Lab1.smcl, replace
/* Sets up a log file (a file that tracks all the code you run in the session 
it is opened for). */

use "SOC401_W21_Billionaires.dta"
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
* Describing Variables
*------------------------

	describe 

*------------------------
* Cleaning Variables
*------------------------
* INDEPENDENT VARIABLE - Gender (Categorical)
	
		rename demographicsgender female
	* Renaming the variable (that you code with)

		label variable female "Female"
	* Renaming the variable label that appears

		recode female (2=0) (1=1)
	* Transforming the data to make the analysis easier

		label define gender 0 "Male" 1 "Female"
		label values female gender
	* Labeling each value in the data


* INDEPENDENT VARIABLE - Age (Continuous)

		rename demographicsage age
	* Renaming the variable	
	
	
*------------------------
* Missing Values
*------------------------

		tabulate female, m
	* See frequency distribution of variables
	
		recode female (3=.)
	* Recode values that don't fit to missing
	
		replace age=. if age<21
	* Replace the numbers in age with missing values (if not already done)
	
		mdesc age female
	* An additional package that is useful for checking missing values.
	* Includes percent missing and actual missing count


*------------------------
* Describing Data
*------------------------

	summarize age
	summarize age, detail
/* Descriptive Statistics of a continuous variable (means, sd, range)
	If you include "detail", you can see additional descriptive statistics, 
	including skew, variance and quartiles. */
	
	tabulate female
	tabulate female, nolabel
/* Frequency distributions for ordinal/categorical variables
		If you include "nolabel" , it shows you the variable with their 
		numeric value. */

	histogram age
	histogram age, bin(10)
* Visualize the distribution of continous variables

	graph bar, over (female)
* For categorical/ordinal variables 



*------------------------
* Closing Environment
*------------------------

log close
translate Lab1.smcl Lab1.pdf



