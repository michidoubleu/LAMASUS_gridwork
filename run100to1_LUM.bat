@echo off
pushd %~dp0
Rscript ..\Condor_run_basic.R config_LUM.R || (
    popd
    exit /b 1
)
Rscript ..\Condor_run_stats.R config_LUM.R
popd
