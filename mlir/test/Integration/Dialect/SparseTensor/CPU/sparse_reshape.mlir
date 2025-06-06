//--------------------------------------------------------------------------------------------------
// WHEN CREATING A NEW TEST, PLEASE JUST COPY & PASTE WITHOUT EDITS.
//
// Set-up that's shared across all tests in this directory. In principle, this
// config could be moved to lit.local.cfg. However, there are downstream users that
//  do not use these LIT config files. Hence why this is kept inline.
//
// DEFINE: %{sparsifier_opts} = enable-runtime-library=true
// DEFINE: %{sparsifier_opts_sve} = enable-arm-sve=true %{sparsifier_opts}
// DEFINE: %{compile} = mlir-opt %s --sparsifier="%{sparsifier_opts}"
// DEFINE: %{compile_sve} = mlir-opt %s --sparsifier="%{sparsifier_opts_sve}"
// DEFINE: %{run_libs} = -shared-libs=%mlir_c_runner_utils,%mlir_runner_utils
// DEFINE: %{run_libs_sve} = -shared-libs=%native_mlir_runner_utils,%native_mlir_c_runner_utils
// DEFINE: %{run_opts} = -e main -entry-point-result=void
// DEFINE: %{run} = mlir-runner %{run_opts} %{run_libs}
// DEFINE: %{run_sve} = %mcr_aarch64_cmd --march=aarch64 --mattr="+sve" %{run_opts} %{run_libs_sve}
//
// DEFINE: %{env} =
//--------------------------------------------------------------------------------------------------

// RUN: %{compile} | %{run} | FileCheck %s
//
// Do the same run, but now with direct IR generation.
// REDEFINE: %{sparsifier_opts} = enable-runtime-library=false
// RUN: %{compile} | %{run} | FileCheck %s
//
// Do the same run, but now with direct IR generation and vectorization.
// REDEFINE: %{sparsifier_opts} = enable-runtime-library=false vl=2 reassociate-fp-reductions=true enable-index-optimizations=true
// RUN: %{compile} | %{run} | FileCheck %s
//
// Do the same run, but now with direct IR generation and VLA vectorization.
// RUN: %if mlir_arm_sve_tests %{ %{compile_sve} | %{run_sve} | FileCheck %s %}

#SparseVector = #sparse_tensor.encoding<{
  map = (d0) -> (d0 : compressed)
}>

#SparseMatrix = #sparse_tensor.encoding<{
  map = (d0, d1) -> (d0 : compressed, d1 : compressed)
}>

#Sparse3dTensor = #sparse_tensor.encoding<{
  map = (d0, d1, d2) -> (d0 : compressed, d1 : compressed, d2 : compressed)
}>

module {

  func.func @reshape0(%arg0: tensor<3x4xf64, #SparseMatrix>) -> tensor<2x6xf64, #SparseMatrix> {
    %shape = arith.constant dense <[ 2, 6 ]> : tensor<2xi32>
    %0 = tensor.reshape %arg0(%shape) : (tensor<3x4xf64, #SparseMatrix>, tensor<2xi32>) -> tensor<2x6xf64, #SparseMatrix>
    return %0 : tensor<2x6xf64, #SparseMatrix>
  }

  func.func @reshape1(%arg0: tensor<3x4xf64, #SparseMatrix>) -> tensor<12xf64, #SparseVector> {
    %shape = arith.constant dense <[ 12 ]> : tensor<1xi32>
    %0 = tensor.reshape %arg0(%shape) : (tensor<3x4xf64, #SparseMatrix>, tensor<1xi32>) -> tensor<12xf64, #SparseVector>
    return %0 : tensor<12xf64, #SparseVector>
  }

  func.func @reshape2(%arg0: tensor<3x4xf64, #SparseMatrix>) -> tensor<2x3x2xf64, #Sparse3dTensor> {
    %shape = arith.constant dense <[ 2, 3, 2 ]> : tensor<3xi32>
    %0 = tensor.reshape %arg0(%shape) : (tensor<3x4xf64, #SparseMatrix>, tensor<3xi32>) -> tensor<2x3x2xf64, #Sparse3dTensor>
    return %0 : tensor<2x3x2xf64, #Sparse3dTensor>
  }


  func.func @main() {
    %m = arith.constant dense <[ [ 1.1,  0.0,  1.3,  0.0 ],
                                 [ 2.1,  0.0,  2.3,  0.0 ],
                                 [ 3.1,  0.0,  3.3,  0.0 ]]> : tensor<3x4xf64>
    %sm = sparse_tensor.convert %m : tensor<3x4xf64> to tensor<3x4xf64, #SparseMatrix>

    %reshaped0 = call @reshape0(%sm) : (tensor<3x4xf64, #SparseMatrix>) -> tensor<2x6xf64, #SparseMatrix>
    %reshaped1 = call @reshape1(%sm) : (tensor<3x4xf64, #SparseMatrix>) -> tensor<12xf64, #SparseVector>
    %reshaped2 = call @reshape2(%sm) : (tensor<3x4xf64, #SparseMatrix>) -> tensor<2x3x2xf64, #Sparse3dTensor>

    %c0 = arith.constant 0 : index
    %df = arith.constant -1.0 : f64

    //
    // CHECK:      ---- Sparse Tensor ----
    // CHECK-NEXT: nse = 6
    // CHECK-NEXT: dim = ( 2, 6 )
    // CHECK-NEXT: lvl = ( 2, 6 )
    // CHECK-NEXT: pos[0] : ( 0, 2 )
    // CHECK-NEXT: crd[0] : ( 0, 1 )
    // CHECK-NEXT: pos[1] : ( 0, 3, 6 )
    // CHECK-NEXT: crd[1] : ( 0, 2, 4, 0, 2, 4 )
    // CHECK-NEXT: values : ( 1.1, 1.3, 2.1, 2.3, 3.1, 3.3 )
    // CHECK-NEXT: ----
    // CHECK:      ---- Sparse Tensor ----
    // CHECK-NEXT: nse = 6
    // CHECK-NEXT: dim = ( 12 )
    // CHECK-NEXT: lvl = ( 12 )
    // CHECK-NEXT: pos[0] : ( 0, 6 )
    // CHECK-NEXT: crd[0] : ( 0, 2, 4, 6, 8, 10 )
    // CHECK-NEXT: values : ( 1.1, 1.3, 2.1, 2.3, 3.1, 3.3 )
    // CHECK-NEXT: ----
    // CHECK:      ---- Sparse Tensor ----
    // CHECK-NEXT: nse = 6
    // CHECK-NEXT: dim = ( 2, 3, 2 )
    // CHECK-NEXT: lvl = ( 2, 3, 2 )
    // CHECK-NEXT: pos[0] : ( 0, 2 )
    // CHECK-NEXT: crd[0] : ( 0, 1 )
    // CHECK-NEXT: pos[1] : ( 0, 3, 6 )
    // CHECK-NEXT: crd[1] : ( 0, 1, 2, 0, 1, 2 )
    // CHECK-NEXT: pos[2] : ( 0, 1, 2, 3, 4, 5, 6 )
    // CHECK-NEXT: crd[2] : ( 0, 0, 0, 0, 0, 0 )
    // CHECK-NEXT: values : ( 1.1, 1.3, 2.1, 2.3, 3.1, 3.3 )
    // CHECK-NEXT: ----
    //
    sparse_tensor.print %reshaped0: tensor<2x6xf64, #SparseMatrix>
    sparse_tensor.print %reshaped1: tensor<12xf64, #SparseVector>
    sparse_tensor.print %reshaped2: tensor<2x3x2xf64, #Sparse3dTensor>

    bufferization.dealloc_tensor %sm : tensor<3x4xf64, #SparseMatrix>
    bufferization.dealloc_tensor %reshaped0 : tensor<2x6xf64, #SparseMatrix>
    bufferization.dealloc_tensor %reshaped1 : tensor<12xf64, #SparseVector>
    bufferization.dealloc_tensor %reshaped2 : tensor<2x3x2xf64, #Sparse3dTensor>

    return
  }

}
