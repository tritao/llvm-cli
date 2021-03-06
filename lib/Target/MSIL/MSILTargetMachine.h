//===-- MSILTargetMachine.h - TargetMachine for the MSIL backend *- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
// This file declares the TargetMachine that is used by the MSIL backend.
//
//===----------------------------------------------------------------------===//

#ifndef MSILTARGETMACHINE_H
#define MSILTARGETMACHINE_H

#include "llvm/Target/TargetMachine.h"

namespace llvm {

class formatted_raw_ostream;

struct MSILTargetMachine : public TargetMachine {
  MSILTargetMachine(const Target &T, StringRef TT,
                   StringRef CPU, StringRef FS, const TargetOptions &Options,
                   Reloc::Model RM, CodeModel::Model CM,
                   CodeGenOpt::Level OL)
    : TargetMachine(T, TT, CPU, FS, Options) {}

  virtual bool addPassesToEmitFile(PassManagerBase &PM,
                                   formatted_raw_ostream &Out,
                                   CodeGenFileType FileType,
                                   bool DisableVerify,
                                   AnalysisID StartAfter,
                                   AnalysisID StopAfter) override;

  virtual const DataLayout *getDataLayout() const { return 0; }
};

extern Target TheMSILTarget;

} // End llvm namespace


#endif
