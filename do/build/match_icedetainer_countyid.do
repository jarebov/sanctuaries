*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: match_ice_detainer_countyid.do																*
*						matches raw data from ICE detainer agreement "ICE_no_detainer_policies.xls" w]/ county ids				*
*																																*
*********************************************************************************************************************************

clear all
set more off

cd "~/Dropbox/Research/sanctuaries/data"

**************************************						 Census							************************************

import excel using "Census/PPQ01.xls", clear firstrow
rename *, lower
keep area stcou
gen ind = substr(stcou,3,3)
drop if ind == "000"
drop ind

split area, parse(", ") gen(n)
drop area
rename n1 county_name 
rename n2 state
rename stcou fips
order county_name state fips
sort county_name state
save "output_datasets/county_fips.dta", replace

**************************************						 ICE							************************************

import excel using "ICE/ICE_no_detainer_policies.xlsx", clear firstrow
rename *, lower

** Spot counties and jails
gen county = regexm(jurisdiction,"County")
gen jail = regexm(jurisdiction,"Jails")

** focus on counties (exclude cities and jails)
keep if county == 1 & jail == 0
drop county jail

* work out the strings
split jurisdiction, parse(", ") gen(name)
drop if name3 != "" // if they have 2 commas, it's not a county. drop
drop name3
rename name2 state
gen county_name = subinstr(name1," County","",1)
drop name1
split state, parse(" (") gen(s)
drop s2 state
rename s1 state

** Adjustments
replace state = "CA" if state ==	"California"
replace state = "CO" if state ==	"Colorado"
replace state = "IL" if state ==	"Illinois"
replace state = "IA" if state ==	"Iowa"
replace state = "KS" if state ==	"Kansas"
replace state = "MD" if state ==	"Maryland"
replace state = "NE" if state ==	"Nebraska"
replace state = "NJ" if state ==	"New Jersey"
replace state = "NM" if state ==	"New Mexico"
replace state = "NY" if state ==	"New York"
replace state = "OR" if state ==	"Oregon"
replace state = "PA" if state ==	"Pennsylvania"
replace state = "TX" if state ==	"Texas"
replace state = "VA" if state ==	"Virginia"
replace state = "WA" if state ==	"Washington"

replace county_name = "Prince George's" if county_name == "Prince George’s"
replace county_name = "Del Norte" if county_name == "Del-Norte"

** Merge with Census
order county_name state date, first
sort county_name state
merge 1:m county_name state using "county_fips.dta" // note: some counties with same name and state have multiple fips in Census data. Not sure why
* should have no _m == 1!
drop if _m == 1
gen detainer = _m == 3
drop _m
order county_name state fips jurisdiction date detainer
sort fips
save "output_datasets/county_detainer.dta", replace
rm "county_fips.dta"
