*********************************************************************************************************************************
*																																*
*			Sanctuaries																											*
*			name file: offenses_eventstudy_quarterly.do																			*
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


**********************		Event study - quarterly data 		***************************

set matsize 11000
use offense_panel_group.dta, clear

** generate useful variables 
foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
rename `var'_c1_i_rate `var'_i_rate  
}

** collapse everything at the quarterly level
gen time_quarter = qofd(dofm(time))
format time_quarter %tq

gen quarter_en = qofd(dofm(enactment))
format quarter_en %tq

collapse tot_pop treat (sum) cod*_i_rate, by(fips quarter_en year time_quarter group)

gen property = cod6_i_rate + cod17_i_rate + cod21_i_rate + cod23_i_rate
gen violent = cod1_i_rate + cod3_i_rate + cod11_i_rate

gen log_tot = log(codtot_i_rate)
gen log_violent = log(violent)
gen log_property = log(property)
egen group_year = group(group year)

keep if year >= 2004

* time frame: 3 years (12 quarters)
gen Timeframe = 1 if abs(time - quarter_en) <= 12
bysort group time: egen timeframe = max(Timeframe)
drop Timeframe

keep if timeframe == 1

gen timefrom = time_q - quarter_en
qui tab timefrom, gen(t)

forvalues y = 1/25 {
replace t`y' = 0 if treat == 0
local z = `y' - 13
label variable t`y' "`z'"
}
gen zero = 0
label variable zero "0"

* simple diff-in-diff
eststo dd_crime: 		qui reg log_tot 		t1-t12 zero t14-t25 i.time_q treat [aw = tot_pop], cluster(fips)
eststo dd_property: 	qui reg log_property 	t1-t12 zero t14-t25 i.time_q treat [aw = tot_pop], cluster(fips)
eststo dd_violent: 		qui reg log_violent 	t1-t12 zero t14-t25 i.time_q treat [aw = tot_pop], cluster(fips)

* diff-in-diff - group FE
eststo dd_crime_g: 		qui areg log_tot 		t1-t12 zero t14-t25 i.time_q treat [aw = tot_pop], cluster(fips) a(group)
eststo dd_property_g: 	qui areg log_property 	t1-t12 zero t14-t25 i.time_q treat [aw = tot_pop], cluster(fips) a(group)
eststo dd_violentv: 	qui areg log_violent 	t1-t12 zero t14-t25 i.time_q treat [aw = tot_pop], cluster(fips) a(group)

* diff-in-diff - county FE
eststo dd_crime_c: 		qui areg log_tot 		t1-t12 zero t14-t25 i.time_q [aw = tot_pop], cluster(fips) a(fips)
eststo dd_property_c: 	qui areg log_property 	t1-t12 zero t14-t25 i.time_q [aw = tot_pop], cluster(fips) a(fips)
eststo dd_violent_c: 	qui areg log_violent 	t1-t12 zero t14-t25 i.time_q [aw = tot_pop], cluster(fips) a(fips)

* diff-in-diff - group*year FE
eststo dd_crime_gy: 	qui areg log_tot 		t1-t12 zero t14-t25 i.time_q treat [aw = tot_pop], cluster(fips) a(group_year)
eststo dd_property_gy: 	qui areg log_property 	t1-t12 zero t14-t25 i.time_q treat [aw = tot_pop], cluster(fips) a(group_year)
eststo dd_violent_gy: 	qui areg log_violent 	t1-t12 zero t14-t25 i.time_q treat [aw = tot_pop], cluster(fips) a(group_year)

* diff-in-diff - group*year and county FE
eststo dd_crime_cgy: 	qui areg log_tot 		t1-t12 zero t14-t25 i.time_q i.fips [aw = tot_pop], cluster(fips) a(group_year)
eststo dd_property_cgy: qui areg log_property 	t1-t12 zero t14-t25 i.time_q i.fips [aw = tot_pop], cluster(fips) a(group_year)
eststo dd_violent_cgy: 	qui areg log_violent 	t1-t12 zero t14-t25 i.time_q i.fips [aw = tot_pop], cluster(fips) a(group_year)

coefplot (dd_crime, lcolor(black) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
		, vert drop(*time* _cons treat)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xtitle("quarter from policy") ytitle("total crime")
			
coefplot (dd_crime_g, lcolor(black) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
		, vert drop(*time* *group* _cons treat)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xtitle("quarter from policy") ytitle("total crime")

coefplot (dd_crime_c, lcolor(black) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
		, vert drop(*time* *fips _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xtitle("quarter from policy") ytitle("total crime")

coefplot (dd_crime_gy, lcolor(black) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
		, vert drop(*time* *group* _cons treat)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xtitle("quarter from policy") ytitle("total crime")

coefplot (dd_crime_cgy, lcolor(black) mcolor(black) recast(connect) ciopts(lcolor(black) recast(rcap))) ///
		, vert drop(*time* *group* *fips* _cons)  levels(90) ///
			omitted yline(0, lcolor(black) lpattern(dot)) xtitle("quarter from policy") ytitle("total crime")
