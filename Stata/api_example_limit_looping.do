#delimit ;
clear;
pause off;
**** Don't forget that you need two packages

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

* loop through each varname and create an empty string variable;
* Add the double quoted name to the quoted local macro. 	;		 
foreach l of local invars {;
	gen str60 `l'="";
	local quote_invars `" `quote_invars' "`l'" "' ;

};

/****************************************************************************
 Lets say that we want to extract all the Pollock Exports from Seattle, WA in Jan and Feb of 2016. 
 I chose this because there are 36 observations of data. 
 https://www.st.nmfs.noaa.gov/ords/foss/trade_data/?q={%22year%22:2016,%22month%22:{%22%24lte%22:2},%22source%22:%22EXP%22,%22district_name%22:%22SEATTLE,%20WA%22,%22name%22:{%22%24like%22:%22%25POLLOCK%25%22}}&limit=100 
****************************************************************************/

/****************************************************************************
We could extract all of this data by setting the limit parameter to something large, like 500;
But this is no fun, because you need to know how many observations are there are before actually programming the query
****************************************************************************/

local url_root https://www.st.nmfs.noaa.gov/ords/foss/trade_data;
local url_subset ?q={%22year%22:2016,%22month%22:{%22%24lte%22:2},%22source%22:%22EXP%22,%22district_name%22:%22SEATTLE,%20WA%22,%22name%22:{%22%24like%22:%22%25POLLOCK%25%22}};
local url_limit &limit=500;

local url_request `url_root'`url_subset'`url_limit';

mac list _url_request;

/* Our strategy is to make use of the "limit" and "offset" parameters and the r(hasMore) macro that is returned when we use the topscalars option*/

/*We want to do submit requests that look like this: This url contains gets the first 10 observations
*/

local url_root https://www.st.nmfs.noaa.gov/ords/foss/trade_data;
local url_subset ?q={%22year%22:2016,%22month%22:{%22%24lte%22:2},%22source%22:%22EXP%22,%22district_name%22:%22SEATTLE,%20WA%22,%22name%22:{%22%24like%22:%22%25POLLOCK%25%22}};
local url_limit &limit=10;
local url_offset &offset=0;
local url_request `url_root'`url_subset'`url_offset'`url_limit';
mac list _url_request;
pause;


/*This url gets the next 10 observations */
local url_offset &offset=10;
local url_request `url_root'`url_subset'`url_offset'`url_limit';
mac list _url_request;
pause;


/*This url gets the next 10 observations */
local url_offset &offset=20;
local url_request `url_root'`url_subset'`url_offset'`url_limit';
mac list _url_request;
pause;

/*This url gets the next 10 observations --although there aren't 10 observations, there are 6*/
local url_offset &offset=30;
local url_request `url_root'`url_subset'`url_offset'`url_limit';
mac list _url_request;



/* We will use r(hasMore) that is returned by the topscalars option.  When r(hasMore) is not true, the while loop will end*/


/* set chunk size and initialize offset*/
/* this is a toy example, so I set this to 25 so we can watch the loop work */
/*I'm not sure what is optimal to set here, but probably not 25. My guess is to set this much closer to the maximum of 10,000*/

local chunksize 25;
local url_limit &limit=`chunksize';

local more="true";
while "`more'"=="true"{;
qui count;
local nobs=r(N);
local url_offset &offset=`nobs';
local url_request `url_root'`url_subset'`url_offset'`url_limit';
mac list _url_request;
insheetjson `invars' using "`url_request'",	column(`quote_invars') tableselector("items") offset(`nobs') topscalars;
local more="`r(hasMore)'";
};
* take a look at the result;
describe;

* convert some of the string variables to numeric;
destring year month hts_number cntry_code fao district_code kilos val, replace;

compress;

