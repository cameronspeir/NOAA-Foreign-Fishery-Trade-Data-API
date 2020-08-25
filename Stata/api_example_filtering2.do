#delimit ;
clear;



***** More complicated queries to the NOAA Fishery Trade Data via the API and Stata;
***** ***** https://www.st.nmfs.noaa.gov/ords/foss/trade_data  ;;

**** Don't forget that you will need these two packages:
*ssc install insheetjson;
*ssc install libjson;

*******		Filtering the data and returning more rows of data 		******;
********************************************************************************;


**** 
**** Example - Salmon exports from Seattle in 2016
**** We need to filter on four variables:
****    “name” contains “SALMON” (case sensitive)
**** 	“source” is equal to “EXP”
****    “district_name” is equal to “SEATTLE, WA”
****    “year” is equal to 2016
**** We also want to return 100 rows of data, rather than the default of 25;





**** STEP 1: set up an empty data set with all of the variables we will import;
* define a local macro, called invars, with the variable names;
local invars year month hts_number name cntry_code fao cntry_name district_code 
			 district_name edible_code kilos val source association rfmo 
			 nmfs_region_code;

* loop through each varname and create an empty string variable; 			 
foreach l of local  invars{;
	gen str30 `l'="";
};

**** STEP 2: build the url containing the details of your query;
**** https://www.st.nmfs.noaa.gov/ords/foss/trade_data/?q={“name”:{“$like”:“%25SALMON%25”},“source”:“EXP”,“district_name”:“SEATTLE, WA”,“year”:“2016”} ;
*local query_url https://www.st.nmfs.noaa.gov/ords/foss/trade_data/;

local url_root https://www.st.nmfs.noaa.gov/ords/foss/trade_data/ ;

local query_unicode
	?q%3D{%22name%22:{%22%24like%22:%22%25SALMON%25%22},%22source%22:%22EXP%22,%22district_name%22:%22SEATTLE, WA%22,%22year%22:%222016%22};
local request_unicode `url_root'`query_unicode';

local url_root https://www.st.nmfs.noaa.gov/ords/foss/trade_data/ ;
local query_text ?q={"name":{"\$like":"%SALMON%"},"source":"EXP","district_name":"SEATTLE, WA","year":"2016"} ;
	
local request_text `url_root'?q={"name":{"\$like":"%25SALMON%25"},"source":"EXP","district_name":"SEATTLE, WA","year":"2016"} ;

macro list ;


**** STEP 3: send your request to the url and let insheetjson covert from json to a Stata data set;

insheetjson `invars'
	using "`request_unicode'",
	column("year" "month" "hts_number" "name" "cntry_code" "fao" "cntry_name" 
			"district_code" "district_name" "edible_code" "kilos" "val" 
			"source" "association" "rfmo" "nmfs_region_code") tableselector("items");

insheetjson `invars'
	using "`request_text'",
	column("year" "month" "hts_number" "name" "cntry_code" "fao" "cntry_name" 
			"district_code" "district_name" "edible_code" "kilos" "val" 
			"source" "association" "rfmo" "nmfs_region_code") tableselector("items");

* take a look at the result;
describe;

* convert some of the string variables to numeric;
destring year month hts_number cntry_code fao district_code kilos val, replace;

