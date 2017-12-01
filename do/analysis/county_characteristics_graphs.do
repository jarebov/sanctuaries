*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: balance_table.do																				*
*						builds tables of sumstats to show balance between treatment and control									*
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

****
use offenses_county_month.dta, clear
keep if year >= 2005
collapse (sum) codtot_c1_i_rate, by(fips year)
sort fips year
merge 1:1 fips year using covariates.dta
keep if year >= 2005
drop _m

** merge treatment nr. 1: county detainer
sort fips
merge m:1 fips using treat_control_list.dta	
gen other = _m == 1
drop _m

** Crime
twoway	(histogram codtot 	if codtot < 10000 & treat == 0, color(none) lcolor(white))	///
		(histogram codtot 	if codtot < 10000 & treat == 1, color(none) lcolor(white))	///
		(histogram codtot 	if codtot < 10000, color(gs8%50))	///
		, xtitle("offenses per 100,000") legend(order(3 "US") rows(1))
graph export "$out/crime_slides1.png", replace

twoway	(histogram codtot 	if codtot < 10000 & treat == 0, color(none) lcolor(white))	///
		(histogram codtot 	if codtot < 10000, color(gs8%50))	///
		(histogram codtot 	if codtot < 10000 & treat == 1, color(red%50))	///
		, xtitle("offenses per 100,000") legend(order(2 "US" 3 "No-detainer") rows(1))
graph export "$out/crime_slides2.png", replace

twoway	(histogram codtot 	if codtot < 10000, color(gs8%50))	///
		(histogram codtot 	if codtot < 10000 & treat == 0, color(green%50))	///
		(histogram codtot 	if codtot < 10000 & treat == 1, color(red%50))	///
		, xtitle("offenses per 100,000")  legend(order(1 "US" 3 "No-detainer" 2 "Bordering") rows(1))
graph export "$out/crime_slides3.png", replace
		
		
** Share hispanic
gen share_hispanic = hisp_pop * 100 / tot_pop

twoway	(histogram share_hispanic 	if treat == 0, color(none) lcolor(white))	///
		(histogram share_hispanic 	if treat == 1, color(none) lcolor(white))	///
		(histogram share_hispanic 	, color(gs8%50))	///
		, xtitle("share hispanic") legend(order(3 "US") rows(1))
graph export "$out/hisp_slides1.png", replace

twoway	(histogram share_hispanic 	if treat == 0, color(none) lcolor(white))	///
		(histogram share_hispanic 	, color(gs8%50))	///
		(histogram share_hispanic 	if treat == 1, color(red%50))	///
		, xtitle("share hispanic") legend(order(2 "US" 3 "No-detainer") rows(1))
graph export "$out/hisp_slides2.png", replace

twoway	(histogram share_hispanic 	, color(gs8%50))	///
		(histogram share_hispanic 	if treat == 0, color(green%50))	///
		(histogram share_hispanic 	if treat == 1, color(red%50))	///
		, xtitle("share hispanic")  legend(order(1 "US" 3 "No-detainer" 2 "Bordering") rows(1))
graph export "$out/hisp_slides3.png", replace
		
** Migration
twoway	(histogram mig_inflow 	if treat == 0, color(none) lcolor(white))	///
		(histogram mig_inflow 	if treat == 1, color(none) lcolor(white))	///
		(histogram mig_inflow 	, color(gs8%50))	///
		, xtitle("migration inflow") legend(order(3 "US") rows(1))
graph export "$out/migr_slides1.png", replace

twoway	(histogram mig_inflow 	if treat == 0, color(none) lcolor(white))	///
		(histogram mig_inflow 	, color(gs8%50))	///
		(histogram mig_inflow 	if treat == 1, color(red%50))	///
		, xtitle("migration inflow") legend(order(2 "US" 3 "No-detainer") rows(1))
graph export "$out/migr_slides2.png", replace

twoway	(histogram mig_inflow 	, color(gs8%50))	///
		(histogram mig_inflow 	if treat == 0, color(green%50))	///
		(histogram mig_inflow 	if treat == 1, color(red%50))	///
		, xtitle("migration inflow")  legend(order(1 "US" 3 "No-detainer" 2 "Bordering") rows(1))
graph export "$out/migr_slides3.png", replace


** Democratic
gen dem_share = dem_vote * 100 

twoway	(histogram dem_share 	if treat == 0, color(none) lcolor(white))	///
		(histogram dem_share 	if treat == 1, color(none) lcolor(white))	///
		(histogram dem_share 	, color(gs8%50))	///
		, xtitle("share democratic votes") legend(order(3 "US") rows(1))
graph export "$out/dem_slides1.png", replace

twoway	(histogram dem_share 	if treat == 0, color(none) lcolor(white))	///
		(histogram dem_share 	, color(gs8%50))	///
		(histogram dem_share 	if treat == 1, color(red%50))	///
		, xtitle("share democratic votes") legend(order(2 "US" 3 "No-detainer") rows(1))
graph export "$out/dem_slides2.png", replace

twoway	(histogram dem_share 	, color(gs8%50))	///
		(histogram dem_share 	if treat == 0, color(green%50))	///
		(histogram dem_share 	if treat == 1, color(red%50))	///
		, xtitle("share democratic votes")  legend(order(1 "US" 3 "No-detainer" 2 "Bordering") rows(1))
graph export "$out/dem_slides3.png", replace

		
** Income
twoway	(histogram median 	if treat == 0, color(none) lcolor(white))	///
		(histogram median 	if treat == 1, color(none) lcolor(white))	///
		(histogram median 	, color(gs8%50))	///
		, xtitle("median household income") legend(order(3 "US") rows(1))
graph export "$out/income_slides1.png", replace

twoway	(histogram median 	if treat == 0, color(none) lcolor(white))	///
		(histogram median 	, color(gs8%50))	///
		(histogram median 	if treat == 1, color(red%50))	///
		, xtitle("median household income") legend(order(2 "US" 3 "No-detainer") rows(1))
graph export "$out/income_slides2.png", replace

twoway	(histogram median 	, color(gs8%50))	///
		(histogram median 	if treat == 0, color(green%50))	///
		(histogram median 	if treat == 1, color(red%50))	///
		, xtitle("median household income")  legend(order(1 "US" 3 "No-detainer" 2 "Bordering") rows(1))
graph export "$out/income_slides3.png", replace
		
		
