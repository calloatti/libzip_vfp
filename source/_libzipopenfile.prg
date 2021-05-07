*!* _libzipopenfile

lparameters pzipfilename, pzippassword

local lozip as '_libzip' of '_libzip.prg'

m.lozip = newobject('_libzip', '_libzip.prg')

if not empty(m.pzipfilename)

	m.lozip.zipopenfile(m.pzipfilename, m.pzippassword)

endif

return m.lozip