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

keep fips adj_fips* datee
sort fips
save adjacency_treated_wide.dta, replace

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
gen border_id = string(fips) + "000000" + string(adj_fips)
drop fips
rename adj_fips fips
drop dateen
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

** generate borders for fips

levelsof fips, local(Fips)
qui foreach d of local Fips {
forvalues b = 1/15 {
replace adj_fips`b' = . if adj_fips`b' == `d'
}
}

forvalues b = 1/15 {
gen border_id`b' = 	string(fips) + "000000" + string(adj_fips`b')
replace border_id`b' = 	"" if adj_fips`b' == .
drop adj_fips`b'
}
sort fips
gen treat = 1
reshape long border_id, i(fips) j(bordernr)

drop if border_id == ""
append using control_panel.dta
drop if border_id == ""
bysort fips border_id: gen x = _n
gen y = x == 1
bysort fips: egen count_border = sum(y)
drop x y
sort fips
save treat_control.dta, replace
rm control_panel.dta
