if (NOT CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|^i[3-9]86|aarch64$")
    return()
endif()

#
# Check compiler for SSE2 intrinsics
#
if (CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_CLANG )
    set(CMAKE_REQUIRED_FLAGS "-msse2")
    check_c_source_runs("
    #include <immintrin.h>

    int main()
    {
    __m128i a = _mm_setzero_si128();
    return 0;
    }"
    CC_HAS_SSE2_INTRINSICS)
endif()

#
# Check compiler for AVX intrinsics
#
if (CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_CLANG )
    set(CMAKE_REQUIRED_FLAGS "-mavx")
    check_c_source_runs("
    #include <immintrin.h>

    int main()
    {
    __m256i a = _mm256_setzero_si256();
    return 0;
    }"
    CC_HAS_AVX_INTRINSICS)
endif()

#
# Check compiler for NEON intrinsics
#
if (CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_CLANG )
    # NEON is supported by default for aarch64
    check_c_source_runs("
    #include <arm_neon.h>

    int main()
    {
    uint64x2_t a = vdupq_n_u64(0);
    return 0;
    }"
    CC_HAS_NEON_INTRINSICS)
endif()

if ((CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64") AND CC_HAS_SSE2_INTRINSICS)
    # any amd64 supports sse2 instructions
    set(ENABLE_SSE2_DEFAULT ON)
else()
    set(ENABLE_SSE2_DEFAULT OFF)
endif()

if ((CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64") AND CC_HAS_NEON_INTRINSICS)
    set(ENABLE_NEON_DEFAULT ON)
else()
    set(ENABLE_NEON_DEFAULT OFF)
endif()

option(ENABLE_SSE2 "Enable compile-time SSE2 support." ${ENABLE_SSE2_DEFAULT})
option(ENABLE_AVX  "Enable compile-time AVX support." OFF)

option(ENABLE_NEON "Enable compile-time NEON support." ${ENABLE_NEON_DEFAULT})

if (ENABLE_SSE2)
    if (!CC_HAS_SSE2_INTRINSICS)
        message( SEND_ERROR "SSE2 is enabled, but is not supported by compiler.")
    else()
        add_compile_flags("C;CXX" "-msse2")
        find_package_message(SSE2 "SSE2 is enabled - target CPU must supppot it"
            "${CC_HAS_SSE2_INTRINSICS}")
    endif()
endif()

if (ENABLE_AVX)
    if (!CC_HAS_AVX_INTRINSICS)
        message(SEND_ERROR "AVX is enabled")
    else()
        add_compile_flags("C;CXX" "-mavx")
        find_package_message(SSE2 "AVX is enabled - target CPU must support it"
            "${CC_HAS_AVX_INTRINSICS}")
    endif()
endif()

if (ENABLE_NEON)
    if (!CC_HAS_NEON_INTRINSICS)
        message( SEND_ERROR "NEON is enabled, but is not supported by compiler.")
    else()
        find_package_message(NEON "NEON is enabled - target CPU must supppot it"
            "${CC_HAS_NEON_INTRINSICS}")
    endif()
endif()
