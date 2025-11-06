function [PredSnoreMLR_All, PredSnoreLR_All] = RunPredSiteFromSnore(MrangeOverride)

global settings AMasterSpreadsheet ChannelsList ChannelsFs

TotalNumPts=size(settings.patients,1);
PtRangeTemp = 1:1:TotalNumPts; %normally
Mrange = PtRangeTemp(settings.analyzelist==1);

if exist('MrangeOverride','var')
    Mrange = MrangeOverride;
end

PredSnoreMLR_All = [];
PredSnoreLR_All = [];

for ptnum = Mrange
    % load analyzed data
    directoryA = settings.AnalyzedDirectory;
    filenameA = [directoryA, settings.savename,'_',num2str(ptnum)];
    A = load(filenameA);
    
    BreathSnoreTable = A.SnoreTables.(['BreathSnoreTable',num2str(settings.DBthres)]) ;
    
    [PredSnoreTblMLR,PredSnoreTblLR] = PredictSiteFromSnore(BreathSnoreTable);
    
    PredSnoreMLR_All = [PredSnoreMLR_All;PredSnoreTblMLR];
    PredSnoreLR_All = [PredSnoreLR_All;PredSnoreTblLR];
end