*!* _libzipnew

local narea

declare integer HeapAlloc in kernel32.dll as _libzip_heapalloc integer hHeap, integer dwFlags, integer dwBytes
declare integer HeapFree in kernel32.dll as _libzip_heapfree integer hheap, integer dwflags, integer lpmem
declare integer HeapSize in kernel32.dll as _libzip_heapsize integer hHeap, integer dwFlags, integer lpMem
declare integer GetProcessHeap in kernel32.dll as _libzip_getprocessheap

m.narea = select()

create cursor '_libzip_temp' (sfilepath V(254), zfilepath V(254), zctime Q(8), zatime Q(8), zmtime Q(8),isdirectory I, blobp I, bloblen I, crc32 C(10))

select '_libzip_temp'

index on _libzip_temp.crc32 tag 'crc32'

select (m.narea)