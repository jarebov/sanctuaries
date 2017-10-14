*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: clean_bls.do																				*
*						cleans BLS data on labor force stats for years 2005-2016																	*
*																																*
*********************************************************************************************************************************
** HELLO
clear all
set more off

cd "~/Dropbox/Research/sanctuaries/data"


foreach y in 05 06 07 08 09 10 11 12 13 14 15 16 {

import excel using "BLS/laucnty`y'.xlsx", clear cellrange(A7)  
keep B C E G H I J
gen fips = B + C
drop B C
rename E year
rename G laborforce
rename H employed
rename I unemployed
rename J urate
drop if fips == ""
destring *, replace force
order fips year
save "`y'.dta", replace
}
foreach y in 05 06 07 08 09 10 11 12 13 14 15 {
append using "`y'.dta"
rm "`y'.dta"
}
rm "16.dta"
sort fips year
save "output_datasets/bls.dta", replace
