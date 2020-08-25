#delimit ;
clear;



***** How to interact with the NOAA Fishery Trade Data via the API and Stata;
***** In this example, we'll retrieve the default data by referencing the API root URL:
***** https://www.st.nmfs.noaa.gov/ords/foss/trade_data  ;;

**** we need to install two packages

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


** get all observations after 2010;
*https://www.st.nmfs.noaa.gov/ords/foss/trade_data/?q={"year":{"$gt": 2010}}
*https://www.st.nmfs.noaa.gov/ords/foss/trade_data/?q={"year":{"$gt":2010}}

*The %22 is Unicode for double quotation marks.  %24 is the unicode for $;
local url_root https://www.st.nmfs.noaa.gov/ords/foss/trade_data/ ;
local query_unicode ?q={%22year%22:{%22%24gt%22:2010}};
local limit_param limit=1000;
local request_big `url_root'`query_unicode'&`limit_param';

macro list;

* send your request to the url and let insheetjson covert from json to a Stata datas set;
insheetjson `invars'
	using "`request_big'",
	column("year" "month" "hts_number" "name" "cntry_code" "fao" "cntry_name" 
			"district_code" "district_name" "edible_code" "kilos" "val" 
			"source" "association" "rfmo" "nmfs_region_code") tableselector("items");

* take a look at the result;
describe;

* convert some of the string variables to numeric;
destring year month hts_number cntry_code fao district_code kilos val, replace;

