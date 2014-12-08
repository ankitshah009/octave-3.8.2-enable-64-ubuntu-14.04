#!/bin/sh

#######################################################################################
### Initialization of the environment
#######################################################################################

# include main compilation parameters
my_dir="$(dirname "$0")"
. "$my_dir/compile-params.in"

# make shared lib directories - otherwise lib compilation creates lib / include / ... file instead of files within the directory
sudo mkdir ${prefix64}/lib
sudo mkdir ${prefix64}/include
sudo mkdir ${prefix64}/share
sudo mkdir ${prefix64}/bin

# pre-compile 64bit indexing for libs
cd ${libs64src}

#######################################################################################
# BLAS
#######################################################################################
cp -Rf ${libs64src_mods}/BLAS.mod/* BLAS/
cd BLAS
# make clean
make prefix64=${prefix64}
# test compilation if requested
if [ "${octave64_libs_compilation_test}" = "Y" ] ; then 
# add library compilation test here - if supported
  echo BLAS lib testing not supported
fi
cd ..

#######################################################################################
# LAPACK
#######################################################################################
cp -Rf ${libs64src_mods}/LAPACK.mod/* LAPACK/
cp -f ./BLAS/blas_LINUX.a ./LAPACK/libblas.a
cd LAPACK
# make clean
make lib prefix64=${prefix64}
# test compilation if requested
if [ "${octave64_libs_compilation_test}" = "Y" ] ; then 
# add library compilation test here - if supported
  make blas_testing prefix64=${prefix64}
  make lapack_testing prefix64=${prefix64}
fi
# installation 
sudo make lapack_install prefix64=${prefix64}
cd ..

#######################################################################################
# BLAS & LAPACK - installation
#######################################################################################
#  copy BLAS & LAPACK to LIB directory
sudo cp -f LAPACK/*.a ${prefix64}/lib

#######################################################################################
# ARPACK
#######################################################################################
cp -Rf ${libs64src_mods}/ARPACK.mod/* ARPACK/
cd ARPACK
# Compile directly into install directory $prefix64/lib
sudo make lib prefix64=${prefix64} octave64_gitroot=${octave64_gitroot} libs64=${libs64}
# Create SO-Lib in install directory $prefix64/lib
sudo ./make_so_lib.sh ${prefix64}
# test compilation if requested
if [ "${octave64_libs_compilation_test}" = "Y" ] ; then 
# add library compilation test here - if supported
  ARPACK lib testing not supported
fi
cd ..

################################################################################$
# QRUPDATE
################################################################################$
cp -Rf ${libs64src_mods}/QRUPDATE.mod/* QRUPDATE/
cd QRUPDATE
make lib solib prefix64=${prefix64} libs64=${libs64}
# test compilation if requested
if [ "${octave64_libs_compilation_test}" = "Y" ] ; then 
# add library compilation test here - if supported
  make test prefix64=${prefix64} libs64=${libs64}
fi
# Installation
sudo make install prefix64=${prefix64} libs64=${libs64}
cd ..

#######################################################################################
# SUITESPARSE
#######################################################################################
cp -Rf ${libs64src_mods}/SUITESPARSE.mod/* SUITESPARSE/
cd SUITESPARSE
# make prefix64=${prefix64}
make library prefix64=${prefix64}
# test compilation if requested
if [ "${octave64_libs_compilation_test}" = "Y" ] ; then 
# test of SUITESPARSE - if supported
  echo SUITESPARSE lib testing not supported
# test of metis-4.0 used inside SUITESPARSE
  echo "Testing metis-4.0 in SUITESPARSE ..."
  cd metis-4.0/Graphs
  ./mtest *.mgraph
  cd ../..
fi
# new version has already "make install" 
sudo make install prefix64=${prefix64}
cd ..

#######################################################################################
# QHULL
#######################################################################################
cp -Rf ${libs64src_mods}/QHULL.mod/* QHULL/
cd QHULL
make prefix64=${prefix64}
# test compilation if requested
if [ "${octave64_libs_compilation_test}" = "Y" ] ; then 
# add library compilation test here - if supported
  make test prefix64=${prefix64}
fi
# Installation
sudo make install prefix64=${prefix64}
cd ..

#######################################################################################
#  GLPK
#######################################################################################
# no GLPK modifications
# cp -Rf ${libs64src_mods}/GLPK.mod/* GLPK/
cd GLPK
./configure prefix=${prefix64}
make prefix64=${prefix64}
# test compilation if requested
if [ "${octave64_libs_compilation_test}" = "Y" ] ; then 
# add library compilation test here - if supported
  make check prefix64=${prefix64}
fi
# Installation
sudo make install prefix64=${prefix64}
cd ..

#######################################################################################
# end of libs
#######################################################################################
cd ../..

