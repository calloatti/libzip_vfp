*!* example_write

*!* this example creates an example_write.zip with the dlls located in windows\system32

Local ofiler as 'Filer.FileUtil'
Local csourcepath, fidx, ores, sfilepath, useprogress, zfilepath, zipbasepath, zipdatetime, zipname
Local zippassword


*!* set useprogress to .F. to not call _libzipprogress or if not using vfp2c32 

m.useprogress = .t.

*!* set pzippassword to '' for no encryption

m.zippassword = '1234'

*!* set zipdatetime to '' to keep original datetimes of files

m.zipdatetime = datetime(2021, 1, 1, 0, 0, 0)

m.zipdatetime = ''

m.csourcepath = getenv("windir") + '\System32'

m.zipname = lower(justpath(sys(16))) + '\example.zip'

clear

m.ofiler = createobject('Filer.FileUtil')

m.ofiler.SearchPath = m.csourcepath

m.ofiler.FileExpression = '*.dll'

m.ofiler.SortBy = 1

*!* set to 1 to include dlls in subfolders

m.ofiler.SubFolder = 0

m.ofiler.find(0)

_libzipnew()

m.zipbasepath = getenv("windir")

for m.fidx = 1 to 200

	*for m.fidx = 1 to m.ofiler.files.count

	m.sfilepath = m.ofiler.files.item(m.fidx).path + m.ofiler.files.item(m.fidx).name

	m.zfilepath = _libziprebasepath(m.sfilepath, m.zipbasepath)

	?'ADDING FILE                 ' + m.zfilepath

	_libzipaddfile(m.sfilepath, m.zfilepath)

endfor
?''
?'SOURCEPATH                 ', addbs(m.csourcepath) + m.ofiler.FileExpression
?'ZIPFILENAME                ', m.zipname
?'CLOSING ZIP...'

m.ores = _libzipclose(m.zipname, m.zippassword, m.zipdatetime, m.useprogress)

wait clear

?'_LIBZIPCLOSE RETURN VALUE: ', transform(m.ores.result)
?'_LIBZIPCLOSE RETURN STRING:', m.ores.resultstr









 