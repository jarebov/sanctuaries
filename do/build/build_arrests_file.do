*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: build_arrest_file.do																			*
*						generates files with arrests at county-month-year, from URC-ASR files									* 
*																																*
*********************************************************************************************************************************

clear all
set more off

cd "~/Dropbox/Research/sanctuaries/data"


qui foreach yr in 07 08 09 10 11 12 13 14 15 16 {
noisily disp "`yr'"

use "UCR_FBI/UCR_master_file/work/arrest_total`yr'.dta", clear

** 
destring arrestcounter*, replace force
gen arrest_total = 0
forvalues n = 1/56 {
replace arrest_total = arrest_total + arrestcounter_`n' if arrestcounter_`n' != .
}

** Generate state fips
gen state_fips = ""
replace state_fips =	"02"	if statecode ==	"50"	
replace state_fips =	"01"	if statecode ==	"01"	
replace state_fips =	"05"	if statecode ==	"03"	
replace state_fips =	"04"	if statecode ==	"02"	
replace state_fips =	"06"	if statecode ==	"04"	
replace state_fips =	"08"	if statecode ==	"05"	
replace state_fips =	"09"	if statecode ==	"06"	
replace state_fips =	"11"	if statecode ==	"08"	
replace state_fips =	"10"	if statecode ==	"07"	
replace state_fips =	"12"	if statecode ==	"09"	
replace state_fips =	"13"	if statecode ==	"10"	
replace state_fips =	"15"	if statecode ==	"51"	
replace state_fips =	"19"	if statecode ==	"14"	
replace state_fips =	"16"	if statecode ==	"11"	
replace state_fips =	"17"	if statecode ==	"12"	
replace state_fips =	"18"	if statecode ==	"13"	
replace state_fips =	"20"	if statecode ==	"15"	
replace state_fips =	"21"	if statecode ==	"16"	
replace state_fips =	"22"	if statecode ==	"17"	
replace state_fips =	"25"	if statecode ==	"20"	
replace state_fips =	"24"	if statecode ==	"19"	
replace state_fips =	"23"	if statecode ==	"18"	
replace state_fips =	"26"	if statecode ==	"21"	
replace state_fips =	"27"	if statecode ==	"22"	
replace state_fips =	"29"	if statecode ==	"24"	
replace state_fips =	"28"	if statecode ==	"23"	
replace state_fips =	"30"	if statecode ==	"25"	
replace state_fips =	"37"	if statecode ==	"32"	
replace state_fips =	"38"	if statecode ==	"33"	
replace state_fips =	"31"	if statecode ==	"26"	
replace state_fips =	"33"	if statecode ==	"28"	
replace state_fips =	"34"	if statecode ==	"29"	
replace state_fips =	"35"	if statecode ==	"30"	
replace state_fips =	"32"	if statecode ==	"27"	
replace state_fips =	"36"	if statecode ==	"31"	
replace state_fips =	"39"	if statecode ==	"34"	
replace state_fips =	"40"	if statecode ==	"35"	
replace state_fips =	"41"	if statecode ==	"36"	
replace state_fips =	"42"	if statecode ==	"37"	
replace state_fips =	"44"	if statecode ==	"38"	
replace state_fips =	"45"	if statecode ==	"39"	
replace state_fips =	"46"	if statecode ==	"40"	
replace state_fips =	"47"	if statecode ==	"41"	
replace state_fips =	"48"	if statecode ==	"42"	
replace state_fips =	"49"	if statecode ==	"43"	
replace state_fips =	"51"	if statecode ==	"45"	
replace state_fips =	"50"	if statecode ==	"44"	
replace state_fips =	"53"	if statecode ==	"46"	
replace state_fips =	"55"	if statecode ==	"48"	
replace state_fips =	"54"	if statecode ==	"47"	
replace state_fips =	"56"	if statecode ==	"49"	

gen fips = state_fips + county if county != "0"
drop if county == "0" | county == "" | month == ""
destring population, replace force
collapse (sum) arrest_total (mean) population (sum) sum_pop = population, by(fips month)
gen year = "20" + "`yr'"
sort fips month
save "arrest_tot`yr'.dta", replace
}


foreach yr in 07 08 09 10 11 12 13 14 15 {
append using "arrest_tot`yr'.dta"
rm "arrest_tot`yr'.dta"
}
rm "arrest_tot.dta"

** correction for county
gen county = substr(fips,3,3)
destring county, replace force
replace county = county*2 - 1
tostring county, gen(county2) format(%03.0f) force
drop fips 
gen fips = state_fips + county2
drop county*

destring fips year month, replace
sort fips year month
save "output_datasets/arrest_total.dta", replace
