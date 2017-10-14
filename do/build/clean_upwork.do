*********************************************************************************************************************************
*																																*
*						Sanctuaries																								*
*						name file: clean_upwork.do																				*
*						cleans data on policies obtained from upwork															*
*																																*
*********************************************************************************************************************************

clear all
set more off

cd "~/Dropbox/Research/sanctuaries/data"

import excel using "upwork/Map Scraping Project.xlsx", clear firstrow
rename *, lower

* adjustments
rename country county_name
replace county_name = trim(county_name)
replace state = trim(state)
replace county_name = subinstr(county_name,"City and County of ","",1)
replace county_name = subinstr(county_name," City and County","",1)
replace county_name = subinstr(county_name,"City and county of ","",1)
replace county_name = subinstr(county_name," City and county","",1)
replace county_name = subinstr(county_name,"County and city of ","",1)
replace county_name = subinstr(county_name," Correctional Facility","",1)
replace county_name = subinstr(county_name," Sheriff","",1)
replace county_name = subinstr(county_name," County","",1)
replace county_name = subinstr(county_name,"W. ","West ",1)
replace county_name = subinstr(county_name,"St. Francios","St. Francois",1)
replace county_name = subinstr(county_name,"St. lawrence","St. Lawrence",1)
replace county_name = subinstr(county_name,"St. Genevieve","Ste. Genevieve",1)
replace county_name = subinstr(county_name,"Susquehana","Susquehanna",1)
replace county_name = subinstr(county_name,"Bullit","Bullitt",1)
replace county_name = subinstr(county_name,"Carrol","Carroll",1)
replace county_name = subinstr(county_name,"Carrolll","Carroll",1)
replace county_name = subinstr(county_name,"Chavez","Chaves",1)
replace county_name = subinstr(county_name,"Chapaign","Champaign",1)
replace county_name = subinstr(county_name,"Coffee","Coffey",1) if state == "KS"
replace county_name = subinstr(county_name,"Commanche","Comanche",1)
replace county_name = subinstr(county_name,"Culpepper","Culpeper",1)
replace county_name = subinstr(county_name,"Cuyohoga","Cuyahoga",1)
replace county_name = subinstr(county_name,"De Kalb","DeKalb",1)
replace county_name = subinstr(county_name,"De Soto","DeSoto",1) if state == "MS"
replace county_name = subinstr(county_name,"Dewitt","DeWitt",1)
replace county_name = subinstr(county_name,"Del-Norte","Del Norte",1)
replace county_name = subinstr(county_name,"Dinwiddle","Dinwiddie",1)
replace county_name = subinstr(county_name,"Emmanuel","Emanuel",1)
replace county_name = subinstr(county_name,"Forrest","Forest",1) if state == "PA"
replace county_name = subinstr(county_name,"Freemont","Fremont",1)
replace county_name = subinstr(county_name,"Genesse","Genesee",1)
replace county_name = subinstr(county_name,"Gilcrist","Gilchrist",1)
replace county_name = subinstr(county_name,"Charlotesville| VA","Charlottesville",1)
replace county_name = subinstr(county_name,"Greenville","Greensville",1) if state == "VA"
replace county_name = subinstr(county_name,"Hentry","Henry",1)
replace county_name = subinstr(county_name,"Huntington","Huntingdon",1) if state == "PA"
replace county_name = subinstr(county_name,"Kennedy","Kenedy",1)
replace county_name = subinstr(county_name,"LaPaz","La Paz",1)
replace county_name = subinstr(county_name,"Lawerence","Lawrence",1)
replace county_name = subinstr(county_name,"McCullough","McCulloch",1)
replace county_name = subinstr(county_name,"Mckinley","McKinley",1)
replace county_name = subinstr(county_name,"Northhampton","Northampton",1)
replace county_name = subinstr(county_name,"Nuckols","Nuckolls",1)
replace county_name = subinstr(county_name,"Ostego","Otsego",1)
replace county_name = subinstr(county_name,"Peterburg","Petersburg",1)
replace county_name = subinstr(county_name,"Rensselear","Rensselaer",1)
replace county_name = subinstr(county_name,"Prince George","Prince George's",1) if state == "MD"
replace county_name = subinstr(county_name,"Lewis &amp; Clark","Lewis and Clark",1)
replace county_name = subinstr(county_name,"Saint Clair","St. Clair",1)
replace county_name = subinstr(county_name,"Saint Croix","St. Croix",1)
replace county_name = subinstr(county_name,"Schonarie","Schoharie",1)
replace county_name = subinstr(county_name,"Shannon (Oglala Lakota)","Shannon",1)
replace county_name = subinstr(county_name,"Southhampton","Southampton",1)
replace county_name = subinstr(county_name,"Suwanee","Suwannee",1)
replace county_name = subinstr(county_name,"Sweetgrass","Sweet Grass",1)
replace county_name = subinstr(county_name,"Vermillion","Vermilion",1) if state == "LA"
replace county_name = subinstr(county_name,"York-Poquoson","York",1) if state == "VA"
replace county_name = subinstr(county_name,"lafayette","Lafayette",1)
replace county_name = subinstr(county_name,"E. ","East ",1)
replace county_name = trim(county_name)
replace state = trim(state)

drop if state == "Saipan" | state == "PR" | state == "Guam"
gen is_city = county_name == "Carson City" | county_name == "Ohau"
gen is_state = county_name == "Alaska" | county_name == "Connecticut" | county_name == "District of Columbia" | county_name == "State of Rhode Island"

sort county state
merge m:m county state using "output_datasets/county_fips.dta"
*(note: non-merged ones are either cities or states)
order county_name fips, first
sort fips
save "output_datasets/upwork_policies.dta", replace
