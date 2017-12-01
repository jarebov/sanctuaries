clear all
set more off

global user = 2 // 1 Jaime, 2 Barbara

if $user == 1{
global path = "/Users/JAIME/Dropbox/research/sanctuaries"
}

if $user == 2{
global path =  "~/Dropbox/Research/sanctuaries"
}

use "$path/data/output_datasets/offense_panel_group.dta", clear
sort group fips time_quarter


* Generate necessary variables
gen lcodtot_c1_i_rate = ln(codtot_c1_i_rate) //log crime rate
gen quarter = quarter(dofq(time_quarter)) //calendar quarter (1,2,3,4)
bysort fips (year): gen tot_pop2000 = tot_pop[1] //baseline population (year 2000)
bysort fips time_quarter: gen obsfips = _n //keep track duplicate control counties
gen timefromenact = time_quarter - quarter_enactment
egen quarter_enactment2 = mean(quarter_enactment), by(group) //assign quarter of enactment to control units 
format quarter_enactment2 %tq
gen timefromenact2 = time_quarter - quarter_enactment2

****************************** TIME TRENDS (HP FILTER) ******************************

* CRIME RATE LEVEL, TREND, BY TREAT CONTROL. NO WEIGHT
preserve
	
	keep if inrange(year,2005,2016)
	
	keep if obsfips==1 //drop duplicate control counties
		
	local var = "codtot_c1_i_rate"
	
	collapse `var', by(time_quarter treat)
	
	tsset treat time_quarter, quarterly
	
	tsfilter hp `var'HP = `var', trend(`var'HPtrend) smooth(1600)

	twoway  (line `var'HPtrend time_quarter if treat==1, lc(black) lw(medthick)) ///
			(line `var'HPtrend time_quarter if treat==0, lc(gray) lp(dash) lw(medthick)) ///
			,ylabel(,grid labsize(small)) ytitle("crime rate (per 100,000) - HP trend {&lambda}=1600" " ", size(small)) xtitle("") ///
			legend(order(1 "policy" 2 "bordering")) xlabel(,labsize(small))
	
	graph export "$path/out/crime_rate_levels_HPtrend_treat_control_noweights.pdf", replace
restore


* CRIME RATE LEVEL, TREND, BY TREAT CONTROL. WEIGHT = POPULATION in 2000
preserve
	
	keep if inrange(year,2005,2016)
	
	keep if obsfips==1 //drop duplicate control counties
		
	local var = "codtot_c1_i_rate"
	
	collapse `var' [aweight=tot_pop2000], by(time_quarter treat)
	
	tsset treat time_quarter, quarterly
	
	tsfilter hp `var'HP = `var', trend(`var'HPtrend) smooth(1600)

	twoway  (line `var'HPtrend time_quarter if treat==1, lc(black) lw(medthick)) ///
			(line `var'HPtrend time_quarter if treat==0, lc(gray) lp(dash) lw(medthick)) ///
			,ylabel(,grid labsize(small)) ytitle("crime rate (per 100,000) - HP trend {&lambda}=1600" " ", size(small)) xtitle("") ///
			legend(order(1 "policy" 2 "bordering")) xlabel(,labsize(small))
	
	graph export "$path/out/crime_rate_levels_HPtrend_treat_control_weights.pdf", replace

	
restore
************************************************************************************************************************



****************************** NORMALIZE TO POLICY IMPLEMENTATION TIME ************************************************************

preserve

	*drop if group==6005|group==6019|group==6023|group==6069|group==6075|group==6081 ///
	*		|group==12001|group==22071|group==42101|group==51013 //drop treat counties that implement policy 2015 and onwards (and their control counties)
	
	
	*replace lcodtot_c1_i_rate = ln(codtot_c1_i_rate+1) if codtot_c1_i_rate==0

	
	drop if  group==6075|group==22071|group==42101 //drop treat counties that implement policy 2016 and onwards (and their control counties)
	
	keep if inrange(year,2006,2015)
	
	reg codtot_c1_i_rate i.treat i.year i.quarter [pweight=tot_pop2000] 
	predict res_codtot_c1_i_rate, residuals

	collapse res_codtot_c1_i_rate [pweight=tot_pop2000] , by(timefromenact2 treat)

	*tsset timefromenact
	
	*tsfilter hp codtot_c1_i_rateHP = codtot_c1_i_rate, trend(codtot_c1_i_rateHPtrend) smooth(25)
	
	keep if inrange(timefromenact2,-8,4)
	
	twoway (connect res_codtot_c1_i_rate timefromenact2 if treat==1,  lc(black) lw(medthick) mc(black) ms(O)) ///
			(connect res_codtot_c1_i_rate timefromenact2 if treat==0, lc(gray) lp(dash) lw(medthick) mc(gray) ms(D)) ///
			, xline(0) ylabel(, grid) ytitle("residualized crime rate") ///
			xtitle("quarters to policy") legend(order(1 "policy" 2 "bordering"))
			
	graph export "$path/out/crime_rate_levels_eventstudy.pdf", replace
	
restore


/*
*do it for those with policy before 2014
preserve


	keep if  group==6085|group==6087|group==9003|group==11001 |group==17031 ///
			|group==35055 |group==42075 |group==44007 |group==55079  
	
	keep if inrange(year,2006,2016)
	
	reg codtot_c1_i_rate i.treat i.year i.quarter [pweight=tot_pop2000] 
	predict res_codtot_c1_i_rate, residuals

	collapse res_codtot_c1_i_rate [pweight=tot_pop2000], by(timefromenact2 treat)

	*tsset timefromenact
	
	*tsfilter hp codtot_c1_i_rateHP = codtot_c1_i_rate, trend(codtot_c1_i_rateHPtrend) smooth(25)
	
	keep if inrange(timefromenact2,-8,4)
	
	twoway (connect res_codtot_c1_i_rate timefromenact2 if treat==1) ///
			(connect res_codtot_c1_i_rate timefromenact2 if treat==0) ///
			, xline(0) ylabel(, grid)
restore

*/











