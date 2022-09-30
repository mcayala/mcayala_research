* Project: Summer Paper
* Written by: Camila Ayala (mc.ayala94@gmail.com)
* Purpose: This do file creates some initial descriptive statistics

 cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"
*  ssc install blindschemes
 set scheme plotplainblind
/*ssc install geo2xy, replace     
ssc install palettes, replace        
ssc install colrspace, replace
ssc install spmap, replace
*/

global output "/Users/camila/Dropbox/PhD/Second year/Summer paper/output"

	
*---------------------------*
* Connected vs no connected *
*---------------------------*

* Prepare merit test
	use "/Users/camila/Dropbox/Maestria/Tesis/Servidor/Saber 11/Datasets/concurso_docentes.dta", clear
	rename num_doc document_id
	isid document_id
	keep document_id prom aprobo
	tempfile merit_test
	save	`merit_test'

* Open dataset
use "Data/merge_JF_teachers_secundaria.dta", clear

* Count by teacher
	bys document_id: gen count = _n 
	tab count // 133,065 unique teachers
	
* Numero de years en los que aparece
	bys document_id: gen n_years = _N
	
* Drop the ones I only observe once
	drop if n_years == 1	
	
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
	
* Merge merit test
	drop _merge
	merge m:1 document_id using `merit_test'
	drop if _merge==2
	
* Lab vars
	lab var female "Female"
	lab var age "Age"
	lab var prom "Merit exam test score"
	lab var temporary "Temporary contract"
	lab var score "Students test score"
	lab var years_exp "Years of experience"
	lab var new_estatuto "New regulation"
	lab var postgrad_degree "Postgrad degree"
	
	egen double fe = group(school_code2)
	
* Balance table
	global DESCVARS female age postgrad_degree temporary years_exp  score prom 

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
	  
	  

*--------------------------------------*
* Percentage of connected in each year *
*--------------------------------------*
	
* Open dataset
use "Data/merge_JF_teachers_secundaria.dta", clear

br document_id year connected_ty connected_council connected_directivo connected_teacher
sort document_id year 

* Numero de years en los que aparece
	bys document_id: gen n_years = _N
	
* Drop the ones I only observe once
	drop if n_years == 1
 
gen uno = 1

collapse (mean) connected_ty connected_council connected_directivo connected_teacher (sum) uno, by(year)

foreach var in connected_ty connected_council connected_directivo connected_teacher {
	replace `var' = `var'*100
}

	lab var connected_ty "Connected to Non-elected Bureaucrat"
	lab var connected_council "Connected to Council Member"
	lab var connected_directivo "Connected to Admin Staff in the School"
	lab var connected_teacher "Connected to Any Teacher in the School"

graph bar connected_ty connected_directivo connected_council  connected_teacher, over(year, label(labsize(vsmall))) blabel(total, format(%9.1f) size(vsmall)) legend(cols(2) order(1 "Connected to Non-elected Bureaucrat" 2 "Connected to Admin Staff in the School" 3 "Connected to Council Member" 4 "Connected to Any Teacher in the School") size(vsmall) position(6)) ytitle("Percentage of secondary teachers", size(small)) ylabel(,labsize(vsmall)) //note(Source: Ministry of National Education of Colombia and Riaño (2022), size(tiny))
graph export "$output/percent_connected_year.png", replace

graph close _all

*---------------------*
* Map by municipality * 
*---------------------*

cd "/Users/camila/Dropbox/PhD/Second year/Summer paper/Data"

	/*
	use "municipios_shp", clear

	// Make sure the coordinates are inside the (-180,180) bounds   

	replace _X = 180 if _X > 180 & _X!=.

	geo2xy _Y _X, proj(web_mercator) replace

	save "municipios_shp2.dta", replace
*/


use "merge_JF_teachers_secundaria.dta", clear

* Numero de years en los que aparece
	bys document_id: gen n_years = _N
	
* Drop the ones I only observe once
	drop if n_years == 1

mdesc muni_code

gen uno = 1

collapse (mean) connected_ty connected_council connected_directivo connected_teacher (sum) uno, by(muni_code)
	tempfile prop_muni
	save	`prop_muni'

*spshape2dta "/Users/camila/Dropbox/PhD/Second year/Summer paper/Data/col-administrative-divisions-shapefiles/col_admbnda_adm2_mgn_20200416",  replace saving(municipios)	

use "municipios.dta", clear

gen muni_code = substr(ADM2_PCODE, 3,.)
destring muni_code, replace
isid muni_code

merge 1:1 muni_code using `prop_muni'
drop if _merge == 2


format connected_ty connected_council connected_directivo connected_teacher %12.2fc
format connected_ty  %12.4fc
set scheme white_tableau


spmap connected_ty using "municipios_shp2", id(_ID) clnum(5) legstyle(2) title("Panel A: Connected to Non-elected Bureaucrat", size(4)) fcolor(Blues2) name(connected_ty, replace) 
spmap connected_council using "municipios_shp2", id(_ID)  clnum(5) legstyle(2) title("Panel B: Connected to Council Member", size(4)) fcolor(Blues2) name(connected_council, replace)
spmap connected_directivo using "municipios_shp2", id(_ID)  clnum(5) legstyle(2) title("Panel C: Connected to Admin Staff in the School", size(4)) fcolor(Blues2) name(connected_directivo, replace)
spmap connected_teacher using "municipios_shp2", id(_ID)  clnum(5) legstyle(2) title("Panel D: Connected to Any Teacher in the School", size(4)) fcolor(Blues2) name(connected_teacher, replace)

graph combine connected_ty connected_council, name(maps1, replace)
graph export "$output/maps1.png", replace


graph combine connected_directivo connected_teacher, name(maps2, replace)
graph export "$output/maps2.png", replace

graph close _all
