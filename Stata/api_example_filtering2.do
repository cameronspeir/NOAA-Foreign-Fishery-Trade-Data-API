#delimit ;
clear;



***** More complicated queries to the NOAA Fishery Trade Data via the API and Stata;
***** ***** https://www.st.nmfs.noaa.gov/ords/foss/trade_data  ;;

**** Don't forget that you will need these two packages:
*ssc install insheetjson;
*ssc install libjson;

**** STEP 1: set up an empty data set with all of the variables we will import;
* define a local macro, called invars, with the variable names;
local invars year month hts_number name cntry_code fao cntry_name district_code 
			 district_name edible_code kilos val source association rfmo 
			 nmfs_region_code;

local quote_invars ;

* loop through each varname and create an empty string variable;
* Add the double quoted name to the quoted local macro. 	;		 
foreach l of local invars {;
	gen str60 `l'="";
	local quote_invars `" `quote_invars' "`l'" "' ;

};


**** 
**** Example - Salmon exports from Seattle in 2016
**** We need to filter on four variables:
****    “name” contains “SALMON” (case sensitive)
**** 	“source” is equal to “EXP”
****    “district_name” is equal to “SEATTLE, WA”
****    “year” is equal to 2016

**** STEP 2: build the url containing the details of your query;
*** THESE URL'S WORK (CUT AND PASTE AND STICKING DIRECTLY INTO INSHEET JSON), PASSING THEM TO insheetjson AS A MACRO DOES NOT WORK
** all Seattle SALMON exports;
** https://www.st.nmfs.noaa.gov/ords/foss/trade_data/?q={"year":2016, "name":{"$like":"%SALMON%"}, "source":"EXP", "district_name":"SEATTLE, WA"};
** https://www.st.nmfs.noaa.gov/ords/foss/trade_data/?q={%22year%22:2016, %22name%22:{%22%24like%22:%22%25SALMON%25%22}, %22source%22:%22EXP%22, %22district_name%22:%22SEATTLE, WA%22};
** https://www.st.nmfs.noaa.gov/ords/foss/trade_data/?q={%22year%22:2016,%22name%22:{%22%24like%22:%22%25SALMON%25%22},%22source%22:%22EXP%22,%22district_name%22:%22SEATTLE,%20WA%22}

local url_root https://www.st.nmfs.noaa.gov/ords/foss/trade_data/ ;
local query_SEA_SAMN
	?q={%22year%22:2016,%22name%22:{%22%24like%22:%22%25SALMON%25%22},%22source%22:%22EXP%22,%22district_name%22:%22SEATTLE,%20WA%22};
local request_SEA_SAMN `url_root'`query_SEA_SAMN';
local url_big https://www.st.nmfs.noaa.gov/ords/foss/trade_data/?q={%22year%22:2016,%22name%22:{%22%24like%22:%22%25SALMON%25%22},%22source%22:%22EXP%22,%22district_name%22:%22SEATTLE,%20WA%22}


macro list ;


**** STEP 3: send your request to the url and let insheetjson covert from json to a Stata data set;
/*
insheetjson `invars'
	using "https://www.st.nmfs.noaa.gov/ords/foss/trade_data/?q={%22year%22:2016,%22name%22:{%22%24like%22:%22%25SALMON%25%22},%22source%22:%22EXP%22,%22district_name%22:%22SEATTLE,%20WA%22}",
		column(`quote_invars') tableselector("items");

* take a look at the result;
describe;
*/

insheetjson `invars'
	using "`url_big'",
		column(`quote_invars') tableselector("items");

* take a look at the result;
describe;



insheetjson `invars'
	using "`request_SEA_SAMN'",
		column(`quote_invars') tableselector("items");
* take a look at the result;
describe;

* convert some of the string variables to numeric;
destring year month hts_number cntry_code fao district_code kilos val, replace;

