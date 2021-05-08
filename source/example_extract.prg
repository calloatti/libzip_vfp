*!* example_extract

clear

m.zipname = lower(justpath(sys(16))) + '\example.zip'

m.zippassword = '12345678'

m.outpath = addbs(justpath(m.zipname)) + juststem(m.zipname)

if not file(m.zipname)

	?'RUN example_write.prg TO GENERATE ZIP'

	return

endif

m.ozip = _libzipopenfile(m.zipname, m.zippassword)

m.ozip.zipentrygetstats()

for m.lnx = 1 to m.ozip.entries

	?'UNZIPING', m.ozip.ename(m.lnx), m.ozip.zipentrytofile(m.lnx, m.outpath)

endfor

?'ZIP SOURCE', m.ozip.zipfilename

?'EXTRACT FOLDER', m.outpath
