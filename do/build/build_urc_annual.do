** Build an annual county panel dataset with URC crime data

************************************************************************
clear all
set more off

global user = 2 // 1 Jaime, 2 Barbara



if $user == 1{
global path = "/Users/JAIME/Dropbox/research"
}

if $user == 2{
global path = "~/Dropbox/Research"
}
************************************************************************

foreach y of numlist 1994/2002 2009/2014{ //need to compile from .txt files for 2003-2008


	*file numbers for each year (from ICPSR):
	if `y' == 1994{
		local d = "06669"
	}

	if `y' == 1995{
		local d = "06850"
	}

	if `y' == 1996{
		local d = "02389"
	}

	if `y' == 1997{
		local d = "02764"
	}

	if `y' == 1998{
		local d = "02910"
	}

	if `y' == 1999{
		local d = "03167"
	}

	if `y' == 2000{
		local d = "03451"
	}

	if `y' == 2001{
		local d = "03721"
	}

	if `y' == 2002{
		local d = "04009"
	}

	if `y' == 2009{
		local d = "30763"
	}

	if `y' == 2010{
		local d = "33523"
	}

	if `y' == 2011{
		local d = "34582"
	}

	if `y' == 2012{
		local d = "35019"
	}

	if `y' == 2013{
		local d = "36117"
	}

	if `y' == 2014{
		local d = "36399"
	}



	use "$path/sanctuaries/data/URC_FBI/annual_data_from_nacjd/`y'/DS0004/`d'-0004-Data.dta", clear

	*drop irrelevant variables
	capture drop CASEID // some years do not have this variable
	drop STUDYNO EDITION PART IDNO

	*generate unique county identifier combining state and county fips codes
	tostring FIPS_ST, gen(state)
	tostring FIPS_CTY, gen(county)
	drop FIPS_ST FIPS_CTY
	replace county = "0" + county if strlen(county)==2
	replace county = "00" + county if strlen(county)==1
	assert strlen(county)==3

	gen county_fips = state + county

	destring county_fips, replace


	foreach v in CPOPARST CPOPCRIM AG_ARRST AG_OFF COVIND INDEX MODINDX MURDER RAPE ROBBERY AGASSLT BURGLRY LARCENY MVTHEFT ARSON{
		capture rename `v' `=lower("`v'")' // INDEX and MODINDX not present in some years
	}

	gen year=`y'

	order year county_fips state county


	save "$path/sanctuaries/data/output_datasets/temp/urc_`y'.dta", replace

}





/*

if `y' == 2003{
	local d = "04360"
}

if `y' == 2004{
	local d = "04466"
}

if `y' == 2005{
	local d = "04717"
}

if `y' == 2006{
	local d = "06850"
}
