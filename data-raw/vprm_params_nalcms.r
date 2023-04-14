vprm_params_nalcms <- data.frame(
	lc_code  = c(  "NA","ENFa","ENFb","ENFc","DBFa","DBFb", "MXF","SHBa","SHBb", "GRSa", "GRSb", "POLa","POLb", "POLc", "WET", "SOY", "BAR",  "URB",   "OTH",   "SNO")
	, lc     = c(     0,     1,     2,     3,     4,     5,     6,     7,     8,      9,     10,     11,    12,     13,    14,    15,    16,     17,      18,    19  )
	, Tmin   = c(     0,     0,     0,     0,     0,     0,     0,     2,     2,      2,      2,      2,     2,      0,     0,     5,     0,      0,       0,     0  )
	, Topt   = c(     0,    20,    20,    20,    20,    20,    20,    20,    20,     20,     18,     18,    18,     20,    20,    22,     0,     20,       0,     0  )
	, Tmax   = c(     0,    40,    40,    40,    40,    40,    40,    40,    40,     40,     40,     40,    40,     40,    40,    40,     0,     40,       0,     0  )
	, Tlow   = c(     0,     1,     1,     1,     5,     5,     2,     1,     1,      1,      1,      1,     1,      2,     3,     2,     0,      1,       0,     0  )
	, PAR0   = c(     0,   446,   446,   446,   570,   570,   629,   321,   321,   3241,    542,    542,   542,    629,   558,  2051,     0,    446,       0,     0  )
	, lambda = c(     0, 0.128, 0.128, 0.128, 0.127, 0.127, 0.123, 0.122, 0.122,  0.057,  0.213,  0.213, 0.213,  0.123, 0.051,  .064,     0,  0.128,   0.000, 0.000  )
	, alpha  = c(     0, 0.250, 0.250, 0.250, 0.271, 0.271, 0.244, 0.028, 0.028,  0.012,  0.028,  0.028, 0.028,  0.244, 0.081,  .209,     0,  0.250,   0.000, 0.000  )
	, beta   = c(     0, 0.170, 0.170, 0.170, 0.250, 0.250, -0.24, 0.480, 0.480,  0.580,  0.720,  0.720, 0.720,  -0.24, 0.240,  .200,     0,  -0.24,   0.000, 0.000  )
)#end data.frame()

### check for each column
# VPRM_OTH  == vprm_params[vprm_params$lc == "OTH",2:9] 

### landcover dataset does not diff grs/svn or crp/soy
vprm_params_nalcms <- vprm_params_nalcms[!vprm_params_nalcms$lc_code %in% c("SOY", "SVN"),]

usethis::use_data(vprm_params_nalcms, overwrite = T)