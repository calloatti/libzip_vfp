*!* example_write_big

*!* this example creates an example_write.zip with the dlls located in windows\system32

*!* set useprogress to .F. to not call _libzipprogress or if not using vfp2c32 

local ofiler as 'Filer.FileUtil'
local useprogress, zippassword, zipdatetime, csourcepath, zipname, zipbasepath, fidx, sfilepath
local zfilepath, ores, maxfiles

m.useprogress = .t.

*!* set pzippassword to '' for no encryption

m.zippassword = ''

*!* set zipdatetime to '' to keep original datetimes of files

*m.zipdatetime = datetime(2021, 1, 1, 0, 0, 0)

m.zipdatetime = ''

m.csourcepath = getenv("windir") + '\System32'

m.zipname = lower(justpath(sys(16))) + '\example.zip'

clear

*!* grab some dll files from system32

m.ofiler = createobject('Filer.FileUtil')

m.ofiler.SearchPath = m.csourcepath

m.ofiler.FileExpression = '*.dll'

m.ofiler.SortBy = 1

*!* set to 1 to include dlls in subfolders

m.ofiler.SubFolder = 1

m.ofiler.find(0)

_libzipnew()

m.zipbasepath = getenv("windir")

m.maxfiles = 4000

for m.fidx = 2000 to min(m.maxfiles, m.ofiler.files.count)

	m.sfilepath = m.ofiler.files.item(m.fidx).path + m.ofiler.files.item(m.fidx).name

	m.zfilepath = _libziprebasepath(m.sfilepath, m.zipbasepath)

	?'ADDING FILE                 ' + m.zfilepath

	_libzipaddfile(m.sfilepath, m.zfilepath)

endfor

_libzipadddir('system32/test1')
_libzipadddir('system32/TEST2')
_libzipadddir('system32/test2/test21')
_libzipadddir('SYSTEM32/TEST3/TEST31')

?''
?'SOURCEPATH                 ', addbs(m.csourcepath) + m.ofiler.FileExpression
?'ZIPFILENAME                ', m.zipname
?'CLOSING ZIP...'

m.ores = _libzipclose(m.zipname, m.zippassword, m.zipdatetime, m.useprogress)

wait clear

?'_LIBZIPCLOSE RETURN VALUE: ', transform(m.ores.result)
?'_LIBZIPCLOSE RETURN STRING:', m.ores.resultstr









