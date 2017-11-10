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

keep fips adj_fips* date
reshape long adj_fips, i(fips) j(n)
drop if adj_fips == .
egen border_id = group(fips adj_fips)

preserve
keep fips border_id date
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

* question: should we treat the treated bordering counties as controls or not? what about treated counties who only border with treated?
* here below, I am only treating counties as controls if they are truly nontreated.
bysort fips: egen Treat = max(treat)
drop if Treat != treat & treat == 0
drop Treat

* generate number of borders
bysort fips: gen nr_borders = _N

sort fips
gen month_enacted = substr(date,1,3) if date != "Undated"
replace month_enacted = "01" if month_enacted == "Jan"
replace month_enacted = "02" if month_enacted == "Feb"
replace month_enacted = "03" if month_enacted == "Mar"
replace month_enacted = "04" if month_enacted == "Apr"
replace month_enacted = "05" if month_enacted == "May"
replace month_enacted = "06" if month_enacted == "Jun"
replace month_enacted = "07" if month_enacted == "Jul"
replace month_enacted = "08" if month_enacted == "Aug"
replace month_enacted = "09" if month_enacted == "Sep"
replace month_enacted = "10" if month_enacted == "Oct"
replace month_enacted = "11" if month_enacted == "Nov"
replace month_enacted = "12" if month_enacted == "Dec"
destring month_enacted, replace force


gen year_enacted = "20" + substr(date,5,2) if date != "" & date != "Undated"
replace year_enacted = "1997" if year == "2097"
destring year_enacted, replace force

sort fips
save treat_control.dta, replace
rm treat.dta

