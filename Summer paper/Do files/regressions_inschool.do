cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"

use "Data/complete_panel_teachers.dta", clear

* Merge variable by JF
	merge 1:1 document_id year using  "Data/complete_panel_teachers_withJF.dta", assert(3) nogen update

* Drop year = 2011
	drop if year == 2011

 * Completar variable Connected to public sector (JF)
	replace connected_ty = 0 if mi(connected_ty)
	
* Pegar base de datos con nuestra sample:
	merge 1:m document_id year using "Data/merge_JF_teachers_secundaria.dta", gen(merge) assert(1 3)
	
* Select relevant sample
	bys document_id: egen max = max(merge)
	keep if max == 3
	drop max
	
* Crear connected variables para el panel completo
  drop connected_council* connected_principal* connected_teacher* connected_directivo*
	
* Completar variables we need for later
	foreach var in apellido1 apellido2 popular_apellido1 popular_apellido2  prob_apellido1 prob_apellido2 muni_code school_code {
		bys document_id: egen mode = mode(`var')
		replace `var' = mode if mi(`var')
		drop mode
		mdesc `var'
	}
	
	foreach var in members_council {
		mdesc `var'
		bys muni_code year: egen mode = mode(`var')
		replace `var' = mode if mi(`var')
		drop mode
		mdesc `var'
	}
	
	foreach var in n_directivo n_principal n_teacher {
		mdesc `var'
		bys school_code year: egen mode = mode(`var')
		replace `var' = mode if mi(`var')
		drop mode
		mdesc `var'
	}
	
* Define always connected, never connected and switchers
	br document_id year connected_ty //connected_council  connected_directivo connected_teacher
	sort document_id year
	foreach var of varlist connected_ty  {  // 
		bys document_id (year): egen max_`var' = max(`var')
		bys document_id (year): egen min_`var' = min(`var')
		gen diff_`var' = (max_`var' != min_`var')
		gen always_`var' = (max_`var' == 1 & min_`var' == 1)
		gen never_`var' = (max_`var' == 0 & min_`var' == 0)
		gen switch_`var' = (diff_`var' == 1)
		tab  always_`var' never_`var' if switch_`var' == 0, m
		tab  always_`var' never_`var' if switch_`var' == 1, m
		drop diff_`var' max_`var' min_`var'
	}
 	
	
* Regressions
	global fe "year document_id"
	reghdfe in_teacher_data connected_ty if always_connected_ty == 0, absorb($fe) cluster(document_id)
	lab var connected_ty "Connected to Non-elected Bureaucrat"


foreach var of varlist connected_ty {
gen year_`var' = year if `var' == 1
		bys document_id: egen E_`var' = min(year_`var')
		*replace E_`var' = . if  E_`var' == 2012
		gen K_`var' = year - E_`var' 
		tab K_`var'
		gen D_`var' = K_`var'>=0 & E_`var' != .
	  
		forvalues l = 0/3 {
			gen L`l'event_`var' = (K_`var'==`l')
		}
		forvalues l = 1/3 {
			gen F`l'event_`var' = (K_`var'==-`l')
		} 
			
		replace L3event_`var' = 1 if K_`var' > 3 & !mi(K_`var')		
		replace F3event_`var' = 1 if K_`var' < -3 & !mi(K_`var')
	
	local title: variable label `var' 
	
	reghdfe in_teacher_data o.F1event_`var' F3event_`var' F2event_`var' L*event_`var' if E_`var' != 2012 & always_connected_ty == 0, a($fe) cluster(document_id)
	
	event_plot, stub_lag(L#event_`var') stub_lead(F#event_`var') plottype(scatter) ciplottype(rcap) ///
		together graph_opt(name(`var', replace) title("`title'", size(small)) ///
			xtitle("Years since connection", size(small)) ytitle("Average effect", size(small)) xlabel(-3(1)3)  ///
			xline(0, lcolor(gs8) lpattern(dash)) yline(0, lcolor(gs8)) graphregion(color(white)) bgcolor(white) ylabel(, angle(horizontal)) ///
			) ///
			lag_opt1(msymbol(Dh) color(navy)) lag_ci_opt1(color(navy)) 	
}	

		graph export "$output/entering_Teaching_career.png", replace 

	