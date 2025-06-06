// RUN: iree-opt --split-input-file --pass-pipeline='builtin.module(iree-amdaie-lowering-strategy{target-device=npu4})' %s | FileCheck %s
// RUN: iree-opt --split-input-file --pass-pipeline='builtin.module(iree-amdaie-lowering-strategy{target-device=npu4 use-tile-pipeline=pack-peel-4-level-tiling})' %s | FileCheck %s --check-prefix=PACK-PEEL-4-LEVEL

// CHECK:       #config = #iree_codegen.lowering_config<tile_sizes = [
// CHECK-SAME:                [128, 128, 0], [0, 0, 1], [1, 1, 0]
// CHECK-SAME:            ]>
// CHECK:       #packingConfig = #amdaie.packing_config<packing_config = [{packedSizes = [32, 32, 128], transposePackIndices = [0, 1, 2], unpackEmpty = [false, false, true],
// CHECK-SAME:                      innerPerm = [
// CHECK-SAME:                              [0, 1], [1, 0], [0, 1]
// CHECK-SAME:                   ], outerPerm = [
// CHECK-SAME:                              [0, 1], [1, 0], [1, 0]
// CHECK-SAME:                   ]}, {packedSizes = [0, 0, 0, 8, 8, 8], transposePackIndices = [0, 1, 2], unpackEmpty = [false, false, true],
// CHECK-SAME:                      innerPerm = [
// CHECK-SAME:                              [0, 1], [1, 0], [0, 1]
// CHECK-SAME:                   ], outerPerm = [
// CHECK-SAME:                              [0, 1, 3, 2], [0, 1, 3, 2], [0, 1, 3, 2]
// CHECK-SAME:                   ]}]>

// PACK-PEEL-4-LEVEL{LITERAL}: #config = #iree_codegen.lowering_config<tile_sizes = [[128, 128, 0], [4, 4, 0], [0, 0, 1], [1, 1, 0]]>
// PACK-PEEL-4-LEVEL{LITERAL}: #packingConfig = #amdaie.packing_config<packing_config = [{packedSizes = [32, 32, 128], transposePackIndices = [0, 1, 2], unpackEmpty = [false, false, true], innerPerm = [[0, 1], [1, 0], [0, 1]], outerPerm = [[0, 1], [1, 0], [1, 0]]}, {packedSizes = [0, 0, 0, 8, 8, 8], transposePackIndices = [0, 1, 2], unpackEmpty = [false, false, true], innerPerm = [[0, 1], [1, 0], [0, 1]], outerPerm = [[0, 1, 3, 2], [0, 1, 3, 2], [0, 1, 3, 2]]}]>
#pipeline_layout = #hal.pipeline.layout<bindings = [
  <storage_buffer>,
  <storage_buffer>,
  <storage_buffer>
]>
module {
  func.func @matmul_i32_dispatch_0_matmul_128x128x256_bf16xbf16xf32() {
    %cst = arith.constant 0.000000e+00 : f32
    %c0 = arith.constant 0 : index
    %0 = hal.interface.binding.subspan layout(#pipeline_layout) binding(0) alignment(64) offset(%c0) flags(ReadOnly) : !iree_tensor_ext.dispatch.tensor<readonly:tensor<128x256xbf16>>
    %1 = hal.interface.binding.subspan layout(#pipeline_layout) binding(1) alignment(64) offset(%c0) flags(ReadOnly) : !iree_tensor_ext.dispatch.tensor<readonly:tensor<256x128xbf16>>
    %2 = hal.interface.binding.subspan layout(#pipeline_layout) binding(2) alignment(64) offset(%c0) : !iree_tensor_ext.dispatch.tensor<writeonly:tensor<128x128xf32>>
    %3 = iree_tensor_ext.dispatch.tensor.load %0, offsets = [0, 0], sizes = [128, 256], strides = [1, 1] : !iree_tensor_ext.dispatch.tensor<readonly:tensor<128x256xbf16>> -> tensor<128x256xbf16>
    %4 = iree_tensor_ext.dispatch.tensor.load %1, offsets = [0, 0], sizes = [256, 128], strides = [1, 1] : !iree_tensor_ext.dispatch.tensor<readonly:tensor<256x128xbf16>> -> tensor<256x128xbf16>
    %5 = tensor.empty() : tensor<128x128xf32>
    %6 = linalg.fill ins(%cst : f32) outs(%5 : tensor<128x128xf32>) -> tensor<128x128xf32>
    // CHECK:  linalg.matmul {lowering_config = #config, packing_config = #packingConfig}
    %7 = linalg.matmul ins(%3, %4 : tensor<128x256xbf16>, tensor<256x128xbf16>) outs(%6 : tensor<128x128xf32>) -> tensor<128x128xf32>
    iree_tensor_ext.dispatch.tensor.store %7, %2, offsets = [0, 0], sizes = [128, 128], strides = [1, 1] : tensor<128x128xf32> -> !iree_tensor_ext.dispatch.tensor<writeonly:tensor<128x128xf32>>
    return
  }
}
