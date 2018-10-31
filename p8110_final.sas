* Nick Williams
* CUMC Department of Biostatistics
* Applied Regression II
* Final Project;

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

data dep_13; 
	set depression; 
	where follow_time < 13; 
run; 

data dep_14; 
	set depression; 
	where follow_time >= 13; 
run; 

proc lifetest data = dep_13 method = km conftype = loglog stderr plots = survival(cl);
	strata parent_dep;  
	time follow_time * child_dep(0); 
run;

proc lifetest data = dep_14 method = km conftype = loglog stderr plots = survival(cl);
	strata parent_dep;  
	time follow_time * child_dep(0); 
run;
 
* Cox model, parent depression status; 

proc phreg data = depression;
	class parent_dep;
	model follow_time * child_dep(0) = parent_dep / ties = efron; 
run; 

* cox model, comparing time of depression onset; 

data depression; 
	set depression; 
	if follow_time >= 13 then early_onset = 0; 
		else early_onset = 1; 
run; 

proc phreg data = depression; 
	class parent_dep (ref = '0') / param = ref;
	class early_onset (ref = '0') / param = ref;
	model follow_time * child_dep(0) = parent_dep early_onset parent_dep*early_onset / ties = efron;
	hazardratio parent_dep / diff = ref;
run; 
 
