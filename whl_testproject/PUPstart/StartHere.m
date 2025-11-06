fh=findall(0,'type','figure');
close(fh);
clear global;
clear;
clc;

% This script sets up the necessary directory structure for the analysis
% Initially, the only directory is PUPbeta20190205,which contains the code
% After running this script (by pressing F5), the following directories will be made:
% Analyzed                  - Results of Analysis are output here
% Analyzed\EventAnalyzed    - Results of Event analysis are output here
% Converted                 - Files that have been converted to the new standard format will appear here
% Source                    - This is a space where you can put your original PSG files if you wish
% Summary                   - The output of summary analysis goes here
%
% You can use this script after setting up the directories, 
% or you can just run PUPbeta.m from the code directory.

global settings PUPbetaGUI AMasterSpreadsheet

%% Set working directory, based on this script running, and add to path
mydir  = mfilename('fullpath');
idcs   = strfind(mydir,filesep);
settings.workdir = mydir(1:idcs(end-1));
addpath(genpath(settings.workdir));

%% Set the location of AMasterSpreadsheet and apply to settings
% this is usually in PuPstart in working dir
settings.AMasterdir = [settings.workdir 'PUPStart\'];
AMasterSpreadsheet = [settings.AMasterdir, 'AMasterSpreadsheet.xlsx']; % 

%% Where is the PUP software code (dropbox folder called "PUPbeta_git") located on your computer? Add all possible options here:
codedirpartial{1} = 'D:\呼吸调控LoopGain\WHL_PUPbeta_git\';
codedirpartial{2} = 'G:\Partners Healthcare Dropbox\SATP Group\';
codedirpartial{3} = 'G:\Dropbox (Personal)\';
codedirpartial{4} = 'C:\users\avz4\Dropbox\';
codedirpartial{5} = 'C:\Users\bwhha\Dropbox (Partners HealthCare)\';
codedirpartial{6} = 'C:\Users\qqz_w\Desktop\code\PUPbeta_git\';
codedirpartial{7} = 'C:\Users\qqz_w\Desktop';

settings.CurrentCodeVersion = 'PUPbeta';
for i=1:length(codedirpartial)
    codedirtemp = [codedirpartial{i} settings.CurrentCodeVersion '\'];
    if exist(codedirtemp,'dir')==7
        settings.codedir = codedirtemp;
        disp(['Code found in: ' settings.codedir])
        break
    end
end

if ~isfield(settings,'codedir')
    error('No code directory found');
end

addpath(genpath(settings.codedir));

%% Recommended settings to Customize
settings.Fs = 125; %Default
settings.savename = 'whl_test';
settings.Pnasaldownisinsp=1; %1 for inspiration down (default), 0 for inspiration up. If you have subjects that are different from your default you can further "InvertFlow" in the AMasterSpreadsheet Col AG
settings.PnasalUprightAuto=0; %Set to 1 if you do not know if inspiration is up or down, the code will guess. Is ~99% accurate. 

%% Specialized (optional) settings

%CONVERT
settings.parallelConvert=0; %default 0, set to 1 for faster but less transparent analysis

%ANALYSIS
settings.parallelAnalysis=0; %default 0, set to 1 for faster but less transparent analysis

%use the following for manual scoring that might be partially unreliable:
settings.lowVEareObstructiveEvents = 0; %default 0 / off; if used, set to 0.5

settings.ApplyClippingCorrection = 0; %Set to 1 for Alice data because it is usually clipped. 
settings.DriftEstimation=1; %set to 2 if you need to use advanced baseline drift correction of the flow signal

settings.useWSanalysisToReplaceAr = 0; %0=use original scoring, 1=use best EEG, 2=use "predicted best" EEG.
        %At startup simply rename new Ar channel as "EventsAr"; rename original/manual
        %"EventsAr" to "EventsArManual" during Analyze so that all functions
        %use the desired arousal scoring.
% 0 = 使用原始觉醒评分
settings.UseAutoScoredRespEventsForLG = 0;  %turn this on to use autoscored events in endotyping
% 0 = 使用手动评分的呼吸事件进行内型分析

%% make directories in workdir if they do not exist
if 1
    if ~(exist([settings.workdir,'Analyzed'], 'dir') == 7)
        mkdir([settings.workdir,'Analyzed']);
    end
    
    if ~(exist([settings.workdir,'Analyzed\EventAnalyzed'], 'dir') == 7)
        mkdir([settings.workdir,'Analyzed\EventAnalyzed']);
    end
    
    if ~(exist([settings.workdir,'Converted'], 'dir') == 7)
        mkdir([settings.workdir,'Converted']);
    end
    
    if ~(exist([settings.workdir,'Source'], 'dir') == 7)
        mkdir([settings.workdir,'Source']);
    end
    
    if ~(exist([settings.workdir,'Summary'], 'dir') == 7)
        mkdir([settings.workdir,'Summary']);
    end
end

%% Switch over to codedir
% not req'd for running PUPbeta, but makes later editing easier
cd(settings.codedir)

%% launch the front end
% having set many of the req'd settings here
[PUPbetaGUI] = PUPbeta(); % read from code dir, it's on the path now

%% Import other settings and defaults
settings = ImportSettings(settings,AMasterSpreadsheet);
