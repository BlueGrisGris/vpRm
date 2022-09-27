### piecewise function index maker
pw_func <- function(Tair){findInterval(Tair , c(-Inf, 20, 30, Inf))}

### attempt at putting the entire pw Tscalar inside the call to terra::app
if(F){
pw_func <- function(Tair){
	pw_idx <- findInterval(Tair , c(-Inf, 20, 30, Inf))
	Tscalar <- c( 
		((Tair-Tmin)*(Tair-Tmax))/((Tair-Tmin)*(Tair-Tmax) - (Tair-20)^2)
		, 1
		, ((Tair-Tmin)*(Tair-Tmax))/((Tair-Tmin)*(Tair-Tmax) - (Tair-30)^2)
	     )[[pw_idx]] #end list
}#end pw_func
}#end if F

### Modified Tscalar form Winbourne et al 2021
win_Tscalar <- function(Tair, Tmin, Tmax){
	### piecewise function from Winbourne et al 2021
	#         pw_idx <- findInterval(Tair , c(-Inf, 20, 30, Inf))
	Tscalar <- terra::app(Tair,fun = pw_func)   
	ones <- Tair 
	#         terra::values(ones) <- rep(1, terra::ncell(Tair))
	Tscalar <- terra::sds( 
		((Tair-Tmin)*(Tair-Tmax))/((Tair-Tmin)*(Tair-Tmax) - (Tair-20)^2)
		, ones
		, ((Tair-Tmin)*(Tair-Tmax))/((Tair-Tmin)*(Tair-Tmax) - (Tair-30)^2)
	     )
	#         [[2]]
	#         [[pw_idx]]#end list

	Tscalar <- Tscalar[[]]

	return(Tscalar)
}#end func mod_Tscalar

Tscalar <- function(Tair, Tmin, Tmax){
	### mean of 2 Topt vals in Winbourne 2021's piecewise
	Topt <- 25
	return(
		((Tair-Tmin)*(Tair-Tmax))/((Tair-Tmin)*(Tair-Tmax) - (Tair-Topt)^2)
	)#end return
}#end func Tscalar


### Modified Pscalar from Winbourne et al 2021
Pscalar <- function(EVI, EVImax, EVImin){
	Pscalar <- (EVI - EVImin)/(EVImax-EVImin)
	Pscalar[Pscalar < 0] <- 0 
	Pscalar[Pscalar > 1] <- 1 
	return(Pscalar )
}#end func Pscalar

### simplified Tscalar for forests.  avg value from mahadevan 2008
Tscalar <- function(Tair, Tmin, Tmax){
	return(.85)
}#end func Tscalar 

### From Mahadevan 2008
mah_Wscalar <- function(LSWI,LSWImax){
	return(
		(1+LSWI)/(1+LSWImax)
	)#end return
}#end func Wscalar

### simplified Wscalar for forests.  avg value from mahadevan 2008
Wscalar <- function(LSWI,LSWImax){
	return(.9)
}#end function Wscalar
