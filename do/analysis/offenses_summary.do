*********************************************************************************************************************************
*																																*
*			Sanctuaries																											*
*			name file: offenses.do																								*
*			merges file with total offenses at county-year-month level with treatment variable & provides first check 			*
*																																*
*********************************************************************************************************************************


clear all
set more off

global user = 2 // 1 Jaime, 2 Barbara

if $user == 1{
cd "/Users/JAIME/Dropbox/research/sanctuaries/data/output_datasets"
global out = "/Users/JAIME/Dropbox/research/sanctuaries/out"
}

if $user == 2{
cd "~/Dropbox/Research/sanctuaries/data/output_datasets"
global out = "~/Dropbox/Research/sanctuaries/out"
}

clear all
set more off


*************************************** Simple comparison - no border FE ***************************************

use offenses_county_month.dta, clear
sort fips
merge m:1 fips using treat_control_list.dta
gen other = _m == 1

foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
rename `var'_c1_i_rate `var'_i_rate  
}

keep if year >= 2004

** Cyclicality
preserve
gen Treat = treat
replace Treat = 3 if treat == .
collapse codtot_i_rate, by(time Treat)
twoway	(line codtot_i_rate time if Treat == 1, lcolor(black) mcolor(black))	///
		(line codtot_i_rate time if Treat == 0, lcolor(gs8) mcolor(gs8))		///
		(line codtot_i_rate time if Treat == 3, lcolor(gs12) mcolor(gs12))		///
		, legend(order(1 "treated" 2 "control" 3 "others"))
restore

** LOOK AT DISTR OVER TIME

** SHARE PROPERTY VS VIOLENT
