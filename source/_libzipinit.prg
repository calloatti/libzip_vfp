*!* _libzipinit

#define ZIP_DLL zip.dll

declare 		zip_error_fini in ZIP_DLL integer zip_error_t
declare 		zip_error_init in ZIP_DLL integer zip_error_t
declare 		zip_register_cancel_callback_with_state in ZIP_DLL integer zip_t, integer zip_cancel_callback, integer ud_free, integer ud
declare 		zip_register_progress_callback in ZIP_DLL integer zip_t, integer zip_progress_callback
declare 		zip_register_progress_callback_with_state in ZIP_DLL integer zip_t, double dprecision, integer zip_progress_callback, integer ud_free, integer ud
declare 		zip_source_free in ZIP_DLL integer zip_source_t
declare 		zip_stat_init in ZIP_DLL integer zip_stat_t
declare integer zip_dir_add in ZIP_DLL integer zip_t, string entryname, integer flags_t
declare integer zip_encryption_method_supported in ZIP_DLL short int16_method, integer iencrypt
declare integer zip_fclose in ZIP_DLL integer zip_file_t
declare integer zip_file_add in ZIP_DLL integer zip_t, string entryname, integer zip_source_t, integer zip_flags_t
declare integer zip_file_extra_field_get in ZIP_DLL integer zip_t, integer u32index1, integer u32index2, short extra_field_index, short @idp, short @lenp, integer zip_flags_t
declare integer zip_file_extra_field_get_by_id in ZIP_DLL integer zip_t, integer u32index1, integer u32index2, short extra_field_id, short extra_field_index, short @lenp, integer zip_flags_t
declare integer zip_file_extra_field_set in ZIP_DLL integer zip_t, integer indexlow, integer indexhigh, short extra_field_id, short extra_field_index, string extra_field_data, short datalen, integer zip_flags_t
declare integer zip_file_set_encryption in ZIP_DLL integer zip_t, integer indexlow, integer indexhigh, short uint16method, string cpassword
declare integer zip_fopen_index in ZIP_DLL integer zip_t, integer u32index1, integer u32index2, integer zip_flags_t
declare integer zip_fread in ZIP_DLL as zip_fread_iiii integer zip_file_t, integer strbuffer, integer nbytes1, integer nbytes2
declare integer zip_fread in ZIP_DLL as zip_fread_isii integer zip_file_t, string  @strbuffer, integer nbytes1, integer nbytes2
declare integer zip_get_error in ZIP_DLL integer zip_t
declare integer zip_get_num_entries in ZIP_DLL integer zip_t, integer zip_flags_t
declare integer zip_name_locate in ZIP_DLL integer zip_t, string fname, integer zip_flags_t
declare integer zip_open in ZIP_DLL string ppath, integer pflags, integer @perrorp
declare integer zip_open_from_source in ZIP_DLL integer zip_source_t, integer pflags, integer zip_error_t
declare integer zip_set_default_password in ZIP_DLL integer zip_t, string cpassword
declare integer zip_source_buffer in ZIP_DLL integer zip_t, integer datap, integer nlenlow, integer nlenhigh, integer freep
declare integer zip_source_buffer_create in ZIP_DLL integer ndata, integer nlenlow, integer nlenhigh, integer freep, integer zip_error_t
declare integer zip_source_file in ZIP_DLL integer zip_t, string filename, integer startlow, integer start_high, integer lenlow, integer lenhigh
declare integer zip_source_win32a_create in ZIP_DLL string fname, integer ustart1, integer ustart2, integer ulen1, integer ulen2, integer zip_error_t
declare integer zip_stat_index in ZIP_DLL integer zip_t, integer u32index1, integer u32index2, integer zip_flags_t, integer zip_stat_t
declare integer	zip_close in ZIP_DLL integer zip_t
declare integer	zip_file_set_mtime in ZIP_DLL integer zip_t, integer indexlow, integer indexhigh, integer time_tlow, integer time_thigh, integer zip_flags_t
declare string  zip_error_strerror in ZIP_DLL integer zip_error_t
declare string 	zip_get_name in ZIP_DLL integer zip_t, integer u32index1, integer u32index2, integer zip_flags_t

declare 		GetSystemTime in kernel32.dll as _libzip_getsystemtime string @lpsystemtime
declare 		GetSystemTimeAsFileTime in kernel32.dll as _libzip_getsystemtimeasfiletime string @lpsystemtimeasfiletime
declare integer CloseHandle in kernel32.dll as _libzip_closehandle integer hobject
declare integer CreateFile in kernel32.dll as _libzip_createfile string lpfilename, integer dwdesiredaccess, integer dwsharemode, integer lpsecurityattributes, integer dwcreationdisposition, integer dwflagsandattributes, integer htemplatefile
declare integer DeleteFile in kernel32.dll as _libzip_deletefile string lpfilename
declare integer GetFileTime in kernel32.dll as _libzip_getfiletime integer hfile, string @lpcreationtime, string @lplastaccesstime, string @lplastwritetime
declare integer GetProcessHeap in kernel32.dll as _libzip_getprocessheap
declare integer GetTimeZoneInformation in kernel32.dll as _libzip_gettimezoneinformation string @time_zone_information
declare integer HeapAlloc in kernel32.dll as _libzip_heapalloc integer hHeap, integer dwFlags, integer dwBytes
declare integer HeapAlloc in kernel32.dll as _libzip_heapalloc integer hHeap, integer dwFlags, integer dwBytes
declare integer HeapFree in kernel32.dll as _libzip_heapfree integer hheap, integer dwflags, integer lpmem
declare integer HeapSize in kernel32.dll as _libzip_heapsize integer hHeap, integer dwFlags, integer lpMem
declare integer lstrlen in kernel32.dll as _libzip_lstrlen integer lpString
declare integer SetFileTime in kernel32.dll as _libzip_setfiletime integer hFile, string lpCreationTime, string lpLastAccessTime, string lpLastWriteTime
declare integer SHCreateDirectory in shell32.dll as _libzip_shcreatedirectory string ihwnd, string pszpath
declare integer SystemTimeToFileTime in kernel32.dll as _libzip_systemtimetofiletime string lpsystemtime, string @lpfiletime

