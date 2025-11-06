function [PredSnoreTblMLR,PredSnoreTblLR] = PredictSiteFromSnore(BreathSnoreTable)
global settings
%% Predict site of collapse
load([settings.folder 'Dropbox (Partners HealthCare)\MEEI DISE\Dan\Model workspaces\PredSiteMLR_MdlCoeff.mat'],...
    'B','FtrsInMdl','FtrNamesInMdl','FtrNames')
FtrIdx = ismember(BreathSnoreTable.Properties.VariableNames,FtrNames);
FeatureArray = BreathSnoreTable{:,FtrIdx};
[PrVOTE] = mnrval(B,FeatureArray(:,FtrsInMdl), 'Model', 'nominal');
[~,PredVOTE_i] = max(PrVOTE,[],2);
VOTEopts = repmat([1 2 3 4], size(FeatureArray,1),1);
PredVOTE = VOTEopts == PredVOTE_i;

PredSnoreMLR = [FeatureArray(:,FtrsInMdl) PrVOTE PredVOTE];
PredSnoreTblMLR = array2table(PredSnoreMLR);
PredSnoreTblMLR.Properties.VariableNames = [FtrNamesInMdl ...
    {'PrV_MLR' 'PrO_MLR' 'PrT_MLR' 'PrE_MLR'} ...
    {'PredV_MLR' 'PredO_MLR' 'PredT_MLR' 'PredE_MLR'}];
clear B FtrNames FtrNamesInMdl FtrsInMdl PredSnoreMLR PredVOTE_i VOTEopts

% LR models
load([settings.folder 'Dropbox (Partners HealthCare)\MEEI DISE\Dan\Model workspaces\PredSiteLR_MdlCoeff.mat'],...
    'mdlFinalV','thresoptV','mdlFinalO','thresoptO','mdlFinalT','thresoptT','mdlFinalE','thresoptE')
PrV_LR = predict(mdlFinalV,BreathSnoreTable);
PredV_LR = PrV_LR > thresoptV;
PrO_LR = predict(mdlFinalO,BreathSnoreTable);
PredO_LR = PrO_LR > thresoptO;
PrT_LR = predict(mdlFinalT,BreathSnoreTable);
PredT_LR = PrT_LR > thresoptT;
PrE_LR = predict(mdlFinalE,BreathSnoreTable);
PredE_LR = PrE_LR > thresoptE;

FtrNamesInMdl = unique([mdlFinalV.CoefficientNames mdlFinalO.CoefficientNames ...
    mdlFinalT.CoefficientNames mdlFinalE.CoefficientNames]);
FtrIdx = ismember(BreathSnoreTable.Properties.VariableNames,...
    FtrNamesInMdl);
FtrTblSubset = BreathSnoreTable(:,FtrIdx);
PredSnoreLR = [FtrTblSubset{:,:} PrV_LR PrO_LR PrT_LR PrE_LR ...
    PredV_LR PredO_LR PredT_LR PredE_LR];
PredSnoreTblLR = array2table(PredSnoreLR);
PredSnoreTblLR.Properties.VariableNames = [FtrTblSubset.Properties.VariableNames ...
    {'PrV_LR' 'PrO_LR' 'PrT_LR' 'PrE_LR'} ...
    {'PredV_LR' 'PredO_LR' 'PredT_LR' 'PredE_LR'}];
