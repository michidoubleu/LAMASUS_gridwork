@echo off
pushd %~dp0
Rscript ..\Condor_run_basic.R config.R || (
    popd
    exit /b 1
)
Rscript ..\Condor_run_stats.R config.R
popd
