global divipola "/Users/camila/Dropbox/PhD/Second year/Summer paper/Data/divipola.dta"

use "Data/SB11_2011_2017_individual.dta", clear
	
	* Create control vars
		tab estu_genero, gen(stu_sex_)
		rename stu_sex_1 male
		rename stu_sex_2 female
		
		tab fami_estratovivienda, gen(strata_)
		
	* Parents education: high school complete or more
		gen	 	mother_educ = 1 if inlist(fami_educacionmadre, 0, 1, 2, 3)
		replace mother_educ = 0 if inlist(fami_educacionmadre, 4, 5, 6, 7, 8, 9)
		gen	 	father_educ = 1 if inlist(fami_educacionpadre, 0, 1, 2, 3)
		replace father_educ = 0 if inlist(fami_educacionpadre, 4, 5, 6, 7, 8, 9)
		
	* Check municipality code
		rename cole_cod_mcpio_ubicacion muni_code
		bys periodo cole_cod_dane_establecimiento: egen min = min(muni_code)
		bys periodo cole_cod_dane_establecimiento: egen max = max(muni_code)
		gen a = 1 if (max != min)
		br periodo cole_cod_dane_establecimiento muni_code if a == 1
		bys periodo cole_cod_dane_establecimiento: egen mode = mode(muni_code)	
		replace muni_code = mode if a == 1
		merge m:1 muni_code using "${divipola}", assert(2 3) keep(3) nogen
		
	/* Fix muni_code
		gen school_id = string(cole_cod_dane_establecimiento, "%16.0f") 
		gen mpio = substr(school_id, 2, 5)
		destring mpio, replace
	*/	
		
	* Collapse by the school
		collapse (mean) std_* score_* male female strata_* father_educ mother_educ (count) N = score_global (first) muni_code, by(periodo cole_cod_dane_establecimiento)
		rename cole_cod_dane_establecimiento school_code
		sort school_code periodo
		isid school_code periodo
		
	* Keep only relevant periods and we keep only first period
		drop if inlist(period, 20111, 20121, 20131, 20141, 20151, 20161, 20171)
		
	* Gen year 
		tostring(period), gen(year)
		replace year = substr(year,1,4)
		destring year, replace
		isid school_code year
		
		keep if year == 2012
		
		sum score_global, d
		gen above_median = 1 if score_global >= `r(p50)'
		replace above_median = 0 if score_global < `r(p50)'
		
		
save "Data/SB11_global.dta", replace
