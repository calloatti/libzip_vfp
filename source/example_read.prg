*!* example_read

local lnx, ozip, plog, zipname

clear

m.zipname = lower(justpath(sys(16))) + '\example.zip'

if not file(m.zipname)

	?'RUN example_write.prg TO GENERATE ZIP'

	return

endif

m.plog = forceext(m.zipname, 'txt')

?'CREATING REPORT PLEASE WAIT'

set console off

set printer to (m.plog)

set printer on

m.ozip = _libzipopenfile(m.zipname)

?m.ozip.zipfilename

m.ozip.zipentrygetstats()

?'EVALIDFIEL     EINDEX      ESIZE  ECOMPSIZE EDATETIM                ECRC32 ECOMPRESSI   EENCRYPT     EFLAGS EISDIRECTO ' + padr('ENAME', 50) + ' EPATH'

for m.lnx = 1 to m.ozip.entries

	?m.ozip.evalidfields(m.lnx), ;
		m.ozip.eindex(m.lnx), ;
		m.ozip.esize(m.lnx), ;
		m.ozip.ecompressedsize(m.lnx), ;
		m.ozip.edatetime(m.lnx), ;
		transform(m.ozip.ecrc(m.lnx), '@0'), ;
		m.ozip.ecompressionmethod(m.lnx), ;
		m.ozip.eencryptionmethod(m.lnx), ;
		m.ozip.eflags(m.lnx), ;
		m.ozip.eisdirectory(m.lnx), ;
		padr(m.ozip.ename(m.lnx), 50), ;
		m.ozip.epath(m.lnx), ;

endfor

set printer off

set printer to

set console on

declare integer ShellExecute in shell32.dll as _apishellexecute ;
	integer nhWnd, ;
	string  lpOperation, ;
	string  lpFile, ;
	string  lpParameters, ;
	string  lpDirectory, ;
	integer nShowCmd

_apishellexecute(_vfp.hwnd, 'open', m.plog, '', '', 1)






