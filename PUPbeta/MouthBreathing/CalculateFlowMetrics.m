% EAS added on 2022-01-04 to detect and handle mouth breathing
% Calculate mouth breathing related metrics for a given flow window
function [meanFlow, medianFlow, stdDevFlow, IQRFlow, percentDifference, mouthBreathing] = CalculateFlowMetrics(windowFlow)
    global settings
    medianFlow = median(windowFlow);
    meanFlow = mean(windowFlow);
    stdDevFlow = std(windowFlow);
    IQRFlow = iqr(windowFlow);
    percentDifference = abs((medianFlow - meanFlow) / stdDevFlow) * 100;
    if (stdDevFlow == 0)
        percentDifference = 0;
    end
    mouthBreathing = 0; % no mouth breathing by default
    if (percentDifference >= settings.MouthBreathingPDThreshold)
        if (meanFlow > medianFlow)
            % expiratory mouth breathing
            mouthBreathing = 1;
        else
            % inspiratory mouth breathing
            mouthBreathing = -1;
        end
    end
end