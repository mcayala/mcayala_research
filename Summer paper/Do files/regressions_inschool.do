cd "/Users/camila/Dropbox/PhD/Second year/Summer paper"

use "Data/complete_panel_teachers.dta", clear

* Merge variable by JF
	merge 1:1 document_id year using  "Data/complete_panel_teachers_withJF.dta", gen(merge1) assert(1 3) update
	drop merge1

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
	
	
*--------------------------*
* Merge council last names *
*--------------------------*
	
* Merge number of council members
	drop _merge
	merge m:1 year muni_code using "Data/members_council"
	drop if _merge == 2
	drop _merge
	/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                         6,852
        from master                     6,834  (_merge==1)
        from using                         18  (_merge==2)

    Matched                           791,640  (_merge==3)
    -----------------------------------------
	*/
	
* Merge council names with apellido1
	rename apellido1 apellido
	merge m:1 year muni_code apellido using "Data/council_data_2012to2019"
	
	/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                       755,247
        from master                   666,124  (_merge==1)
        from using                     89,123  (_merge==2)

    Matched                           132,350  (_merge==3)
    -----------------------------------------
	*/
	
* Create connected variable
	drop if _merge == 2
	gen 	connected_council_ap1 = .
	replace connected_council_ap1 = 1 if _merge == 3
	replace connected_council_ap1 = 0 if _merge == 1
	drop _merge 
	rename apellido apellido1
	rename n_apellido_council n_council_ap1

* Merge council names with apellido2
	rename apellido2 apellido
	merge m:1 year muni_code apellido using "Data/council_data_2012to2019"
	drop if _merge == 2
	gen 	connected_council_ap2 = .
	replace connected_council_ap2 = 1 if _merge == 3	
	replace connected_council_ap2 = 0 if _merge == 1
	drop _merge
	rename apellido apellido2
	rename n_apellido_council n_council_ap2
	
	gen 	connected_council = .
	replace connected_council = 1 if connected_council_ap1 == 1
	replace connected_council = 1 if connected_council_ap2 == 1
	replace connected_council = 0 if mi(connected_council)
	
* Generate connection sending to missing the popular last names	
	gen connected_council2 = connected_council
	replace connected_council2 = . if popular_apellido1 == 1
	replace connected_council2 = . if popular_apellido2 == 1

* Now generate continuous variable of number of connections
	br apellido1 apellido2 prob_apellido1 prob_apellido2 members_council connected_council_ap1 n_council_ap1 connected_council_ap2 n_council_ap2
	
	* Number of members they should be connected with, based on their last names
		gen council_members_ap1 = members_council*prob_apellido1
		gen council_members_ap2 = members_council*prob_apellido2
		gen 	tot_potential_conn_council = council_members_ap1+council_members_ap2
		replace tot_potential_conn_council = council_members_ap1 if mi(apellido2)
		
	* Actual connections they have
		gen 	conn_council_ap1 = n_council_ap1 if connected_council_ap1 == 1
		replace conn_council_ap1 = 0 if mi(conn_council_ap1)
		gen 	conn_council_ap2 = n_council_ap2 if connected_council_ap2 == 1
		replace conn_council_ap2 = 0 if mi(conn_council_ap2)
		replace conn_council_ap2 = 0 if apellido1 == apellido2
		
		gen tot_conn_council = conn_council_ap1 + conn_council_ap2
		
	* Create continuous variables
		gen connected_council3 = tot_conn_council-tot_potential_conn_council
		drop council_members_ap* tot_potential_conn_council* conn_council_ap* tot_conn_council* n_council_ap*
	
*-------------------------------------*
* Merge principal/teachers last names *
*-------------------------------------*	
	
* Merge names with apellido1
	rename apellido1 apellido	
	drop n_apellido_teacher1 n_apellido_directivo1 n_apellido_principal1 n_apellido_teacher2 n_apellido_directivo2 n_apellido_principal2
	merge m:1 year school_code apellido using "Data/principal&teachers_lastnames", keepus(directivo principal teacher n_apellido*)
	drop if _merge == 2

* Gen connection var
	br year school_code apellido directivo teacher _merge principal n_apellido*
	gen 	connected_teacher_ap1 = .
	replace connected_teacher_ap1 = 1 if _merge == 3 & n_apellido_teacher > 1 & teacher == 1
	replace connected_teacher_ap1 = 0 if mi(connected_teacher_ap1)
	
	gen 	connected_principal_ap1 = .
	replace connected_principal_ap1 = 1 if _merge == 3 & n_apellido > 1 & principal == 1
	replace connected_principal_ap1 = 0 if mi(connected_principal_ap1)
	
	gen 	connected_directivo_ap1 = .
	replace connected_directivo_ap1 = 1 if _merge == 3 & n_apellido > 1 & directivo == 1
	replace connected_directivo_ap1 = 0 if mi(connected_directivo_ap1)
	rename apellido apellido1
	rename (n_apellido_teacher n_apellido_directivo n_apellido_principal) (n_apellido_teacher1 n_apellido_directivo1 n_apellido_principal1)
	drop _merge directivo principal teacher  

* Merge names with apellido2
	rename apellido2 apellido
	merge m:1 year school_code apellido using "Data/principal&teachers_lastnames", keepus(directivo principal teacher n_apellido*)
	drop if _merge == 2

* Gen connection var for apellido2
	br year school_code apellido directivo teacher _merge principal n_apellido*
	gen 	connected_teacher_ap2 = .
	replace connected_teacher_ap2 = 1 if _merge == 3 & n_apellido_teacher > 1  & teacher == 1
	replace connected_teacher_ap2 = 0 if mi(connected_teacher_ap2)
	
	gen 	connected_principal_ap2 = .
	replace connected_principal_ap2 = 1 if _merge == 3 & n_apellido > 1 & principal == 1
	replace connected_principal_ap2 = 0 if mi(connected_principal_ap2)
	
	gen 	connected_directivo_ap2 = .
	replace connected_directivo_ap2 = 1 if _merge == 3 & n_apellido > 1 & directivo == 1
	replace connected_directivo_ap2 = 0 if mi(connected_directivo_ap2)
	rename apellido apellido2
	rename (n_apellido_teacher n_apellido_directivo n_apellido_principal) (n_apellido_teacher2 n_apellido_directivo2 n_apellido_principal2)
	drop _merge directivo principal teacher 

* Gen connection var 
	gen 	connected_teacher = .
	replace connected_teacher = 1 if connected_teacher_ap1 == 1
	replace connected_teacher = 1 if connected_teacher_ap2 == 1
	replace connected_teacher = 0 if mi(connected_teacher)
	
	gen 	connected_principal = .
	replace connected_principal = 1 if connected_principal_ap1 == 1
	replace connected_principal = 1 if connected_principal_ap2 == 1
	replace connected_principal = 0 if mi(connected_principal)

	gen 	connected_directivo = .
	replace connected_directivo = 1 if connected_directivo_ap1 == 1
	replace connected_directivo = 1 if connected_directivo_ap2 == 1
	replace connected_directivo = 0 if mi(connected_directivo)

* Taking out popular last names
	gen 	connected_teacher2 = connected_teacher
	replace connected_teacher2 = . if popular_apellido1 == 1
	replace connected_teacher2 = . if popular_apellido2 == 1
	
	gen 	connected_principal2 = connected_principal
	replace connected_principal2 = . if popular_apellido1 == 1
	replace connected_principal2 = . if popular_apellido2 == 1
	
	gen 	connected_directivo2 = connected_directivo
	replace connected_directivo2 = . if popular_apellido1 == 1
	replace connected_directivo2 = . if popular_apellido2 == 1
	
* Now generate continuous variable of number of connections

	* For n_apellido1 and n_apellido2, we substract one because it's accounting for him/herself
		replace n_apellido_teacher1 = n_apellido_teacher1 - 1
		replace n_apellido_teacher2 = n_apellido_teacher2 - 1 
	
	foreach type in teacher directivo principal  {
		br apellido1 apellido2 prob_apellido1 prob_apellido2 n_`type' connected_`type'_ap1 n_apellido_`type'1 connected_`type'_ap2 n_apellido_`type'2
		* Number of members they should be connected with, based on their last names
			gen `type'_ap1 = n_`type'*prob_apellido1
			gen `type'_ap2 = n_`type'*prob_apellido2
			gen 	tot_potential_conn_`type' = `type'_ap1+`type'_ap2
			replace tot_potential_conn_`type' = `type'_ap1 if mi(apellido2)	
		
		* Actual connections they have
			gen 	conn_`type'_ap1 = n_apellido_`type'1 if connected_`type'_ap1 == 1
			replace conn_`type'_ap1 = 0 if mi(conn_`type'_ap1)
			gen 	conn_`type'_ap2 = n_apellido_`type'2 if connected_`type'_ap2 == 1
			replace conn_`type'_ap2 = 0 if mi(conn_`type'_ap2)	
			replace conn_`type'_ap2 = 0 if apellido1 == apellido2
	
			gen tot_conn_`type' = conn_`type'_ap1 + conn_`type'_ap2	

		* Create continuous variables
			gen connected_`type'3 = tot_conn_`type'-tot_potential_conn_`type'
			drop `type'_ap1 tot_potential_conn_`type'* conn_`type'_ap* tot_conn_`type'*	
			
	}	

	sum connected_*	
	bys in_teacher_data: mdesc connected_*

	
* Regressions
	global fe "year document_id muni_code"
	reghdfe in_teacher_data connected_ty, absorb($fe) cluster(document_id)
	reghdfe in_teacher_data connected_council, absorb($fe) cluster(document_id)
	reghdfe in_teacher_data connected_directivo, absorb($fe) cluster(document_id)
	reghdfe in_teacher_data connected_teacher2, absorb($fe) cluster(document_id)


foreach var of varlist connected_ty connected_council  connected_directivo connected_teacher {
	gen year_`var' = year if `var' == 1
	bys document_id: egen event_`var' = min(year_`var')
	replace event_`var' = . if  event_`var' == 2012
	gen t_`var' = year - event_`var' 
	tab t_`var'

	* Create event time dummies
		* Lags
		forvalues l = 0/3 {
			gen L`l'event = (t_`var'==`l')
		}
		replace L3event = (t_`var'>=3 & !mi(t_`var'))
		
		* Leads
		forvalues l = 1/3 { 
                gen F`l'event = (t_`var'==-`l')
        }
        replace F3event = (t_`var'<=-3  & !mi(t_`var'))
		
	
	local title: variable label `var' 
	
	reghdfe in_teacher_data o.F1event F3event F2event L*event if event_`var' != 2012, absorb(year document_id) cluster(document_id)
	
	event_plot, default_look stub_lag(L#event) stub_lead(F#event) together plottype(scatter) ///
                graph_opt(xtitle("Years since the event")  name(`var', replace) title("`title'", size(smalll)) xlabel(-3(1)3))
				
	drop F*event L*event 
}
