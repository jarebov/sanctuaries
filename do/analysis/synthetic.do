*********************************************************************************************************************************
*																																*
*			Sanctuaries																											*
*			name file: synthetic.do																								*
*			synthetic controls																						 			*
*																																*
*********************************************************************************************************************************


clear all
set more off

global user = 2 // 1 Jaime, 2 Barbara

if $user == 1{
cd "/Users/JAIME/Dropbox/research/sanctuaries/data/output_datasets"
global out = "/Users/JAIME/Dropbox/research/sanctuaries/out"
global synth = "/Users/JAIME/Dropbox/research/sanctuaries/data/synth"
}

if $user == 2{
cd "~/Dropbox/Research/sanctuaries/data/output_datasets"
global out = "~/Dropbox/Research/sanctuaries/out"
global synth = "~/Dropbox/Research/sanctuaries/data/synth"
}

clear all
set more off


set matsize 11000

**********************		Synthetic controls: match on crime, population, unemployment 		***************************

** create dataset

use treat_control_list.dta, clear
keep if treat == 1
sort fips
merge 1:m fips using offenses_county_month.dta
keep if year >= 2010
replace treat = 0 if _m == 2
drop _m

keep fips treat enactment time year month codtot_c1_i_rate tot_pop codtot_c1_i

** collapse everything at the quarterly level
gen time_quarter = qofd(dofm(time))
format time_quarter %tq

gen quarter_en = qofd(dofm(enactment))
format quarter_en %tq
gen year_en = yofd(dofm(enactment))
format year_en %ty

collapse tot_pop treat (sum) cod*_i_rate, by(fips quarter_en year year_en time_quarter)

sort fips year
merge m:1 fips year using pop_byrace.dta
drop if _m != 3
drop _m
merge m:1 fips year using wkage_pop.dta
drop if _m != 3
drop _m
merge m:1 fips year using bls.dta
drop if _m != 3
drop _m

** generate population shares
foreach var in wa_male wa_female ba_male ba_female aa_male aa_female h_male h_female white_pop black_pop asian_pop hisp_pop workingage_pop laborforce {
gen `var'_share = `var' / tot_pop
}


** synthetic controls for each treated county
levelsof fips if treat == 1, local(Treat)

* list of variables on which to match (including depvar)
global Var = "codtot_c1_i_rate codtot_c1_i_rate"
global Var_1 = "codtot_c1_i_rate"

** Generate state variable
gen state = floor(fips/1000)

levelsof fips if treat == 1 & year_en > 2010 & state != 11, local(Treat)

qui foreach c of local Treat {
noisily disp "county n. `c'"

tsset fips time_quarter
preserve
levelsof state if fips == `c', local(State)
keep if fips == `c' | (treat == 0 & state == `State')

codebook fips
* "fill in" the dataset
bysort fips (time_q): carryforward $Var_1, replace
tsfill, full 
bysort fips (time_q): carryforward $Var_1, replace
qui reg $Var
gen mis = 1 - e(sample)
bysort fips: egen Mis = max(mis)
drop if Mis == 1
drop Mis mis

* calculate weights and save them
levelsof quarter_en if fips == `c', local(enact)
synth 	$Var, ///
		trunit(`c') trperiod(`enact') figure keep($synth/`c', replace)
graph export "$out/synth`c'.png", replace
restore
}

preserve
clear
set obs 1
gen fips = .
save temp.dta, replace
restore

levelsof fips if treat == 1 & year_en > 2010 & state != 11, local(Treat)
qui foreach c of local Treat {
noisily disp "county n. `c'"
preserve
use $synth/`c'.dta, clear
gen fips_treated = `c'
rename _Co fips
drop if fips == .
rename _W_ weight
sort fips
merge 1:m fips using offenses_county_month.dta
keep if _m == 3
drop _m
append using temp.dta
sort fips
save temp.dta, replace
restore
}

preserve
use temp.dta, clear
collapse codtot_c1_i_rate [aw = weight], by(time fips_treated)
gen time_quarter = qofd(dofm(time))
collapse (sum) codtot_c1_i_rate, by(fips_treated time_quarter)
save temp2.dta, replace
restore

** Generate panel of offenses for treated and synthetic control
* control:

keep fips time_quarter quarter_en year tot_pop codtot_c1_i_rate treat 
keep if treat == 1
append using temp2.dta
replace treat = 0 if treat == .
replace fips = fips_treated if fips == .
replace fips_treated = fips if fips_treated == .
gsort fips_treated time -treat
bysort fips_treated time: carryforward tot_pop, replace
sort fips time treat



