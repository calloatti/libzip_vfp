*!* _libzipopenbuffer

*!* pzipbuffer: points to a buffer of a zip file in memory
*!* ppath: optional, path of the zip file in the buffer

*!* when you open a buffer that points to a zip file inside a zip file, 
*!* ppath represents the path of the file in the original zip

*!* for example you have c:\data\main.zip
*!* and inside that zip there is a file called sub.zip
*!* the epath[x] of that entry will be main.zip/sub.zip

*!* you want to open sub.zip without extracting it from main.zip:

*!* buffer = ozip.zipentrytobuffer[x]
*!* m.ozipsub = _libzipopenbuffer(buffer, ozip.epath[x])

*!* then all the entries in sub.zip will have an epath starting with ozip.epath[x]
*!* that way you can keep track of subzip names

lparameters pzipbuffer, ppath

local lozip as '_libzip' of '_libzip.prg'

m.lozip = newobject('_libzip', '_libzip.prg')

m.lozip.zipopenbuffer(m.pzipbuffer, m.ppath)

return m.lozip