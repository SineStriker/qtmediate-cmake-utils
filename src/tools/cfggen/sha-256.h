#ifndef SHA_256_H
#define SHA_256_H

// https://github.com/notepad-plus-plus/notepad-plus-plus/blob/master/PowerEditor/src/MISC/sha2

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void calc_sha_256(uint8_t hash[32], const void *input, size_t len);

#ifdef __cplusplus
}
#endif

#endif // SHA_256_H
