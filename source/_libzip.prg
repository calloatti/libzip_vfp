*!* _libzip

#include _libzip.h

define class _libzip as custom

	zip_source_t = 0
	zip_error_t	 = 0
	zipfilename	 = ""
	zip_stat_t	 = 0
	*-- struct zip pointer
	zip_t		= 0
	zip_buffer	= 0
	entries		= 0
	zip_utcbias	= 0
	name		= "_libzip"
	dimension eflags[1]
	dimension eencryptionmethod[1]
	dimension ecompressionmethod[1]
	dimension ecrc[1]
	dimension edatetime[1]
	dimension ecompressedsize[1]
	dimension esize[1]
	dimension eindex[1]
	dimension ename[1]
	dimension evalidfields[1]
	dimension epath[1]
	dimension eisdirectory[1]

	procedure init

		this.initdeclares()
		this.initbuffers()
		this.initarrays()

	endproc

	procedure initarrays

		this.evalidfields		= 0
		this.ename				= ''
		this.eindex				= 0
		this.esize				= 0
		this.ecompressedsize	= 0
		this.edatetime			= {//::}
		this.ecrc				= 0
		this.ecompressionmethod	= 0
		this.eencryptionmethod	= 0
		this.eflags				= 0
		this.eisdirectory		= 0
		this.epath				= ''

	endproc

	procedure initbuffers

		local time_zone_information

		this.zip_stat_t = _libzip_heapalloc(_libzip_getprocessheap(), 8, 64)

		this.zip_error_t = _libzip_heapalloc(_libzip_getprocessheap(), 8, 12)

		zip_error_init(this.zip_error_t)

		m.time_zone_information = replicate(0h00, 172)

		_libzip_gettimezoneinformation(@m.time_zone_information)

		this.zip_utcbias = ctobin(left(m.time_zone_information, 4), '4rs') * 60

	endproc

	procedure initdeclares

		declare integer	zip_close in ZIP_DLL integer zip_t
		declare 		zip_error_fini in ZIP_DLL integer zip_error_t
		declare 		zip_error_init in ZIP_DLL integer zip_error_t
		declare string 	zip_error_strerror in ZIP_DLL integer zip_error_t
		declare integer zip_fclose in ZIP_DLL integer zip_file_t
		declare integer zip_fopen_index in ZIP_DLL integer zip_t, integer u32index1, integer u32index2, integer zip_flags_t
		declare integer zip_fread in ZIP_DLL as zip_fread_isii integer zip_file_t, string  @strbuffer, integer nbytes1, integer nbytes2
		declare integer zip_fread in ZIP_DLL as zip_fread_iiii integer zip_file_t, integer strbuffer, integer nbytes1, integer nbytes2
		declare string 	zip_get_name in ZIP_DLL integer zip_t, integer u32index1, integer u32index2, integer zip_flags_t
		declare integer zip_get_num_entries in ZIP_DLL integer zip_t, integer zip_flags_t
		declare integer zip_name_locate in ZIP_DLL integer zip_t, string fname, integer zip_flags_t
		declare integer zip_open in ZIP_DLL string ppath, integer pflags, integer @perrorp
		declare integer zip_open_from_source in ZIP_DLL integer zip_source_t, integer pflags, integer zip_error_t
		declare integer zip_source_buffer_create in ZIP_DLL integer ndata, integer nlenlow, integer nlenhigh, integer freep, integer zip_error_t
		declare integer zip_source_file in ZIP_DLL integer zip_t, string filename, integer startlow, integer start_high, integer lenlow, integer lenhigh
		declare 		zip_source_free in ZIP_DLL integer zip_source_t
		declare integer zip_source_win32a_create in ZIP_DLL string fname, integer ustart1, integer ustart2, integer ulen1, integer ulen2, integer zip_error_t
		declare integer zip_stat_index in ZIP_DLL integer zip_t, integer u32index1, integer u32index2, integer zip_flags_t, integer zip_stat_t
		declare 		zip_stat_init in ZIP_DLL integer zip_stat_t
		declare integer zip_set_default_password in ZIP_DLL integer zip_t, string cpassword

		declare integer lstrlen in kernel32.dll as _libzip_lstrlen integer lpString
		declare integer HeapAlloc in kernel32.dll as _libzip_heapalloc integer hHeap, integer dwFlags, integer dwBytes
		declare integer HeapFree in kernel32.dll as _libzip_heapfree integer hheap, integer dwflags, integer lpmem
		declare integer GetProcessHeap in Kernel32.dll as _libzip_getprocessheap
		declare integer HeapSize in kernel32.dll as _libzip_heapsize integer hHeap, integer dwFlags, integer lpMem

		*!* time_zone_information 172 bytes
		declare integer GetTimeZoneInformation in kernel32.dll as _libzip_gettimezoneinformation string @time_zone_information

	endproc

	procedure zipopenfile

		lparameters pzipfilename, pzippassword

		local lnx

		this.zipfilename = m.pzipfilename

		this.zipclose()

		if empty(this.zipfilename)

			return

		endif

		this.zip_source_t = zip_source_win32a_create(this.zipfilename, 0, 0, 0, 0, this.zip_error_t)

		if this.zip_source_t = 0

			error 'zip_source_win32a_create: ' + zip_error_strerror (this.zip_error_t)

		endif

		this.zip_t = zip_open_from_source(this.zip_source_t, ZIP_RDONLY, this.zip_error_t)

		if this.zip_t = 0

			error 'zip_open_from_source: ' + zip_error_strerror (this.zip_error_t)

		endif

		if not empty(m.pzippassword) and vartype(m.pzippassword) = 'C'

			if zip_set_default_password(this.zip_t, m.pzippassword) # 0 then

				error 'zip_set_default_password'

			endif

		endif

		this.entries = zip_get_num_entries(this.zip_t, ZIP_FL_UNCHANGED)

		if this.entries > 0

			dimension this.evalidfields(this.entries)
			dimension this.ename(this.entries)
			dimension this.eindex(this.entries)
			dimension this.esize(this.entries)
			dimension this.ecompressedsize(this.entries)
			dimension this.edatetime(this.entries)
			dimension this.ecrc(this.entries)
			dimension this.ecompressionmethod(this.entries)
			dimension this.eencryptionmethod(this.entries)
			dimension this.eflags(this.entries)
			dimension this.eisdirectory(this.entries)
			dimension this.epath(this.entries)

		endif

		this.initarrays()

		for m.lnx = 1 to this.entries

			this.ename(m.lnx)  = zip_get_name(this.zip_t, m.lnx - 1, 0, ZIP_FL_ENC_GUESS)

			this.epath(m.lnx) = justfname(this.zipfilename) + '/' + this.ename(m.lnx)

			this.eindex(m.lnx) = m.lnx

			if right(this.ename(m.lnx), 1) == '/' then

				this.eisdirectory(m.lnx) = 1

			else

				this.eisdirectory(m.lnx) = 0

			endif

		endfor

	endproc

	procedure zipclose

		if this.zip_t # 0

			zip_close(this.zip_t)

		endif

		if this.zip_buffer # 0 then

			_libzip_heapfree(_libzip_getprocessheap(), 0, this.zip_buffer)

			this.zip_buffer = 0
		
		endif
		
		*!* zip_open_from_source(3), zip_file_add(3), and
		*!* zip_file_replace(3) will decrement the reference count of the zip_source_t when they are
		*!* done using it, so zip_source_free(3) only needs to be called when these functions return
		*!* an error.

		*!*	if this.zip_source_t # 0

		*!*		zip_source_free(this.zip_source_t)

		*!*	endif

		dimension this.evalidfields[1]
		dimension this.ename[1]
		dimension this.eindex[1]
		dimension this.esize[1]
		dimension this.ecompressedsize[1]
		dimension this.edatetime[1]
		dimension this.ecrc[1]
		dimension this.ecompressionmethod[1]
		dimension this.eencryptionmethod[1]
		dimension this.eflags[1]
		dimension this.eisdirectory[1]
		dimension this.epath[1]

		this.initarrays()

		this.entries	  = 0
		this.zip_source_t = 0
		this.zip_t		  = 0

	endproc

	procedure zipentrytostring

		lparameters pidxorfilename

		local bytesread, filebytes, idx, zip_file_t

		m.filebytes = ''

		if vartype(m.pidxorfilename) = 'C'

			m.idx = this.zipnamelocate(m.pidxorfilename, .t.)

		else

			m.idx = m.pidxorfilename

		endif

		if m.idx > 0 and this.eisdirectory(m.idx) = 0

			if this.evalidfields(m.idx) = 0 then

				this.zipentrygetstats(m.idx)

			endif

			m.zip_file_t = zip_fopen_index(this.zip_t, m.idx - 1, 0, ZIP_FL_UNCHANGED)

			if m.zip_file_t = 0 then

				error 'zip_fopen_index'

			endif

			m.filebytes = space(this.esize(m.idx))

			m.bytesread = zip_fread_isii(m.zip_file_t, @m.filebytes, this.esize(m.idx), 0)

			if m.bytesread = -1 then

				error 'zip_fread'

			endif

			if zip_fclose(m.zip_file_t) # 0 then

				error 'zip_fclose'

			endif

		endif

		return m.filebytes

	endproc

	procedure zipopenbuffer

		lparameters pzip_buffer, ppath

		local freep, lnx, nlenlow

		this.zipclose()

		this.zip_buffer = m.pzip_buffer

		if empty(this.zip_buffer)

			return

		endif

		m.nlenlow = _libzip_heapsize(_libzip_getprocessheap(), 0, this.zip_buffer)

		m.freep = 0

		*!* If freep is non-zero, the buffer will be freed when it is no longer needed. 
		*!* data must remain valid for the lifetime of the created source.

		this.zip_source_t = zip_source_buffer_create(this.zip_buffer, m.nlenlow, 0, m.freep, this.zip_error_t)

		if this.zip_source_t = 0

			error 'zip_source_buffer_create: ' + zip_error_strerror (this.zip_error_t)

		endif

		this.zip_t = zip_open_from_source(this.zip_source_t, ZIP_RDONLY, this.zip_error_t)

		if this.zip_t = 0

			error 'zip_open_from_source: ' + zip_error_strerror (this.zip_error_t)

		endif

		this.entries = zip_get_num_entries(this.zip_t, ZIP_FL_UNCHANGED)

		if this.entries > 0

			dimension this.evalidfields(this.entries)
			dimension this.ename(this.entries)
			dimension this.eindex(this.entries)
			dimension this.esize(this.entries)
			dimension this.ecompressedsize(this.entries)
			dimension this.edatetime(this.entries)
			dimension this.ecrc(this.entries)
			dimension this.ecompressionmethod(this.entries)
			dimension this.eencryptionmethod(this.entries)
			dimension this.eflags(this.entries)
			dimension this.eisdirectory(this.entries)
			dimension this.epath(this.entries)

		endif

		this.initarrays()

		for m.lnx = 1 to this.entries

			this.ename(m.lnx)  = zip_get_name(this.zip_t, m.lnx - 1, 0, ZIP_FL_ENC_GUESS)

			if empty(m.ppath)

				this.epath(m.lnx) = this.ename(m.lnx)

			else

				this.epath(m.lnx) = m.ppath + '/' + this.ename(m.lnx)

			endif

			this.eindex(m.lnx) = m.lnx

			if right(this.ename(m.lnx), 1) == '/' then

				this.eisdirectory(m.lnx) = 1

			else

				this.eisdirectory(m.lnx) = 0

			endif

		endfor

	endproc

	procedure zipentrytobuffer

		lparameters pidxorfilename

		local bytesread, idx, pointer, zip_file_t

		m.pointer = 0

		if vartype(m.pidxorfilename) = 'C'

			m.idx = this.zipnamelocate(m.pidxorfilename, .t.)

		else

			m.idx = m.pidxorfilename

		endif

		if m.idx > 0 and this.eisdirectory(m.idx) = 0

			if this.evalidfields(m.idx) = 0 then

				this.zipentrygetstats(m.idx)

			endif

			m.zip_file_t = zip_fopen_index(this.zip_t, m.idx - 1, 0, ZIP_FL_UNCHANGED)

			if m.zip_file_t = 0 then

				error 'zip_fopen_index'

			endif

			m.pointer = _libzip_heapalloc(_libzip_getprocessheap(), 8, this.esize(m.idx))

			m.bytesread = zip_fread_iiii(m.zip_file_t, m.pointer, this.esize(m.idx), 0)

			if m.bytesread # this.esize(m.idx) then

				error 'zip_fread'

			endif

			if zip_fclose(m.zip_file_t) # 0 then

				error 'zip_fclose'

			endif

		endif

		return m.pointer

	endproc

	procedure zipentrytofile

		lparameters pidx, ppath

		local bytesread, byteswrite, cbytes, fhandle, nbytes, zip_file_t

		if this.eisdirectory(m.pidx) = 0

			m.ppath = addbs(m.ppath) + this.ename(m.pidx)

			if not directory(justpath(m.ppath))

				mkdir (justpath(m.ppath))

			endif

			if file(m.ppath)

				m.fhandle = fopen(m.ppath, 2)

				fchsize(m.fhandle, 0)

			else

				m.fhandle = fcreate(m.ppath)

			endif

			m.zip_file_t = zip_fopen_index(this.zip_t, m.pidx - 1, 0, ZIP_FL_UNCHANGED)

			if m.zip_file_t = 0 then

				error 'zip_fopen_index'

			endif

			m.nbytes = 4096

			m.cbytes = replicate(0h00, m.nbytes)

			do while .t.

				m.bytesread = zip_fread_isii(m.zip_file_t, @m.cbytes, m.nbytes, 0)

				if m.bytesread = -1 then

					error 'zip_fread'

				endif

				if m.bytesread = 0 then

					exit

				endif

				m.byteswrite = fwrite(m.fhandle, m.cbytes, m.bytesread)

				if m.byteswrite # m.bytesread

					error 'FWRITE'

				endif

			enddo

			if zip_fclose(m.zip_file_t) # 0 then

				error 'zip_fclose'

			endif

			if fclose(m.fhandle) # .t.

				error 'FCLOSE'

			endif

		endif

	endproc

	procedure zipnamelocate

		*!* The zip_name_locate() function returns the index of the file named fname in archive. 
		*!* If archive does not contain a file with that name, 0 is returned.

		lparameters pentryname, pignorecase, pignoredir

		local idx, zip_flags_t

		m.zip_flags_t = 0

		if m.pignorecase then

			m.zip_flags_t = m.zip_flags_t + ZIP_FL_NOCASE

		endif

		if m.pignoredir then

			m.zip_flags_t = m.zip_flags_t + ZIP_FL_NODIR

		endif

		m.pentryname = chrtran(m.pentryname, '\', '/')

		m.idx = zip_name_locate(this.zip_t, m.pentryname, m.zip_flags_t)

		return m.idx + 1

	endproc

	procedure zipentrygetstats

		lparameters pidx

		local lnx, result


		if empty(m.pidx) then

			for m.lnx = 1 to this.entries

				this.zipentrygetstats(m.lnx)

			endfor

		else

			zip_stat_init(this.zip_stat_t)

			m.result = zip_stat_index(this.zip_t, m.pidx - 1, 0, ZIP_FL_UNCHANGED, this.zip_stat_t)

			if m.result # 0

				error 'zip_stat_index'

			endif

			*!*	struct zip_stat {
			*!*	    8 0  zip_uint64_t valid;                 /* which fields have valid values */
			*!*	    4 8  const char *name;                   /* name of the file */
			*!*	    8 12 zip_uint64_t index;                 /* index within archive */
			*!*	    8 20 zip_uint64_t size;                  /* size of file (uncompressed) */
			*!*	    8 28 zip_uint64_t comp_size;             /* size of file (compressed) */
			*!*	    8 36 time_t mtime;                       /* modification time */
			*!*	    4 44 zip_uint32_t crc;                   /* crc of file data */
			*!*	    2 48 zip_uint16_t comp_method;           /* compression method used */
			*!*	    2 50 zip_uint16_t encryption_method;     /* encryption method used */
			*!*	    4 52 zip_uint32_t flags;                 /* reserved for future use */

			*!*	Offset of valid: 0
			*!*	Offset of mname: 8
			*!*	Offset of mindex: 16
			*!*	Offset of size: 24
			*!*	Offset of comp_size: 32
			*!*	Offset of mtime: 40
			*!*	Offset of crc: 48
			*!*	Offset of comp_method: 52
			*!*	Offset of encryption_method: 54
			*!*	Offset of flags: 56
			*!*	Size: 64
			*!*	Align: 8

			*!* fix entry datetime localtime/utctime difference

			this.evalidfields(m.pidx)		= this._readuint64(this.zip_stat_t)
			this.ename(m.pidx)				= this._readpstring(this.zip_stat_t + 8)
			this.eindex(m.pidx)				= this._readuint64(this.zip_stat_t + 16) + 1
			this.esize(m.pidx)				= this._readuint64(this.zip_stat_t + 24)
			this.ecompressedsize(m.pidx)	= this._readuint64(this.zip_stat_t + 32)
			this.edatetime(m.pidx)			= {^1970/01/01 00:00:00} + this._readuint64(this.zip_stat_t + 40) - this.zip_utcbias
			this.ecrc(m.pidx)				= this._readuint64(this.zip_stat_t + 48)
			this.ecompressionmethod(m.pidx)	= this._readuint16(this.zip_stat_t + 52)
			this.eencryptionmethod(m.pidx)	= this._readuint16(this.zip_stat_t + 54)
			this.eflags(m.pidx)				= this._readuint32(this.zip_stat_t + 56)

		endif

	endproc

	procedure zipfreebuffer

		lparameters pbuffer

		if m.pbuffer # 0 then

			_libzip_heapfree(_libzip_getprocessheap(), 0, m.pbuffer)

		endif

	endproc

	procedure _readuint64

		lparameters paddress

		local uint

		m.uint = 0

		m.uint = m.uint + asc(sys(2600, m.paddress + 0, 1)) * 2^0

		m.uint = m.uint + asc(sys(2600, m.paddress + 1, 1)) * 2^8

		m.uint = m.uint + asc(sys(2600, m.paddress + 2, 1)) * 2^16

		m.uint = m.uint + asc(sys(2600, m.paddress + 3, 1)) * 2^24

		m.uint = m.uint + asc(sys(2600, m.paddress + 4, 1)) * 2^32

		m.uint = m.uint + asc(sys(2600, m.paddress + 5, 1)) * 2^40

		m.uint = m.uint + asc(sys(2600, m.paddress + 6, 1)) * 2^48

		m.uint = m.uint + asc(sys(2600, m.paddress + 7, 1)) * 2^56

		return int(m.uint)

	endproc

	procedure _readuint32

		lparameters paddress

		local uint

		m.uint = 0

		m.uint = m.uint + asc(sys(2600, m.paddress + 0, 1)) * 2^0

		m.uint = m.uint + asc(sys(2600, m.paddress + 1, 1)) * 2^8

		m.uint = m.uint + asc(sys(2600, m.paddress + 2, 1)) * 2^16

		m.uint = m.uint + asc(sys(2600, m.paddress + 3, 1)) * 2^24

		return int(m.uint)

	endproc

	procedure _readuint16

		lparameters paddress

		local uint

		m.uint = 0

		m.uint = m.uint + asc(sys(2600, m.paddress + 0, 1)) * 2^0

		m.uint = m.uint + asc(sys(2600, m.paddress + 1, 1)) * 2^8

		return int(m.uint)

	endproc

	procedure _readuint8

		lparameters paddress

		return asc(sys(2600, m.paddress + 0, 1))

	endproc

	procedure _readpstring

		lparameters paddress

		local pointer, strlen

		m.pointer = this._readuint32(m.paddress)

		m.strlen = _libzip_lstrlen(m.pointer)

		return sys(2600, m.pointer, m.strlen)

	endproc

	procedure destroy

		if this.zip_t # 0

			zip_close(this.zip_t)

		endif

		if this.zip_buffer # 0 then

			_libzip_heapfree(_libzip_getprocessheap(), 0, this.zip_buffer)

		endif

		if this.zip_stat_t # 0 then

			_libzip_heapfree(_libzip_getprocessheap(), 0, this.zip_stat_t)

		endif

		zip_error_fini(this.zip_error_t)

		if this.zip_error_t # 0 then

			_libzip_heapfree(_libzip_getprocessheap(), 0, this.zip_error_t)

		endif

	endproc

enddefine



