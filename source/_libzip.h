
#define HEAP_ZERO_MEMORY	8

#define ZIP_CREATE		1
#define ZIP_EXCL		2
#define ZIP_CHECKCONS	4
#define ZIP_TRUNCATE	8
#define ZIP_RDONLY	16

#define ZIP_FL_ENC_GUESS 0
#define ZIP_FL_ENC_UTF_8 2048
#define ZIP_FL_ENC_CP437 4096

#define ZIP_FL_NOCASE		1		&&/* ignore case on name lookup */
#define ZIP_FL_NODIR		2		&&/* ignore directory component */

#define ZIP_FL_UNCHANGED	8		&&/* use original data, ignoring changes */
#define ZIP_FL_OVERWRITE 8192

#define ZIP_FL_ENC_RAW		64		&&/* get unmodified string */
#define ZIP_FL_ENC_STRICT	128 	&&/* follow specification strictly */
#define ZIP_FL_UNCHANGED	8		&&/* use original data, ignoring changes */

#define ZIP_EM_NONE 0
#define ZIP_EM_AES_128 0x0101
#define ZIP_EM_AES_192 0x0102
#define ZIP_EM_AES_256 0x0103

#define DZIP_STAT_NAME				0x0001
#define DZIP_STAT_INDEX				0x0002
#define DZIP_STAT_SIZE				0x0004
#define DZIP_STAT_COMP_SIZE			0x0008
#define DZIP_STAT_MTIME				0x0010
#define DZIP_STAT_CRC				0x0020
#define DZIP_STAT_COMP_METHOD		0x0040
#define DZIP_STAT_ENCRYPTION_METHOD	0x0080
#define DZIP_STAT_FLAGS				0x0100

#define ZIP_EXTRA_FIELD_ALL 0xffff
#define ZIP_EXTRA_FIELD_NEW 0xffff

#define ZIP_FL_LOCAL 256
#define ZIP_FL_CENTRAL 512

#DEFINE GENERIC_READ	0x80000000
#DEFINE GENERIC_WRITE	0x40000000
#Define FILE_SHARE_READ			1
#Define FILE_SHARE_WRITE		2

#define OPEN_EXISTING				0x03
#define FILE_ATTRIBUTE_NORMAL		0x80
#define FILE_FLAG_BACKUP_SEMANTICS	0x02000000


