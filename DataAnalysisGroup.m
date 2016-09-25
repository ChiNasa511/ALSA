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

% Graph for Grouped Gender vs Reaction Time
xGroupMatch = [1 2];
yNewMatch = vertcat(yMatch, yMatch2, yMatch3);
matchMean1 = mean(yNewMatch(:,1));
matchMean2 = mean(yNewMatch(:,2));
yGroupMatch = [matchMean1 matchMean2];

stdNew = vertcat(stdRTMatch, stdRTMatch2, stdRTMatch3);
stdMatch1 = std(stdNew(:,1));
stdMatch2 = std(stdNew(:,2));
stdRTGroupMatch = [stdMatch1 stdMatch2];

eGroupMatch = stdRTGroupMatch/sqrt(3);
figure
hold on
bar(xGroupMatch,yGroupMatch)
errorbar(xGroupMatch,yGroupMatch,eGroupMatch)
title('Gender vs Reaction Time')

% Concatenating all matching and nonmatching vectors
matchVectorGroup = vertcat(matchVector, matchVector2, matchVector3);
nonmatchVectorGroup = vertcat(nonmatchVector, nonmatchVector2, nonmatchVector3);

% Two Sample t-test
[testdecision,pvalue,ci,stats] = ttest2(matchVectorGroup,nonmatchVectorGroup);

% Graph for Orientation vs Reaction Time
figure
hold on
plot(uniqueOriDiff,meanRTbyOdiffCor,'k-o')
errorbar(uniqueOriDiff,meanRTbyOdiffCor,rtSEMbyOdiffCor)
plot(uniqueOriDiff2,meanRTbyOdiffCor2,'k-o')
errorbar(uniqueOriDiff2,meanRTbyOdiffCor2,rtSEMbyOdiffCor2)
plot(uniqueOriDiff3,meanRTbyOdiffCor3,'k-o')
errorbar(uniqueOriDiff3,meanRTbyOdiffCor3,rtSEMbyOdiffCor3)
title('Mean RT of Orientation Difference in Correct Trials')

figure  
hold on
plot(uniqueOriDiffInc1,meanRTbyOdiffInc,'k-o')
errorbar(uniqueOriDiffInc1,meanRTbyOdiffInc,rtSEMbyOdiffInc)
plot(uniqueOriDiffInc2,meanRTbyOdiffInc2,'k-o')
errorbar(uniqueOriDiffInc2,meanRTbyOdiffInc2,rtSEMbyOdiffInc2)
plot(uniqueOriDiffInc3,meanRTbyOdiffInc3,'k-o')
errorbar(uniqueOriDiffInc3,meanRTbyOdiffInc3,rtSEMbyOdiffInc3)
title('Mean RT of Orientation Difference in Incorrect Trials')

% Graph for Proportion Correct vs Orientation Difference
figure 
hold on
plot(uniqueOriDiff,meanACCDiff,'k-o')
plot(uniqueOriDiff,meanACCDiff2,'k-o')
plot(oriDiffFinal,meanACCDiff3,'k-o')
title('Effect of Orientation Difference on Proportion Correct')