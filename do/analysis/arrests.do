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

** generate useful variables
gen pop_density = tot_pop / land_area if year == 2010
gen wkage_share = workingage / tot_pop if year == 2010
gen lf_participation = laborforce / tot_pop if year == 2010
gen mig_in_rate = mig_inflow if year == 2005
gen mig_out_rate = mig_outflow if year == 2005
gen medianinc = median if year == 2010
gen democratic = dem_vote if year == 2008
gen share_black = black_pop / tot_pop if year == 2010
gen share_hisp = hisp_pop / tot_pop if year == 2010
gen u_rate = urate if year == 2010
gen homeown = home_own_frac if year == 2010

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

gen arrest_rate = arrest / tot_pop

gen treat_post = 0 if other == 0
replace treat_post = 1 if year > year_enacted
replace treat_post = 1 if year == year_enacted & month > month_enacted

* just plot arrest rates
preserve
keep if months == 12
keep fips month year arrest_t tot_pop
duplicates drop
collapse (mean) arrest [aw = tot_pop], by(month)
twoway (connected arrest month) 
restore

preserve
keep fips month year arrest_rate tot_pop
duplicates drop
gen monthyear = year + month/100
collapse arrest_rate [aw = tot_pop], by(monthyear)
twoway (connected arrest monthyear) 
restore


gen months_from = (year - year_enacted) * 12 + (month - month_enacted)

preserve
keep if months == 12
keep if treat == 1
keep fips arrest_t tot_pop months_from
duplicates drop
collapse arrest [aw = tot_pop], by(months_from)
twoway (connected arrest months_from) if abs(months_from) < 24, xline(0)
restore
