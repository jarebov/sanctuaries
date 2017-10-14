*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: clena_saipe.do																				*
*						cleans SAIPE Census for years 2005-2015																	*
*																																*
*********************************************************************************************************************************

clear all
set more off

cd "~/Dropbox/Research/sanctuaries/data"

foreach y in 05 06 07 08 09 10 11 12 13 14 15 {
if `y' < 13 {
import excel using "SAIPE/est`y'all.xls", clear cellrange(A3) firstrow 
}
if `y' >= 13 {
import excel using "SAIPE/est`y'all.xls", clear cellrange(A4) firstrow 
}
keep StateFIPS CountyFIPS PovertyEstimateAllAges MedianHouseholdIncome
rename *, lower
capt gen county = string(countyfips,"%03.0f")
capt drop if countyfips == .
capt drop if countyfips == ""
drop if county == "000"
capt gen county = countyfips
drop countyfips
gen fips = statefips + county
drop statefips county
destring fips, replace
order fips, first
destring poverty median, replace

label variable poverty		"Poverty estimate, all ages"
label variable median		"Median income estimate"

gen year = "20" + "`y'"
destring year, replace
order fips year
save "`y'.dta", replace
}

foreach y in 05 06 07 08 09 10 11 12 13 14 {
append using "`y'.dta"
rm "`y'.dta"
}
rm "15.dta"
sort fips year
save "output_datasets/saipe.dta", replace
