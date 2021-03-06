/*
 * Copyright 2016 MongoDB, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


#include <stdlib.h>
#include <my_global.h>
#include "mongoc-config.h"

#ifndef MONGOC_CRYPTO_PRIVATE_H
#define MONGOC_CRYPTO_PRIVATE_H

typedef struct _mongoc_crypto_t mongoc_crypto_t;

struct _mongoc_crypto_t {
   void (*hmac_sha1) (mongoc_crypto_t *crypto,
                      const void *key,
                      int key_len,
                      const unsigned char *d,
                      int n,
                      unsigned char *md /* OUT */);
   my_bool (*sha1) (mongoc_crypto_t *crypto,
                 const unsigned char *input,
                 const size_t input_len,
                 unsigned char *output /* OUT */);
};

void
mongoc_crypto_init (mongoc_crypto_t *crypto);

void
mongoc_crypto_hmac_sha1 (mongoc_crypto_t *crypto,
                         const void *key,
                         int key_len,
                         const unsigned char *d,
                         int n,
                         unsigned char *md /* OUT */);

my_bool
mongoc_crypto_sha1 (mongoc_crypto_t *crypto,
                    const unsigned char *input,
                    const size_t input_len,
                    unsigned char *output /* OUT */);

#endif /* MONGOC_CRYPTO_PRIVATE_H */
