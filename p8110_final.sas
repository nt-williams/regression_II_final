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

