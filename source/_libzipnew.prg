*!* _libzipnew

local narea

declare integer HeapAlloc in kernel32.dll as _libzip_heapalloc integer hHeap, integer dwFlags, integer dwBytes

declare integer HeapFree in kernel32.dll as _libzip_heapfree integer hheap, integer dwflags, integer lpmem

declare integer HeapSize in kernel32.dll as _libzip_heapsize integer hHeap, integer dwFlags, integer lpMem

declare integer GetProcessHeap in Kernel32.dll as _libzip_getprocessheap

m.narea = select()

create cursor '_libzip_temp' (sfilepath v(254), zfilepath v(254), isdirectory i, blobp i, bloblen i, crc32 c(10))

select '_libzip_temp'

index on _libzip_temp.crc32 tag 'crc32'

select (m.narea)