/*
 * This code is derived from (original license follows):
 *
 * This is an OpenSSL-compatible implementation of the RSA Data Security, Inc.
 * MD5 Message-Digest Algorithm (RFC 1321).
 *
 * Homepage:
 * http://openwall.info/wiki/people/solar/software/public-domain-source-code/md5
 *
 * Author:
 * Alexander Peslyak, better known as Solar Designer <solar at openwall.com>
 *
 * This software was written by Alexander Peslyak in 2001.  No copyright is
 * claimed, and the software is hereby placed in the public domain.
 * In case this attempt to disclaim copyright and place the software in the
 * public domain is deemed null and void, then the software is
 * Copyright (c) 2001 Alexander Peslyak and it is hereby released to the
 * general public under the following terms:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted.
 *
 * There's ABSOLUTELY NO WARRANTY, express or implied.
 *
 * See md5.c for more information.
 */

#ifndef LLVM_SYSTEM_MD5_H
#define LLVM_SYSTEM_MD5_H

#include "llvm/ADT/SmallString.h"
#include "llvm/Support/DataTypes.h"

namespace llvm {

template <typename T> class ArrayRef;

class MD5 {
  // Any 32-bit or wider unsigned integer data type will do.
  typedef uint32_t MD5_u32plus;

  MD5_u32plus a, b, c, d;
  MD5_u32plus hi, lo;
  unsigned char buffer[64];
  MD5_u32plus block[16];

public:
  typedef unsigned char MD5Result[16];

  MD5();

  /// \brief Updates the hash for arguments provided.
  void update(ArrayRef<unsigned char> Data);

  /// \brief Finishes off the hash and puts the result in result.
  void final(MD5Result &result);

  /// \brief Translates the bytes in \p Res to a hex string that is
  /// deposited into \p Str. The result will be of length 32.
  static void stringifyResult(MD5Result &Res, SmallString<32> &Str);

private:
  const unsigned char *body(ArrayRef<unsigned char> Data);
};

}

#endif
