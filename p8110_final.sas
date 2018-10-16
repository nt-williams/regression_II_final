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

* descriptive statistics; 

proc means data = depression median clm maxdec = 2; 
	var BEDEPON;
	class PARDEP; 
	where DSMDEPHR = 1;
run; 

* defining survival time; 

data depression;
	set depression; 

	if DSMDEPHR = 1 then 
		follow_time = BEDEPON; 
	else if DSMDEPHR = 0 
		then follow_time = PTAGE; 
run; 
