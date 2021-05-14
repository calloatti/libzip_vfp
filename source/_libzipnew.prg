*!* _libzipnew

local narea

_libzipinit()

m.narea = select()

create cursor '_libzip_temp' (sfilepath V(254), zfilepath V(254), zctime Q(8), zatime Q(8), zmtime Q(8),isdirectory I, blobp I, bloblen I, crc32 C(10))

select '_libzip_temp'

index on _libzip_temp.crc32 tag 'crc32'

select (m.narea)