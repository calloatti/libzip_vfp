*!* _libzipclose

#include _libzip.h

lparameters pzipfilename, pzippassword, pzipdatetime, puseprogress

local oresult as 'empty'
local callback, ccollate, crc32, dprecision, encmethod, errorp, extra_field_data, freep, narea
local nindex, result, resultstr, sfilepath, time_zone_information, userdata, zfilepath, zip_error_t
local zip_source_t, zip_t, pzipfiletime, pzipsystemtime

declare integer zip_open in ZIP_DLL string ppath, integer pflags, integer @perrorp
declare integer	zip_close in ZIP_DLL integer zip_t
declare integer zip_source_file in ZIP_DLL integer zip_t, string filename, integer startlow, integer start_high, integer lenlow, integer lenhigh
declare integer zip_file_add in ZIP_DLL integer zip_t, string entryname, integer zip_source_t, integer zip_flags_t
declare integer zip_get_error in ZIP_DLL integer zip_t
declare string  zip_error_strerror in ZIP_DLL integer zip_error_t
declare integer zip_dir_add in ZIP_DLL integer zip_t, string entryname, integer flags_t
declare integer zip_source_buffer in ZIP_DLL integer zip_t, integer datap, integer nlenlow, integer nlenhigh, integer freep
declare integer zip_file_extra_field_set in ZIP_DLL integer zip_t, integer indexlow, integer indexhigh, short extra_field_id, short extra_field_index, string extra_field_data, short datalen, integer zip_flags_t
declare integer zip_file_set_mtime in ZIP_DLL integer zip_t, integer indexlow, integer indexhigh, integer time_tlow, integer time_thigh, integer zip_flags_t
declare zip_register_cancel_callback_with_state in ZIP_DLL integer zip_t, integer zip_cancel_callback, integer ud_free, integer ud
declare zip_register_progress_callback_with_state in ZIP_DLL integer zip_t, double dprecision, integer zip_progress_callback, integer ud_free, integer ud
declare zip_register_progress_callback in ZIP_DLL integer zip_t, integer zip_progress_callback
declare integer zip_encryption_method_supported in ZIP_DLL short int16_method, integer iencrypt
declare integer zip_set_default_password in ZIP_DLL integer zip_t, string cpassword
declare integer zip_file_set_encryption in ZIP_DLL integer zip_t, integer indexlow, integer indexhigh, short uint16method, string cpassword

declare integer GetTimeZoneInformation in kernel32.dll as _libzip_gettimezoneinformation string @time_zone_information
declare integer GetFileTime in kernel32.dll as _libzip_getfiletime integer hfile, string @lpcreationtime, string @lplastaccesstime, string @lplastwritetime
declare GetSystemTime in kernel32.dll as _libzip_getsystemtime string @lpsystemtime
declare GetSystemTimeAsFileTime in kernel32.dll as _libzip_getsystemtimeasfiletime string @lpsystemtimeasfiletime
declare integer SystemTimeToFileTime in kernel32.dll as _libzip_systemtimetofiletime string lpsystemtime, string @lpfiletime

declare integer CreateFile in kernel32.dll as _libzip_createfile string lpfilename, integer dwdesiredaccess, integer dwsharemode, integer lpsecurityattributes, integer dwcreationdisposition, integer dwflagsandattributes, integer htemplatefile
declare integer CloseHandle in kernel32.dll as _libzip_closehandle integer hobject

m.narea = select()

select '_libzip_temp'

*!* fix slashes

replace _libzip_temp.zfilepath with chrtran(_libzip_temp.zfilepath, '\', '/') in '_libzip_temp' all

use dbf('_libzip_temp') again in 0 alias '_libzip_dirs'

select '_libzip_dirs'

*!* add directories extracted from filepaths to _libzip_temp

scan

	m.sfilepath	= justpath(rtrim(_libzip_dirs.sfilepath, 1, '/'))
	m.zfilepath	= justpath(rtrim(_libzip_dirs.zfilepath, 1, '/'))

	do while not empty(m.zfilepath)

		m.crc32 = padl(sys(2007, upper(m.zfilepath ) + '/', 0, 1), 10, '0')

		if seek(m.crc32, '_libzip_temp', 'crc32') = .f.

			append blank in '_libzip_temp'

			replace ;
				_libzip_temp.sfilepath	 with m.sfilepath, ;
				_libzip_temp.zfilepath	 with m.zfilepath + '/', ;
				_libzip_temp.isdirectory with 1, ;
				_libzip_temp.crc32		 with m.crc32 in '_libzip_temp'

		endif

		*!* remove rightmost directory from path, loop again

		m.sfilepath	= justpath(m.sfilepath)
		m.zfilepath	= justpath(m.zfilepath)

	enddo

endscan

use in '_libzip_dirs'

*!* sort _libzip_temp into new table by zip file name, cannot use index due to index length limit

m.ccollate = set("Collate")

set collate to "GENERAL"

select * from '_libzip_temp' order by _libzip_temp.zfilepath into cursor '_libzip_entries' readwrite

set collate to (m.ccollate)

use in '_libzip_temp'

_libzip_getfiletimes()

*!* create/open zip

m.errorp = 0

m.zip_t = zip_open(m.pzipfilename,  ZIP_CREATE + ZIP_TRUNCATE, @m.errorp)

if m.zip_t = 0 then

	error 'zip_open'

endif

*!* set zip password

m.encmethod = ZIP_EM_NONE

if not empty(m.pzippassword) and vartype(m.pzippassword) = 'C'

	m.result = zip_set_default_password(m.zip_t, m.pzippassword)

	if m.result # 0 then

		error 'zip_set_default_password'

	endif

	do case

	case zip_encryption_method_supported(ZIP_EM_AES_256, 0) + zip_encryption_method_supported(ZIP_EM_AES_256, 1) = 2

		m.encmethod = ZIP_EM_AES_256

	case zip_encryption_method_supported(ZIP_EM_AES_192, 0) + zip_encryption_method_supported(ZIP_EM_AES_192, 1) = 2

		m.encmethod = ZIP_EM_AES_192

	case zip_encryption_method_supported(ZIP_EM_AES_128, 0) + zip_encryption_method_supported(ZIP_EM_AES_128, 1) = 2

		m.encmethod = ZIP_EM_AES_128

	endcase

endif

*!* fix datetime local to utc

if vartype(m.pzipdatetime) = 'T'

	m.time_zone_information = replicate(0h00, 172)

	_libzip_gettimezoneinformation(@m.time_zone_information)

	m.pzipdatetime = m.pzipdatetime + ctobin(left(m.time_zone_information, 4), '4rs') * 60

	m.pzipfiletime = 0h0000000000000000

	m.pzipsystemtime = 0h + bintoc(year(m.pzipdatetime), '2rs') + bintoc(month(m.pzipdatetime), '2rs') + bintoc(dow(m.pzipdatetime, 1) - 1, '2rs') + bintoc(day(m.pzipdatetime), '2rs') + bintoc(hour(m.pzipdatetime), '2rs') + bintoc(minute(m.pzipdatetime), '2rs') + bintoc(sec(m.pzipdatetime), '2rs') + 0h0000

	_libzip_systemtimetofiletime(m.pzipsystemtime, @m.pzipfiletime)

endif

select '_libzip_entries'

scan

	doevents

	m.sfilepath	= _libzip_entries.sfilepath
	m.zfilepath	= _libzip_entries.zfilepath

	m.nindex = -1

	do case

	case _libzip_entries.isdirectory = 1

		*!* directory

		m.nindex = zip_dir_add(m.zip_t, m.zfilepath, ZIP_FL_ENC_GUESS)

		if m.nindex = -1 then

			error 'zip_dir_add: ' + m.zfilepath + '*'

		endif

	case _libzip_entries.blobp # 0

		*!* create source from blob (pointer to data)

		m.freep = 0

		m.zip_source_t = zip_source_buffer(m.zip_t, _libzip_entries.blobp, _libzip_entries.bloblen, 0, m.freep)

		if m.zip_source_t = 0 then

			error 'zip_source_buffer'

		endif

		*!* add blob source to zip

		m.nindex = zip_file_add(m.zip_t, m.zfilepath, m.zip_source_t, ZIP_FL_ENC_GUESS + ZIP_FL_OVERWRITE)

		if m.nindex = -1 then

			error 'zip_file_add: ' + m.zfilepath

		endif

		_lipzip_setencryption(m.zip_t, m.nindex, m.encmethod)

	case not empty(m.sfilepath) and file(m.sfilepath, 1)

		*!* create source from file on disk

		m.zip_source_t = zip_source_file(m.zip_t, m.sfilepath, 0, 0, 0, 0)

		if m.zip_source_t = 0 then

			error 'zip_source_file: ' + m.sfilepath

		endif

		*!* add file to zip

		m.nindex = zip_file_add(m.zip_t, m.zfilepath, m.zip_source_t, ZIP_FL_ENC_GUESS + ZIP_FL_OVERWRITE)

		if m.nindex = -1 then

			error 'zip_file_add: ' + m.zfilepath

		endif

		_lipzip_setencryption(m.zip_t, m.nindex, m.encmethod)

	endcase

	*!* set entry datetime

	if vartype(m.pzipdatetime) == 'T'

		zip_file_set_mtime(m.zip_t, m.nindex, 0, m.pzipdatetime - {^1970/01/01 00:00:00}, 0, 0)

		m.extra_field_data = 0h0000000001001800 + m.pzipfiletime + m.pzipfiletime + m.pzipfiletime

	else

		zip_file_set_mtime(m.zip_t, m.nindex, 0, _libzip_filetimetounixtime(_libzip_entries.zmtime), 0, 0)

		*!* extra_field_data: Reserved Long + short NTFS attribute tag value #1 + short Size of attribute #1, in bytes + data (see ntfs-tags.txt)

		m.extra_field_data = 0h0000000001001800 + _libzip_entries.zmtime + _libzip_entries.zatime + _libzip_entries.zctime

	endif

	m.result = zip_file_extra_field_set(m.zip_t, m.nindex, 0, 0x000a, ZIP_EXTRA_FIELD_NEW, m.extra_field_data, 32, ZIP_FL_CENTRAL)

	if m.result # 0

		m.zip_error_t = zip_get_error(m.zip_t)

		error 'zip_file_extra_field_set error: ' + zip_error_strerror(m.zip_error_t)

	endif

endscan

*!* setup progress callback

#define CALLBACK_SYNCRONOUS			1
#define CALLBACK_ASYNCRONOUS_POST	2
#define CALLBACK_ASYNCRONOUS_SEND	4
#define CALLBACK_CDECL				8

if m.puseprogress = .t.

	_libzip_initvfp2c32()

	m.callback = createcallbackfunc('_libzipprogress_internal', 'VOID', 'INTEGER,DOUBLE,INTEGER', null, CALLBACK_CDECL)

	m.dprecision = 0.001

	m.userdata = writecstring(0, m.pzipfilename)

	zip_register_progress_callback_with_state(m.zip_t, m.dprecision, m.callback, 0, m.userdata)

endif

*!* close zip

m.result = zip_close(m.zip_t)

if m.puseprogress = .t.

	DestroyCallbackFunc(m.callback)

	freemem(m.userdata)

endif

*!* get result string and create result object

m.zip_error_t = zip_get_error(m.zip_t)

m.resultstr = zip_error_strerror(m.zip_error_t)

m.oresult = createobject('empty')

addproperty(m.oresult, 'result', m.result)
addproperty(m.oresult, 'resultstr', m.resultstr)

*!* free allocated memory

scan for _libzip_entries.blobp # 0

	_libzip_heapfree(_libzip_getprocessheap(), 0, _libzip_entries.blobp)

endscan

if application.startmode > 0

	use in '_libzip_entries'

endif

select (m.narea)

return m.oresult

procedure _libzipprogress_internal

	lparameters pzip_t, pprogress, puserdata

	_libzipprogress(round(m.pprogress * 100, 2), readcstring(m.puserdata))

	doevents

endproc

procedure _libzip_getfiletimes

	local hfile, lpsystemtimeasfiletime, result, zatime, zctime, zmtime, zxtime

	m.lpsystemtimeasfiletime = 0h0000000000000000

	_libzip_getsystemtimeasfiletime(@m.lpsystemtimeasfiletime)

	m.zxtime = m.lpsystemtimeasfiletime

	select '_libzip_entries'

	scan

		if empty(_libzip_entries.sfilepath)

			m.zctime = m.zxtime
			m.zatime = m.zxtime
			m.zmtime = m.zxtime

		else

			m.hfile = _libzip_createfile(_libzip_entries.sfilepath, 0x80000000, 0x01, 0, 0x03, 0x80 + 0x02000000, 0)

			if m.hfile # 0 then

				m.zctime = 0h0000000000000000
				m.zatime = 0h0000000000000000
				m.zmtime = 0h0000000000000000

				m.result = _libzip_getfiletime(m.hfile, @m.zctime, @m.zatime, @m.zmtime )

				_libzip_closehandle(m.hfile)

			endif

		endif

		replace ;
			_libzip_entries.zctime with	m.zctime, ;
			_libzip_entries.zatime with	m.zatime, ;
			_libzip_entries.zmtime with	m.zmtime in '_libzip_entries'

	endscan

endproc

procedure _lipzip_setencryption

	lparameters pzip_t, pindex, pencryptionmethod

	*!* set encryption for files and blobs

	local result

	if m.pencryptionmethod # ZIP_EM_NONE

		m.result = zip_file_set_encryption(m.pzip_t,  m.pindex, 0, m.pencryptionmethod, 0)

		if m.result # 0 then

			error 'zip_file_set_encryption'

		endif

	endif

endproc

procedure _libzip_filetimetounixtime

	lparameters pfiletime

	return int((_lipzip_readuint(64, m.pfiletime) - 0x019DB1DED53E8000) / 10000000)

endproc

procedure _lipzip_readuint

	lparameters pbits, pstr

	local lnx, uint

	m.uint = 0

	for m.lnx = 0 to (m.pbits / 8) - 1

		m.uint = m.uint + asc(substr(m.pstr, m.lnx + 1, 1)) * 2^((m.lnx) * 8)

	endfor

	return int(m.uint)

endproc

procedure _libzip_initvfp2c32

	external library vfp2c32.fll

	if not "vfp2c32.fll" $ lower(set("Library")) then

		if application.startmode > 0 then

			set library to (justpath(application.servername) + "\vfp2c32.fll") additive

		else

			set library to vfp2c32.fll additive

		endif

	endif

endproc











