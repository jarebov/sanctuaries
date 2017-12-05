*********************************************************************************************************************************
*																																*
*			Sanctuaries																											*
*			name file: offenses_by_hispanic.do																					*
*			diff-in-diff regressions, by quartile of hispanic pop - total crime										 			*
*																																*
*********************************************************************************************************************************


clear all
set more off
set matsize 11000

global user = 2 // 1 Jaime, 2 Barbara

if $user == 1{
cd "/Users/JAIME/Dropbox/research/sanctuaries/data/output_datasets"
global out = "/Users/JAIME/Dropbox/research/sanctuaries/out"
global tab = "/Users/JAIME/Dropbox/research/sanctuaries/sanctuaries_git/tex/tables"
}

if $user == 2{
cd "~/Dropbox/Research/sanctuaries/data/output_datasets"
global out = "~/Dropbox/Research/sanctuaries/out"
global tab = "~/Dropbox/Research/sanctuaries/sanctuaries_git/tex/tables"
}

clear all
set more off


use offense_panel_group.dta, clear
sort fips year
merge m:1 fips year using covariates.dta
drop if _m == 2
drop _m

** generate useful variables 
gen hisp_share = hisp_pop / tot_pop
gen black_share = black_pop / tot_pop
global covar = "black_share hisp_share mig_inflow medianho urate"
bysort fips (year): carryforward $covar, replace // fill in missings by just doing carryfw
gsort fips -year
bysort fips: carryforward $covar, replace // fill in missings by just doing carryfw
bysort fips (year): gen black_share2010 = black_share[1] //baseline black share (year 2010)
bysort fips (year): gen hisp_share2010 = hisp_share[1] //baseline hispanic share (year 2010)
bysort fips (year): gen mig_inflow2005 = mig_inflow[1] //baseline migration (year 2005)
bysort fips (year): gen dem2008 = dem_vote_frac[9] //baseline migration (year 2005)


egen group_year = group(group year)
gen treat_post = treat == 1 & post == 1
qui sum hisp_share2010, det
gen hisp_q4 = hisp_share2010 > r(p75)
gen hisp_q3 = hisp_share2010 <= r(p75) & hisp_share2010 > r(p50)
gen hisp_q2 = hisp_share2010 <= r(p50) & hisp_share2010 > r(p25)
gen hisp_q1 = hisp_share2010 <= r(p25)
gen treat_post_hisp1 = treat_post * hisp_q1
gen treat_post_hisp2 = treat_post * hisp_q2
gen treat_post_hisp3 = treat_post * hisp_q3
gen treat_post_hisp4 = treat_post * hisp_q4
gen county = 0
gen trend = 0
gen Gr = 0

keep if year >= 2006 & year_enactment2 <= 2016


global covar2 = "c.black_share2010#i.year c.hisp_share2010#i.year c.mig_inflow2005#i.year medianho urate"


gen Timeframe = 1 if timefromenact2 >= -8 & timefromenact2 <= 4
bysort group time_quarter: egen timeframe = max(Timeframe)
drop Timeframe

** Labels
label variable treat_post 		"no-detainer $\times$ post"
label variable treat_post_hisp1 "no-detainer $\times$ post $\times$ q1"
label variable treat_post_hisp2 "no-detainer $\times$ post $\times$ q2"
label variable treat_post_hisp3 "no-detainer $\times$ post $\times$ q3"
label variable treat_post_hisp4 "no-detainer $\times$ post $\times$ q4"

**********************		Regressions - groups of treated and control 		***************************

* Table 3: simple DD, county FE, county FE with pre-trends, with and without covariates - by quartile of hisp pop 
eststo t1: qui areg lcodtot_c1_i_rate_w treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4 i.time_quarter  county if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post_hisp1]
disp _b[treat_post_hisp1]/_se[treat_post_hisp1]
disp _b[treat_post_hisp2]
disp _b[treat_post_hisp2]/_se[treat_post_hisp2]
disp _b[treat_post_hisp3]
disp _b[treat_post_hisp3]/_se[treat_post_hisp3]
disp _b[treat_post_hisp4]
disp _b[treat_post_hisp4]/_se[treat_post_hisp4]
disp e(N)

eststo t2: qui areg lcodtot_c1_i_rate_w treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4 i.time_quarter  $covar2 county if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post_hisp1]
disp _b[treat_post_hisp1]/_se[treat_post_hisp1]
disp _b[treat_post_hisp2]
disp _b[treat_post_hisp2]/_se[treat_post_hisp2]
disp _b[treat_post_hisp3]
disp _b[treat_post_hisp3]/_se[treat_post_hisp3]
disp _b[treat_post_hisp4]
disp _b[treat_post_hisp4]/_se[treat_post_hisp4]
disp e(N)

eststo t3: qui areg lcodtot_c1_i_rate_w_dt treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4 i.time_quarter  county trend if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post_hisp1]
disp _b[treat_post_hisp1]/_se[treat_post_hisp1]
disp _b[treat_post_hisp2]
disp _b[treat_post_hisp2]/_se[treat_post_hisp2]
disp _b[treat_post_hisp3]
disp _b[treat_post_hisp3]/_se[treat_post_hisp3]
disp _b[treat_post_hisp4]
disp _b[treat_post_hisp4]/_se[treat_post_hisp4]
disp e(N)

eststo t4: qui areg lcodtot_c1_i_rate_w_dt treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4 i.time_quarter  $covar2 county trend if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post_hisp1]
disp _b[treat_post_hisp1]/_se[treat_post_hisp1]
disp _b[treat_post_hisp2]
disp _b[treat_post_hisp2]/_se[treat_post_hisp2]
disp _b[treat_post_hisp3]
disp _b[treat_post_hisp3]/_se[treat_post_hisp3]
disp _b[treat_post_hisp4]
disp _b[treat_post_hisp4]/_se[treat_post_hisp4]
disp e(N)

preserve
label variable treat_post_hisp1 "1st quartile"
label variable treat_post_hisp2 "2nd quartile"
label variable treat_post_hisp3 "3rd quartile"
label variable treat_post_hisp4 "4th quartile"
coefplot (t1, lcolor(black) mcolor(black)  ciopts(lcolor(black) recast(rcap))) ///
		, keep(treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4)  levels(90) ///
			omitted xline(0, lcolor(black) lpattern(dot)) ytitle("share hispanic (quartile)") xtitle("effect of no-detainer on total crime")
graph export "$out/logcrime_dd_byhisp1.png", replace
restore

preserve
label variable treat_post_hisp1 "1st quartile"
label variable treat_post_hisp2 "2nd quartile"
label variable treat_post_hisp3 "3rd quartile"
label variable treat_post_hisp4 "4th quartile"
coefplot (t1, label("baseline") lcolor(black) mcolor(black)  ciopts(lcolor(black) recast(rcap))) ///
		 (t2, label("controls") lcolor(gs8) mcolor(gs8) msymbol(square)  ciopts(lcolor(gs8) recast(rcap))) ///
		 , keep(treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4)  levels(90) ///
			omitted xline(0, lcolor(black) lpattern(dot)) ytitle("share hispanic (quartile)") xtitle("effect of no-detainer on total crime")
graph export "$out/logcrime_dd_byhisp2.png", replace
restore

preserve
label variable treat_post_hisp1 "1st quartile"
label variable treat_post_hisp2 "2nd quartile"
label variable treat_post_hisp3 "3rd quartile"
label variable treat_post_hisp4 "4th quartile"
coefplot (t1, label("baseline") lcolor(black) mcolor(black)  ciopts(lcolor(black) recast(rcap))) ///
		 (t2, label("controls") lcolor(gs8) mcolor(gs8) msymbol(square)  ciopts(lcolor(gs8) recast(rcap))) ///
		 (t4, label("controls + pre-trends") lcolor(gs12) mcolor(gs12) msymbol(diamond)  ciopts(lcolor(gs12) recast(rcap))) ///
		 , keep(treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4)  levels(90) ///
			omitted xline(0, lcolor(black) lpattern(dot)) ytitle("share hispanic (quartile)") xtitle("effect of no-detainer on total crime") legend(rows(1))
graph export "$out/logcrime_dd_byhisp3.png", replace
restore

esttab	t1 t2 t3 t4 using "$tab/logcrime_byhisp_dd1.tex"	///
		, b(4) se(4) unstack nonote label replace se keep(treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4) indicate("County FE = *county*" "Time FE = *year*" "Controls = urate" "Trends = trend") ///
		nomti obslast star(* 0.10 ** 0.05 *** 0.01) width(0.7\textwidth)

	

* Violent
eststo t1: qui areg lcodviolent_c1_i_rate_w treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4 i.time_quarter  county if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post_hisp1]
disp _b[treat_post_hisp1]/_se[treat_post_hisp1]
disp _b[treat_post_hisp2]
disp _b[treat_post_hisp2]/_se[treat_post_hisp2]
disp _b[treat_post_hisp3]
disp _b[treat_post_hisp3]/_se[treat_post_hisp3]
disp _b[treat_post_hisp4]
disp _b[treat_post_hisp4]/_se[treat_post_hisp4]
disp e(N)

eststo t2: qui areg lcodviolent_c1_i_rate_w treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4 i.time_quarter  $covar2 county if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post_hisp1]
disp _b[treat_post_hisp1]/_se[treat_post_hisp1]
disp _b[treat_post_hisp2]
disp _b[treat_post_hisp2]/_se[treat_post_hisp2]
disp _b[treat_post_hisp3]
disp _b[treat_post_hisp3]/_se[treat_post_hisp3]
disp _b[treat_post_hisp4]
disp _b[treat_post_hisp4]/_se[treat_post_hisp4]
disp e(N)

eststo t3: qui areg lcodviolent_c1_i_rate_w_dt treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4 i.time_quarter  county trend if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post_hisp1]
disp _b[treat_post_hisp1]/_se[treat_post_hisp1]
disp _b[treat_post_hisp2]
disp _b[treat_post_hisp2]/_se[treat_post_hisp2]
disp _b[treat_post_hisp3]
disp _b[treat_post_hisp3]/_se[treat_post_hisp3]
disp _b[treat_post_hisp4]
disp _b[treat_post_hisp4]/_se[treat_post_hisp4]
disp e(N)

eststo t4: qui areg lcodviolent_c1_i_rate_w_dt treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4 i.time_quarter  $covar2 county trend if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post_hisp1]
disp _b[treat_post_hisp1]/_se[treat_post_hisp1]
disp _b[treat_post_hisp2]
disp _b[treat_post_hisp2]/_se[treat_post_hisp2]
disp _b[treat_post_hisp3]
disp _b[treat_post_hisp3]/_se[treat_post_hisp3]
disp _b[treat_post_hisp4]
disp _b[treat_post_hisp4]/_se[treat_post_hisp4]
disp e(N)

preserve
label variable treat_post_hisp1 "1st quartile"
label variable treat_post_hisp2 "2nd quartile"
label variable treat_post_hisp3 "3rd quartile"
label variable treat_post_hisp4 "4th quartile"
coefplot (t1, lcolor(black) mcolor(black)  ciopts(lcolor(black) recast(rcap))) ///
		, keep(treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4)  levels(90) ///
			omitted xline(0, lcolor(black) lpattern(dot)) ytitle("share hispanic (quartile)") xtitle("effect of no-detainer on violent crime")
graph export "$out/logviolent_dd_byhisp1.png", replace
restore

preserve
label variable treat_post_hisp1 "1st quartile"
label variable treat_post_hisp2 "2nd quartile"
label variable treat_post_hisp3 "3rd quartile"
label variable treat_post_hisp4 "4th quartile"
coefplot (t1, label("baseline") lcolor(black) mcolor(black)  ciopts(lcolor(black) recast(rcap))) ///
		 (t2, label("controls") lcolor(gs8) mcolor(gs8) msymbol(square)  ciopts(lcolor(gs8) recast(rcap))) ///
		 , keep(treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4)  levels(90) ///
			omitted xline(0, lcolor(black) lpattern(dot)) ytitle("share hispanic (quartile)") xtitle("effect of no-detainer on violent crime")
graph export "$out/logviolent_dd_byhisp2.png", replace
restore

preserve
label variable treat_post_hisp1 "1st quartile"
label variable treat_post_hisp2 "2nd quartile"
label variable treat_post_hisp3 "3rd quartile"
label variable treat_post_hisp4 "4th quartile"
coefplot (t1, label("baseline") lcolor(black) mcolor(black)  ciopts(lcolor(black) recast(rcap))) ///
		 (t2, label("controls") lcolor(gs8) mcolor(gs8) msymbol(square)  ciopts(lcolor(gs8) recast(rcap))) ///
		 (t4, label("controls + pre-trends") lcolor(gs12) mcolor(gs12) msymbol(diamond)  ciopts(lcolor(gs12) recast(rcap))) ///
		 , keep(treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4)  levels(90) ///
			omitted xline(0, lcolor(black) lpattern(dot)) ytitle("share hispanic (quartile)") xtitle("effect of no-detainer on violent crime") legend(rows(1))
graph export "$out/logviolent_dd_byhisp3.png", replace
restore

esttab	t1 t2 t3 t4 using "$tab/logviolent_byhisp_dd1.tex"	///
		, b(4) se(4) unstack nonote label replace se keep(treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4) indicate("County FE = *county*" "Time FE = *year*" "Controls = urate" "Trends = trend") ///
		nomti obslast star(* 0.10 ** 0.05 *** 0.01) width(0.7\textwidth)

	
* Property
eststo t1: qui areg lcodnonviolent_c1_i_rate_w treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4 i.time_quarter  county if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post_hisp1]
disp _b[treat_post_hisp1]/_se[treat_post_hisp1]
disp _b[treat_post_hisp2]
disp _b[treat_post_hisp2]/_se[treat_post_hisp2]
disp _b[treat_post_hisp3]
disp _b[treat_post_hisp3]/_se[treat_post_hisp3]
disp _b[treat_post_hisp4]
disp _b[treat_post_hisp4]/_se[treat_post_hisp4]
disp e(N)

eststo t2: qui areg lcodnonviolent_c1_i_rate_w treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4 i.time_quarter  $covar2 county if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post_hisp1]
disp _b[treat_post_hisp1]/_se[treat_post_hisp1]
disp _b[treat_post_hisp2]
disp _b[treat_post_hisp2]/_se[treat_post_hisp2]
disp _b[treat_post_hisp3]
disp _b[treat_post_hisp3]/_se[treat_post_hisp3]
disp _b[treat_post_hisp4]
disp _b[treat_post_hisp4]/_se[treat_post_hisp4]
disp e(N)

eststo t3: qui areg lcodnonviolent_c1_i_rate_w_dt treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4 i.time_quarter  county trend if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post_hisp1]
disp _b[treat_post_hisp1]/_se[treat_post_hisp1]
disp _b[treat_post_hisp2]
disp _b[treat_post_hisp2]/_se[treat_post_hisp2]
disp _b[treat_post_hisp3]
disp _b[treat_post_hisp3]/_se[treat_post_hisp3]
disp _b[treat_post_hisp4]
disp _b[treat_post_hisp4]/_se[treat_post_hisp4]
disp e(N)

eststo t4: qui areg lcodnonviolent_c1_i_rate_w_dt treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4 i.time_quarter  $covar2 county trend if timeframe == 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post_hisp1]
disp _b[treat_post_hisp1]/_se[treat_post_hisp1]
disp _b[treat_post_hisp2]
disp _b[treat_post_hisp2]/_se[treat_post_hisp2]
disp _b[treat_post_hisp3]
disp _b[treat_post_hisp3]/_se[treat_post_hisp3]
disp _b[treat_post_hisp4]
disp _b[treat_post_hisp4]/_se[treat_post_hisp4]
disp e(N)

preserve
label variable treat_post_hisp1 "1st quartile"
label variable treat_post_hisp2 "2nd quartile"
label variable treat_post_hisp3 "3rd quartile"
label variable treat_post_hisp4 "4th quartile"
coefplot (t1, lcolor(black) mcolor(black)  ciopts(lcolor(black) recast(rcap))) ///
		, keep(treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4)  levels(90) ///
			omitted xline(0, lcolor(black) lpattern(dot)) ytitle("share hispanic (quartile)") xtitle("effect of no-detainer on property crime")
graph export "$out/logproperty_dd_byhisp1.png", replace
restore

preserve
label variable treat_post_hisp1 "1st quartile"
label variable treat_post_hisp2 "2nd quartile"
label variable treat_post_hisp3 "3rd quartile"
label variable treat_post_hisp4 "4th quartile"
coefplot (t1, label("baseline") lcolor(black) mcolor(black)  ciopts(lcolor(black) recast(rcap))) ///
		 (t2, label("controls") lcolor(gs8) mcolor(gs8) msymbol(square)  ciopts(lcolor(gs8) recast(rcap))) ///
		 , keep(treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4)  levels(90) ///
			omitted xline(0, lcolor(black) lpattern(dot)) ytitle("share hispanic (quartile)") xtitle("effect of no-detainer on property crime")
graph export "$out/logproperty_dd_byhisp2.png", replace
restore

preserve
label variable treat_post_hisp1 "1st quartile"
label variable treat_post_hisp2 "2nd quartile"
label variable treat_post_hisp3 "3rd quartile"
label variable treat_post_hisp4 "4th quartile"
coefplot (t1, label("baseline") lcolor(black) mcolor(black)  ciopts(lcolor(black) recast(rcap))) ///
		 (t2, label("controls") lcolor(gs8) mcolor(gs8) msymbol(square)  ciopts(lcolor(gs8) recast(rcap))) ///
		 (t4, label("controls + pre-trends") lcolor(gs12) mcolor(gs12) msymbol(diamond)  ciopts(lcolor(gs12) recast(rcap))) ///
		 , keep(treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4)  levels(90) ///
			omitted xline(0, lcolor(black) lpattern(dot)) ytitle("share hispanic (quartile)") xtitle("effect of no-detainer on property crime") legend(rows(1))
graph export "$out/logproperty_dd_byhisp3.png", replace
restore

esttab	t1 t2 t3 t4 using "$tab/logproperty_byhisp_dd1.tex"	///
		, b(4) se(4) unstack nonote label replace se keep(treat_post_hisp1 treat_post_hisp2 treat_post_hisp3 treat_post_hisp4) indicate("County FE = *county*" "Time FE = *year*" "Controls = urate" "Trends = trend") ///
		nomti obslast star(* 0.10 ** 0.05 *** 0.01) width(0.7\textwidth)

	
