*********************************************************************************************************************************
*																																*
*			Sanctuaries																											*
*			name file: offenses.do																								*
*			merges file with total offenses at county-year-month level with treatment variable & provides first check 			*
*																																*
*********************************************************************************************************************************


clear all
set more off
set matsize 11000

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


use offense_panel_group.dta, clear
sort fips year
merge m:1 fips year using covariates.dta
drop if _m == 2
drop _m

** generate useful variables 
foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
rename `var'_c1_i_rate `var'_i_rate  
}
gen quarter = quarter(dofq(time_quarter)) //calendar quarter (1,2,3,4)
gen year_en = year(dofq(quarter_enactment)) //calendar year of enactment
bysort fips (year): gen tot_pop2000 = tot_pop[1] //baseline population (year 2000)
bysort fips time_quarter: gen obsfips = _n //keep track duplicate control counties
gen timefromenact = time_quarter - quarter_enactment
egen quarter_enactment2 = mean(quarter_enactment), by(group) //assign quarter of enactment to control units 
egen year_enactment2 = mean(year_en), by(group) //assign year of enactment to control units 
format quarter_enactment2 %tq
gen timefromenact2 = time_quarter - quarter_enactment2
gen post = timefromenact2 > 0

gen property = cod6_i_rate + cod17_i_rate + cod21_i_rate + cod23_i_rate
gen violent = cod1_i_rate + cod3_i_rate + cod11_i_rate

gen log_tot = log(codtot_i_rate)
gen log_violent = log(violent)
gen log_property = log(property)

gen hisp_share = hisp_pop / tot_pop
gen black_share = black_pop / tot_pop
egen group_year = group(group year)

gen treat_post = treat == 1 & post == 1


keep if year >= 2006 & year_enactment2 <= 2015

global covar = "black_share hisp_share mig_inflow medianho dem_vote urate"
bysort fips (year): carryforward $covar, replace // fill in missings by just doing carryfw
gsort fips -year
bysort fips: carryforward $covar, replace // fill in missings by just doing carryfw

**********************		Regressions - groups of treated and control 		***************************

gen Timeframe = 1 if timefromenact2 >= -8 & timefromenact2 <= 4
bysort group time_quarter: egen timeframe = max(Timeframe)
drop Timeframe


* Table 1: simple DD, county FE, county FE with pre-trends, with and without covariates 
qui areg log_tot treat_post i.quarter i.year if timeframe == 1 [aw = tot_pop], a(fips) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_tot treat_post i.quarter i.year $covar if timeframe == 1 [aw = tot_pop], a(fips) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

preserve
	qui areg log_tot c.year#i.fips treat_post i.quarter i.year if post == 0 [aw=tot_pop], a(fips)
	codebook fips if e(sample)
	mat b=e(b)
	mat b=b[1,1..374]
	mat score res1 = b
	gen res2 =  log_tot -  res1
	qui areg res2 treat_post i.quarter i.year if timeframe == 1 [aw = tot_pop], a(fips) cluster(fips)
	disp _b[treat_post]
	disp _b[treat_post]/_se[treat_post]
	disp e(N)
restore

preserve
	qui areg log_tot c.year#i.fips treat_post i.quarter i.year $covar if post == 0 [aw=tot_pop], a(fips)
	codebook fips if e(sample)
	mat b=e(b)
	mat b=b[1,1..367]
	mat score res1 = b
	gen res2 =  log_tot -  res1
	qui areg res2 treat_post i.quarter i.year $covar if timeframe == 1 [aw = tot_pop], a(fips) rob cluster(fips)
	disp _b[treat_post]
	disp _b[treat_post]/_se[treat_post]
	disp e(N)
restore



