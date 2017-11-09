*********************************************************************************************************************************
*																																*
*			Sanctuaries																											*
*			name file: arrests.do																								*
*			merges file with total arrests at county-year-month level with treatment variable & provides first check 			*
*																																*
*********************************************************************************************************************************

** BARBARA NEEDS TO CLEAN THIS - PLEASE JAIME DONT GET MAD


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

****
use covariates.dta, clear


** keep relevant variables
collapse (mean)  tot_pop, by(fips stateabbr)
drop if stateabbr == ""			

** merge treatment nr. 1: county detainer
sort fips
merge 1:m fips using treat_control.dta	
gen other = _m == 1
drop _m

** merge in  arrests
sort fips
merge m:m fips using arrest_total.dta	 // merge not perfect - check
keep if _m == 3
drop _m

** generate arrest rate as share over population
gen arrest_rate = arrest / tot_pop

** running variable for detainer*post enactment
gen treat_post = 0 if other == 0
replace treat_post = 1 if year > year_enacted
replace treat_post = 1 if year == year_enacted & month > month_enacted

** address the problem of pooling everything in december for some months
bysort fips year: gen months = _N
keep if months > 1

*** Simple plot of arrest rates
preserve
gen monthyear = year + month/100
collapse arrest_rate [aw = tot_pop], by(month)
twoway (connected arrest month) 
restore

*** Average arrest rates for treated counties, by time to enactment
gen months_from = (year - year_enacted) * 12 + (month - month_enacted)
preserve
keep if treat == 1
keep fips arrest_t tot_pop months_from
duplicates drop
collapse arrest [aw = tot_pop], by(months_from)
twoway (connected arrest months_from) if abs(months_from) < 24, xline(0)
restore

*** Simple event study: time-to-enactment
qui tab months_from, gen(M)

forvalues m = 97/145 { 
local z = `m' - 121
replace M`m' = 0 if treat == 0
label variable M`m' "`z'"
}

reg arrest_rate treat M97-M145 i.month i.year
