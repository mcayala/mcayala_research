* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file creates some initial descriptive statistics

cd "/Volumes/Camila/Dropbox/PhD/Second year/Summer paper"
set scheme plotplainblind

global output "/Volumes/Camila/Dropbox/PhD/Second year/Summer paper/output"

* Prepare merit test
	use "/Volumes/Camila/Dropbox/Maestría/Tesis/Servidor/Saber 11/Datasets/concurso_docentes.dta", clear
	rename num_doc document_id
	isid document_id
	keep document_id prom aprobo
	tempfile merit_test
	save	`merit_test'


*---------------------------*
* Connected vs no connected *
*---------------------------*

* Open dataset
	use "Data/merge_JF_teachers_secundaria.dta", clear

	
* Merge merit test
	merge m:1 document_id using `merit_test', keep(1 3) 
	
* Education level
	tab educ_level
	gen 	educ_level2 = educ_level
	replace educ_level2 = 2 if educ_level == 3
	replace educ_level2 = 2 if educ_level == 4
	lab def educ_level2 0 "0: None" 1 "1: High school" 2 "2: More than high school (vocational, bachelor or posgraduate)"
	lab val educ_level2 educ_level2

* Create variables	
	tab educ_level2, gen(educ_level2_)
	tab type_contract, gen(type_contract)
	destring school_code, gen(double school_code2)
	format school_code2 %16.0g
	 
* Lab vars
	lab var female "Teacher is female"
	lab var edad "Teacher's age'"
	lab var educ_level2_1 "Educ level: None"
	lab var educ_level2_2 "Educ level: High school"
	lab var educ_level2_3 "Educ level: More than high school"
	lab var urban "Teaches in urban area"
	lab var type_contract1 "Type of contract: Temporary"
	lab var type_contract2 "Type of contract: Permanent"
	lab var prom "Merit exam test score"
	
	egen double fe = group(school_code2)
	
	* Stats
	iebaltab female edad type_contract1 type_contract2 educ_level2_1 educ_level2_2 educ_level2_3 urban prom, grpv(connected_ty) order(1 0) total rowvar  savetex(${output}/descriptive_stats_connectedvsnoconnected_noFE) replace
	
	iebaltab female edad type_contract1 type_contract2 educ_level2_1 educ_level2_2 educ_level2_3 urban prom if year == 2011, grpv(connected_ty) order(1 0) total rowvar  fixedeffect(fe)  savetex(${output}/descriptive_stats_connectedvsnoconnected_withFE) replace
	 
	 
	  
	  