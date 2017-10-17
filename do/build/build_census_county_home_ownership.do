* compute county-level home ownership rates for the 2000 and 2010 Censuses *

************************************************************************
clear all
set more off

global user = 2 // 1 Jaime, 2 Barbara

if $user == 1{
global path = "/Users/JAIME/Dropbox/research"
}

if $user == 2{
global path = "~/Dropbox/Research"
}
************************************************************************



****************************** 2000 Census ******************************
*Source: SF1 100% Table H011
import delimited "$path/sanctuaries/data/Census/2000 SF1 100%/table_H011/DEC_00_SF1_H011_with_ann.csv", varnames(1) rowrange(3) clear 

drop geoid
/*there are three observations for each county: overall, urban, and rural. drop
	urban and rural observations and keep only overall*/
drop if regexm(geodisplaylabel,"Urban") | regexm(geodisplaylabel,"Rural")

rename geoid2 			county_fips
rename geodisplaylabel	county_name
rename vd01				total_population
rename vd02				owner_occupied
rename vd03				renter_occupied

destring total_population, replace
destring owner_occupied, replace
destring renter_occupied, replace

gen home_own_frac = owner_occupied/total_population 
gen year=2000

drop renter_occupied owner_occupied total_population

save "$path/sanctuaries/data/output_datasets/temp/ownrate2000.dta", replace





****************************** 2010 Census ******************************
*Source: SF1 100% Table H11

import delimited "$path/sanctuaries/data/Census/2010 SF1 100%/tableH11/DEC_10_SF1_H11_with_ann.csv", varnames(1) rowrange(3) colrange(2) stringcols(1) numericcols(3 4 5 6) clear 

/*there are three observations for each county: overall, urban, and rural. drop
	urban and rural observations and keep only overall*/
drop if regexm(geodisplaylabel,"Urban") | regexm(geodisplaylabel,"Rural")


rename geoid2 			county_fips
rename geodisplaylabel	county_name
rename d001				total_population
rename d002				owned_w_mortgage
rename d003				owned_free_clear
rename d004				renter_occupied


/*total population is missing for 37 observations. add up the different categories*/
replace total_population = owned_w_mortgage + owned_free_clear + renter_occupied if total_population==.


gen home_own_frac = (owned_w_mortgage+owned_free_clear)/total_population
gen year=2010

drop owned_w_mortgage owned_free_clear renter_occupied total_population





****************************** append both years together
append using "$path/sanctuaries/data/output_datasets/temp/ownrate2000.dta"
erase "$path/sanctuaries/data/output_datasets/temp/ownrate2000.dta"
sort county_fips year 

label var home_own_frac "home ownership rate - census SF100% 2000 and 2010"


rename county_fips fips
destring fips, replace
save "$path/sanctuaries/data/output_datasets/home_ownership_bycounty_2000_2010.dta", replace









