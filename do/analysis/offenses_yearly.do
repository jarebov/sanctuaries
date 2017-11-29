*********************************************************************************************************************************
*																																*
*			Sanctuaries																											*
*			name file: offenses_quarterly.do																					*
*			regressions at quarterly level																			 			*
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




**********************		Regressions - groups of treated and control 		***************************

set matsize 11000
use offense_panel_group.dta, clear

** generate useful variables 
foreach var in codtot cod1 cod3 cod6 cod11 cod17 cod21 cod23 {
rename `var'_c1_i_rate `var'_i_rate  
}

** collapse everything at the quarterly level
gen time_sem = hofd(dofm(time))
gen en_sem = hofd(dofm(enactment))
collapse tot_pop treat (sum) cod*_i_rate, by(fips time_sem group en_sem year)

gen property = cod6_i_rate + cod17_i_rate + cod21_i_rate + cod23_i_rate
gen violent = cod1_i_rate + cod3_i_rate + cod11_i_rate

gen log_tot = log(codtot_i_rate)
gen log_violent = log(violent)
gen log_property = log(property)

egen group_year = group(group year)

gen post = time_sem > en_sem
gen treat_post = treat == 1 & post == 1


keep if year >= 2004

* time frame - 2, 3, 4 semesters

foreach time in 2 3 4 {

gen Timeframe = 1 if abs(time_sem - en_sem) <= `y'
bysort group time: egen timeframe = max(Timeframe)
drop Timeframe

* simple diff-in-diff
qui reg codtot_i_rate treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui reg log_tot treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_qty_`time'.doc", keep(treat treat_post) word ctitle("total") replace label ///
		addtext(Time FE,Yes,County FE,No,Group FE,No,Group*Year FE,No) dec(3) 
		
qui reg property treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui reg log_property treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_qty_`time'.doc", keep(treat treat_post) word ctitle("property") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,No,Group*Year FE,No) dec(3) 
		
qui reg violent treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui reg log_violent treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_qty_`time'.doc", keep(treat treat_post) word ctitle("violent") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,No,Group*Year FE,No) dec(3) 
		

* diff-in-diff - group FE
qui areg codtot_i_rate treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(group)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_tot treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(group)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_qty_`time'.doc", keep(treat treat_post) word ctitle("total") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,Yes,Group*Year FE,No) dec(3)
		
qui areg property treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(group)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_property treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(group)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_qty_`time'.doc", keep(treat treat_post) word ctitle("property") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,Yes,Group*Year FE,No) dec(3)
		
qui areg violent treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(group)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_violent treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(group)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_qty_`time'.doc", keep(treat treat_post) word ctitle("violent") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,Yes,Group*Year FE,No) dec(3)

* diff-in-diff - county FE
qui areg codtot_i_rate treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
		
qui areg log_tot treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_qty_`time'.doc", keep(treat treat_post) word ctitle("total") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,No,Group*Year FE,No) dec(3)
		
qui areg property treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_property treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_qty_`time'.doc", keep(treat treat_post) word ctitle("property") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,No,Group*Year FE,No) dec(3)
		
qui areg violent treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_violent treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses_qty_`time'.doc", keep(treat treat_post) word ctitle("violent") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,No,Group*Year FE,No) dec(3)
		
* diff-in-diff - group*year FE

qui areg codtot_i_rate treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_tot treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_qty_`time'.doc", keep(treat treat_post) word ctitle("total") replace label ///
		addtext(Time FE,Yes,County FE,No,Group FE,No,Group*Year FE,Yes) dec(3)
		
qui areg property treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_property treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_qty_`time'.doc", keep(treat treat_post) word ctitle("property") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,No,Group*Year FE,Yes) dec(3)
		
qui areg violent treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_violent treat treat_post i.time_s if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_qty_`time'.doc", keep(treat treat_post) word ctitle("violent") append label ///
		addtext(Time FE,Yes,County FE,No,Group FE,No,Group*Year FE,Yes) dec(3)
		
* diff-in-diff - group and county FE

qui areg codtot_i_rate treat treat_post i.time_s i.group if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_tot treat treat_post i.time_s i.group if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_qty_`time'.doc", keep(treat treat_post) word ctitle("total") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,Yes,Group*Year FE,No) dec(3)
		
qui areg property treat treat_post i.time_s i.group if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_property treat treat_post i.time_s i.group if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_qty_`time'.doc", keep(treat treat_post) word ctitle("property") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,Yes,Group*Year FE,No) dec(3)
		
qui areg violent treat treat_post i.time_s i.group if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_violent treat treat_post i.time_s i.group if timeframe == 1 [aw = tot_pop], cluster(fips) a(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_qty_`time'.doc", keep(treat treat_post) word ctitle("violent") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,Yes,Group*Year FE,No) dec(3)
		
* diff-in-diff - group-year and county FE

qui areg codtot_i_rate treat treat_post i.time_s i.fips if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_tot treat_post i.time_s i.fips if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_qty_`time'.doc", keep(treat treat_post) word ctitle("total") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,No,Group*Year FE,Yes) dec(3)
		
qui areg property treat_post i.time_s i.fips if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_property treat treat_post i.time_s i.fips if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_qty_`time'.doc", keep(treat treat_post) word ctitle("property") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,No,Group*Year FE,Yes) dec(3)
		
qui areg violent treat_post i.time_s i.fips if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)

qui areg log_violent treat treat_post i.time_s i.fips if timeframe == 1 [aw = tot_pop], cluster(fips) a(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
disp e(N)
outreg2 using "$out/offenses2_qty_`time'.doc", keep(treat treat_post) word ctitle("violent") append label ///
		addtext(Time FE,Yes,County FE,Yes,Group FE,No,Group*Year FE,Yes) dec(3)
		
drop timeframe 
}
