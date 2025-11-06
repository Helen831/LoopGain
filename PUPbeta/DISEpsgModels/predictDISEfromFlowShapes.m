function DISEfromFlowShapesT = predictDISEfromFlowShapes(MrangeOverride)

FlowShapeT = getFlowShapeEventData(MrangeOverride);

load('DISEpsgModels.mat')
    PredList = {'nanmean_SkewDistInsp_O','nanmean_InspVol_03Ti_O','nanmean_TpeakI_TpeakE_O','nanmean_Vpeak1_Vpeak_O','nanmean_DV_NED2_T','nanmean_RiseTime50_T'};
    Tsub = FlowShapeT(:,PredList);
    
    TsubZscores = array2table((FlowShapeT{:,PredList}-ShapeMeans)./ShapeSDs);
        TsubZscores.Properties.VariableNames = strcat(PredList,'_1SD');
        Tsub = [Tsub TsubZscores];
        
        clear TsubZscores
    Tsub.Pr_CCCp = predict(mdlCCCp,Tsub);
    Tsub.Pr_LW = predict(mdlLW,Tsub);
    Tsub.Pr_TB = predict(mdlTB,Tsub);
    Tsub.Pr_E = predict(mdlE,Tsub);
    Tsub.Pr_CCpLWnotTBE = predict(mdlCCCpLWnotTBE,Tsub);
    
    Tsub.PredCCCp = 1*(Tsub.Pr_CCCp > mdlCCCp_Cutoff); 
        Tsub.PredCCCp(isnan(Tsub.Pr_CCCp))=NaN;
    Tsub.PredLW = 1*(Tsub.Pr_LW > mdlLW_Cutoff); 
        Tsub.PredLW(isnan(Tsub.Pr_LW))=NaN;
    Tsub.PredTB = 1*(Tsub.Pr_TB > mdlTB_Cutoff);
        Tsub.PredTB(isnan(Tsub.Pr_TB))=NaN;
    Tsub.PredE = 1*(Tsub.Pr_E > mdlE_Cutoff); 
        Tsub.PredE(isnan(Tsub.Pr_E))=NaN;
    Tsub.PredCCpLWnotTBE = 1*(Tsub.Pr_CCpLWnotTBE > mdlCCCpLWnotTBE_Cutoff);
        Tsub.PredCCpLWnotTBE(isnan(Tsub.Pr_CCpLWnotTBE))=NaN;
        
        DISEfromFlowShapesT = Tsub;
        %%
        if 0
            global settings
            DISEfromFlowShapesT = predictDISEfromFlowShapes(1:2060);
            save([settings.SummaryDirectory  'DISEfromFlowShapesT.mat'],'DISEfromFlowShapesT')
        end
        
        
    