vprm_params <- data.frame(
	lc_code  = c("DBF", "MXF", "SHB", "URB", "SOY", "CRP", "GRS", "SVN", "WET", "ENF", "OTH" )
	, lc     = c(   41,    43,    52,    24,    82,    82,    71,    71,    90,    42,    11 )
	, Tmin   = c(    0,     0,     2,     0,     5,     5,     2,     2,     0,     0,     0 )
	, Topt   = c(   20,    20,    20,    20,    22,    22,    18,    20,    20,    20,    20 )
	, Tmax   = c(   40,    40,    40,    40,    40,    40,    40,    40,    40,    40,     0 )
	, Tlow   = c(    5,     2,     1,     2,     2,     2,     1,     1,     3,     1,     0 )
	, PAR0   = c(  570,   629,   321,   629,  2051,  1250,   542,  3241,   558,   446,     0 )
	, lambda = c(0.127, 0.123, 0.122, 0.123, 0.064, 0.075, 0.213, 0.057, 0.051, 0.128, 0.000 )
	, alpha  = c(0.271, 0.244, 0.028, 0.244, 0.209, 0.173, 0.028, 0.012, 0.081, 0.250, 0.000 )
	, beta   = c(0.250, -0.24, 0.480, -0.24, 0.200, 0.820, 0.720, 0.580, 0.240, 0.170, 0.000 )
)#end data.frame()

### check for each column
# VPRM_OTH  == vprm_params[vprm_params$lc == "OTH",2:9] 

### landcover dataset does not diff grs/svn or crp/soy
vprm_params <- vprm_params[!vprm_params$lc_code %in% c("SOY", "SVN"),]

usethis::use_data(vprm_params, overwrite = T)
