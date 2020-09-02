#delimit ;
clear;



***** How to interact with the NOAA Fishery Trade Data via the API and Stata;
***** In this example, we'll retrieve the default data by referencing the API root URL:
***** https://www.st.nmfs.noaa.gov/ords/foss/trade_data  ;;

**** we need to install two packages

*ssc install insheetjson;
*ssc install libjson;

**** set up an empty data set with names of the columns that we will import;
* define a local macro, called invars, with the column names;
local invars year month hts_number name cntry_code fao cntry_name district_code 
			 district_name edible_code kilos val source association rfmo 
			 nmfs_region_code;

* Define a local macro, called quote_invars, that contains nothing.;
* We will use this to contain the elements of invars, but wrapped in double quotations;

local quote_invars ;
mac list;

* loop through each varname and create an empty string variable;
* Add the double quoted name to the quoted local macro.; 			 
foreach l of local invars {;
di "`l'";
	gen str60 `l'="";
	local quote_invars `" `quote_invars' "`l'" "' ;

};



* send your request to the url and let insheetjson covert from json to a Stata datas set;
insheetjson `invars'
	using https://www.st.nmfs.noaa.gov/ords/foss/trade_data,
	column(`quote_invars') tableselector("items");

* take a look at the result;
describe;

* convert some of the string variables to numeric;
destring year month hts_number cntry_code fao district_code kilos val, replace;

compress;
