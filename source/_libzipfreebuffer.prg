*!* _libzipfreebuffer

lparameters pbuffer

if m.pbuffer # 0 then

	_libzip_heapfree(_libzip_getprocessheap(), 0, m.pbuffer)

endif  