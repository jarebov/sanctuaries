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

keep fips treat dateen
** month and date in which the policy was enacted

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
replace year_enacted = "1997" if year_enacted == "2097"
destring year_enacted, replace force
drop dateen
duplicates drop
save treat_control_list.dta, replace

rm control_panel.dta
