
*********************************************************************************************************************************
*																																*
*				Sanctuaries																										*
*				name file: build_panel_border.do																				*
*				builds dataset of treated and control counties - format allows for border comparison							*
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

use adjacency_treated_wide.dta, clear

* the following line drops undated counties & one county with detainer in 1997
drop if date == "Undated " | date == "Sep-97" | date == ""
drop if regexm(dateen,"17")

preserve
keep fips
save treat_temp.dta, replace
restore

levelsof fips, local(Fips)
qui foreach f of local Fips {
noisily disp "`f'"
preserve
keep if fips == `f'

qui foreach d of local Fips {
forvalues b = 1/15 {
replace adj_fips`b' = . if adj_fips`b' == `d'
}
}
reshape long adj_fips, i(fips) j(n)
drop if adj_fips == .
gen group = fips
drop fips
rename adj_fips fips
sort fips
merge 1:m fips using offenses_county_month.dta
keep if _m == 3
drop _m
drop dateen
gen nr_borders = _N
sort fips
save contr`f'.dta, replace
restore
}

preserve
levelsof fips, local(Fips)
clear
gen fips = .
qui foreach f of local Fips {
append using contr`f'.dta
rm contr`f'.dta
}

drop if fips == .
sort fips
capt drop _m
merge m:1 fips using treat_temp.dta
drop if _m == 3
capt drop _m
rm treat_temp.dta
gen treat = 0
save control_panel.dta, replace
restore


keep fips dateenacted
gen group = fips

sort fips
merge 1:m fips using offenses_county_month.dta
keep if _m == 3
capt drop _m
gen treat = 1
append using control_panel.dta

gen enactment = monthly(dateenacted, "M20Y")
format enactment %tm

bysort fips: egen M = max(treat)
replace treat = 1 if M > 0
drop M
duplicates drop

** collapse everything at the quarterly level
gen time_quarter = qofd(dofm(time))
format time_quarter %tq
gen quarter_enactment = qofd(dofm(enactment))
format quarter_enactment %tq
collapse tot_pop treat (sum) *rate, by(fips quarter_enactment year time_quarter group nr_borders)

*label crime rate codes
foreach k in 0 1 2 3{
	label var cod1_c`k'_rate "murder per 100,000 card `k'"
	label var cod3_c`k'_rate "rape per 100,000 card `k'"
	label var cod6_c`k'_rate "robbery per 100,000 card `k'"
	label var cod11_c`k'_rate "assault per 100,000 card `k'"
	label var cod17_c`k'_rate "burglary per 100,000 card `k'"
	label var cod21_c`k'_rate "larceny per 100,000 card `k'"
	label var cod23_c`k'_rate "auto theft per 100,000 card `k'"
	label var codtot_c`k'_rate "all 7 index crimes per 100,000 card `k'"

	label var cod1_c`k'_i_rate "murder per 100,000 card `k' - smoothed"
	label var cod3_c`k'_i_rate "rape per 100,000 card `k' - smoothed"
	label var cod6_c`k'_i_rate "robbery per 100,000 card `k' - smoothed"
	label var cod11_c`k'_i_rate "assault per 100,000 card `k' - smoothed"
	label var cod17_c`k'_i_rate "burglary per 100,000 card `k' - smoothed"
	label var cod21_c`k'_i_rate "larceny per 100,000 card `k' - smoothed"
	label var cod23_c`k'_i_rate "auto theft per 100,000 card `k' - smoothed"
	label var codtot_c`k'_i_rate "all 7 index crimes per 100,000 card `k' - smoothed"
}

label var tot_pop "population"


sort fips time
save offense_panel_group.dta, replace
rm control_panel.dta
