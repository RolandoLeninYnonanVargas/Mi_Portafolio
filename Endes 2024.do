********************************************************************************
*								 ENDES 2024
********************************************************************************

clear all
cls

* Modulo 1631
* Modulo 1632
* Modulo 1634
* Modulo 1635

*Básico
*cd "E:\BASES DE DATOS\ENDES\OPS_comprimido1996-2016\ENDES 2024"

*Otra forma
global path2024 "F:\BASES DE DATOS\ENDES\OPS_comprimido1996-2016\ENDES 2024"

use "$path2024\rec0111_2024.dta", clear
sort caseid
merge 1:1 caseid using "$path2024\rec42_2024.dta", nogen
merge 1:1 caseid using "$path2024\re223132_2024.dta", nogen 
merge 1:1 caseid using "$path2024\re516171_2024.dta"

rename *, lower

* Generar los pesos
gen wt= v005/1000000
gen cluster = v001
gen estrato = v024

* Indicamos a stata el diseño muestral
********************************************************************************
 svyset cluster [pweight=wt], strata(estrato)
********************************************************************************

* Desagregaciones:
* riqueza: v190
* educación: v106
* urbano/rural: v025

********************************************************************************
* Capítulo 2: Características de las mujeres
********************************************************************************

*  PERÚ: NIVEL DE EDUCACIÓN DE LAS MUJERES EN EDAD FÉRTIL DE 15 A 49 AÑOS DE EDAD, 2024

tab v106 if (v013>=1 & v013<=7) /*muestral*/
tab v106 if (v013>=1 & v013<=7) [iw=wt] /*poblacional (no recomendable)*/

svy: tab v106 if (v013>=1 & v013<=7), col 
svy: tab v106, subpop(if v013>=1 & v013<=7)

svy: proportion v106 if (v013>=1 & v013<=7) /*al utilizarlo podrian encontrar diferencias en la varianza, y por ende, en los errores estandar*/

svy, subpop(if v013>=1 & v013<=7): proportion v106 

*cv
svy, subpop(if v013>=1 & v013<=7): tab v106, col cv

display (0.0008008/0.0090376)*100 /*calculo manual*/


* PERÚ: DISTRIBUCIÓN DE LAS MUJERES EN EDAD FÉRTIL DE 12 A 49 AÑOS DE EDAD,SEGÚN GRUPOS DE EDAD, 2023-2024
clonevar quintiles_edad = v013 
gen quintiles_edad = v013

svy: proportion v013
svy: proportion quintiles_edad

* PERÚ: MEDIANA DE AÑOS DE EDUCACIÓN DE LAS MUJERES EN EDAD FÉRTIL DE 15 A 49 AÑOS DE EDAD, SEGÚN ÁREA DE RESIDENCIA, 2023 Y 2024

preserve
	keep if v013>=1 & v013<=7
	gen edu = v133
	replace edu = 20 if v133>20 & v133<95
	replace edu = . if v133>95 | v149>7
	summarize edu [fweight=v005], detail

	* 50% percentil
		scalar sp50= r(p50)
		gen dummy = .
		replace dummy = 0
		replace dummy = 1 if edu<sp50
		summarize dummy [fweight=v005], detail
		scalar sL=r(mean)
		drop dummy
		
		gen dummy = .
		replace dummy = 0
		replace dummy = 1 if edu<=sp50
		summarize dummy [fweight=v005], detail
		scalar sU=r(mean)

		gen educ_median = round(sp50-1+(0.5-sL)/(sU-sL),.1)
		
		svy: tab educ_median
		tab educ_median [iw=wt]
restore


* PERÚ: CONDICIÓN DE TRABAJO EN LOS ÚLTIMOS 12 MESES DE LAS MUJERES EN EDAD FÉRTIL
* DE 15 A 49 AÑOS DE EDAD, SEGÚN ÁREA DE RESIDENCIA Y REGION NATURAL, 2024
fre v731

recode v731 (0 = 0 "No empleada en los últimos 12 meses") (1 = 2 "Sin empleo actual") (2 3 = 1 "Empleo actual"), gen(situacion_empleo)

svy, subpop(if v013>=1 & v013<=7): proportion situacion_empleo


* PERÚ: GRUPO DE OCUPACIÓN DE LAS MUJERES EN EDAD FÉRTIL DE 15 A 49 AÑOS DE EDAD, 2023 - 2024
recode v717 (3 7 = 1 "Ventas y servicios") (1 = 2 "Profesional/ técnico/ gerente") (4 = 3 "Agricultura") (6 = 4 "Servicio doméstico") (8 = 5 "Manual calificado") (2 = 6 "Oficinista") (9 = 7 "Manual no calificado") (. 0 98 = .) if inlist(v731,1,2,3), gen(ocupacion)

svy, subpop(if v013>=1 & v013<=7): proportion ocupacion

* PERÚ: COBERTURA DE SEGUROS DE SALUD DE LAS MUJERES EN EDAD FÉRTIL DE 15 A 49 AÑOS DE EDAD, SEGÚN ÁREA DE RESIDENCIA, 2024
gen seguro_sis = v481g == 1
gen seguro_essalud = v481e == 1
gen seguro_ffaa = v481f == 1
gen seguro_eps = v481h == 1
recode v481 (1 = 1 "Con seguro") (0 = 0 "Sin seguro"), gen(acceso_seguro)  

svy, subpop(if v013>=1 & v013<=7): proportion seguro_sis
svy, subpop(if v013>=1 & v013<=7): proportion seguro_essalud
svy, subpop(if v013>=1 & v013<=7): proportion seguro_ffaa
svy, subpop(if v013>=1 & v013<=7): proportion seguro_eps
svy, subpop(if v013>=1 & v013<=7): proportion acceso_seguro

********************************************************************************
* Capítulo 3: Fecundidad en adolescentes
********************************************************************************

*PERÚ: ADOLESCENTES DE 15 A 19 AÑOS DE EDAD QUE SON MADRES O QUE ESTÁN EMBARAZADAS POR PRIMERA VEZ, SEGÚN CARACTERISTICA SELECCIONADA, 2024 

*Madres
gen madres_15a19 = 0 if v013==1
replace madres_15a19 = 1 if v013==1 & v201>0

label var madres_15a19
label def madres_15a19 1 "Ya son madres" 0 "No es madre"
label values madres_15a19 madres_15a19

svy: proportion madres_15a19

*Embarazadas con el primer hijo
gen eph_15a19 = 0 if v013==1
replace eph_15a19 = 1 if v013==1 & (v201==0 & v213==1)

label var eph_15a19
label def eph_15a19 1 "Embarazadas con el primer hijo" 0 "No"
label values eph_15a19 eph_15a19

svy, subpop(if v025==1): proportion eph_15a19
svy, subpop(if v025==1): tab eph_15a19, count cv

* Adolescentes alguna vez embarazadas (15 a 19 años)
gen alg_embar= 0 if v013==1
replace alg_embar= 1 if v013==1 & (v201>0 | v213==1 )

svy: proportion alg_embar


********************************************************************************
* Cap 4: Planificación Familiar
********************************************************************************
* PERÚ: MUJERES DE 15 A 49 AÑOS DE EDAD ACTUALMENTE UNIDAS QUE USAN ALGUN MÉTODO DE PLANIFICACIÓN FAMILIAR, 2019-2024

gen muj_union = 0 if v013>=1 & v013<=7
replace muj_union = 1 if (v013>=1 & v013<=7) & (v501==1 | v501==2)

recode v313 (3 = 1 "Método moderno") (1 2 = 2 "Método tradicional") ( 0 = 3 "No usa método"), gen(uso_metodo)

svy, subpop(if muj_union==1): proportion uso_metodo

*  PERÚ: MÉTODOS MODERNOS MÁS USADOS POR LAS MUJERES DE 15 A 49 AÑOS DE EDAD ACTUALMENTE UNIDAS, 2023 - 2024
svy, subpop(if muj_union==1): proportion v312

* PERÚ: MUJERES DE 15 A 49 AÑOS DE EDAD ACTUALMENTE UNIDAS QUE USAN CUALQUIER MÉTODO DE PLANIFICACIÓN FAMILIAR, 2021 - 2024
gen tipo_metodo = 0 if v013>=1 & v013<=7 & muj_union==1 
replace tipo_metodo = 1 if v013>=1 & v013<=7 & muj_union==1 & (v312==6 | v312==7)
replace tipo_metodo = 2 if v013>=1 & v013<=7 & muj_union==1 & (v312==1 | v312==2 | v312==3 | v312==5 | v312==8 | v312==11 | v312==13 | v312==15 | v312==16)
label var tipo_metodo "Tipo de método"
label def tipo_metodo 1 "Método definitivo" 2 "Método temporales" 0 "Ningún método"
label value tipo_metodo tipo_metodo

svy: proportion tipo_metodo

* PERÚ: FUENTE DE SUMINISTRO DE MÉTODOS MODERNOS DE LAS USUARIAS ACTUALES (MUJERES DE 15 A 49 AÑOS DE EDAD), 2023 - 2024
svy, subpop(if v013>=1 & v013<=7 & uso_metodo==1): proportion v327 

* Mediana de edad de la primera relación sexual 

		preserve 
		keep if v013>=3 & v013<=7
		gen afs=v531
		drop if v531==0
		summarize afs [fweight=v005], detail
		
		* 50% percentile
		scalar sp50=r(p50)
	
			gen dummy=. 
			replace dummy=0 
			replace dummy=1 if afs<sp50 
			summarize dummy [fweight=v005]
			scalar sL=r(mean)
			drop dummy
	
			gen dummy=. 
			replace dummy=0 
			replace dummy=1 if afs<=sp50 
			summarize dummy [fweight=v005]
			scalar sU=r(mean)
			drop dummy

			gen rc_afs_median=round(sp50-1+(.5-sL)/(sU-sL),.01)
			label var rc_afs_median	"Median age sex activity"
				
		svy: tab rc_afs_median //median
		mean afs [iw=wt]		  //mean
		restore

		
************************************************************************
*  Indicadores de Salud materna 
************************************************************************		

clear all
cd "E:\BASES DE DATOS\ENDES\OPS_comprimido1996-2016\ENDES 2024"
		
use "rec0111_2024.dta", clear
sort caseid
merge 1:1 caseid using "rec42_2024.dta", nogen
merge 1:1 caseid using "re223132_2024.dta", nogen	
merge n:n caseid using "rec41_2024.dta", nogen	
merge n:n caseid using "re516171_2024.dta", nogen
merge n:n caseid using "rec84dv_2024.dta", nogen
merge n:n caseid using "rec21_2024.dta", nogen

ren *, lower

*Generamos el peso:
gen wt = v005/1000000
gen cluster= v001
gen region= v024
	
		
***********************************************************************
svyset cluster [pweight=wt], strata(region) 
***********************************************************************

* Desagregaciones:
* quintil riqueza = v190
* nivel educativo = v106
* area geográfica= v025
* departamento = v024


****************************************************************************
* Número de atenciones prenatales

*período de 5 años precedente a la encuesta
gen period = 60
gen age=v008-b3

*Número de atenciones prenatales +4
recode m14 (0=0 "none") (1=1) (2 3=2 "2-3") (4 5=3 "4-5") (6/20=4 "+6") (21/max =9 "don't know/missing"), gen(rh_anc_numvs)
replace rh_anc_numvs=. if age>=period  
label var rh_anc_numvs "Número de atenciones prenatales"
		
recode rh_anc_numvs (0 1 2 =0 "no") (3 4 =1 "yes") (9=9 "ns/no"), gen(rh_anc_4vs)
lab var rh_anc_4vs "Número de atenciones prenatales +4"

svy: proportion rh_anc_numvs 
tab rh_anc_numvs [iw=wt]
 

****************************************************************************
* Partos atendidos por personal sanitario cualificado (medicos, enfermeros y obstetras)

gen births_pers=0 if m3n==0 | m3n==1
replace births_pers=1 if m3a==1 | m3b==1 | m3c==1
label define births_pers 1 "personal de salud capacitado" 0 "Other"  
label values births_pers births_pers
label var    births_pers "partos atendidos por personal sanitario cualificado"

svy, subpop(if midx==1): proportion births_pers 
tab births_pers [iw=wt] if midx==1


****************************************************************************
* Parto institucional

recode m15 (21 22 23 24 25 26 27 31 32 41 42=1) (11 12 13 96 33=2), gen(delv_hf)
label def delv_hf 1 "Si" 2 "No"  
label var delv_hf "Parto en establecimiento de salud"

recode delv_hf (2 1 = 2), gen(idelv)
replace idelv=1 if delv_hf==1 & births_pers==1
replace idelv=. if age>=period 
label def idelv 1 "Si" 2 "No" 
label var idelv "Parto realizado en estab. de salud y atendido por prof. de salud"

svy, subpop(if midx==1): proportion idelv if midx==1
tab idelv [iw=wt] if midx==1


********************************************************************************
* Indicadores de Salud Infantil
********************************************************************************

clear all
global path2024 "F:\BASES DE DATOS\ENDES\OPS_comprimido1996-2016\ENDES 2024"

use "$path2024\rec21_2024.dta", clear
rename bidx hidx
save "$path2024\rec21_2024.dta", replace
		
use "$path2024\rec21_2024.dta", clear
merge 1:1 caseid hidx using "$path2024\rec43_2024.dta", nogen
tempfile base1
save "`base1'"

use "$path2024\rec0111_2024.dta", clear
merge 1:m caseid using "`base1'", nogen

ren *, lower

*Generamos el peso:
gen wt = v005/1000000
gen cluster= v001
gen region= v024
	
		
***********************************************************************
svyset cluster [pweight=wt], strata(region) 
***********************************************************************								
								
****************************************************************************
* Cobertura de DPT3

* Niños menores de 1 año que recibieron 3 dosis de la vacuna dpt 
* de acuerdo al esquema de vacunación NTS N°141-MINSA 

*edad en meses
gen age=v008-b3

*fuente de información
recode h1 (1=1 "tarjeta de vacunación") (else=2 "madre"), gen(source)

*De acuerdo al esquema de vacunación NTS N° 141-MINSA (primera dosis a los 2 meses, 
* segunda dosis a los 4 meses y tercera dosis a los 6 meses)
gen doses1=age>2
gen doses2=age>4
gen doses3=age>6

* DPT 1, 2, 3 
recode h3 (1 2 3=1) (else=0), gen(dpt1)
recode h5 (1 2 3=1) (else=0), gen(dpt2)
recode h7 (1 2 3=1) (else=0), gen(dpt3)
gen dptsum= dpt1+dpt2+dpt3
 
gen ch_pent1_either=dptsum>=1 if  doses1==1
gen ch_pent2_either=dptsum>=2 if  doses2==1
gen ch_pent3_either=dptsum>=3 if  doses3==1

*Tabulados
svy, subpop(if v012>14 & age<12 & b5==1 ): proportion ch_pent3_either 
tab ch_pent3_either [iw=wt] if v012>14 & age<12 & b5==1


****************************************************************************
* Cobertura de vacunación contra la Polio

recode h4 (1 2 3=1) (else=0), gen(polio1)
recode h6 (1 2 3=1) (else=0), gen(polio2)
recode h8 (1 2 3=1) (else=0), gen(polio3)
gen poliosum=polio1 + polio2 + polio3

gen ch_polio1_either=poliosum>=1 if  doses1==1
gen ch_polio2_either=poliosum>=2 if  doses2==1
gen ch_polio3_either=poliosum>=3 if  doses3==1

svy, subpop(if v012>14 & age<12 & b5==1): proportion ch_polio3_either 
tab ch_polio3_either [iw=wt] if v012>14 & age<12 & b5==1


****************************************************************************
* Cobertura de la vacuna BCG 
             
recode h2 (1 2 3=1) (else=0), gen(ch_bcg_either)

*Tabulados 
svy, subpop(if v012>14 & age<12 & b5==1): proportion ch_bcg_either 
tab ch_bcg_either [iw=wt] if v012>14 & age<12 & b5==1


****************************************************************************
* Cobertura de la vacuna antisarampionosa

*Según esquemade vacunación NTS N° 141-MINSA
gen doses_1=age>12
recode h9 (1 2 3 8=1) (else=0), gen(meas1)

*Cualquier fuente
gen ch_meas_either=meas1>=1 if  doses_1==1
label var ch_meas_either "Vacunación contra el sarampión según cualquiera de las fuentes"

*Tabulados
svy, subpop(if v012>14 & age<24 & b5==1): proportion ch_meas_either 
tab ch_meas_either [iw=wt] if v012>14 & age<24 & b5==1

****************************************************************************
* Niños menores de 5 años con diarrea que reciben SRO

gen ch_diar=0
replace ch_diar=1 if h11==2
replace ch_diar =. if h11==.
label var ch_diar "Diarrea en las 2 semanas previas a la encuesta"

svy: proportion ch_diar 

****************************************************************************
* Prevalecia de diarrea (EDA) en niños  
gen age=v008-b3
recode age (0/5=1 "Menos de 6 meses")(6/11=2 "6-11")(12/23=3 "12-23") ///
 (24/35=4 "24-35")(36/47=5 "36-47")(48/59=6 "48-59")(nonm=.), gen(group_age) 
recode h11(0 8=1 "No")(2=2 "Si") if b5==1 & age<60 & v012>14 , gen(eda)

svy, subpop(group_age): proportion eda /* EDA en menores de 5 años */
tab eda group_age [iw=wt], nofreq row


****************************************************************************
*Tratamiento de diarrea mediante Sales de Rehidratación oral (SRO)
gen ch_diar_ors=0 if ch_diar==1
replace ch_diar_ors=1 if (h13==1 | h13==2 | h13b==1) & ch_diar==1
label var ch_diar_ors "Administración de sales de rehidratación oral para la diarrea"

svy, subpop(if b8<60 & b5==1 & v012>14): proportion ch_diar_ors 
tab ch_diar_ors if b8<60 & b5==1 & v012>14 [iw=wt]


************************************************************************
*  Indicadores DIT
************************************************************************


clear all
global path2024 "F:\BASES DE DATOS\ENDES\OPS_comprimido1996-2016\ENDES 2024"

use "$path2024\RECH1_2024.dta", clear
rename HC0 HC0
save "$path2024\RECH1_2024.dta", replace

use "$path2024\RECH4_2024.dta", clear
rename IDXH4 HC0
save "$path2024\RECH4_2024.dta", replace


use "$path2024\RECH1_2024.dta", clear
merge 1:1 HHID HC0 using "$path2024\RECH4_2024.dta", nogen
merge 1:1 HHID HC0 using "$path2024\RECH6_2024.dta", nogen
merge m:1 HHID using "$path2024\RECH23_2024.dta", nogen
merge m:1 HHID using "$path2024\RECH0_2024.dta"

rename *, lower

***************************************************************
*				Establecemos el diseño muestral				  
***************************************************************
gen peso =hv005/1000000

svyset hv001 [w=peso], strata(hv024)
***************************************************************

codebook shregion
tab shregion
recode shregion (1 2 = 1 "Costa") (3 = 2 "Sierra") (4 = 3 "Selva"), gen(area_nat) 
tab area_nat	

/* Desnutrición Crónica Total*/
*Definición: Niñas y niños que están por debajo de -2 DE de la media de la talla para la edad 

gen desnwho=1 if hc70<- 200 & hv103==1
replace desnwho=2 if hc70>=-200 & hc70<601 & hv103==1
label define desnwho 1 "con_desnutricion_cronica" 2 "sin_desnutricion_cronica"
label values desnwho desnwho
label var desnwho "Desnutricion cronica total - OMS"
tab hv025 desnwho if hc1>=0 & hc1<=59 [iweight=peso], row

svy: proportion desnwho 
svy, subpop(if hv025==1): proportion desnwho
svy, subpop(if hv025==2): proportion desnwho


/* Desnutrición Crónica Severa */
*Definición: Niñas y niños que están por debajo de -3 DE de la media de la talla para la edad
gen desn_sev=1 if hc70<-300  & hv103==1
replace desn_sev=2 if hc70>=-300 & hc70<601 & hv103==1
label define desn_sev 1 "con_desnutricion_cronica_severa" 2 "sin_desnutricion_cronica_severa"
label values desn_sev desn_sev
label var desn_sev "Desnutricion cronica severa - OMS"
tab hv025 desn_sev if hc1>=0 & hc1<=59 [iweight=peso], row

svy: proportion desn_sev 
svy: proportion desn_sev, over(hv024)
svy: proportion desn_sev, over(shregion)
svy: proportion desn_sev, over(ambito)


/* Anemia */
gen alt=(hv040/1000)*3.3
gen haj= (hc53/10) -(-0.032*alt+0.022*alt*alt) 
gen anemia=1 if (haj>1 & haj<11 ) 
replace anemia=2 if (haj>=11 & haj<30 ) 
label define anemia 1 "con_anemia" 2 "sin_anemia"
label values anemia anemia
label var    anemia "anemia"

gen  EDAD_6a59=1 if hc1>=6 & hc1<=59
tab anemia [iw=peso] if EDAD_6a59==1 & hv103==1 

svy, subpop(if EDAD_6a59==1 & hv103==1): proportion anemia


/*Puntuación z media de talla para la edad de niños menores de 5 años */
gen haz=hc70/100 if hc70<996
summarize haz if hv103==1 [iw=peso]
gen nt_ch_mean_haz=round(r(mean),0.1)
label var nt_ch_mean_haz "Puntuación z media de talla para la edad de niños menores de 5 años"
























