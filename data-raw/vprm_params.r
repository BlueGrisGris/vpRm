vprm_params <- data.frame(
	lc_code  = c("DBFa","DBFb", "MXF","SHBa","SHBb", "URB", "SOY", "CRP","GRSa","GRSb", "SVN", "WET","ENFa","ENFb","ENFc", "OTH" )
	, lc     = c(     4,     5,     6,     7,     8,    17,    15,    15,     9,    10,     9,    14,     1,     2,     3,    18 )
	, Tmin   = c(     0,     0,     0,     2,     2,     0,     5,     5,     2,     2,     2,     0,     0,     0,     0,     0 )
	, Topt   = c(    20,    20,    20,    20,    20,    20,    22,    22,    18,    18,    20,    20,    20,    20,    20,    20 )
	, Tmax   = c(    40,    40,    40,    40,    40,    40,    40,    40,    40,    40,    40,    40,    40,    40,    40,     0 )
	, Tlow   = c(     5,     5,     2,     1,     1,     2,     2,     2,     1,     1,     1,     3,     1,     1,     1,     0 )
	, PAR0   = c(   570,   570,   629,   321,   321,   629,  2051,  1250,   542,   542,  3241,   558,   446,   446,   446,     0 )
	, lambda = c( 0.127, 0.127, 0.123, 0.122, 0.122, 0.123, 0.064, 0.075, 0.213, 0.213, 0.057, 0.051, 0.128, 0.128, 0.128, 0.000 )
	, alpha  = c( 0.271, 0.271, 0.244, 0.028, 0.028, 0.244, 0.209, 0.173, 0.028, 0.028, 0.012, 0.081, 0.250, 0.250, 0.250, 0.000 )
	, beta   = c( 0.250, 0.250, -0.24, 0.480, 0.480, -0.24, 0.200, 0.820, 0.720, 0.720, 0.580, 0.240, 0.170, 0.170, 0.170, 0.000 )
)#end data.frame()

### check for each column
# VPRM_OTH  == vprm_params[vprm_params$lc == "OTH",2:9] 

### landcover dataset does not diff grs/svn or crp/soy
vprm_params <- vprm_params[!vprm_params$lc_code %in% c("SOY", "SVN"),]

usethis::use_data(vprm_params, overwrite = T)
