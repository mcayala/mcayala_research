use "Data/base_docentes_clean_2011_2017.dta", clear


* Complete panel 
br document_id year
isid document_id year school_code
duplicates drop document_id year, force

	rename school_code school_code2
	destring school_code2, gen(double school_code) 
	format school_code %16.0g
	drop school_code2
	
	
gen in_teacher_data = 1

keep in_teacher_data document_id school_code year

reshape wide in_teacher_data school_code, i(document_id) j(year)

reshape long in_teacher_data school_code, i(document_id) j(year)

replace in_teacher_data = 0 if mi(in_teacher_data)
