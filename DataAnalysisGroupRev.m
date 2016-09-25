% MATLAB Arbitrarily Learned Sensorimotor Assocation Project
% Data Analysis Group 
%
% Chinasa T. Okolo
% July 27th, 2016
% HHMI EXROP
% Shadlen Lab
%

% Graph for Gender vs Reaction Time
xGroup = [1 2 3 4];
yNew = vertcat(y, y2, y3);
mean1 = mean(yNew(:,1));
mean2 = mean(yNew(:,2));
mean3 = mean(yNew(:,3));
mean4 = mean(yNew(:,4));
yGroup = [mean1 mean2 mean3 mean4];

stdNew = vertcat(stdRT, stdRT2, stdRT3);
std1 = std(stdNew(:,1));
std2 = std(stdNew(:,2));
std3 = std(stdNew(:,3));
std4 = std(stdNew(:,4));
stdRTGroup = [std1 std2 std3 std4];

eGroup = stdRTGroup/sqrt(3);
figure
hold on
bar(xGroup,yGroup)
errorbar(xGroup,yGroup,eGroup)
title('Gender vs Reaction Time')

% Graph for Orientation vs Reaction Time
uniqueOriDiffCorr = vertcat(uniqueOriDiff, uniqueOriDiff2, uniqueOriDiff3);
MRTOdiffCorr = vertcat(meanRTbyOdiffCor, meanRTbyOdiffCor2, meanRTbyOdiffCor3);
    MRTCorrGroup = mean(MRTOdiffCorr);
RTSEMOdiffCorr = vertcat(rtSEMbyOdiffCor, rtSEMbyOdiffCor2, rtSEMbyOdiffCor3);
    %RTSEMCorrGroup = mean(RTSEMOdiffCorr);
    
stdRTGroup2 = [stdCorr stdCorr2 stdCorr3];
eGroup2 = stdRTGroup2/sqrt(3);

uniqueOriDiffInc = vertcat(uniqueOriDiffInc1, uniqueOriDiffInc2, uniqueOriDiffInc3);
MRTOdiffInc = vertcat(meanRTbyOdiffInc, meanRTbyOdiffInc2, meanRTbyOdiffInc3);
    MRTIncGroup = mean(MRTOdiffInc);
RTSEMOdiffInc = vertcat(rtSEMbyOdiffInc, rtSEMbyOdiffInc2, rtSEMbyOdiffInc3);
    %RTSEMIncGroup = mean(RTSEMOdiffInc);
    
stdRTGroup3 = [stdInc stdInc2 stdInc3];
eGroup3 = stdRTGroup3/sqrt(3);   

figure
subplot(2,1,1)   
hold on
plot(uniqueOriDiffCorr,MRTCorrGroup,'k-o')
errorbar(uniqueOriDiffCorr,MRTCorrGroup,RTSEMOdiffCorr)
title('Mean RT of Orientation Difference in Correct Trials')

subplot(2,1,2)    
hold on
plot(uniqueOriDiffInc,MRTIncGroup,'k-o')
errorbar(uniqueOriDiffInc,MRTIncGroup,RTSEMOdiffInc)
title('Mean RT of Orientation Difference in Incorrect Trials')