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
egen border_id = group(fips adj_fips)

preserve
keep fips border_id
duplicates drop
save treat.dta, replace
restore

keep adj_fips border_id

duplicates drop
rename adj fips
sort fips
gen treat = 0
/*
merge m:m fips using treat.dta
gen treat = _m == 2 | _m == 3
drop _m
*/
append using treat.dta
replace treat = 1 if treat == .

* note: the following takes care of the fact that some treated counties border with other treated counties, and are therefore counted twice.
duplicates tag fips border_id, gen(tag)
drop if tag > 0 & treat == 0
bysort border_id: gen T = _N
drop if T == 1

* generate number of borders
bysort fips: gen nr_borders = _N

sort fips
save treat_control.dta, replace
rm treat.dta

