
*********************************************************************************************************************************
*																																*
*				Sanctuaries																										*
*				name file: build_panel_border.do																				*
*				builds dataset of treated and control counties - format allows for border comparison							*
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
set matsize 11000

**

use adjacency_treated_wide.dta, clear

* the following line drops undated counties & one county with detainer in 1997
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
gen group = fips
drop fips
rename adj_fips fips
sort fips
merge 1:m fips using offenses_county_month.dta
keep if _m == 3
drop _m
drop dateen
gen nr_borders = _N
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


keep fips dateenacted
gen group = fips

sort fips
merge 1:m fips using offenses_county_month.dta
keep if _m == 3
capt drop _m
gen treat = 1
append using control_panel.dta

gen enactment = monthly(dateenacted, "M20Y")
format enactment %tm

bysort fips: egen M = max(treat)
replace treat = 1 if M > 0
drop M
duplicates drop

** collapse everything at the quarterly level
gen time_quarter = qofd(dofm(time))
format time_quarter %tq
gen quarter_enactment = qofd(dofm(enactment))
format quarter_enactment %tq

drop if group == .




*** Collapse data at the quarter level

*this preserves labels during collapse (1/2)
foreach v of var * {
 	local l`v' : variable label `v'
        if `"`l`v''"' == "" {
 		local l`v' "`v'"
		}
}

collapse tot_pop treat (sum) *rate, by(fips quarter_enactment year time_quarter group nr_borders)

*this preserves labels during collapse (2/2)
foreach v of var * {
 	label var `v' "`l`v''"
 }


 
***Generate logs:
foreach v of varlist cod*_rate {

	gen l`v' = ln(`v')

}

*and label them
foreach k in 0 1 2 3{
	label var lcod1_c`k'_rate "log-murder per 100,000 card `k'"
	label var lcod3_c`k'_rate "log-rape per 100,000 card `k'"
	label var lcod6_c`k'_rate "log-robbery per 100,000 card `k'"
	label var lcod11_c`k'_rate "log-assault per 100,000 card `k'"
	label var lcod17_c`k'_rate "log-burglary per 100,000 card `k'"
	label var lcod21_c`k'_rate "log-larceny per 100,000 card `k'"
	label var lcod23_c`k'_rate "log-auto theft per 100,000 card `k'"
	
	label var lcodtot_c`k'_rate "log-all 7 index crimes per 100,000 card `k'"
	
	label var lcodviolent_c`k'_rate "log-violent per 100,000 card `k'"
	label var lcodnonviolent_c`k'_rate "log-non-violent per 100,000 card `k'"

	
	
	label var lcod1_c`k'_i_rate "log-murder per 100,000 card `k' - smoothed"
	label var lcod3_c`k'_i_rate "log-rape per 100,000 card `k' - smoothed"
	label var lcod6_c`k'_i_rate "log-robbery per 100,000 card `k' - smoothed"
	label var lcod11_c`k'_i_rate "log-assault per 100,000 card `k' - smoothed"
	label var lcod17_c`k'_i_rate "log-burglary per 100,000 card `k' - smoothed"
	label var lcod21_c`k'_i_rate "log-larceny per 100,000 card `k' - smoothed"
	label var lcod23_c`k'_i_rate "log-auto theft per 100,000 card `k' - smoothed"
	
	label var lcodtot_c`k'_i_rate "log-all 7 index crimes per 100,000 card `k' - smoothed"
	
	label var lcodviolent_c`k'_i_rate "log-violent per 100,000 card `k'- smoothed"
	label var lcodnonviolent_c`k'_i_rate "log-non-violent per 100,000 card `k'- smoothed"
}

 
 
* Generate necessary variables
gen quarter = quarter(dofq(time_quarter)) //calendar quarter (1,2,3,4)
label var quarter "calendar quarter (1,2,3,4)"
gen year_en = year(dofq(quarter_enactment)) //calendar year of enactment
label var year_en "calendar year of enactment"

bysort fips (year): gen tot_pop2000 = tot_pop[1] //baseline population (year 2000)
bysort fips time_quarter: gen obsfips = _n //keep track duplicate control counties
label var obsfips "keep if obsfips=1 limits to non-duplicate county obs"
gen timefromenact = time_quarter - quarter_enactment

egen quarter_enactment2 = mean(quarter_enactment), by(group) //assign quarter of enactment to control units
label var quarter_enactment2 "assign quarter of enactment to control units"
egen year_enactment2 = mean(year_en), by(group) //assign year of enactment to control units 
label var year_enactment2 "assign year of enactment to control units "
format quarter_enactment2 %tq
gen timefromenact2 = time_quarter - quarter_enactment2
gen post = timefromenact2 > 0




*********** Drop groups where date of enactment is in 2015 or 2016
drop if inrange(year_enactment2,2015,2016)
***********


*** Winsorize *********
foreach v of varlist *_rate{
	gen `v'_w = `v'
	
	forvalues y = 2000/2016 {
		qui sum `v' if year==`y', det
		replace `v'_w=r(p1) if `v' < r(p1) & year==`y' & `v'!=.
		replace `v'_w=r(p99) if `v' > r(p99) & year==`y' & `v'!=.
	}
}
************************




****** Adjustments due to bad data (From visual inspection) ******************
drop if fips==8023 //control county, missing data
drop if fips==20045 //control county, bad data: crimes drop to <10% of pre 2014 levels after 2014m7
drop if fips==20155 & time_quarter==tq(2016q4) //control county, 2016m11 and 2016m12 not reported
drop if group==24033 & year==2016 //treated county, 2016 not fully reported (drop same time period for its control units)
drop if fips==31093 //control, 2014q3,q4 and 2015 missing (right around the relevant policy change). It is a tiny county with mostly zeros and ones as data
drop if fips==35021 //control, data ends in 2007 and relevant policy date change is 2014
drop if fips==8021 & group==35055 //control, no data from 2003-2011. But still useful as control for other counties in 2014
drop if fips==35033 //control, missing data 2012-2013, messing up for the three groups for which it serves as control
drop if fips==36081 //control, data stops in 2010 and relevant policy change is in 2014
drop if fips==36085 //control, data stops in 2010 and relevant policy change is in 2014
drop if group==41005 //treat, data for 2014 and 2015 all messed up right around policy change. drop its control units too
drop if fips==41035 & year==2016 //control, data for 2016 not fully reported
drop if group==41041 & (time_quarter==tq(2015q4) | year==2016) //treat, not fully reported on those dates
drop if group==41063 & year==2016 //treat, 2016 not fully reported
******************************************************************************************




*** Taking away Pre-Trends *********

*county-specific (some counties serve as control for more than one unit, at different points in time. need to take that into account)
*estimated on two years before policy change


*generate fips-group identifier
tostring fips, gen(fips_string)
tostring group, gen (group_string)
gen unit = "f"+fips_string+"-"+"g"+group_string
drop fips_string group_string

egen unit_num = group(fips group)


*define the two years of pre-period
gen pre2 = 0
label var pre2 "=1 if unit in [-8,-1] quarters before enactment"
replace pre2 = 1 if inrange(timefromenact2,-8,-1)


qui distinct unit_num
local units = r(ndistinct) //local with distinct number of units

local todetrend = "lcodtot_c1_i_rate codtot_c1_i_rate lcodtot_c1_i_rate_w codtot_c1_i_rate_w lcodviolent_c1_i_rate codviolent_c1_i_rate lcodviolent_c1_i_rate_w codviolent_c1_i_rate_w lcodnonviolent_c1_i_rate codnonviolent_c1_i_rate lcodnonviolent_c1_i_rate_w codnonviolent_c1_i_rate_w"

foreach v of varlist `todetrend'{
	qui reg `v' c.time_quarter#i.unit_num i.quarter if pre2==1 [pweight=tot_pop2000]
	qui distinct unit_num if e(sample)
	local units = r(ndistinct) //local with distinct number of units
	mat b`v'=e(b)
	mat t`v'=b`v'[1,1..`units']
	mat score `v'FIT = t`v'
	gen `v'_dt = `v' - `v'FIT
	drop `v'FIT
}

local todetrend = "cod1_c1_i_rate lcod1_c1_i_rate cod3_c1_i_rate lcod3_c1_i_rate cod6_c1_i_rate lcod6_c1_i_rate cod11_c1_i_rate lcod11_c1_i_rate cod17_c1_i_rate lcod17_c1_i_rate cod21_c1_i_rate lcod21_c1_i_rate cod23_c1_i_rate lcod23_c1_i_rate"
foreach v of varlist `todetrend'{
	qui reg `v' c.time_quarter#i.unit_num i.quarter if pre2==1 [pweight=tot_pop2000]
	qui distinct unit_num if e(sample)
	local units = r(ndistinct) //local with distinct number of units
	mat b`v'=e(b)
	mat t`v'=b`v'[1,1..`units']
	mat score `v'FIT = t`v'
	gen `v'_dt = `v' - `v'FIT
	drop `v'FIT
}

local todetrend = "cod1_c1_i_rate_w lcod1_c1_i_rate_w cod3_c1_i_rate_w lcod3_c1_i_rate_w cod6_c1_i_rate_w lcod6_c1_i_rate_w cod11_c1_i_rate_w lcod11_c1_i_rate_w cod17_c1_i_rate_w lcod17_c1_i_rate_w cod21_c1_i_rate_w lcod21_c1_i_rate_w cod23_c1_i_rate_w lcod23_c1_i_rate_w"
foreach v of varlist `todetrend'{
	qui reg `v' c.time_quarter#i.unit_num i.quarter if pre2==1 [pweight=tot_pop2000]
	qui distinct unit_num if e(sample)
	local units = r(ndistinct) //local with distinct number of units
	mat b`v'=e(b)
	mat t`v'=b`v'[1,1..`units']
	mat score `v'FIT = t`v'
	gen `v'_dt = `v' - `v'FIT
	drop `v'FIT
}

************************




sort fips time_quarter
save offense_panel_group.dta, replace
rm control_panel.dta

















