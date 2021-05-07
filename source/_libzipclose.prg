*!* _libzipclose

#include _libzip.h

lparameters pzipfilename, pzippassword, pzipdatetime, puseprogress

local oresult as 'empty'
local callback, ccollate, crc32, dprecision, encmethod, entrynum, errorp, freep, mresult, narea
local nindex, result, resultstr, sfilepath, time_zone_information, userdata, zfilepath, zip_error_t
local zip_source_t, zip_t

declare integer zip_open in ZIP_DLL string ppath, integer pflags, integer @perrorp
declare integer	zip_close in ZIP_DLL integer zip_t
declare integer zip_source_file in ZIP_DLL integer zip_t, string filename, integer startlow, integer start_high, integer lenlow, integer lenhigh
declare integer zip_file_add in ZIP_DLL integer zip_t, string entryname, integer zip_source_t, integer zip_flags_t
declare integer zip_get_error in ZIP_DLL integer zip_t
declare string  zip_error_strerror in ZIP_DLL integer zip_error_t
declare integer zip_dir_add in ZIP_DLL integer zip_t, string entryname, integer flags_t
declare integer zip_source_buffer in ZIP_DLL integer zip_t, integer datap, integer nlenlow, integer nlenhigh, integer freep
declare integer zip_file_set_mtime in ZIP_DLL integer zip_t, integer indexlow, integer indexhigh, integer time_tlow, integer time_thigh, integer zip_flags_t
declare zip_register_cancel_callback_with_state in ZIP_DLL integer zip_t, integer zip_cancel_callback, integer ud_free, integer ud
declare zip_register_progress_callback_with_state in ZIP_DLL integer zip_t, double dprecision, integer zip_progress_callback, integer ud_free, integer ud
declare zip_register_progress_callback in ZIP_DLL integer zip_t, integer zip_progress_callback
declare integer zip_encryption_method_supported in ZIP_DLL short int16_method, integer iencrypt
declare integer zip_set_default_password in ZIP_DLL integer zip_t, string cpassword
declare integer zip_file_set_encryption in ZIP_DLL integer zip_t, integer indexlow, integer indexhigh, short uint16method, string cpassword

declare integer GetTimeZoneInformation in kernel32.dll as _libzip_gettimezoneinformation string @time_zone_information

m.narea = select()

select '_libzip_temp'

*!* fix slashes

replace _libzip_temp.zfilepath with chrtran(_libzip_temp.zfilepath, '\', '/') in '_libzip_temp' all

use dbf('_libzip_temp') again in 0 alias '_libzip_dirs'

select '_libzip_dirs'

*!* add directories extracted from filepaths to _libzip_temp

scan

	if _libzip_dirs.isdirectory = 1

		loop

	endif

	m.zfilepath = justpath(_libzip_dirs.zfilepath)

	do while not empty(m.zfilepath)

		m.crc32 = padl(sys(2007, upper(m.zfilepath ) + '/', 0, 1), 10, '0')

		if seek(m.crc32, '_libzip_temp', 'crc32') = .f.

			append blank in '_libzip_temp'

			replace ;
				_libzip_temp.sfilepath	 with '*', ;
				_libzip_temp.zfilepath	 with m.zfilepath + '/', ;
				_libzip_temp.isdirectory with 1, ;
				_libzip_temp.crc32		 with m.crc32 in '_libzip_temp'

		endif

		*!* remove rightmost directory from path, loop again

		m.zfilepath = justpath(m.zfilepath)

	enddo

endscan

use in '_libzip_dirs'

*!* sort _libzip_temp into new table by zip file name, cannot use index due to index length limit

m.ccollate = set("Collate")

set collate to "GENERAL"

select * from '_libzip_temp' order by _libzip_temp.zfilepath into cursor '_libzip_entries'

set collate to (m.ccollate)

use in '_libzip_temp'

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

*!* fix datetime local/utc

if vartype(m.pzipdatetime) = 'T'

	m.time_zone_information = replicate(0h00, 172)

	_libzip_gettimezoneinformation(@m.time_zone_information)

	m.pzipdatetime = m.pzipdatetime + ctobin(left(m.time_zone_information, 4), '4rs') * 60

endif

select '_libzip_entries'

m.entrynum = 1

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

	case not empty(m.sfilepath) and file(m.sfilepath)

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

	endcase

	*!* set encryption for files

	if _libzip_entries.isdirectory = 0 and m.encmethod # ZIP_EM_NONE

		m.mresult = zip_file_set_encryption(m.zip_t,  m.nindex, 0, m.encmethod, 0)

		if m.result # 0 then

			error 'zip_file_set_encryption'

		endif

	endif

	*!* set entry datetime

	if vartype(m.pzipdatetime) == 'T'

		zip_file_set_mtime(m.zip_t, m.nindex, 0, m.pzipdatetime - {^1970/01/01 00:00:00}, 0, 0)

	endif

	m.entrynum = m.entrynum + 1

endscan

*!* setup progress callback

#define CALLBACK_SYNCRONOUS			1
#define CALLBACK_ASYNCRONOUS_POST	2
#define CALLBACK_ASYNCRONOUS_SEND	4
#define CALLBACK_CDECL				8

if m.puseprogress = .t.

	_libzip_init_vfp2c32()

	m.callback = createcallbackfunc('_libzipprogress_internal', 'VOID', 'INTEGER,DOUBLE,INTEGER', null, CALLBACK_CDECL)

	m.dprecision = 0.01

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

	_libzipprogress(int(m.pprogress * 100), readcstring(m.puserdata))

endproc













