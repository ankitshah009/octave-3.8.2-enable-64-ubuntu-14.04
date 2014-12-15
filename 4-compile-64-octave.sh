#!/bin/sh

##########################################################################################
### Initialize environment
##########################################################################################

# include main compilation parameters
my_dir="$(dirname "$0")"
. "$my_dir/compile-params.in"

cd ${octave64src}

##########################################################################################
### Compile Octave with 64-bit Indexing Enabled
##########################################################################################

# copy modification of octave source code
cp -Rf ${libs64src_mods}/octave-src/* ./

# configure compilation - depends on the SuiteSparse library version

if [ "${octave64_SS_version}" = "4.2.1" ]
then
# This works - fine - only 3 WARNINGS in configure (colamd, ccolamd, cholmod not found) 
# - compilation ok and tests with results PASS 11543, FAIL 0, XFAIL 7, SKIPPED 54
    ./configure \
      --with-colamd="-lcolamd -lsuitesparseconfig -lrt" \
      --with-colamd-includedir=${prefix64}/include --with-colamd-libdir=${prefix64}/lib \
      --with-ccolamd="-lccolamd -lsuitesparseconfig -lrt" \
      --with-ccolamd-includedir=${prefix64}/include --with-ccolamd-libdir=${prefix64}/lib \
      --with-cholmod="-lcholmod -lsuitesparseconfig -lrt" \
      --with-cholmod-includedir=${prefix64}/include --with-cholmod-libdir=${prefix64}/lib \
      --with-umfpack="-lumfpack -lsuitesparseconfig -lrt" \
      --with-umfpack-includedir=${prefix64}/include --with-umfpack-libdir=${prefix64}/lib \
      ${octave64_config_extra} --prefix=${prefix64} --enable-64 F77_INTEGER_8_FLAG='-fdefault-integer-8' LIBS="${libs64}" LD_LIBRARY_PATH="${prefix64}/lib" CPPFLAGS="-I${prefix64}/include" LDFLAGS="-L${prefix64}/lib"
elif [ "${octave64_SS_version}" = "4.4.1" ]
then
# getting compilation error if cholmod is specified
# thus we will compile without cholmod
    ./configure \
      --with-colamd="-lcolamd -lsuitesparseconfig -lrt" \
      --with-colamd-includedir=${prefix64}/include --with-colamd-libdir=${prefix64}/lib \
      --with-ccolamd="-lccolamd -lsuitesparseconfig -lrt" \
      --with-ccolamd-includedir=${prefix64}/include --with-ccolamd-libdir=${prefix64}/lib \
      --without-cholmod \
      --with-umfpack="-lumfpack -lsuitesparseconfig -lrt" \
      --with-umfpack-includedir=${prefix64}/include --with-umfpack-libdir=${prefix64}/lib \
      ${octave64_config_extra} --prefix=${prefix64} --enable-64 F77_INTEGER_8_FLAG='-fdefault-integer-8' LIBS="${libs64}" LD_LIBRARY_PATH="${prefix64}/lib" CPPFLAGS="-I${prefix64}/include" LDFLAGS="-L${prefix64}/lib"
else
    echo "SuiteSparse version ${octave64_SS_version} - compilation not tested/supported ... "; 
    exit 1
fi

# build 
make clean
make

##########################################################################################
### Test Octave
##########################################################################################

# test compilation if requested
if [ "${octave64_compilation_test}" = "Y" ] ; then 
# test compiled sources by executing internal checks
  echo "`date` : Executing Octave post-compilation tests (make check) ..."
  make check
fi
