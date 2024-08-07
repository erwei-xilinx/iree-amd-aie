//===- XLLVMToLLVMIRTranslation.cpp - Translate AIEVec to LLVM IR ---------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
// (c) Copyright 2024 Advanced Micro Devices, Inc.
//
//===----------------------------------------------------------------------===//
//
// This file implements a translation between the AIEVec dialect and LLVM IR.
//
//===----------------------------------------------------------------------===//

#include "Passes.h"
#include "XLLVMDialect.h"
#include "llvm/IR/IRBuilder.h"
#include "mlir/IR/Operation.h"
#include "mlir/Target/LLVMIR/ModuleTranslation.h"

using namespace mlir;
using namespace mlir::LLVM;

namespace {
/// Implementation of the dialect interface that converts operations belonging
/// to the XLLVM dialect to LLVM IR.
class XLLVMDialectLLVMIRTranslationInterface
    : public LLVMTranslationDialectInterface {
 public:
  using LLVMTranslationDialectInterface::LLVMTranslationDialectInterface;

  /// Translates the given operation to LLVM IR using the provided IR builder
  /// and saving the state in `moduleTranslation`.
  LogicalResult convertOperation(
      Operation *op, llvm::IRBuilderBase &builder,
      LLVM::ModuleTranslation &moduleTranslation) const final {
    Operation &opInst = *op;
#include "aievec/XLLVMConversions.inc"

    return failure();
  }
};
}  // namespace

void mlir::iree_compiler::aievec::registerXLLVMDialectTranslation(
    DialectRegistry &registry) {
  registry.insert<xllvm::XLLVMDialect>();
  registry.addExtension(+[](MLIRContext *ctx, xllvm::XLLVMDialect *dialect) {
    dialect->addInterfaces<XLLVMDialectLLVMIRTranslationInterface>();
  });
}
