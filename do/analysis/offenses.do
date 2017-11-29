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


******************************** Simple comparison - no groups (one obs is one county-month) ***************************************

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


*** Average crime rates for treated counties, by time to enactment
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


**********************		Regressions - groups of treated and control 		***************************

set matsize 11000
use offense_panel_group.dta, clear

** generate useful variables 
foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
rename `var'_c1_i_rate `var'_i_rate  
}

gen property = cod6_i_rate + cod17_i_rate + cod21_i_rate + cod23_i_rate
gen violent = cod1_i_rate + cod3_i_rate + cod11_i_rate

gen log_tot = log(codtot_i_rate)
gen log_violent = log(violent)
gen log_property = log(property)

egen group_year = group(group year)

gen post = time > enactment
gen treat_post = treat == 1 & post == 1


keep if year >= 2004

* time frame - 12, 24, or 36 months

foreach time in 24 36 {
gen Timeframe = 1 if abs(time - enactment) < `time'
bysort group time: egen timeframe = max(Timeframe)
drop Timeframe

* simple diff-in-diff
qui reg codtot_i_rate treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui reg log_tot treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_`time'.doc", keep(treat treat_post) word ctitle("total") replace label ///
		addtext(Time FE,Yes,County FE,No,Group FE,No,Group*Year FE,No) dec(3) 
		
qui reg property treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui reg log_property treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_`time'.doc", keep(treat treat_post) word ctitle("property") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,No,Group*Year FE,No) dec(3) 
		
qui reg violent treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui reg log_violent treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_`time'.doc", keep(treat treat_post) word ctitle("violent") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,No,Group*Year FE,No) dec(3) 
		

* diff-in-diff - group FE
qui areg codtot_i_rate treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(group)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_tot treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(group)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_`time'.doc", keep(treat treat_post) word ctitle("total") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,Yes,Group*Year FE,No) dec(3)
		
qui areg property treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(group)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_property treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(group)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_`time'.doc", keep(treat treat_post) word ctitle("property") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,Yes,Group*Year FE,No) dec(3)
		
qui areg violent treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(group)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_violent treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(group)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_`time'.doc", keep(treat treat_post) word ctitle("violent") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,Yes,Group*Year FE,No) dec(3)

* diff-in-diff - county FE
qui areg codtot_i_rate treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
		
qui areg log_tot treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_`time'.doc", keep(treat treat_post) word ctitle("total") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,No,Group*Year FE,No) dec(3)
		
qui areg property treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_property treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_`time'.doc", keep(treat treat_post) word ctitle("property") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,No,Group*Year FE,No) dec(3)
		
qui areg violent treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_violent treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_`time'.doc", keep(treat treat_post) word ctitle("violent") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,No,Group*Year FE,No) dec(3)
		
* diff-in-diff - group*year FE

qui areg codtot_i_rate treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_tot treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_`time'.doc", keep(treat treat_post) word ctitle("total") replace label ///
		addtext(Time FE,Yes,County FE,No,Group FE,No,Group*Year FE,Yes) dec(3)
		
qui areg property treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_property treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_`time'.doc", keep(treat treat_post) word ctitle("property") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,No,Group*Year FE,Yes) dec(3)
		
qui areg violent treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_violent treat treat_post i.time if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_`time'.doc", keep(treat treat_post) word ctitle("violent") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,No,Group*Year FE,Yes) dec(3)
		
* diff-in-diff - group and county FE

qui areg codtot_i_rate treat treat_post i.time i.group if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_tot treat treat_post i.time i.group if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_`time'.doc", keep(treat treat_post) word ctitle("total") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,Yes,Group*Year FE,No) dec(3)
		
qui areg property treat treat_post i.time i.group if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_property treat treat_post i.time i.group if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_`time'.doc", keep(treat treat_post) word ctitle("property") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,Yes,Group*Year FE,No) dec(3)
		
qui areg violent treat treat_post i.time i.group if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_violent treat treat_post i.time i.group if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_`time'.doc", keep(treat treat_post) word ctitle("violent") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,Yes,Group*Year FE,No) dec(3)
		
* diff-in-diff - group-year and county FE

qui areg codtot_i_rate treat treat_post i.time i.fips if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_tot treat_post i.time i.fips if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_`time'.doc", keep(treat treat_post) word ctitle("total") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,No,Group*Year FE,Yes) dec(3)
		
qui areg property treat_post i.time i.fips if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_property treat treat_post i.time i.fips if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_`time'.doc", keep(treat treat_post) word ctitle("property") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,No,Group*Year FE,Yes) dec(3)
		
qui areg violent treat_post i.time i.fips if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_violent treat treat_post i.time i.fips if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_`time'.doc", keep(treat treat_post) word ctitle("violent") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,No,Group*Year FE,Yes) dec(3)
		
drop timeframe 
}
