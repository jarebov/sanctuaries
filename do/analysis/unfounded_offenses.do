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
}

if $user == 2{
cd "~/Dropbox/Research/sanctuaries/data/output_datasets"
global out = "~/Dropbox/Research/sanctuaries/out"
}

clear all
set more off


*************************************** Simple comparison - no border FE ***************************************

use offenses_county_month.dta, clear

* the following code allows to look at UNFOUNDED as a share of offense
foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
gen `var'_i_rate  = `var'_c0_i_rate * 100  / `var'_c1_i_rate  
}
**
sort fips
merge m:1 fips using treat_control_list.dta
gen other = _m == 1

** running variable for detainer*post enactment
gen treat_post = 0 if other == 0
replace treat_post = 1 if year > year_enacted
replace treat_post = 1 if year == year_enacted & month > month_enacted


*** Trends by month
preserve
keep if year > 2003
collapse tot_pop codtot_i_rate (max) treat_post, by (fips year)
collapse codtot_i_rate (sum) treat_post [aw = tot_pop], by (year)
twoway 	(connected cod year, lcolor(black) mcolor(black)) 			///
		(bar treat_post year, lcolor(gs10) fcolor(gs10) yaxis(2)) 	///
		, ylabel(0(0.5)2) ylabel(0(50)400, axis(2)) ytitle("# offenses per 100,000") ///
		ytitle("# no-ICE policies", axis(2)) legend(order(1 "percent unfoundeded offences" 2 "no-ICE policies")) xlabel(2004(2)2016)
graph export "$out/unfounded_offenses_policies.png", replace
restore

gen property = (cod6_c0_i_rate + cod17_c0_i_rate + cod21_c0_i_rate + cod23_c0_i_rate) * 100 / (cod6_c1_i_rate + cod17_c1_i_rate + cod21_c1_i_rate + cod23_c1_i_rate)
gen violent = (cod1_c0_i_rate + cod3_c0_i_rate + cod11_c0_i_rate) * 100 / (cod1_c1_i_rate + cod3_c1_i_rate + cod11_c1_i_rate)
gen months_from = (year - year_enacted) * 12 + (month - month_enacted)


*** Average unfounded rates for treated counties, by time to enactment (WEIRD SHAPE)
preserve
keep if treat == 1
keep codtot_i_rate violent property tot_pop fips year months_from
duplicates drop
collapse codtot violent property [aw = tot_pop], by(months_from)
twoway	(connected codtot_i_rate months_from, lcolor(black) mcolor(black)) ///
		if abs(months_from) < 24, xline(0) ytitle("Total crimes per 100,000")  xtitle("months from policy")
graph export "$out/unfounded_by_month_treated.png", replace
restore

** Property vs Violent crime: (WEIRD SHAPE coming from PROPERTY)
preserve
keep if treat == 1
keep codtot_i_rate violent property tot_pop fips year months_from
duplicates drop
collapse codtot violent property [aw = tot_pop], by(months_from)
twoway	(connected violent months_from, lcolor(gs4) mcolor(gs4) lpattern(dash) msymbol(square)) ///
		(connected property months_from, lcolor(gs12) mcolor(gs12) msymbol(x) yaxis(2)) ///
		if abs(months_from) < 24, xline(0) legend(order(1 "Violent" 2 "Property"))   ///
		ytitle("Violent crimes share unfoundeded") ytitle("Property crimes share unfoundeded", axis(2)) xtitle("months from policy")
graph export "$out/violent_property_unfounded_by_month_treated.png", replace
restore


*** Simple event study
gen trim_from = round(months_from / 3)
qui tab trim_from if abs(trim_from) < 9, gen(m)

qui forvalues m = 1/17 {
replace m`m' = 0 if treat == 0
local n = `m' - 9
label variable m`m' "`n'"
}

gen zero = 0
label variable zero "0"
qui areg codtot_i_rate 	m1-m8 zero m10-m17 treat i.year i.month if year >= 2007 [aw = tot_pop], a(fips) cluster(fips)
eststo codtot_i_rate
coefplot	(codtot_i_rate, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert keep(m1 m2 m3 m4 m5 m6 m7 m8 zero m10 m11 m12 m13 m14 m15 m16 m17)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(9)  xtitle("quarters from policy") ytitle("change in total crime, per 100,000")
graph export "$out/eventstudy_unfounded_totcrime_qts.png", replace

qui areg violent 	m1-m8 zero m10-m17 treat i.year i.month if year >= 2007 [aw = tot_pop], a(fips) cluster(fips)
eststo violent
coefplot	(violent, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert keep(m1 m2 m3 m4 m5 m6 m7 m8 zero m10 m11 m12 m13 m14 m15 m16 m17)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(9)  xtitle("quarters from policy") ytitle("change in violent crime, per 100,000")
graph export "$out/eventstudy_unfounded_violent_qts.png", replace

qui areg property 	m1-m8 zero m10-m17 treat i.year i.month if year >= 2007 [aw = tot_pop], a(fips) cluster(fips)
eststo property
coefplot	(property, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert keep(m1 m2 m3 m4 m5 m6 m7 m8 zero m10 m11 m12 m13 m14 m15 m16 m17)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(9)  xtitle("quarters from policy") ytitle("change in violent crime, per 100,000")
graph export "$out/eventstudy_unfounded_property_qts.png", replace

			

***************************************			 Border FE 			***************************************

set matsize 11000
use offense_panel_border.dta, clear
* the following code allows to look at UNFOUNDED as a share of offense
foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
gen `var'_i_rate  = `var'_c0_i_rate * 100  / `var'_c1_i_rate  
}

gen property = (cod6_c0_i_rate + cod17_c0_i_rate + cod21_c0_i_rate + cod23_c0_i_rate) * 100 / (cod6_c1_i_rate + cod17_c1_i_rate + cod21_c1_i_rate + cod23_c1_i_rate)
gen violent = (cod1_c0_i_rate + cod3_c0_i_rate + cod11_c0_i_rate) * 100 / (cod1_c1_i_rate + cod3_c1_i_rate + cod11_c1_i_rate)

gen months_from = (year - year_enacted) * 12 + (month - month_enacted)
gen trim_from = round(months_from / 3)
qui tab trim_from if abs(trim_from) < 9, gen(m)

qui forvalues m = 1/17 {
replace m`m' = 0 if treat == 0
local n = `m' - 9
label variable m`m' "`n'"
}

gen weight = tot_pop / count_border
gen zero = 0
label variable zero "0"

egen idborder = group(border_id)

qui areg codtot_i_rate 	m1-m8 zero m10-m17 treat i.year i.month i.idborder if year >= 2007 [aw = weight], a(fips) cluster(fips)
eststo codtot_i_rate
coefplot	(codtot_i_rate, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert keep(m1 m2 m3 m4 m5 m6 m7 m8 zero m10 m11 m12 m13 m14 m15 m16 m17)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13) xtitle("quarters from policy") ytitle("change in total crime, per 100,000")
graph export "$out/eventstudy_unfounded_totcrime_qts_border.png", replace

qui areg violent 		m1-m8 zero m10-m17 treat i.year i.month i.idborder if year >= 2007 [aw = weight], a(fips) cluster(fips)
eststo violent
coefplot	(violent, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert keep(m1 m2 m3 m4 m5 m6 m7 m8 zero m10 m11 m12 m13 m14 m15 m16 m17)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13) xtitle("quarters from policy") ytitle("change in violent crime, per 100,000")
graph export "$out/eventstudy_unfounded_violent_qts_border.png", replace

qui areg property 		m1-m8 zero m10-m17 treat i.year i.month i.idborder if year >= 2007 [aw = weight], a(fips) cluster(fips)
eststo property
coefplot	(property, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert keep(m1 m2 m3 m4 m5 m6 m7 m8 zero m10 m11 m12 m13 m14 m15 m16 m17)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13) xtitle("quarters from policy") ytitle("change in property crime, per 100,000")
graph export "$out/eventstudy_unfounded_property_qts_border.png", replace

***************************************	Border FE (analysis at the year level)	***************************************

set matsize 11000
use offense_panel_border.dta, clear
* the following code allows to look at unfounded as a share of offense
foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
gen `var'_i_rate  = `var'_c0_i_rate * 100  / `var'_c1_i_rate  
}

gen property = (cod6_c0_i_rate + cod17_c0_i_rate + cod21_c0_i_rate + cod23_c0_i_rate) * 100 / (cod6_c1_i_rate + cod17_c1_i_rate + cod21_c1_i_rate + cod23_c1_i_rate)
gen violent = (cod1_c0_i_rate + cod3_c0_i_rate + cod11_c0_i_rate) * 100 / (cod1_c1_i_rate + cod3_c1_i_rate + cod11_c1_i_rate)

collapse tot_pop count_border *_i_rate violent property, by(fips year treat month_enacted year_enacted border_id)

gen years_from = (year - year_enacted) 
replace years_from = 1 if year == year_enacted & month_enacted <= 6


*** Average unfounded rates for treated counties, by time to enactment
preserve
keep if treat == 1
keep codtot_i violent property tot_pop fips year years_from
duplicates drop
collapse codtot violent property [aw = tot_pop], by(years_from)
twoway	(connected codtot_i_rate years_from, lcolor(black) mcolor(black)) ///
		if abs(years_from) < 5, xline(0) ytitle("Total crimes per 100,000")  xtitle("years from policy")
graph export "$out/totcrime_unfounded_by_year_treated.png", replace
restore

** Property vs Violent crime:

preserve
keep if treat == 1
keep codtot_i violent property tot_pop fips year years_from
duplicates drop
collapse codtot violent property [aw = tot_pop], by(years_from)
twoway	(connected violent years_from, lcolor(gs4) mcolor(gs4) lpattern(dash) msymbol(square)) ///
		(connected property years_from, lcolor(gs12) mcolor(gs12) msymbol(x) yaxis(2)) ///
		if abs(years_from) < 5, xline(0) legend(order(1 "Violent" 2 "Property"))  ///
		ytitle("Violent crimes per 100,000") ytitle("Property crimes per 100,000", axis(2)) xtitle("years from policy")
graph export "$out/violent_property_unfounded_by_year_treated.png", replace
restore


** Event study

qui tab years_from if abs(years_from) < 5, gen(m)
qui forvalues m = 1/9 {
replace m`m' = 0 if treat == 0
local n = `m' - 5
label variable m`m' "`n'"
}

gen weight = tot_pop / count_border
gen zero = 0
label variable zero "0"

egen idborder = group(border_id)

qui areg codtot_i_rate 	m1-m4 zero m6-m9 treat i.year i.month i.idborder if year >= 2007 [aw = tot_pop], a(fips) cluster(fips)
eststo codtot_i_rate
coefplot	(codtot_i_rate, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert keep(m1 m2 m3 m4 zero m6 m7 m8 m9)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13)  xtitle("years from policy") ytitle("change in total crime, per 100,000")
graph export "$out/eventstudy_unfounded_totcrime_yr_collapsed_border.png", replace

qui areg violent 	m1-m4 zero m6-m9 treat i.year i.month i.idborder if year >= 2007 [aw = tot_pop], a(fips) cluster(fips)
eststo violent
coefplot	(violent, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert keep(m1 m2 m3 m4 zero m6 m7 m8 m9)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13)  xtitle("years from policy") ytitle("change in violent crime, per 100,000")
graph export "$out/eventstudy_unfounded_violent_yr_collapsed_border.png", replace

qui areg property 	m1-m4 zero m6-m9 treat i.year i.month i.idborder if year >= 2007 [aw = tot_pop], a(fips) cluster(fips)
eststo property
coefplot	(property, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert keep(m1 m2 m3 m4 zero m6 m7 m8 m9)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13)  xtitle("years from policy") ytitle("change in property crime, per 100,000")
graph export "$out/eventstudy_unfounded_property_yr_collapsed_border.png", replace
