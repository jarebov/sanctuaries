*********************************************************************************************************************************
*																																*
*			Sanctuaries																											*
*			name file: offenses.do																								*
*			diff-in-diff regressions, total crime - various specifications											 			*
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


egen group_year = group(group time_quarter)
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
gen cleared = codtot_c2_i_rate_w/codtot_c1_i_rate_w
gen cleared_v = codviolent_c2_i_rate_w/codviolent_c1_i_rate_w
gen cleared_p = codnonviolent_c2_i_rate_w/codnonviolent_c1_i_rate_w

keep if year >= 2006 & year_enactment2 <= 2016


global covar2 = "c.black_share2010#i.time_quarter c.hisp_share2010#i.time_quarter c.mig_inflow2005#i.time_quarter medianho urate"


gen Timeframe = 1 if timefromenact2 >= -8 & timefromenact2 <= 4
bysort group time_quarter: egen timeframe = max(Timeframe)
drop Timeframe

** Labels
label variable treat_post "no-detainer $\times$ post"
label variable treat_post_hisp1 "no-detainer $\times$ post $\times$ q1"
label variable treat_post_hisp2 "no-detainer $\times$ post $\times$ q2"
label variable treat_post_hisp3 "no-detainer $\times$ post $\times$ q3"
label variable treat_post_hisp4 "no-detainer $\times$ post $\times$ q4"

********************************************		Regressions 	******************************************************

* Total crime
eststo t1: qui areg cleared treat_post i.time_quarter county if timeframe == 1 & cleared < 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
qui sum cleared if e(sample)
estadd scalar Ymean = r(mean)

eststo t2: qui areg cleared treat_post i.time_quarter $covar2 county if timeframe == 1 & cleared < 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
qui sum cleared if e(sample)
estadd scalar Ymean = r(mean)

eststo t3: qui areg cleared treat_post i.time_quarter i.fips county Gr if timeframe == 1  & cleared < 1 [aw = tot_pop2000], a(group_year) cluster(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
qui sum cleared if e(sample)
estadd scalar Ymean = r(mean)

eststo t4: qui areg cleared treat_post i.time_quarter i.fips county $covar2 Gr if timeframe == 1 & cleared < 1 [aw = tot_pop2000], a(group_year) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
qui sum cleared if e(sample)
estadd scalar Ymean = r(mean)

esttab	t1 t2 t3 t4 using "$tab/logcrime_cleared_dd.tex"	///
		, b(4) se(4) unstack nonote label replace se keep(treat_post) indicate("County FE = *county*" "Group-by-time FE = *Gr*" "Time FE = *time*" "Controls = urate") ///
		nomti obslast star(* 0.10 ** 0.05 *** 0.01)  stats(Ymean)


* Violent crime
eststo t1: qui areg cleared_v treat_post i.time_quarter county if timeframe == 1 & cleared_v < 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
qui sum cleared_v if e(sample)
estadd scalar Ymean = r(mean)

eststo t2: qui areg cleared_v treat_post i.time_quarter $covar2 county if timeframe == 1 & cleared_v < 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
qui sum cleared_v if e(sample)
estadd scalar Ymean = r(mean)

eststo t3: qui areg cleared_v treat_post i.time_quarter i.fips county Gr if timeframe == 1  & cleared_v < 1 [aw = tot_pop2000], a(group_year) cluster(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
qui sum cleared_v if e(sample)
estadd scalar Ymean = r(mean)

eststo t4: qui areg cleared_v treat_post i.time_quarter i.fips county $covar2 Gr if timeframe == 1 & cleared_v < 1 [aw = tot_pop2000], a(group_year) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
qui sum cleared_v if e(sample)
estadd scalar Ymean = r(mean)

esttab	t1 t2 t3 t4 using "$tab/logviolent_cleared_dd.tex"	///
		, b(4) se(4) unstack nonote label replace se keep(treat_post) indicate("County FE = *county*" "Group-by-time FE = *Gr*" "Time FE = *time*" "Controls = urate") ///
		nomti obslast star(* 0.10 ** 0.05 *** 0.01)  stats(Ymean)



* Property crime
eststo t1: qui areg cleared_p treat_post i.time_quarter county if timeframe == 1 & cleared_p < 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
qui sum cleared_p if e(sample)
estadd scalar Ymean = r(mean)

eststo t2: qui areg cleared_p treat_post i.time_quarter $covar2 county if timeframe == 1 & cleared_p < 1 [aw = tot_pop2000], a(fips) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
qui sum cleared_p if e(sample)
estadd scalar Ymean = r(mean)

eststo t3: qui areg cleared_p treat_post i.time_quarter i.fips county Gr if timeframe == 1  & cleared_p < 1 [aw = tot_pop2000], a(group_year) cluster(group_year)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
qui sum cleared_p if e(sample)
estadd scalar Ymean = r(mean)

eststo t4: qui areg cleared_p treat_post i.time_quarter i.fips county $covar2 Gr if timeframe == 1 & cleared_p < 1 [aw = tot_pop2000], a(group_year) cluster(fips)
disp _b[treat_post]
disp _b[treat_post]/_se[treat_post]
qui sum cleared_p if e(sample)
estadd scalar Ymean = r(mean)

esttab	t1 t2 t3 t4 using "$tab/lognonviolent_cleared_dd.tex"	///
		, b(4) se(4) unstack nonote label replace se keep(treat_post) indicate("County FE = *county*" "Group-by-time FE = *Gr*" "Time FE = *time*" "Controls = urate") ///
		nomti obslast star(* 0.10 ** 0.05 *** 0.01)  stats(Ymean)

