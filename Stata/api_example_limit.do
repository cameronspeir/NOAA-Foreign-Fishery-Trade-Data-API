#delimit ;
clear;
**** Don't forget that you need two packages

*ssc install insheetjson;
*ssc install libjson;


**** set up an empty data set with all of the variables we will import;
* define a local macro, called invars, with the variable names;
local invars year month hts_number name cntry_code fao cntry_name district_code 
			 district_name edible_code kilos val source association rfmo 
			 nmfs_region_code;

* loop through each varname and create an empty string variable; 			 
foreach l of local  invars{;
	gen str30 `l'="";
};

****************************************************************************
*** specify the number of observations to retrieve - use limit parameter ***;
*** build this url: https://www.st.nmfs.noaa.gov/ords/foss/trade_data/?limit=100;
local url_root https://www.st.nmfs.noaa.gov/ords/foss/trade_data/ ;
local limit_param ?limit=100;
local url_request `url_root'`limit_param';

macro list;



* send your request to the url and let insheetjson covert from json to a Stata datas set;
insheetjson `invars'
	using "`url_request'",
	column("year" "month" "hts_number" "name" "cntry_code" "fao" "cntry_name" 
			"district_code" "district_name" "edible_code" "kilos" "val" 
			"source" "association" "rfmo" "nmfs_region_code") tableselector("items");

* take a look at the result;
describe;

* convert some of the string variables to numeric;
destring year month hts_number cntry_code fao district_code kilos val, replace;

