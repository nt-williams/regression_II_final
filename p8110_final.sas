* Nick Williams
* CUMC Department of Biostatistics
* Applied Regression II
* Final Project;

* importing data;

proc import out = depression 
			 datafile = "C:\Users\niwi8\OneDrive\Documents\fall_2018\regression\final\regression_II_final\data.csv"
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

* descriptive statistics; 

proc means data = depression median clm maxdec = 2; 
	var age_child_dep;
	class parent_dep; 
	where child_dep = 1;
run; 

* KM-surv curve, parent depression status; 

proc lifetest data = depression method = km conftype = loglog stderr plots = survival(cl);
	strata parent_dep;  
	time follow_time * child_dep(0); 
run; 

