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
sort fips
merge m:1 fips using treat_control_list.dta
gen other = _m == 1

foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
rename `var'_c1_i_rate `var'_i_rate  
}

** running variable for detainer*post enactment
gen treat_post = 0 if other == 0
replace treat_post = 1 if year > year_enacted
replace treat_post = 1 if year == year_enacted & month > month_enacted

** keep data from 2004 onwards
keep if year >= 2004

gen property = cod6_i_rate + cod17_i_rate + cod21_i_rate + cod23_i_rate
gen violent = cod1_i_rate + cod3_i_rate + cod11_i_rate
gen months_from = (year - year_enacted) * 12 + (month - month_enacted)

gen log_tot = log(codtot_i_rate)
gen log_violent = log(violent)
gen log_property = log(property)




*** Trends by month
preserve
keep if year > 2003
collapse tot_pop (sum) codtot_i_rate (max) treat_post, by (fips year)
bysort year: egen Treat_post = sum(treat_post)
collapse codtot_i_rate Treat_post [aw = tot_pop], by (year)
twoway 	(connected cod year, lcolor(black) mcolor(black)) 			///
		(bar Treat_post year, lcolor(gs10) fcolor(gs10) yaxis(2)) 	///
		, ylabel(2000(500)5000) ylabel(0(50)250, axis(2)) ytitle("# offenses per 100,000") ///
		ytitle("# no-ICE policies", axis(2)) legend(order(1 "offenses per 100,000" 2 "no-ICE policies")) xlabel(2004(2)2016)
graph export "$out/offenses_policies.png", replace
restore


*** Average arrest rates for treated counties, by time to enactment
preserve
keep if treat == 1
keep codtot_i_rate violent property tot_pop fips year months_from
duplicates drop
collapse codtot violent property [aw = tot_pop], by(months_from)
twoway	(connected codtot_i_rate months_from, lcolor(black) mcolor(black)) ///
		if abs(months_from) < 25, xline(0) ytitle("Total crimes per 100,000")  xtitle("months from policy")
graph export "$out/totcrime_by_month_treated.png", replace
restore

** Property vs Violent crime:
preserve
keep if treat == 1
keep codtot_i_rate violent property tot_pop fips year months_from
duplicates drop
collapse codtot violent property [aw = tot_pop], by(months_from)
twoway	(connected violent months_from, lcolor(gs4) mcolor(gs4) lpattern(dash) msymbol(square)) ///
		(connected property months_from, lcolor(gs12) mcolor(gs12) msymbol(x) yaxis(2)) ///
		if abs(months_from) < 24, xline(0) legend(order(1 "Violent" 2 "Property"))  ///
		ytitle("Violent crimes per 100,000") ytitle("Property crimes per 100,000", axis(2)) xtitle("months from policy")
graph export "$out/violent_property_by_month_treated.png", replace
restore



*** Simple event study

qui tab months_from, gen(m)

qui forvalues m = 1/251 {
replace m`m' = 0 if treat == 0
local n = `m' - 151
label variable m`m' "`n'"
}

gen zero = 0
label variable zero "0"

* logs
qui areg log_tot 	m139-m150 zero m152-m163 i.time [aw = tot_pop], a(fips) cluster(fips)
eststo codtot_i_rate
coefplot	(codtot_i_rate, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13)  xtitle("months from policy") ytitle("% change in total crime, per 100,000")
graph export "$out/eventstudy_logcrime_qts.png", replace

qui areg log_violent 	m139-m150 zero m152-m163 i.time [aw = tot_pop], a(fips) cluster(fips)
eststo violent
coefplot	(violent, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13)  xtitle("months from policy") ytitle("% change in violent crime, per 100,000")
graph export "$out/eventstudy_logviolent_qts.png", replace

qui areg log_property 	m139-m150 zero m152-m163 i.time [aw = tot_pop], a(fips) cluster(fips)
eststo property
coefplot	(property, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13)  xtitle("months from policy") ytitle("% change in violent crime, per 100,000")
graph export "$out/eventstudy_logproperty_qts.png", replace

	
* levels
qui areg codtot_i_rate 	m139-m150 zero m152-m163 i.time [aw = tot_pop], a(fips) cluster(fips)
eststo codtot_i_rate
coefplot	(codtot_i_rate, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13)  xtitle("months from policy") ytitle("change in total crime, per 100,000")
graph export "$out/eventstudy_crime_qts.png", replace

qui areg violent 	m139-m150 zero m152-m163 i.time [aw = tot_pop], a(fips) cluster(fips)
eststo violent
coefplot	(violent, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13)  xtitle("months from policy") ytitle("change in violent crime, per 100,000")
graph export "$out/eventstudy_violent_qts.png", replace

qui areg property 	m139-m150 zero m152-m163 i.time [aw = tot_pop], a(fips) cluster(fips)
eststo property
coefplot	(property, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13)  xtitle("months from policy") ytitle("change in violent crime, per 100,000")
graph export "$out/eventstudy_property_qts.png", replace

			

***************************************		 Border FE (monthly) 		***************************************

set matsize 11000
use offense_panel_border.dta, clear

** generate useful variables 
foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
rename `var'_c1_i_rate `var'_i_rate  
}

gen property = cod6_i_rate + cod17_i_rate + cod21_i_rate + cod23_i_rate
gen violent = cod1_i_rate + cod3_i_rate + cod11_i_rate

keep if year >= 2004

egen idborder = group(border_id)

gen log_tot = log(codtot_i_rate)
gen log_violent = log(violent)
gen log_property = log(property)
gen weight = tot_pop / count_border


gen months_from = (year - year_enacted) * 12 + (month - month_enacted)
qui tab months_from, gen(m)

qui forvalues m = 1/251 {
replace m`m' = 0 if treat == 0
local n = `m' - 151
label variable m`m' "`n'"
}

gen zero = 0
label variable zero "0"



* logs
qui areg log_tot 	m139-m150 zero m152-m163 i.time i.idborder [aw = weight], a(fips) cluster(fips)
eststo codtot_i_rate
coefplot	(codtot_i_rate, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13) xtitle("months from policy") ytitle("% change in total crime, per 100,000")
graph export "$out/eventstudy_logcrime_months_border.png", replace

qui areg log_violent 	m139-m150 zero m152-m163 i.time i.idborder [aw = weight], a(fips) cluster(fips)
eststo violent
coefplot	(violent, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13) xtitle("months from policy") ytitle("% change in violent crime, per 100,000")
graph export "$out/eventstudy_logviolent_months_border.png", replace

qui areg log_property 	m139-m150 zero m152-m163 i.time i.idborder [aw = weight], a(fips) cluster(fips)
eststo property
coefplot	(property, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13) xtitle("months from policy") ytitle("% change in property crime, per 100,000")
graph export "$out/eventstudy_logproperty_months_border.png", replace

	

* levels
qui areg codtot_i_rate 	m139-m150 zero m152-m163 i.time i.idborder [aw = weight], a(fips) cluster(fips)
eststo codtot_i_rate
coefplot	(codtot_i_rate, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13) xtitle("months from policy") ytitle("% change in total crime, per 100,000")
graph export "$out/eventstudy_crime_months_border.png", replace

qui areg violent 	m139-m150 zero m152-m163 i.time i.idborder [aw = weight], a(fips) cluster(fips)
eststo violent
coefplot	(violent, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13) xtitle("months from policy") ytitle("% change in violent crime, per 100,000")
graph export "$out/eventstudy_violent_months_border.png", replace

qui areg property 	m139-m150 zero m152-m163 i.time i.idborder [aw = weight], a(fips) cluster(fips)
eststo property
coefplot	(property, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13) xtitle("months from policy") ytitle("% change in property crime, per 100,000")
graph export "$out/eventstudy_property_months_border.png", replace

	

***************************************		 Border FE (quarterly) 		***************************************

set matsize 11000
use offense_panel_border.dta, clear

keep if year >= 2004
gen weight = tot_pop / count_border

** generate useful variables 
foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
rename `var'_c1_i_rate `var'_i_rate  
}

gen property = cod6_i_rate + cod17_i_rate + cod21_i_rate + cod23_i_rate
gen violent = cod1_i_rate + cod3_i_rate + cod11_i_rate


gen quarter = ceil(4 * month / 12)

* collapse data
collapse tot_pop weight (sum) *_i_rate violent property, by(fips quarter year treat month_enacted year_enacted border_id)

egen idborder = group(border_id)
gen log_tot = log(codtot_i_rate)
gen log_violent = log(violent)
gen log_property = log(property)

gen quarter_enacted = ceil(4 * month_enacted / 12)
gen quarters_from = (year - year_enacted) * 4 + (quarter - quarter_enacted)
qui tab quarters_from, gen(m)

qui forvalues m = 1/84 {
replace m`m' = 0 if treat == 0
local n = `m' - 51
label variable m`m' "`n'"
}

gen zero = 0
label variable zero "0"

* logs
qui areg log_tot 	m35-m50 zero m52-m67 i.quarter#i.year [aw = weight], a(fips) cluster(fips)
eststo codtot_i_rate
coefplot	(codtot_i_rate, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *quarter *year treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(17) xtitle("months from policy") ytitle("change in total crime, per 100,000")
graph export "$out/eventstudy_logcrime_qts_border.png", replace

qui areg log_violent 	m35-m50 zero m52-m67 i.quarter#i.year [aw = weight], a(fips) cluster(fips)
eststo violent
coefplot	(violent, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *quarter *year treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(17) xtitle("quarters from policy") ytitle("change in violent crime, per 100,000")
graph export "$out/eventstudy_logviolent_qts_border.png", replace

qui areg log_property 	m35-m50 zero m52-m67 i.quarter#i.year [aw = weight], a(fips) cluster(fips)
eststo property
coefplot	(property, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *quarter *year treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(17) xtitle("quarters from policy") ytitle("change in property crime, per 100,000")
graph export "$out/eventstudy_logproperty_qts_border.png", replace



* levels
qui areg codtot_i_rate 	m35-m50 zero m52-m67 i.quarter#i.year [aw = weight], a(fips) cluster(fips)
eststo codtot_i_rate
coefplot	(codtot_i_rate, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *quarter *year treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(17) xtitle("months from policy") ytitle("change in total crime, per 100,000")
graph export "$out/eventstudy_crime_qts_border.png", replace

qui areg violent 	m35-m50 zero m52-m67 i.quarter#i.year [aw = weight], a(fips) cluster(fips)
eststo violent
coefplot	(violent, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *quarter *year treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(17) xtitle("quarters from policy") ytitle("change in violent crime, per 100,000")
graph export "$out/eventstudy_violent_qts_border.png", replace

qui areg property 	m35-m50 zero m52-m67 i.quarter#i.year [aw = weight], a(fips) cluster(fips)
eststo property
coefplot	(property, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *quarter *year treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(17) xtitle("quarters from policy") ytitle("change in property crime, per 100,000")
graph export "$out/eventstudy_property_qts_border.png", replace




***************************************		 Border FE (yearly) 		***************************************

set matsize 11000
use offense_panel_border.dta, clear

keep if year >= 2004
gen weight = tot_pop / count_border

** generate useful variables 
foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
rename `var'_c1_i_rate `var'_i_rate  
}

gen property = cod6_i_rate + cod17_i_rate + cod21_i_rate + cod23_i_rate
gen violent = cod1_i_rate + cod3_i_rate + cod11_i_rate

* collapse data
collapse tot_pop weight (sum) *_i_rate violent property, by(fips year treat month_enacted year_enacted border_id)

egen idborder = group(border_id)
gen log_tot = log(codtot_i_rate)
gen log_violent = log(violent)
gen log_property = log(property)

gen years_from = (year - year_enacted)
replace years_from = 1 if year == year_enacted & month_enacted <= 3

qui tab years_from, gen(m)

qui forvalues m = 1/21 {
replace m`m' = 0 if treat == 0
local n = `m' - 13
label variable m`m' "`n'"
}

gen zero = 0
label variable zero "0"

* logs
qui areg log_tot 	m1-m12 zero m14-m21 i.year i.idborder [aw = weight], a(fips) cluster(fips)
eststo codtot_i_rate
coefplot	(codtot_i_rate, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert keep(m9 m10 m11 m12 zero m14 m15 m16 m17) levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(17) xtitle("months from policy") ytitle("% change in total crime, per 100,000")
graph export "$out/eventstudy_logcrime_yrs_border.png", replace

areg log_tot 	treat_post i.year i.idborder [aw = weight], a(fips) cluster(fips)


qui areg log_violent m1-m12 zero m14-m21 i.year i.idborder [aw = weight], a(fips) cluster(fips)
eststo violent
coefplot	(violent, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert keep(m9 m10 m11 m12 zero m14 m15 m16 m17) levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(17) xtitle("years from policy") ytitle("% change in violent crime, per 100,000")
graph export "$out/eventstudy_logviolent_yrs_border.png", replace

areg log_violent 	treat_post i.year i.idborder [aw = weight], a(fips) cluster(fips)


qui areg log_property m1-m12 zero m14-m21 i.year i.idborder [aw = weight], a(fips) cluster(fips)
eststo property
coefplot	(property, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert keep(m9 m10 m11 m12 zero m14 m15 m16 m17) levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(17) xtitle("years from policy") ytitle("% change in property crime, per 100,000")
graph export "$out/eventstudy_logproperty_yrs_border.png", replace

areg log_tot 	treat_post i.year i.idborder [aw = weight], a(fips) cluster(fips)

* levels
qui areg codtot_i_rate 	m1-m12 zero m14-m21 i.year i.idborder [aw = weight], a(fips) cluster(fips)
eststo codtot_i_rate
coefplot	(codtot_i_rate, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert keep(m9 m10 m11 m12 zero m14 m15 m16 m17) levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(17) xtitle("months from policy") ytitle("change in total crime, per 100,000")
graph export "$out/eventstudy_crime_yrs_border.png", replace

areg log_tot 	treat_post i.year i.idborder [aw = weight], a(fips) cluster(fips)


qui areg violent m1-m12 zero m14-m21 i.year i.idborder [aw = weight], a(fips) cluster(fips)
eststo violent
coefplot	(violent, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert keep(m9 m10 m11 m12 zero m14 m15 m16 m17) levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(17) xtitle("years from policy") ytitle("change in violent crime, per 100,000")
graph export "$out/eventstudy_violent_yrs_border.png", replace

areg log_violent 	treat_post i.year i.idborder [aw = weight], a(fips) cluster(fips)


qui areg property m1-m12 zero m14-m21 i.year i.idborder [aw = weight], a(fips) cluster(fips)
eststo property
coefplot	(property, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert keep(m9 m10 m11 m12 zero m14 m15 m16 m17) levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(17) xtitle("years from policy") ytitle("change in property crime, per 100,000")
graph export "$out/eventstudy_property_yrs_border.png", replace

areg log_tot 	treat_post i.year i.idborder [aw = weight], a(fips) cluster(fips)


