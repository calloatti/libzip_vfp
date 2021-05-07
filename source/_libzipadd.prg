*!* _libzipadd

*!* DO NOT USE DIRECTLY! 

*!* use _libzipaddfile, _lipzipadddir, _libzipaddblob

lparameters ptype, p1, p2

local bloblen, blobp, crc32, isdirectory, sfilepath, zfilepath

do case

case m.ptype == 'FILE'

	m.sfilepath = m.p1

	m.zfilepath = m.p2

	m.bloblen = 0

	m.blobp = 0

	m.isdirectory = 0

case m.ptype == 'BLOB'

	m.sfilepath = ''

	m.zfilepath = m.p2

	m.bloblen = len(m.p1)

	m.blobp = _libzip_heapalloc(_libzip_getprocessheap(), 8, m.bloblen)

	m.isdirectory = 0

	sys(2600, m.blobp, m.bloblen, m.p1)

case m.ptype == 'BUFFER'

	m.sfilepath = ''

	m.zfilepath = m.p2

	m.bloblen = _libzip_heapsize(_libzip_getprocessheap(), 0, m.p1)

	m.blobp = m.p1

	m.isdirectory = 0

case m.ptype == 'DIR'

	m.sfilepath = ''

	m.zfilepath = m.p1

	m.bloblen = 0

	m.blobp = 0

	m.isdirectory = 1

	if not right(m.zfilepath, 1) $ '/\' then

		m.zfilepath = m.zfilepath + '/'

	endif

otherwise

	error 'INVALID _LIBZIPADD PARAMETER'

endcase

m.zfilepath = chrtran(m.zfilepath, '\', '/')

m.crc32 = padl(sys(2007, upper(m.zfilepath), 0, 1), 10, '0')

*!* if an entry with the same name (crc32) already exists, replace it

if seek(m.crc32, '_libzip_temp', 'crc32') = .f.

	append blank in '_libzip_temp'

endif

replace ;
	_libzip_temp.sfilepath	 with m.sfilepath, ;
	_libzip_temp.zfilepath	 with m.zfilepath, ;
	_libzip_temp.isdirectory with m.isdirectory, ;
	_libzip_temp.blobp		 with m.blobp, ;
	_libzip_temp.bloblen	 with m.bloblen, ;
	_libzip_temp.crc32		 with m.crc32 in '_libzip_temp'        