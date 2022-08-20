* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file cleans council data


* Set directory 
	cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
	
use "Data/Elecciones/2011/winners_2011.dta", clear
	
* Append winners elections 2015
	append using "Data/Elecciones/2015/winners_2015"
		
* gen number of council members per depto
	gen uno = 1
	bys muni_code year: egen members_council = sum(uno)
	drop uno
		
	preserve
		keep muni_code year members_council
		duplicates drop  muni_code year, force
		tempfile members_council
		save	`members_council'
	restore
	
* Reshape	
	bys muni_code year: gen count = _n
	reshape  long apellido, i(muni_code year count) j(no_apellido)
	
* Ñ and accents
	foreach var in apellido {
		replace `var' = upper(`var')
		replace `var' = subinstr(`var', "Ñ", "N",.)
		replace `var' = subinstr(`var', "Á", "A",.)
		replace `var' = subinstr(`var', "É", "E",.)
		replace `var' = subinstr(`var', "Í", "I",.)
		replace `var' = subinstr(`var', "Ó", "O",.)
		replace `var' = subinstr(`var', "Ú", "U",.)
		replace `var' = subinstr(`var', "Ü", "U",.)
		replace `var' = strtrim(`var')
	}	
		
* Drop duplicates in apellido
	drop if mi(apellido)
	
* Get 10 common last names
	preserve
		gen n_lastname = 1
		collapse (count) n_lastname, by(apellido)
		sort n_lastname
		gen popular = 1 if n_lastname>=300
		replace popular = 0 if mi(popular)
		tempfile common
		save	`common'
	restore
	
	gen n_apellido = 1
	collapse (sum) n_apellido, by(muni_code year apellido)
	sort muni_code year apellido
	isid muni_code year apellido
	merge m:1 apellido using `common', assert(3) nogen
	merge m:1 muni_code year using `members_council', assert(3) nogen
	
* Extend data for all years
	tab year
	replace year = 2012 if year == 2011
	expand 2 if year == 2012, gen(dupindicator)
	replace year = 2013 if dupindicator == 1
	drop dupindicator
	
	expand 2 if year == 2012, gen(dupindicator)
	replace year = 2014 if dupindicator == 1
	drop dupindicator

	expand 2 if year == 2012, gen(dupindicator)
	replace year = 2015 if dupindicator == 1
	drop dupindicator
	
* Extend data for all years
	expand 2 if year == 2016, gen(dupindicator)
	replace year = 2017 if dupindicator == 1
	drop dupindicator
	
	expand 2 if year == 2016, gen(dupindicator)
	replace year = 2018 if dupindicator == 1
	drop dupindicator

	expand 2 if year == 2016, gen(dupindicator)
	replace year = 2019 if dupindicator == 1
	drop dupindicator
	
	tab year
	drop if year >=2018
	
	preserve
		keep muni_code year members_council
		duplicates drop  muni_code year, force
		save "Data/members_council", replace
	restore
	
	keep muni_code apellido year n_apellido
	rename n_apellido n_apellido_council
	isid muni_code apellido year

* Save council data
 save "Data/council_data_2012to2019", replace
