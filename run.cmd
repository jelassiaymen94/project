@echo off
%~dp0\FXServer +set citizen_dir %~dp0\citizen\ %* +exec server.cfg

PAUSE