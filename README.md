Startup

1. Note the location of your PUPbeta_git 'software' folder
2. Create a location for your Data, e.g. in '...\MyProject\Source\'
3. Copy the PUPstart folder into e.g. '...\MyProject\' so that it is next to the Source folder. 
4. Open StartHere.m in Matlab
-Customize the line: 
line 37> codedirpartial{5} = 'D:\Dropbox (Partners HealthCare)\'; 
to reflect where your software folder is located, which for me was 'D:\Dropbox (Partners HealthCare)\'
5. Customize settings in "Recommended settings to Customize" at approximately line 56-60
-Fs is the Sampling rate, we prefer 100-149 Hz, best to choose something that is a multiple of your Flow sampling rate. e.g. if you have 128 Hz then keep it at 128. If you have 64 Hz flow, then 128 Hz is good. if you have 50 Hz flow then upsample to 100 Hz etc.
-savename is the project name. default is 'MyProject'. Change this to whatever you like. 
-Pnasaldownisinsp specifies whether nasal pressure airflow is normally inspiration down (1) or inspiration is up (0)
6. Run StartHere in MATLAB (press F5). MATLAB should execute code for several seconds with no errors (red), and open a user interface.  
7. Click 'Open spreadsheet' on the user interface.

Spreadsheet setup--Convert
8. Fill out the spreadsheet to indicate the filenames of exported EDFs (column U) and any annotations files (column V for events, column W for epochs; can be the same annotations file). 
9. It is easiest if data are all within Source and annotations are named the same as the EDF. If data are in subdirectories then you can specify these subdirectories e.g. "1534\" in cols X,Y,Z.
10. You will need to know the "System" you are exporting data from and this system must be built into our software. Current options include: 
'ProfusionXML'
'Minerva'
'BrainRT'
'RemLogic'
'RemLogicXML'
'RemLogicText'
'Alice
'AliceTaiwan'
'AliceG3'
'AliceG3Machine'
'AliceG3Taiwan'
'Deltamed'
'SomnoStarEpochsXls'
'GrassTwinTxt'
'Sandman'
'SandmanPlusLabview'
'NKxdf'
'NKxdfB'
'EdfUnscored'
'Danalyzer'
'Michele'
'ApneaLink'
'AnnotEannot'
'NSRR'
'MignotAutostage'
'Spike'
'NoxMat'
'NoxMatSAS'
'NoxMatT3'
11. Tell Column AB which patients you want to convert. 1=Yes, 0=Skip.
12. Save and Close Spreadsheet

EDF Channel Linking 
13. Rerun PUPstart in MATLAB 
14. Run Channel Labels, Spreadsheet should open. Channel names for each channel number should be in cols BS and across. 
15. Enter the appropriate channel numbers in AJ to BE. NaN incidates missing. Can use Excel prograaming or manual entry here.
16. If EEG data in the Source EDF are 'unpaired' then put the pairs in adjacent columns e.g. EEG1=C3, EEG2=M2 and set EverySecondEEGisRef=1;
17. Save Spreadsheet


18. Run Convert via user interface. 
19. Check files are in the Converted folder as expected
20. Optional: run "LoadAndPlot(X)" in the command window for the PSG in row X of the spreadsheet to plot the data and check stages, events, and arousals were properly imported.
21. Run Analyze via user interface
22. Run Summary via user interface
Open the generated table file in the SummaryAnalysis Folder in matlab to see the results




