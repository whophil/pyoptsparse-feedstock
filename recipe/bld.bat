@echo on

cd %SRC_DIR%

:: stuff copied from scipy-feedstock
:: <!-- https://github.com/conda-forge/scipy-feedstock/blob/40592d7c04a7fe28191b39616837217ed285ee90/recipe/build-output.bat#L27-L45
REM set compilers to clang-cl
set "CC=clang-cl"
set "CXX=clang-cl"

:: flang 17 still uses "temporary" name
set "FC=flang-new"

:: need to read clang version for path to compiler-rt
FOR /F "tokens=* USEBACKQ" %%F IN (`clang.exe -dumpversion`) DO (
    SET "CLANG_VER=%%F"
)

:: attempt to match flags for flang as we set them for clang-on-win, see
:: https://github.com/conda-forge/clang-win-activation-feedstock/blob/main/recipe/activate-clang_win-64.sh
:: however, -Xflang --dependent-lib=msvcrt currently fails as an unrecognized option, see also
:: https://github.com/llvm/llvm-project/issues/63741
set "FFLAGS=-D_CRT_SECURE_NO_WARNINGS -D_MT -D_DLL --target=x86_64-pc-windows-msvc -nostdlib"
set "LDFLAGS=--target=x86_64-pc-windows-msvc -nostdlib -Xclang --dependent-lib=msvcrt -fuse-ld=lld"
set "LDFLAGS=%LDFLAGS% -Wl,-defaultlib:%BUILD_PREFIX%/Library/lib/clang/!CLANG_VER:~0,2!/lib/windows/clang_rt.builtins-x86_64.lib"
:: -->

REM See the unix build.sh for more details on the build process below.
set MESON_ARGS=-Dpython_target=%PYTHON% %EXTRA_FLAGS%
python -m build -n -x .
pip install --prefix "%PREFIX%" --no-deps --no-index --find-links dist pyoptsparse