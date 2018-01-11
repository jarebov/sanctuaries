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

	keep if  year_enactment2 <= 2016 // removing weird county
	
	keep if inrange(year,2006,2016)
	
	reg codtot_c1_i_rate_w i.treat i.time_quarter [pweight=tot_pop2000] 
	predict res_codtot_c1_i_rate, residuals

	collapse res_codtot_c1_i_rate [pweight=tot_pop2000] , by(timefromenact2 treat)


	keep if inrange(timefromenact2,-8,4)
	
	twoway (connect res_codtot_c1_i_rate timefromenact2 if treat==1,  lc(black) lw(medthick) mc(black) ms(O)) ///
			(connect res_codtot_c1_i_rate timefromenact2 if treat==0, lc(gray) lp(dash) lw(medthick) mc(gray) ms(D)) ///
			, xline(-0.5) ylabel(, grid) ytitle("residualized crime rate") ///
			xtitle("quarters to policy") legend(order(1 "policy" 2 "bordering"))
			
	graph export "$path/out/crime_rate_levels_eventstudy.pdf", replace
	
restore

** removing county FE
preserve

	keep if  year_enactment2 <= 2016 // removing weird county
	
	keep if inrange(year,2006,2016)
	
	areg codtot_c1_i_rate_w i.treat i.time_quarter [pweight=tot_pop2000] , a(fips)
	predict res_codtot_c1_i_rate, residuals

	collapse res_codtot_c1_i_rate [pweight=tot_pop2000] , by(timefromenact2 treat)


	keep if inrange(timefromenact2,-8,4)
	
	twoway (connect res_codtot_c1_i_rate timefromenact2 if treat==1,  lc(black) lw(medthick) mc(black) ms(O)) ///
			(connect res_codtot_c1_i_rate timefromenact2 if treat==0, lc(gray) lp(dash) lw(medthick) mc(gray) ms(D)) ///
			, xline(-0.5) ylabel(, grid) ytitle("residualized crime rate") ///
			xtitle("quarters to policy") legend(order(1 "policy" 2 "bordering"))
			
	graph export "$path/out/crime_rate_levels_eventstudy_countyFE.pdf", replace
	
restore

** removing pretrends
preserve

	keep if  year_enactment2 <= 2016 // removing weird county
	
	keep if inrange(year,2006,2016)
	
	reg codtot_c1_i_rate_w_dt i.treat i.time_quarter [pweight=tot_pop2000] 
	predict res_codtot_c1_i_rate, residuals

	collapse res_codtot_c1_i_rate [pweight=tot_pop2000] , by(timefromenact2 treat)

	keep if inrange(timefromenact2,-8,4)

	twoway (connect res_codtot_c1_i_rate timefromenact2 if treat==1,  lc(black) lw(medthick) mc(black) ms(O)) ///
			(connect res_codtot_c1_i_rate timefromenact2 if treat==0, lc(gray) lp(dash) lw(medthick) mc(gray) ms(D)) ///
			, xline(-0.5) ylabel(, grid) ytitle("residualized crime rate") ///
			xtitle("quarters to policy") legend(order(1 "policy" 2 "bordering"))
	
	graph export "$path/out/crime_rate_levels_eventstudy_nopretrends.pdf", replace
	
restore


** removing pretrends and county FE
preserve

	keep if  year_enactment2 <= 2014 // removing weird county
	
	keep if inrange(year,2006,2016)
	
	areg codtot_c1_i_rate_dt i.treat i.time_quarter [pweight=tot_pop2000] , a(fips)
	predict res_codtot_c1_i_rate, residuals

	collapse res_codtot_c1_i_rate [pweight=tot_pop2000] , by(timefromenact2 treat)


	keep if inrange(timefromenact2,-8,4)
	
	twoway (connect res_codtot_c1_i_rate timefromenact2 if treat==1,  lc(black) lw(medthick) mc(black) ms(O)) ///
			(connect res_codtot_c1_i_rate timefromenact2 if treat==0, lc(gray) lp(dash) lw(medthick) mc(gray) ms(D)) ///
			, xline(-0.5) ylabel(, grid) ytitle("residualized crime rate") ///
			xtitle("quarters to policy") legend(order(1 "policy" 2 "bordering"))
			
	graph export "$path/out/crime_rate_levels_eventstudy_nopretrends_countyFE.pdf", replace
	
restore



*do it for those with policy before 2015

preserve

	keep if  year_enactment2 <= 2014 // removing weird county
	
	keep if inrange(year,2006,2016)
	
	reg codtot_c1_i_rate i.treat i.time_quarter [pweight=tot_pop2000] 
	predict res_codtot_c1_i_rate, residuals

	collapse res_codtot_c1_i_rate [pweight=tot_pop2000] , by(timefromenact2 treat)


	keep if inrange(timefromenact2,-8,4)
	
	twoway (connect res_codtot_c1_i_rate timefromenact2 if treat==1,  lc(black) lw(medthick) mc(black) ms(O)) ///
			(connect res_codtot_c1_i_rate timefromenact2 if treat==0, lc(gray) lp(dash) lw(medthick) mc(gray) ms(D)) ///
			, xline(-0.5) ylabel(, grid) ytitle("residualized crime rate") ///
			xtitle("quarters to policy") legend(order(1 "policy" 2 "bordering"))
			
	graph export "$path/out/crime_rate_levels_eventstudy_pre2015.pdf", replace
	
restore

** removing county FE
preserve

	keep if  year_enactment2 <= 2014 // removing weird county
	
	keep if inrange(year,2006,2016)
	
	areg codtot_c1_i_rate i.treat i.time_quarter [pweight=tot_pop2000] , a(fips)
	predict res_codtot_c1_i_rate, residuals

	collapse res_codtot_c1_i_rate [pweight=tot_pop2000] , by(timefromenact2 treat)


	keep if inrange(timefromenact2,-8,4)
	
	twoway (connect res_codtot_c1_i_rate timefromenact2 if treat==1,  lc(black) lw(medthick) mc(black) ms(O)) ///
			(connect res_codtot_c1_i_rate timefromenact2 if treat==0, lc(gray) lp(dash) lw(medthick) mc(gray) ms(D)) ///
			, xline(-0.5) ylabel(, grid) ytitle("residualized crime rate") ///
			xtitle("quarters to policy") legend(order(1 "policy" 2 "bordering"))
			
	graph export "$path/out/crime_rate_levels_eventstudy_countyFE_pre2015.pdf", replace
	
restore

** removing pretrends
preserve

	keep if  year_enactment2 <= 2014 // removing weird county
	
	keep if inrange(year,2006,2016)
	
	reg codtot_c1_i_rate_dt i.treat i.time_quarter [pweight=tot_pop2000] 
	predict res_codtot_c1_i_rate, residuals

	collapse res_codtot_c1_i_rate [pweight=tot_pop2000] , by(timefromenact2 treat)

	keep if inrange(timefromenact2,-8,4)

	twoway (connect res_codtot_c1_i_rate timefromenact2 if treat==1,  lc(black) lw(medthick) mc(black) ms(O)) ///
			(connect res_codtot_c1_i_rate timefromenact2 if treat==0, lc(gray) lp(dash) lw(medthick) mc(gray) ms(D)) ///
			, xline(-0.5) ylabel(, grid) ytitle("residualized crime rate") ///
			xtitle("quarters to policy") legend(order(1 "policy" 2 "bordering"))
	
	graph export "$path/out/crime_rate_levels_eventstudy_nopretrends_pre2015.pdf", replace
	
restore


** removing pretrends and county FE
preserve

	keep if  year_enactment2 <= 2014 // removing weird county
	
	keep if inrange(year,2006,2016)
	
	areg codtot_c1_i_rate_dt i.treat i.time_quarter [pweight=tot_pop2000] , a(fips)
	predict res_codtot_c1_i_rate, residuals

	collapse res_codtot_c1_i_rate [pweight=tot_pop2000] , by(timefromenact2 treat)


	keep if inrange(timefromenact2,-8,4)
	
	twoway (connect res_codtot_c1_i_rate timefromenact2 if treat==1,  lc(black) lw(medthick) mc(black) ms(O)) ///
			(connect res_codtot_c1_i_rate timefromenact2 if treat==0, lc(gray) lp(dash) lw(medthick) mc(gray) ms(D)) ///
			, xline(-0.5) ylabel(, grid) ytitle("residualized crime rate") ///
			xtitle("quarters to policy") legend(order(1 "policy" 2 "bordering"))
			
	graph export "$path/out/crime_rate_levels_eventstudy_nopretrends_countyFE_pre2015.pdf", replace
	
restore



