*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: build_treat_control.do																		*
*						builds dataset of treated and control counties, based on a given treatment								*
*																																*
*********************************************************************************************************************************

clear all
set more off

global user = 2 // 1 Jaime, 2 Barbara

if $user == 1{
cd "/Users/JAIME/Dropbox/research/sanctuaries/data/output_datasets"
}

if $user == 2{
cd "~/Dropbox/Research/sanctuaries/data/output_datasets"
}

clear all
set more off

**

use county_detainer.dta, clear
destring fips, replace
keep if detainer == 1
sort fips
merge 1:1 fips using county_adjacency.dta
keep if _m == 3
drop _m

keep fips adj_fips*
reshape long adj_fips, i(fips) j(n)
drop if adj_fips == .
bysort fips: gen nr_borders = _N
preserve
keep fips nr
duplicates drop
save treat.dta, replace
restore
keep adj_fips
duplicates drop
rename adj fips
sort fips
merge 1:1 fips using treat.dta
gen treat = _m == 2 | _m == 3
drop _m
sort fips
save treat_control.dta, replace
rm treat.dta

