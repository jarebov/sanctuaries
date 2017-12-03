*********************************************************************************************************************************
*																																*
*			Sanctuaries																											*
*			name file: offenses.do																								*
*			merges file with total offenses at county-year-month level with treatment variable & provides first check 			*
*																																*
*********************************************************************************************************************************


clear all
set more off

global user = 2 // 1 Jaime, 2 Barbara

if $user == 1{
cd "/Users/JAIME/Dropbox/research/sanctuaries/data/output_datasets"
global out = "/Users/JAIME/Dropbox/research/sanctuaries/out"
global test = "/Users/JAIME/Dropbox/research/sanctuaries/out/test"
}

if $user == 2{
cd "~/Dropbox/Research/sanctuaries/data/output_datasets"
global out = "~/Dropbox/Research/sanctuaries/out"
global test = "~/Dropbox/Research/sanctuaries/out/test"
}

clear all
set more off


*************************************** Simple comparison - no border FE ***************************************

use offenses_county_month.dta, clear
sort fips
merge m:1 fips using treat_control_list.dta
gen other = _m == 1

foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
rename `var'_c1_i_rate `var'_i_rate  
}

gen logcrime = log(codtot_i_rate)
gen property = cod6_i_rate + cod17_i_rate + cod21_i_rate + cod23_i_rate
gen violent = cod1_i_rate + cod3_i_rate + cod11_i_rate
gen logprop = log(property)
gen logviolent = log(violent)

keep if year >= 2004

** Cyclicality in offenses

* all conunties, by month:
preserve
gen Treat = treat
replace Treat = 3 if treat == .
collapse codtot_i_rate [aw = tot_pop], by(month Treat)
twoway	(line codtot month if Treat == 1, lcolor(black) mcolor(black))	///
		(line codtot month if Treat == 0, lcolor(gs8) mcolor(gs8))		///
		(line codtot month if Treat == 3, lcolor(gs12) mcolor(gs12))		///
		, legend(order(1 "treated" 2 "control" 3 "others"))
restore

* monthly:
preserve
gen Treat = treat
replace Treat = 3 if treat == .
collapse codtot_i_rate [aw = tot_pop], by(time Treat)
twoway	(line codtot_i_rate time if Treat == 1, lcolor(black) mcolor(black))	///
		(line codtot_i_rate time if Treat == 0, lcolor(gs8) mcolor(gs8))		///
		(line codtot_i_rate time if Treat == 3, lcolor(gs12) mcolor(gs12))		///
		, legend(order(1 "treated" 2 "control" 3 "others"))
restore


* quarterly:
preserve
gen time_quarter = qofd(dofm(time))
format time_quarter %tq
gen Treat = treat
replace Treat = 3 if treat == .
tab Treat
collapse (mean) codtot_i_rate [aw = tot_pop], by(fips time_quarter Treat)
collapse codtot_i_rate, by(time_quarter Treat)
twoway	(line codtot_i_rate time if Treat == 1, lcolor(black) mcolor(black))	///
		(line codtot_i_rate time if Treat == 0, lcolor(gs8) mcolor(gs8))		///
		(line codtot_i_rate time if Treat == 3, lcolor(gs12) mcolor(gs12))		///
		, legend(order(1 "treated" 2 "control" 3 "others"))
restore

* by-yearly:
preserve
gen time_sem = hofd(dofm(time))
format time_sem %th
gen Treat = treat
replace Treat = 3 if treat == .
tab Treat
collapse (sum) codtot_i_rate [aw = tot_pop], by(fips time_sem Treat)
collapse codtot_i_rate, by(time_sem Treat)
twoway	(line codtot_i_rate time if Treat == 1, lcolor(black) mcolor(black))	///
		(line codtot_i_rate time if Treat == 0, lcolor(gs8) mcolor(gs8))		///
		(line codtot_i_rate time if Treat == 3, lcolor(gs12) mcolor(gs12))		///
		, legend(order(1 "treated" 2 "control" 3 "others"))
restore

* yearly:
preserve
gen Treat = treat
replace Treat = 3 if treat == .
tab Treat
collapse (sum) codtot_i_rate [aw = tot_pop], by(fips year Treat)
collapse codtot_i_rate, by(year Treat)
twoway	(line codtot_i_rate year if Treat == 1, lcolor(black) mcolor(black))	///
		(line codtot_i_rate year if Treat == 0, lcolor(gs8) mcolor(gs8))		///
		(line codtot_i_rate year if Treat == 3, lcolor(gs12) mcolor(gs12))		///
		, legend(order(1 "treated" 2 "control" 3 "others"))
restore



** Look at differences in offenses by time to policy

* monthly
preserve
keep if treat == 1
gen timeto = time - enactment
collapse codtot_i_rate [aw = tot_pop], by(timeto)
keep if abs(timeto) <= 60
twoway	(line codtot_i_rate timeto, lcolor(black) mcolor(black))	///
		, xline(0)
restore

* quarterly
preserve
keep if treat == 1
gen time_quarter = qofd(dofm(time))
format time_quarter %tq
gen time_en = qofd(dofm(enactment))
format time_en %tq
gen timeto = time_quarter - time_en
collapse codtot_i_rate [aw = tot_pop], by(timeto)
keep if abs(timeto) <= 15
twoway	(line codtot_i_rate timeto, lcolor(black) mcolor(black))	///
		, xline(0)
restore

* bi-yearly
preserve
keep if treat == 1
gen time_sem = hofd(dofm(time))
format time_sem %th
gen time_en = hofd(dofm(enactment))
format time_en %th
gen timeto = time_sem - time_en
collapse codtot_i_rate [aw = tot_pop], by(timeto)
keep if abs(timeto) <= 10
twoway	(line codtot_i_rate timeto, lcolor(black) mcolor(black))	///
		, xline(0)
restore

preserve
keep if treat == 1
gen time_sem = hofd(dofm(time))
format time_sem %th
gen time_en = hofd(dofm(enactment))
format time_en %th
gen timeto = time_sem - time_en
collapse violent property [aw = tot_pop], by(timeto)
keep if abs(timeto) <= 10
twoway	(line violent timeto, lcolor(red) mcolor(black))	///
		(line property timeto, lcolor(blue) mcolor(black) yaxis(2))	///
		, xline(0)
restore

* yearly
preserve
keep if treat == 1
gen time_en = yofd(dofm(enactment))
format time_en %ty
gen timeto = year - time_en
collapse codtot_i_rate violent property [aw = tot_pop], by(timeto)
keep if abs(timeto) <= 5
twoway	(line codtot_i_rate timeto, lcolor(black) mcolor(black))	///
		, xline(0)
restore

preserve
keep if treat == 1
gen time_en = yofd(dofm(enactment))
format time_en %ty
gen timeto = year - time_en
collapse codtot_i_rate violent property [aw = tot_pop], by(timeto)
keep if abs(timeto) <= 5
twoway	(line violent timeto, lcolor(red) mcolor(black))	///
		(line property timeto, lcolor(blue) mcolor(black) yaxis(2))	///
		, xline(0)
restore

** Look at differences in offenses by time to policy, comparing them with counties in their group


use offense_panel_group.dta, clear

foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
rename `var'_c1_i_rate `var'_i_rate  
}

gen logcrime = log(codtot_i_rate)
gen property = cod6_i_rate + cod17_i_rate + cod21_i_rate + cod23_i_rate
gen violent = cod1_i_rate + cod3_i_rate + cod11_i_rate
gen logprop = log(property)
gen logviolent = log(violent)

keep if year >= 2004


* quarterly
preserve
gen time_q = qofd(dofm(time))
format time_q %tq
gen time_en = qofd(dofm(enactment))
format time_en %tq
gen timeto = time_q - time_en
bysort group time: egen Timeto = max(timeto)
collapse codtot_i_rate violent property [aw = tot_pop], by(Timeto treat) 
keep if abs(Timeto) <= 10
twoway	(line codtot_i_rate Timeto if treat == 1, lcolor(black) mcolor(black))	///
		(line codtot_i_rate Timeto if treat == 0, lcolor(gs10) mcolor(gs10))	///
		, xline(0)
restore

* bi-yearly
preserve
gen time_sem = hofd(dofm(time))
format time_sem %th
gen time_en = hofd(dofm(enactment))
format time_en %th
gen timeto = time_sem - time_en
bysort group time: egen Timeto = max(timeto)
collapse codtot_i_rate violent property [aw = tot_pop], by(Timeto treat) 
keep if abs(Timeto) <= 10
twoway	(line codtot_i_rate Timeto if treat == 1, lcolor(black) mcolor(black))	///
		(line codtot_i_rate Timeto if treat == 0, lcolor(gs10) mcolor(gs10))	///
		, xline(0)
restore

* yearly
preserve
gen time_en = yofd(dofm(enactment))
format time_en %ty
gen timeto = year - time_en
bysort group time: egen Timeto = max(timeto)
collapse codtot_i_rate violent property [aw = tot_pop], by(Timeto treat) 
keep if abs(Timeto) <= 10
twoway	(line property Timeto if treat == 1, lcolor(black) mcolor(black))	///
		(line property Timeto if treat == 0, lcolor(gs10) mcolor(gs10))	///
		, xline(0)
restore


** Trends in each one of the treated counties 
levelsof fips if treat == 1, local(treated)
foreach f of local treated {
preserve
keep if fips == `f'
levelsof enactment, local(enact)
keep if year >= 2008
twoway (line codtot_i_rate time), title("`f'") xline(`enact')
graph export "$test/treated`f'.png", replace
restore
}

