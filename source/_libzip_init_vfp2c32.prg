*!* _libzip_init_vfp2c32

external library vfp2c32.fll

if not "vfp2c32.fll" $ lower(set("Library")) then

	if application.startmode > 0 then

		set library to (justpath(application.servername) + "\vfp2c32.fll") additive

	else

		set library to vfp2c32.fll additive

	endif

endif

 