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
	

***************************************			 Border FE 			***************************************

set matsize 11000
use offense_panel_border.dta, clear
* the following code allows to look at UNFOUND as a share of offense
foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
gen `var'_i_rate  = `var'_c0_i_rate * 100  / `var'_c1_i_rate  
}

gen property = (cod6_c0_i_rate + cod17_c0_i_rate + cod21_c0_i_rate + cod23_c0_i_rate) * 100 / (cod6_c1_i_rate + cod17_c1_i_rate + cod21_c1_i_rate + cod23_c1_i_rate)
gen violent = (cod1_c0_i_rate + cod3_c0_i_rate + cod11_c0_i_rate) * 100 / (cod1_c1_i_rate + cod3_c1_i_rate + cod11_c1_i_rate)


keep if year >= 2004

gen months_from = (year - year_enacted) * 12 + (month - month_enacted)
qui tab months_from, gen(m)

qui forvalues m = 1/251 {
replace m`m' = 0 if treat == 0
local n = `m' - 151
label variable m`m' "`n'"
}

gen weight = tot_pop / count_border
gen zero = 0
label variable zero "0"

egen idborder = group(border_id)

gen log_tot = log(codtot_i_rate)
gen log_violent = log(violent)
gen log_property = log(property)



qui areg log_tot 	m139-m150 m151 m152-m163  i.time i.idborder [aw = weight], a(fips) cluster(fips)
eststo codtot_i_rate
coefplot	(codtot_i_rate, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13) xtitle("months from policy") ytitle("change in total crime, per 100,000")
graph export "$out/eventstudy_totcrime_months_border.png", replace

qui areg log_violent m139-m150 m151 m152-m163 i.time i.idborder [aw = weight], a(fips) cluster(fips)
eststo violent
coefplot	(violent, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13) xtitle("months from policy") ytitle("change in violent crime, per 100,000")
graph export "$out/eventstudy_violent_months_border.png", replace

qui areg log_property m139-m150 m151 m152-m163 i.time i.idborder [aw = weight], a(fips) cluster(fips)
eststo property
coefplot	(property, lcolor(black) fcolor(none) mcolor(black) recast(connect) ciopts(color(gs8%30) recast(rarea))) ///
			, vert drop(*month *time treat *idborder _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xline(13) xtitle("months from policy") ytitle("change in property crime, per 100,000")
graph export "$out/eventstudy_property_months_border.png", replace

	

	
	
