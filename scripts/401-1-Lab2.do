*------------------------
* Set Up Environment
*------------------------
clear
	* Clear the environment before starting a new task

cd "/Users/ewuramaokai/Desktop/Northwestern/Winter 2021/[TA] SOC 401-1"
	* Set your current working directory (folder you want to import from/export 
	* to)

log using Lab2.smcl, replace
	/* Sets up a log file (a file that tracks all the code you run in the 
	session it is opened for). */

use "SOC401_W21_Billionaires_v2.dta"
	* This is the data we'll be using. This command opens the .dta file in STATA
 

*------------------------
* Evaluating Associations
*------------------------
/* In linear regression, we assume that there is a linear relationship between
	our continuous variables and our outcome variable. To verify this, we need 
	to check the relationship between y and x. One way to do this is to
	create a scatter graph that visualizes them together.*/
	
scatter wealthworthinbillions age
	/*This makes a basic scatter graph of y (dependent variable) on x 
	(independent variable). It allows you to gauge - from initial glance - 
	whether there is a linear relationship between y and x.*/
	
	*At times though, we need extra help to see the linear association.
	
scatter wealthworthinbillions age || lfit wealthworthinbillions age
	/* This allows us to place a line of best fit (regression line) over our
	scatter graph. When we use the 'lfit' command though, we assume that 
	that the realtionship is linear to begin with, and simply ask STATA to 
	show us what that linear relationship is. This means it will fit a line 
	EVEN IF the relationship isn't linear. */
	
scatter wealthworthinbillions age || lowess wealthworthinbillions age
	/* This places what we call a 'lowess' curve on your graph. The important 
	thing to remember about this command is that it creates a line that is
	weighted to the data. This means it accounts for outliers to reveal whether
	there are aspects of your data that deviate from linearity / shows if the 
	relationship isn't linear. */
	
	/* RESEARCH NOTE
		Evaluating linearity - as with many aspects of quantitative research - 
		involves subjective interpretation. Does the result of our previous
		lowess curve count as a 'linear' relationship? What wouldn't count as
		linear? */

		
/* Another way we might evaluate for linear regression is the 		
	correlation between your variables. This is especially important amongst 
	various independent variables to make sure they do not violate the 
	assumption of independence (collinearity). */

correlate wealthworthinbillions age female
	/* We are able to evaluate whether two variables are strongly, moderately
		or even highly correlated with one another in this context. 
		Correlate uses "listwise deletion" to deal with missing values, 
		meaning that if an observation is missing on ANY of the variables 
		you are correlating it deletes it automatically from the entire 
		correlation matrix.*/

pwcorr wealthworthinbillions age female, sig    
pwcorr wealthworthinbillions age female, star (0.05)
	/* The command does a number of things differently from 'correlate'
		a) It addresses missing values differently. Pwcorr uses 
			"pairwise deletion", meaning it excludes an observation from the 
			correlation calculation of each pair of correlations. 
			i.e. If there are missing values on age but not the other variables, 
			only the correlations with age will see their sample size change. 
		
		2) Correlate doesn't allow you to the statistical significance of an
			association. With pwcorr, you can ask to see the p-value for the 
			correlations (sig), and even have it display a star if the p-value
			is below the number you write in the brackets. */


*------------------------
* Running (and reading) a Regression
*------------------------
/* At this point, you've checked the linearity of associations between your 
continuous independent and dependent variables, as well as checked the 
correlations between all the variables for your analysis. It is now time to 
run your first regression. */

regress wealthworthinbillions female age 
	/*As you can see, the command is relatively straight forward. 
		Remember: the dependent variable always comes first in the code 
		(the logic being that you are regression y on x). The starred outputs 
		are what you will likely spend the most time analyzing. 
		
		COME SEEK HELP IF YOU'RE CONFUSED ON WHAT ANY OF THESE MEAN!*/
		
/*		
      Source |       SS           df       MS      Number of obs   =    *2,229*
-------------+----------------------------------   F(2, 2226)      =      8.88
       Model |  515.668041         2  257.834021   Prob > F        =    0.0001
    Residual |  64627.4392     2,226  29.0329916   R-squared       =   *0.0079*
-------------+----------------------------------   Adj R-squared   =    0.0070
       Total |  65143.1073     2,228  29.2383785   Root MSE        =    5.3882

------------------------------------------------------------------------------
wealthwort~s |      Coef.    Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      female |   *.4309052*  .3898967     1.11   0.269    -.3336941    1.195504
         age |    .0354921    .008692     4.08  *0.000*    .0184469    .0525373
       _cons |    1.461568   .5575309     2.62   0.009    *.3682333    2.554903*
------------------------------------------------------------------------------*/

/*Let's take a look at a few variations on code you might want to know.*/	

regress wealthworthinbillions i.female c.age
	/*You might be wondering: what do the 'i.' and 'c.' mean? Sometimes, we need
	to tell Stata how to treat each variable. The 'i' tells Stata to treat it 
	as an indicator variable (categorical), and 'c' identifies it as continuous.
	
	Notice how our female variable now shows the name of the variable, and 
	beneath it the actual value labeled one. */
	
/*
      Source |       SS           df       MS      Number of obs   =     2,229
-------------+----------------------------------   F(2, 2226)      =      8.88
       Model |  515.668041         2  257.834021   Prob > F        =    0.0001
    Residual |  64627.4392     2,226  29.0329916   R-squared       =    0.0079
-------------+----------------------------------   Adj R-squared   =    0.0070
       Total |  65143.1073     2,228  29.2383785   Root MSE        =    5.3882

------------------------------------------------------------------------------
wealthwort~s |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      female |
     Female  |   .4309052   .3898967     1.11   0.269    -.3336941    1.195504
         age |   .0354921    .008692     4.08   0.000     .0184469    .0525373
       _cons |   1.461568   .5575309     2.62   0.009     .3682333    2.554903
------------------------------------------------------------------------------*/

	
/* LONG ANSWER:
	Stata's automatic response is to treat any variable as "a ONE unit difference in". 
	While that makes sense for continuous and MOST ordinal variables, that 
	doesn't really make sense for nominal variables, especially those with more
	than two categories. Using this is useful to make sure you (and Stata)
	are always aware what each variable is. */
	

regress wealthworthinbillions i.female c.age if wealthtype2==3
	/* Sometimes, you want to run a regression on a subsample of people in 
	your dataset. The 'if' command lets you specify what that subgroup is 
	(I selected observations with billionaires whose wealth was inherited).
	
	Notice how the number of observations changes. */

/*	
      Source |       SS           df       MS      Number of obs   =       765
-------------+----------------------------------   F(2, 762)       =      7.99
       Model |  372.207956         2  186.103978   Prob > F        =    0.0004
    Residual |  17754.1282       762  23.2993809   R-squared       =    0.0205
-------------+----------------------------------   Adj R-squared   =    0.0180
       Total |  18126.3362       764  23.7255709   Root MSE        =    4.8269

------------------------------------------------------------------------------
wealthwort~s |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      female |
     Female  |   .5844082   .4130495     1.41   0.158    -.2264418    1.395258
         age |   .0482612   .0128561     3.75   0.000     .0230236    .0734988
       _cons |   .8206522    .830654     0.99   0.323    -.8099897    2.451294
------------------------------------------------------------------------------*/


*------------------------
* Closing Environment
*------------------------

log close
translate Lab2.smcl Lab2.pdf, replace


	


	

