* What: SRQM Session 5
* Who:  F. Briatte and I. Petev
* When: 2012-02-13


* ================
* = INTRODUCTION =
* ================


* This do-file is adapted from the replication material (data and code) provided
* by Frank Baumgartner et al., "Lobbying and Policy Change. Who Wins, Who Loses,
* and Why" (University of Chicago Press, 2009). The analysis and interpretation
* does not necessarily follow the original work: replicate and see for yourself.

* Data: Lobbying and Policy Change, Issue-Level Dataset (2010).
cap use "http://www.unc.edu/~fbaum/books/lobby/_documentation/data/issue_level_data_24_August_2010.dta", clear

* Use local copy if the original dataset cannot be downloaded at the URL above.
if _rc != 0 use "Datasets/lobbying2010.dta", clear

* Create a folder to export tables and graphs. This code is particularly handy
* if you are working on a draft paper and need to save a few replication files.
global pwd=c(pwd)
global wd "Replication/week5-files"
cap mkdir "$wd"
cd "$wd"

* Use the black and white graph scheme by Edwin Leuven for figures.
cap net from "http://leuven.economists.nl/stata"
cap net install schemes
cap set scheme bw

* Log.
cap log using "week5.log", name(week5) replace

* This do-file contains a detailed guide to exporting summary statistics tables
* with the tsst or tabout commands: make sure that you use these commands when
* you work on the first draft of your final paper! To export graphics, use the
* graph export command.

* Finally, note that this do-file uses programming functions like foreach loops
* that are beyond our course requirements. In practice, you are not required to
* produce similar code: everything you need to know on variable transformations
* is in the do-file from last week.


* ================
* = DATA SUMMARY =
* ================


* In a nutshell, Baumgartner et al. identified US organizations that reported
* lobbyists in the late Clinton (1999-2000) and early Bush (2001-2002) years.
* They then asked them details on the very last policy issue that had crossed
* their desk. The result is a pseudo-randomized sample of 98 policy issues.

* Chapter 5 of the book is an analysis of partisan vs. non-partisan issues, as
* measured on a 2-point scale by policy advocates that also include government
* officials. The authors refined that measure by looking at party positions to
* distinguish "strongly partisan" (2) from "somewhat partisan" (1) issues.

* Summary of the two partisanship measures.
tab1 partisan partisan3

* Crosstabulation of both measures supported by Fisher's exact test, which we
* will cover next week with other non-parametric association tests.
tab partisan partisan3, exact

* The authors also collected systematic information on Congressional activity
* and media coverage for each issue. Relevant measures are summarised below.

* Variable labels.
d p00* partisan* bills hearings witness floor house senate natjourn news tv

* Summary statistics.
su p00* partisan* bills hearings witness floor house senate natjourn news tv

* Both.
codebook p00* partisan* bills hearings witness floor house senate natjourn news tv, c

* Our empirical interest is whether a higher degree of partisanship over a given
* issue is associated with higher degrees of political and media salience. These
* three dimensions of policy-making might or might not match; the data will help
* understand how the agendas of parties, Congressmen and media outlets interact.
* Please refer to Baumgartner et al. 2009 for a complete treatment of the topic.

* List policy issues by degree of partisanship, summarising Congressional bills,
* overall floor statements and TV news stories for each issue in the dataset.
bysort partisan3: table p002name, c(mean bills mean floor mean tv)

* Plotting various measures of salience over each degree of partisanship.
* Select all lines in the foreach loop to execute.
foreach v of varlist bills hearings witness floor house senate natjourn news tv {
	tw (hist partisan3, lc(gs8) xti("") yti("") discrete xlab(0 "low" 1 "med" 2 "hi") ylab(0(.25).5, angle(0)) ysc(alt axis(1))) ///
		(sc `v' partisan3, yti("", axis(2)) sort ylab(, axis(2) angle(0)) yaxis(2) ysc(alt axis(2))), ///
		ti(`v', size(medium) margin(bottom)) legend(off) name(`v',replace)
}

* Fig. 1
* ------

* Measures of political and media salience by degree of partisanship.
* Run all lines together to generate.
gr combine bills hearings witness floor house senate natjourn news tv, ///
	note("Right axis: histograms by degree of partisanship. Left axis, from top to bottom and left to right: number of bills introduced, hearings held, " ///
	"witnesses testifying before Congress, floor statements (overall, House, Senate) and news stories (National Journal, newspapers, TV).", margin(sides) size(vsmall)) ///
	name(fig1, replace)
gr export fig1.pdf, name(fig1) replace

* The degree of partisanship coded by Baumgartner et al. creates three groups of
* policy issues within their sample. To generalize these proportions to the true
* population of policy issues, we estimate the proportions of each group.
prop partisan3


* =============================
* = EXPORT SUMMARY STATISTICS =
* =============================


* There are two simple ways to export a summary statistics table. The first one
* involves the tsst command, which is part of the SRQM Teaching Pack. Using the
* tsst command should be enough for the purposes fo this course. The second way
* of exporting summary statistics tables involves installing the tabout command
* and using its two export commands. This method consumes more code but it will
* work outside this course and provides more flexibility and options. 

* (1) tsst
* --------

* The command is part of the course: if you have set up the SRQM folder as your
* working directory, it should work straight away.

tsst using stats.txt, su(hearings witness floor house senate natjourn news tv) fr(partisan3) replace


* (2) tabout
* ----------

* Install the command by uncommenting the line below.
* ssc install tabout, replace

* Export continuous data.
tabstatout bills hearings witness floor house senate natjourn news tv, ///
	tf(stats1) s(n mean sd min max) c(s) f(%9.2fc) replace

* Export categorical data.
tabout partisan3 using stats2.csv, ///
	replace c(freq col) oneway ptot(none) f(2) style(tab)

* Note: CSV files often require that you import them rather than just open them.
* In Microsoft Excel, use 'File : Import' and follow the Excel import procedure.
* Furthermore, as tabout uses two different commands and files to save summary 
* statistics, you will need to assemble the final table in your spreadsheet or
* text document. Editors from the Google Documents or Open Office suites also
* have excellent editing capabilities.


* ==================
* = MEAN ESTIMATES =
* ==================


* Mean number of bills, hearings and witnesses for each degree of partisanship.
table partisan3, c(n bills mean bills mean hearings mean witness)

* The apparent progression of each measure is a characteristic of the sample. To
* generalize to the true population of issues, we show 95% confidence intervals,
* shown here for the number of Congressional bills introduced.
bysort partisan3: ci bills

* The intervals tend to indicate that only strongly partisan issues generate a
* systematically higher number of bills introduced in Congress. However, bills
* are not a normally distributed variable: a histogram shows extreme skewness.
hist bills, normal percent

* Another way to realise the problem is to compare the mean and median amount of
* bills introduced before Congress for each degree of partisanship. The command
* below reveals that the average number of bills for low and somewhat partisan
* issues is far superior to the median, indicating "positive" (left-side) skew.
tabstat bills, s(n mean median) by(partisan3)

* The ladder of powers shows that we can arrange for this problem by using the
* square root of bills to approach normality. This command is the same command
* as the "gladder" command, using a statistical test instead of a visual check.
ladder bills

* Transforming bills to its square root.
gen sqrt_bills=sqrt(bills)
la var sqrt_bills "Number of bills introduced (square root)"

* Comparing skewness and kurtosis for bills and its square root.
tabstat bills sqrt_bills, s(skew kurt) c(s)

* Computing more accurate 95% confidence intervals on sqrt(bills). Check whether
* the intervals are similar to the previous ones for bills, in order to confirm
* or not the observation that highly partisan bills are significantly associated
* with a higher number of bills introduced before Congress.
bysort partisan3: ci bills sqrt_bills

* Checking whether other variables might require a non-linear transformation 
* prior to assuming normality. The "sktest" command is less preferrable than
* visual diagnostics with quantile plots; it is used here for brevity, and a
* code loop for generating quantile plots is provided below.
sktest bills hearings witness floor house senate natjourn news tv

* Below is a trivial loop to assess the normality of each independent variable.
* Uncomment and select all lines to run:

* foreach v of varlist bills hearings witness floor house senate natjourn news tv {
*	qnorm `v', name(qplot_`v', replace)
* }

* The same logic thus applies to all measures of salience. The following code
* assumes that a square root or log transformation might apply to each measure,
* and performs a transformation where relevant based on a Chi-squared test. The
* details of the code are unimportant, it just runs quicker than manual checks,
* although that is how it was done in the first place to check for other otions.
* Select all lines in the foreach loop to execute.
foreach v of varlist bills hearings witness floor house senate natjourn news tv {
	cap drop log_`v' sqrt_`v'
	qui ladder `v' // check for a square root transformation
	if r(P_sqrt) < .05 & r(sqrt) < r(ident) cap gen sqrt_`v' = sqrt(`v')
	cap gen `v'_hack=`v'+1 // circumvent zero values by adding a tiny value
	ladder `v'_hack // check for a logarithmic transformation
	if r(P_log) < .05 & r(log) < r(ident) cap gen log_`v' = ln(`v'_hack)
	if r(P_log) < .05 & r(log) < r(sqrt) cap drop sqrt_`v'
	drop `v'_hack
}
tabstat log_* sqrt_*, s(n mean variance sd skew kurt) c(s)

* The next fraction of the code computes 95% confidence intervals from summary 
*statistics for all transformed measures of salience. Note that the operation 
* will temporarily overwrite the initial data while executing, then restore it.
* Select all lines in the foreach loop to execute.
global i=0
foreach v of varlist log_* sqrt_* {
	global i=$i+1 // graph counter
	di $i
	preserve
	statsby "su `v'" mean=r(mean) sd=r(sd) n=r(N), by(partisan3) clear
	gen ub = mean + invttail(n-1,0.025)*(sd / sqrt(n)) // upper bound
	gen lb = mean - invttail(n-1,0.025)*(sd / sqrt(n)) // lower bound
	* Plot.
	tw sc mean partisan3, xti("") xsc(r(-.5(.5)2.5)) xlab(0 "low" 1 "med" 2 "hi") ms(O) || ///
	rcap ub lb partisan3, lc(black) ||, ///
	ti(`v', size(medium) margin(bottom)) legend(off) yla(, ang(h)) ///
	name(ci$i, replace)
	restore
}

* Fig. 2
* ------

* Estimates of political and media salience by degree of partisanship.
* Run all lines together to generate.
gr combine ci7 ci1 ci8 ci2 ci3 ci4 ci5 ci9 ci6, note("Confidence intervals at 95% by degree of partisanship. From top to bottom and left to right: number of bills introduced, hearings held, " ///
	"witnesses testifying before Congress, floor statements (overall, House, Senate) and news stories (National Journal, newspapers, TV).", margin(sides) size(vsmall)) ///
	name(fig2, replace)
gr export fig2.pdf, name(fig2) replace


* ========
* = EXIT =
* ========


* Close log (if opened).
cap log close week5

* Reset working directory.
cd "$pwd"

* We are done. Just quit the application, have a nice week, and see you soon :)
* exit
