* Nick Williams
* CUMC Department of Biostatistics
* Applied Regression II
* Final Project;

************************************
Part 1

* importing data;

proc import out = depression 
			 datafile = "C:\Users\niwi8\OneDrive\Documents\fall_2018\regression\final\regression_II_final\data\data.csv"
			 dbms = csv replace; 
			 getnames = yes; 
run; 

data depression; 
	set depression; 
	rename PARDEP = parent_dep
		   DSMDEPHR = child_dep
		   PTSEX = child_sex
		   PTAGE = child_age
		   BEDEPON = age_child_dep
		   DSMSUBHR = sub_abuse_child
		   BESUBON = age_sub_child
		   SESCLASS = ses_parent
		   MSPARENT = mar_stat_parent; 
run; 

* defining survival time; 

data depression;
	set depression; 

	if child_dep = 1 then 
		follow_time = age_child_dep; 
	else if child_dep = 0 
		then follow_time = child_age; 
run;  

* KM-surv curve, parent depression status; 

proc lifetest data = depression method = km conftype = loglog stderr plots = survival(cl);
	strata parent_dep;  
	time follow_time * child_dep(0); 
run; 

**********************************************
Part 2 
 
* Cox model, parent depression status crude model; 

proc phreg data = depression;
	class parent_dep (ref = '0') / param = ref;
	model follow_time * child_dep(0) = parent_dep / ties = efron risklimits;
	assess ph / resample;  
run; 

* cox model, parent depression status adjusted model; 

proc phreg data = depression; 
	class parent_dep (ref = '0')
		  child_sex (ref = '1') 
		  ses_parent (ref = '1')
		  mar_stat_parent (ref = '1') / param = ref;
	model follow_time*child_dep(0) = parent_dep child_sex ses_parent mar_stat_parent / ties = efron risklimits;
	assess ph / resample; 
run; 

* cox model, comparing time of depression onset; 

data depression; 
	set depression; 
	if follow_time >= 13 then early_onset = 0; 
		else early_onset = 1; 
run; 

* crude;

proc phreg data = depression;
	class parent_dep (ref = '0') 
		  early_onset (ref = '0') / param = ref;
	model follow_time * child_dep(0) = parent_dep early_onset parent_dep*early_onset / ties = efron;
	hazardratio parent_dep / diff = ref;
run;

* adjusted;

proc phreg data = depression;
	class parent_dep (ref = '0') 
		  early_onset (ref = '0') 
		  child_sex (ref = '1') 
		  ses_parent (ref = '1')
		  mar_stat_parent (ref = '1') / param = ref;
	model follow_time * child_dep(0) = parent_dep early_onset child_sex ses_parent 
			mar_stat_parent parent_dep*early_onset / ties = efron risklimits;
	hazardratio parent_dep / diff = ref;
run; 

* plotting survival curves;

data plot; 
	input Strata parent_dep early_onset child_sex ses_parent mar_stat_parent; 
	datalines; 
	1 1 1 1 1 1
	2 0 1 1 1 1
	3 1 0 1 1 1
	4 0 0 1 1 1
	;
run; 

proc phreg data = depression plots(overlay) = survival;
	model follow_time * child_dep(0) = parent_dep early_onset parent_dep*early_onset / ties = efron;
	hazardratio parent_dep / diff = ref;
	baseline covariates = plot / rowid = Strata;
	title "Survival curves of different child categories";
run; 

proc phreg data=depression;
class parent_dep(ref="0") /param=ref; 
model follow_time*child_dep(0) = parent_dep int / ties=efron rl covb;
if follow_time>=13 then onset=0; else onset=1; 
int = parent_dep*onset; 
run;
 
**********************************************************************************************************************************************
Part 3; 

data depression; 
	set depression; 

	if age_child_dep = -1 then age_child_dep = .;
	if age_sub_child = -1 then age_sub_child = .;

	if sub_abuse_child = 1
		then follow_time_sub = age_sub_child; 
	else follow_time_sub = child_age; 
run;

* crude model; 

proc phreg data = depression; 
	title "Cox regression with depression status treated as time-dependent - crude"; 
	model follow_time_sub * sub_abuse_child(0) = dep / ties = efron risklimits; 
		* looking at each event timepoint and comparing the age of onset of dep to age of onset of sub abuse;
		if age_child_dep > follow_time_sub or child_dep = 0 then dep = 0; 
			else dep = 1; 
run; 

* full model;  

proc phreg data = depression; 
	title "Cox regression with depression status treated as time-dependent";
	class parent_dep (ref = '0') 
		  child_sex (ref = '1') / param = ref;  
	model follow_time_sub * sub_abuse_child(0) = dep parent_dep child_sex child_age / ties = efron risklimits; 
		* looking at each event timepoint and comparing the age of onset of dep to age of onset of sub abuse;
		if age_child_dep > follow_time_sub or child_dep = 0 then dep = 0; 
			else dep = 1; 
run; 

* assessing ph assumption of other covariates; 

proc phreg data = depression; 
	class parent_dep (ref = '0') 
		  child_sex (ref = '1') / param = ref;  
	model follow_time_sub * sub_abuse_child(0) = parent_dep child_sex child_age / ties = efron risklimits; 
	assess ph / resample;  
run;
