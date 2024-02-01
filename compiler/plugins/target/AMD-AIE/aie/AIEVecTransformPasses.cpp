// Copyright 2024 The IREE Authors
//
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

// #include "aie/Dialect/AIEVec/Transforms/Passes.h"
#include "aie/Dialect/AIEVec/Pipelines/Passes.h"

// namespace {
// #define GEN_PASS_REGISTRATION
// #include "aie/Dialect/AIEVec/Transforms/Passes.h.inc"
// }  // namespace

namespace mlir::iree_compiler::AMDAIE {
void registerAIEVecTransformPasses() {
  xilinx::aievec::registerAIEVecPipelines();
}
}  // namespace mlir::iree_compiler::AMDAIE
