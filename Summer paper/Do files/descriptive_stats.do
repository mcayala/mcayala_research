* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file creates some initial descriptive statistics

cd "/Volumes/Camila/Dropbox/PhD/Second year/Summer paper"
set scheme plotplainblind

*---------------------------*
* Connected vs no connected *
*---------------------------*

* Open dataset
	use "Data/merge_JF_teachers_secundaria.dta"

* Create variables	
	tab educ_level, gen(educ_level_)
	tab type_contract, gen(type_contract)
	 
* Demean each variable by school
	global vars "female educ_level_1 educ_level_2 educ_level_3 educ_level_4 educ_level_5 urban"
	foreach var 
	bys school_code year: 
	
	
* For tomorrow merit test
* trained in teaching
	