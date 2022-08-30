* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file creates some initial descriptive statistics

 cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
*  ssc install blindschemes
 set scheme plotplainblind

global output "/Users/camila/Dropbox/PhD/Second year/Summer paper/output"

* Prepare merit test
	use "/Users/camila/Dropbox/Maestria/Tesis/Servidor/Saber 11/Datasets/concurso_docentes.dta", clear
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

* Count by teacher
	bys document_id: gen count = _n 
	tab count // 133,065 unique teachers
	
* Generate ever connected
	foreach var in connected_ty connected_tby connected_council connected_principal connected_directivo connected_teacher {
		bys document_id: egen ever_`var' = max(`var')
	}

* Count connected
	tab ever_connected_ty if count == 1, m
	tab ever_connected_council if count == 1, m
	tab ever_connected_directivo if count == 1, m
	tab ever_connected_teacher if count == 1, m

	/*
	tab ever_connected_ty if count == 1 & ever_connected_council== 0 & ever_connected_directivo== 0 & ever_connected_teacher==0,  m
	tab ever_connected_ty if count == 1 & ever_connected_council== 1 & ever_connected_directivo== 0 & ever_connected_teacher==0,  m
	tab ever_connected_ty if count == 1 & ever_connected_council== 0 & ever_connected_directivo== 1 & ever_connected_teacher==0,  m
	tab ever_connected_ty if count == 1 & ever_connected_council== 0 & ever_connected_directivo== 0 & ever_connected_teacher==1,  m
	tab ever_connected_ty if count == 1 & ever_connected_council== 1 & ever_connected_directivo== 0 & ever_connected_teacher==1,  m
	tab ever_connected_ty if count == 1 & ever_connected_council== 1 & ever_connected_directivo== 1 & ever_connected_teacher==0,  m
	tab ever_connected_ty if count == 1 & ever_connected_council== 0 & ever_connected_directivo== 1 & ever_connected_teacher==1,  m
	tab ever_connected_ty if count == 1 & ever_connected_council== 1 & ever_connected_directivo== 1 & ever_connected_teacher==1,  m
	
	
	tab ever_connected_council if count == 1 & ever_connected_ty== 0 & ever_connected_directivo== 0 & ever_connected_teacher==0,  m
	tab ever_connected_council if count == 1 & ever_connected_ty== 1 & ever_connected_directivo== 0 & ever_connected_teacher==0,  m
	tab ever_connected_council if count == 1 & ever_connected_ty== 0 & ever_connected_directivo== 1 & ever_connected_teacher==0,  m
	tab ever_connected_council if count == 1 & ever_connected_ty== 0 & ever_connected_directivo== 0 & ever_connected_teacher==1,  m
	tab ever_connected_council if count == 1 & ever_connected_ty== 1 & ever_connected_directivo== 0 & ever_connected_teacher==1,  m
	tab ever_connected_council if count == 1 & ever_connected_ty== 1 & ever_connected_directivo== 1 & ever_connected_teacher==0,  m
	tab ever_connected_council if count == 1 & ever_connected_ty== 0 & ever_connected_directivo== 1 & ever_connected_teacher==1,  m
	tab ever_connected_council if count == 1 & ever_connected_ty== 1 & ever_connected_directivo== 1 & ever_connected_teacher==1,  m
	
	
	tab ever_connected_directivo if count == 1 & ever_connected_ty == 0 & ever_connected_council== 0 & ever_connected_teacher==0,  m
	tab ever_connected_directivo if count == 1 & ever_connected_ty == 0 & ever_connected_council== 0 & ever_connected_teacher==1,  m
	
	
	tab ever_connected_teacher if count == 1 & ever_connected_ty == 0 & ever_connected_council== 0 & ever_connected_directivo==0,  m
	*/
	
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
	
	
* Merge merit test
	drop _merge
	merge m:1 document_id using `merit_test'
	drop if _merge==2
	
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
	lab var connected_ty "Connected (JF)"
	lab var connected_tby "Top Connected (JF)"
	lab var connected_council "Connected to Council Member"
	lab var connected_council2 "Connected to Council Member (no common last names)"
	lab var connected_council3 "Connected to Council Member (continuous var)"
	lab var connected_principal "Connected to Principal"
	lab var connected_principal2 "Connected to Principal (no common last names)"
	lab var connected_principal3 "Connected to Principal (continuous var)"
	lab var connected_directivo "Connected to Admin Staff in the School"
	lab var connected_directivo2 "Connected to Admin Staff in the School (no common last names)"
	lab var connected_directivo3 "Connected to Admin Staff in the School (continuous var)"
	lab var connected_teacher "Connected to Any Teacher in the School"
	lab var connected_teacher2 "Connected to Any Teacher in the School (no common last names)"
	lab var connected_teacher3 "Connected to Any Teacher in the School (continuous var)"
	
	
	egen double fe = group(school_code2)
	
* Balance table
	global DESCVARS female edad type_contract1 educ_level2_1 educ_level2_2 educ_level2_3 urban prom
	

foreach x in connected_ty connected_council connected_directivo connected_teacher {
	mata: mata clear

	* First test of differences
	local i = 1

	foreach var in $DESCVARS {
		reg `var' `x', r 
		outreg, keep(`x')  rtitle("`: var label `var''") stats(b) ///
			noautosumm store(row`i')  starlevels(10 5 1) starloc(1)
		outreg, replay(diff) append(row`i') ctitles("",Difference ) ///
			store(diff) note("")
		local ++i
	}
	outreg, replay(diff)	
	
	* Then Summary statistics
	local count: word count $DESCVARS
	mat sumstat = J(`count',6,.)

	local i = 1
	foreach var in $DESCVARS {
		quietly: summarize `var' if `x'==1
		mat sumstat[`i',1] = r(N)
		mat sumstat[`i',2] = r(mean)
		mat sumstat[`i',3] = r(sd)
		quietly: summarize `var' if `x'==0
		mat sumstat[`i',4] = r(N)
		mat sumstat[`i',5] = r(mean)
		mat sumstat[`i',6] = r(sd)
		local i = `i' + 1
	}
	frmttable, statmat(sumstat) store(sumstat) sfmt(gc,f,f,gc,f,f)	sdec(3)
	

	outreg using "${output}/descriptive_stats_`x'", ///
    replay(sumstat) merge(diff) tex nocenter note("") fragment plain replace ///
    ctitles("", "Connected", "", "", "Not Connected", "", "", "" \ "", N, Mean, Sd, N, Mean, Sd, Diff) ///
    multicol(1,2,3;1,5,3) 	
	
}	
	  	
	
	
	

	
	
	
	
	

	  