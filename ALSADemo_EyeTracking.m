% MATLAB Arbitrarily Learned Sensorimotor Assocation Project
%
% Chinasa T. Okolo
% July 7th, 2016
% HHMI EXROP
% Shadlen Lab
%
% Basic demo for sample-sample-test method.
%
% Possible things to change later:
% - take the duration of the picture from an exp. distr. (influence
% difficulty)

DebugMode = false;

if ~DebugMode
    subjNo = input('participant code [two numerals]: ','s');
    initials = input('participant initials [three letters]: ','s');
    hand = input('right or left handed? [one letter: r or l]: ','s');
    age = input('participant age [years]: ','s');
    gender = input('male or female [m or f]: ','s');
    datafileName = strcat(subjNo, '_' , initials, date, hand, age, gender,'_ALSAData.mat');
    datafileNameEyetracker = strcat('ALSADATA_', subjNo, initials, date, hand, age, gender,'_EyetrackerEDFData');
else
    datafileName = 'ALSATestfile';
end

%----------------------------------------------------------------------
%                      Start of Eye Tracking
%----------------------------------------------------------------------

distanceToScreen = 24.25; % in inches
sizeOfImage = 2.10; % in inches 250 pix
pixOfImage = 250;    % pixels in 2.1 inch

pixPerDeg = pixOfImage/(rad2deg(atan((sizeOfImage/2)/distanceToScreen))*2);

% Compute visual degrees for fixation (2) and target (4)
FixationWindow = pixPerDeg * 2; % 2 visual degrees
TargetWindow = pixPerDeg * 2; % 2 visual degrees

% Calibrate the eyetracker:
EyetrackerConnected = true;

% Eyetracking file name
edfName = strcat('ALSA', subjNo, initials);

if EyetrackerConnected
    [filenameEyetracker, el] = eyelink_ini_az('edfName', round(1*255), round(0.1*255));
end

dbstop if error

commandwindow;

% Durations constants
picDuration = .55;
fixdotDuration = .75;
dotDuration = .55;
decisionDuration = 3;
feedbackTime = .75;

circ = 215;
rho = 200;

%----------------------------------------------------------------------
%                       Screen setup
%----------------------------------------------------------------------

% Set the screen number to the external secondary monitor if one is connected
screenNumber = max(Screen('Screens'));

% Define colors
white = WhiteIndex(screenNumber);
grey = white/2;
black = BlackIndex(screenNumber);
red = [255, 0, 0];
green = [50, 205, 50];

% Open the screen
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black, [], 32, 2);

% Flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
Screen('TextSize', window, 20);

% Query the maximum priority level
topPriorityLevel = MaxPriority(window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------
%#ok<*NASGU>
% Keyboard setup
spaceKey = KbName('space');
escapeKey = KbName('ESCAPE');
RestrictKeysForKbCheck([spaceKey escapeKey]);

%----------------------------------------------------------------------
%                        Fixation Dot
%----------------------------------------------------------------------

% Get the size of the on screen window in pixels.
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Set the color of our dots
dotColor = black;
dotColorTarget = red;

% Place dot in center of screen
allPos = [xCenter yCenter];

% Dot size in pixels
dotSizePix = 20;
dotSizePixSmall = 12;

DebugMode = false;

PointDistance = 250;

%----------------------------------------------------------------------
%                      Experimental Image List
%----------------------------------------------------------------------

% Get image files for the experiment
imgList = dir(fullfile('*.jpg'));
imgList(end)=[];
imageNames = char({imgList.name}');
numImages = length(imgList);
numTrials = 260;

% Make a list of genders
femaleGender = ((imageNames(:,2))=='F');
maleGender = ((imageNames(:,2))=='M');

% Make a list of picture IDs
PicID = str2num(imageNames(:,3:6));
PicID_Unique = unique(PicID);
numID = length(PicID_Unique);

% -------------------------------------------------------------------------

KeyBoardNumbers = GetKeyboardIndices;
responseKeyboard = KeyBoardNumbers(2);

% Start recording, send a message to the edf file:
if EyetrackerConnected
    pause(0.1) % send some samples to edf file
    
    %Send message to EDF file
    edfstring = 'StartExperiment';
    Eyelink('Message', edfstring);
end

%----------------------------------------------------------------------
%                      Experimental Loop
%----------------------------------------------------------------------

% Accuracy variables
correct = 0;
wrong = 0;
ACC = 0;
ESCAPING = 0;

% Data Structures
RTvector = NaN(numTrials, 1);
ACCvector = NaN(numTrials, 1);
PicIDVector = NaN(numTrials, 3);
GenderVector = NaN(numTrials, 3);
OrientationVector = NaN(numTrials, 3);
picOnsetVector = NaN(numTrials, 3);
maskDurationVector = NaN(numTrials, 2);
PosVector = NaN(numTrials, 4);
thetaRhoVector = NaN(numTrials, 3);
CWVector = NaN(numTrials, 2);
saccadePosVector = NaN(numTrials, 2);

% Begin looping
for trial = 1:numTrials
    
    % Take a break every 25 trials, subject can press space key to move on
    [~, ~, keyCode] = KbCheck(responseKeyboard);
    if mod(trial, 25) == 0
        breakText = 'Take a break or press the spacebar to continue';
        keyPress = 0;
        tic
        while toc < 5 && ~keyPress
            DrawFormattedText(window, breakText, 'center', 'center', white  )
            Screen('Flip', window);
            [~, ~, keyCode] = KbCheck;
            if (keyCode(spaceKey) == 1)
                keyPress = 1;
                break;
            end
        end
    end
    
    %   Set up variables for s1, s2, t
    %--------------------------------------------------------------
    
    % Variables for duration
    picOnset1 = (exprnd(.7) + 0.1); % sample 1
    picOnset2 = (exprnd(.7) + 0.1); % sample 2
    picOnset3 = (exprnd(.7) + 0.1); % test
    
    if picOnset1 > 2
        picOnset1 = 2;
    end
    
    if picOnset2 > 2
        picOnset2 = 2;
    end
    
    if picOnset3 > 2
        picOnset3 = 2;
    end
    
    maskDuration1 = (0.08 + (0.5 - 0.08) * rand); % sample 1
    maskDuration2 = (0.08 + (0.5 - 0.08) * rand); % sample 2
    
    picOnsetVector(trial, 1) = picOnset1;
    picOnsetVector(trial, 2) = picOnset2;
    picOnsetVector(trial, 3) = picOnset3;
    maskDurationVector(trial, 1) = maskDuration1;
    maskDurationVector(trial, 2) = maskDuration2;
    
    % Get background image
    backgroundImage = 'backgroundImage.jpg';
    
    % Now load the image
    theBackgroundImage = imread(backgroundImage);
    
    % Make the edges black
    theBackgroundImage(:,[1:2,end-1,end],:)=0;
    theBackgroundImage([1:2,end-1,end],:,:)=0;
    
    % Background image
    backTex = Screen('MakeTexture', window, theBackgroundImage);
    
    % Draw the texture
    Screen('DrawTexture', window, backTex);
    
    %%%%% For both sample 1 and 2:
    randomNumber = randperm(numImages,2);
    
    %   Set up variables for Sample 1
    %--------------------------------------------------------------
    
    % Get corresponding name of the image
    randomImage = imgList(randomNumber(1)).name;
    
    % Get gender of image
    imageGender = randomImage(:,2);
    GenderVector(trial, 1) = imageGender;
    
    % Get ID of image
    imagePicID = str2num(randomImage(:,3:6));
    PicIDVector(trial, 1) = imagePicID;
    
    % Get orientation of image
    picOrientation = str2num(randomImage(:,13:15));
    OrientationVector(trial, 1) = picOrientation;
    
    % Now load the image
    theImage = imread(randomImage);
    
    % Get picture size
    sizeX = size(theImage, 1);
    sizeY = size(theImage, 2);
    
    % Random polar coordinates
    th1 = randperm(360,1);
    theta1 = deg2rad(th1);
    [x1, y1] = pol2cart(theta1, rho);
    
    thetaRhoVector(trial, 1) = rho;
    thetaRhoVector(trial, 2) = theta1;
    
    sampx1 = xCenter+x1-(sizeX/2);
    sampy1 = yCenter+y1-(sizeY/2);
    
    PosVector(trial, 1) = sampx1;
    PosVector(trial, 2) = sampy1;
    
    %   Set up variables for Sample 2
    %--------------------------------------------------------------
    
    % Image for sample 2
    randomImage2 = imgList(randomNumber(2)).name;
    theImage2 = imread(randomImage2);
    
    % Get information about image
    imageGender2 = randomImage2(:,2);
    GenderVector(trial, 2) = imageGender2;
    
    imagePicID2 = str2num(randomImage2(:,3:6));
    PicIDVector(trial, 2) = imagePicID2;
    
    picOrientation2 = str2num(randomImage2(:,13:15));
    OrientationVector(trial,2) = picOrientation2;
    
    % Random polar coordinates
    th2 = randperm(360,1);

    if abs(th1-th2) <= 90 || abs(th1+(360-th2)) <= 90
        while abs(th1-th2) <= 90 || abs(th1+(360-th2)) <= 90
            th2 = randperm(360,1);
        end
    end        

    theta2 = deg2rad(th2);
    thetaRhoVector(trial, 3) = theta2;
    [x2, y2] = pol2cart(theta2, rho);
    
    % Make coordinates for dot
    newx1 = xCenter+x2-(sizeX/2);
    newy1 = yCenter+y2-(sizeY/2);
    
    PosVector(trial,3) = newx1;
    PosVector(trial,4) = newy1;
    
    %   Set up variables for Test
    %--------------------------------------------------------------
    
    % Randomly assign picID of one of previously shown pictures
    xRand = randi(2);
    if xRand == 1
        imagePicIDRand = imagePicID;
    elseif xRand == 2
        imagePicIDRand = imagePicID2;
    end
    
    % Create list of ID and select another aspect
    randomID = str2num(imageNames(:,3:6)) == imagePicIDRand;
    PicIDVector(trial, 3) = imagePicIDRand;
    
    findList = find(randomID == true);
    sampleRand = randi(length(findList));
    findRandSample = findList(sampleRand);
    testImage = imageNames(findList(sampleRand),:);
    
    imageGenderRand = randomImage(:,2);
    GenderVector(trial, 3) = imageGenderRand;
    
    picOrientationRand = str2num(testImage(:,13:15));
    OrientationVector(trial,3) = picOrientationRand;
    
    %   Start drawing on the screen with good timing:
    %--------------------------------------------------------------
    
    % Draw fixation dot to the screen
    Screen('DrawTexture', window, backTex);
    Screen('DrawDots', window, allPos, dotSizePix , dotColor, [], 2);
    Screen('Flip', window);
    WaitSecs(fixdotDuration);
    
    % Just before the flip, we send a message to the edf file
    if EyetrackerConnected
        % send message to EDF file
        edfstring = ['ALSA_trial' num2str(trial) '_fixOnset1'];
        Eyelink('Message', edfstring);
    end
    
    % Check if fixation point is hit
    Hit = 0;
    while Hit == 0
        [Hit, EyePosition] = checkwindow(xCenter, yCenter, FixationWindow);
        
        % Escape if needed and save files
        [~, ~, keyCode] = KbCheck(responseKeyboard);
        if (keyCode(escapeKey) == 1)
            Eyelink('Stoprecording');
            Eyelink('Closefile');
            Eyelink('ShutDown');
            Screen('CloseAll');
            % Save data file
            save(datafileName, 'PicIDVector', 'RTvector',...
                'ACCvector', 'GenderVector', 'OrientationVector', 'picOnsetVector',...
                'maskDurationVector', 'PosVector', 'saccadePosVector', 'thetaRhoVector', 'CWVector');
            % Receive edf file
            eyelink_receive_file(filenameEyetracker);
            return %---> can use return to avoid a crash when escaping     
        end
    end
    Screen('DrawTexture', window, backTex);
    Screen('DrawDots', window, allPos, dotSizePixSmall , dotColor, [], 2);
    
    Screen('Flip', window);
    WaitSecs(picOnset1);
    
    %                      Sample 1
    %--------------------------------------------------------------
    Screen('DrawTexture', window, backTex);
    
    % Make image into a textures
    tex = Screen('MakeTexture', window, theImage);
    
    % Draw the texture
    Screen('DrawTexture', window, tex);
    
    % Send a message to edf file
    if EyetrackerConnected
        edfstring = ['ALSA_trial' num2str(trial) '_image1Onset'];
        Eyelink('Message', edfstring);
    end
    Screen('Flip', window);
    
    WaitSecs(picDuration);
    
    % Draw mask
    Screen('DrawTexture', window, backTex);
    pict = 256*rand(sizeY, sizeX, 3);
    texMask = Screen('MakeTexture', window, pict);
    Screen('DrawTexture', window, texMask);
    
    if EyetrackerConnected
        edfstring = ['ALSA_trial' num2str(trial) '_mask1Onset'];
        Eyelink('Message', edfstring);
    end
    Screen('Flip', window);
    WaitSecs(maskDuration1);
    
    % Draw dot to new position
    Screen('DrawTexture', window, backTex);
    imageDotPos = [sampx1+(sizeX/2) sampy1+(sizeY/2)];
    Screen('DrawDots', window, imageDotPos, dotSizePix, dotColorTarget, [], 2);
    
    % Send a message to edf file
    if EyetrackerConnected
        edfstring = ['ALSA_trial' num2str(trial) '_image1MovPos'];
        Eyelink('Message', edfstring);
    end
    Screen('Flip', window);
   
    % Check if target position is hit
    Hit = 0;
    while Hit == 0
        [Hit, EyePosition] = checkwindow(imageDotPos(1), imageDotPos(2), TargetWindow);
        
        % Escape if needed and save files
        [~, ~, keyCode] = KbCheck(responseKeyboard);
        if (keyCode(escapeKey) == 1)
            Eyelink('Stoprecording');
            Eyelink('Closefile');
            Eyelink('ShutDown');
            Screen('CloseAll');
            % Save data file
            save(datafileName, 'PicIDVector', 'RTvector',...
                'ACCvector', 'GenderVector', 'OrientationVector', 'picOnsetVector',...
                'maskDurationVector', 'PosVector', 'saccadePosVector', 'thetaRhoVector', 'CWVector');
            % Receive edf file
            eyelink_receive_file(filenameEyetracker);
            return
        end
    end
    
    WaitSecs(dotDuration);
    
    % Draw a fixation dot
    Screen('DrawTexture', window, backTex);
    Screen('DrawDots', window, allPos, dotSizePix, dotColor, [], 2);
    
    % Send a message to edf file
    if EyetrackerConnected
        edfstring = ['ALSA_trial' num2str(trial) '_fixOnset2'];
        Eyelink('Message', edfstring);
    end
    Screen('Flip', window);
    
    % Check if fixation point is hit
    Hit = 0;
    while Hit == 0
        [Hit, EyePosition] = checkwindow(xCenter, yCenter, FixationWindow);
        
        % Escape if needed and save files
        [~, ~, keyCode] = KbCheck(responseKeyboard);
        if (keyCode(escapeKey) == 1)
            Eyelink('Stoprecording');
            Eyelink('Closefile');
            Eyelink('ShutDown');
            Screen('CloseAll');
            % Save data file
            save(datafileName, 'PicIDVector', 'RTvector',...
                'ACCvector', 'GenderVector', 'OrientationVector', 'picOnsetVector',...
                'maskDurationVector', 'PosVector', 'saccadePosVector', 'thetaRhoVector', 'CWVector');
            % Receive edf file
            eyelink_receive_file(filenameEyetracker);
            return
        end
    end
    
    Screen('DrawTexture', window, backTex);
    Screen('DrawDots', window, allPos, dotSizePixSmall, dotColor, [], 2);
    Screen('Flip', window);
    WaitSecs(fixdotDuration + picOnset2);
    
    %                      Sample 2
    %--------------------------------------------------------------
    % Background image
    Screen('DrawTexture', window, backTex);
    tex2 = Screen('MakeTexture', window, theImage2);
    Screen('DrawTexture', window, tex2);
    
    % Send a message to edf file
    if EyetrackerConnected
        edfstring = ['ALSA_trial' num2str(trial) '_image2Onset'];
        Eyelink('Message', edfstring);
    end
    Screen('Flip',window);
    WaitSecs(picDuration);
    
    % Draw mask
    Screen('DrawTexture', window, backTex);
    texMask = Screen('MakeTexture', window, pict);
    Screen('DrawTexture', window, texMask);
    if EyetrackerConnected
        edfstring = ['ALSA_trial' num2str(trial) '_mask2Onset'];
        Eyelink('Message', edfstring);
    end
    Screen('Flip', window);
    
    WaitSecs(maskDuration2);
    
    % Draw dot to new position
    Screen('DrawTexture', window, backTex);
    imageDotPos2 = [newx1+(sizeX/2) newy1+(sizeY/2)];
    Screen('DrawDots', window, imageDotPos2, dotSizePix, dotColorTarget, [], 2);
    
    % Send a message to edf file
    if EyetrackerConnected
        edfstring = ['ALSA_trial' num2str(trial) '_image2MovPos'];
        Eyelink('Message', edfstring);
    end
    Screen('Flip', window);
    
    % Check if target position is hit
    Hit = 0;
    while Hit == 0
        [Hit, EyePosition] = checkwindow(imageDotPos2(1), imageDotPos2(2) , TargetWindow);
        
        % Escape if needed and save files
        [~, ~, keyCode] = KbCheck(responseKeyboard);
        if (keyCode(escapeKey) == 1)
            Eyelink('Stoprecording');
            Eyelink('Closefile');
            Eyelink('ShutDown');
            Screen('CloseAll');
            % Save data file
            save(datafileName, 'PicIDVector', 'RTvector',...
                'ACCvector', 'GenderVector', 'OrientationVector', 'picOnsetVector',...
                'maskDurationVector', 'PosVector', 'saccadePosVector', 'thetaRhoVector', 'CWVector');
            % Receive edf file
            eyelink_receive_file(filenameEyetracker);
            return
        end
    end
    WaitSecs(dotDuration);
    
    %                      Test
    %--------------------------------------------------------------
    
    % Draw a fixation dot for the start of test
    Screen('DrawTexture', window, backTex);
    Screen('DrawDots', window, allPos, dotSizePix, dotColor, [], 2);
    
    if EyetrackerConnected
        edfstring = ['ALSA_trial' num2str(trial) '_fixOnset3'];
        Eyelink('Message', edfstring);
    end
    Screen('Flip', window);
    
    % Check if fixation point is hit
    Hit = 0;
    while Hit == 0
        [Hit, EyePosition] = checkwindow(xCenter, yCenter, FixationWindow);
        
        % Escape if needed and save files
        [~, ~, keyCode] = KbCheck(responseKeyboard);
        if (keyCode(escapeKey) == 1)
            Eyelink('Stoprecording');
            Eyelink('Closefile');
            Eyelink('ShutDown');
            Screen('CloseAll');
            % Save data file
            save(datafileName, 'PicIDVector', 'RTvector',...
                'ACCvector', 'GenderVector', 'OrientationVector', 'picOnsetVector',...
                'maskDurationVector', 'PosVector', 'saccadePosVector', 'thetaRhoVector', 'CWVector');
            % Receive edf file
            eyelink_receive_file(filenameEyetracker);
            return
        end
    end
    Screen('DrawTexture', window, backTex);
    Screen('DrawDots', window, allPos, dotSizePixSmall, dotColor, [], 2);
    Screen('Flip', window);
    WaitSecs(fixdotDuration + picOnset3);
    
    % Draw random image
    Screen('DrawTexture', window, backTex);
    theImageRand = imread(testImage);
    texRand = Screen('MakeTexture', window, theImageRand);
    Screen('DrawTexture', window, texRand);
    if EyetrackerConnected
        edfstring = ['ALSA_trial' num2str(trial) '_image3Onset'];
        Eyelink('Message', edfstring);
    end
    Screen('Flip',window);
    WaitSecs(picDuration);
    
    % Make decision
    Screen('DrawTexture', window, backTex);
    Screen('DrawDots', window, allPos, dotSizePix, black, [], 2);
    if EyetrackerConnected
        edfstring = ['ALSA_trial' num2str(trial) '_decision1'];
        Eyelink('Message', edfstring);
    end
    Screen('Flip', window);
    
    %                      Accuracy Check
    %--------------------------------------------------------------

    % Determine the position of the test image used
    if imagePicIDRand == imagePicID
        imageRandPos = imageDotPos;
    elseif imagePicIDRand == imagePicID2
        imageRandPos = imageDotPos2;
    end
    
    % Collect eye response
    Hit = 0; 
    while Hit == 0
        [Hit, EyePosition] = checkwindow(xCenter, yCenter, FixationWindow); % Wait until fixation point is hit
    end
    
    Screen('DrawTexture', window, backTex);
    Screen('DrawDots', window, allPos, dotSizePixSmall, green, [], 2);
    
    if EyetrackerConnected
        edfstring = ['ALSA_trial' num2str(trial) '_decision2'];
        Eyelink('Message', edfstring);
    end
    
    [VBLTimestamp, startrt] = Screen('Flip', window);
    
    TargetHit=NaN;
    Hit = 1;
    responseMade = 0;
    
    while (GetSecs - startrt) < decisionDuration && responseMade == 0 %%%%%%----> allow for maximum of 3 seconds to get to target
       
        % Check when leaving fixation window
        [Hit, EyePosition] = checkwindow(xCenter, yCenter, FixationWindow);
                
        if Hit == 0 % means that subject has left window
            
            % Add delay if saccade started
            tsac = tic;
            tElapsed = toc(tsac);
            while tElapsed < 0.1
                tElapsed = toc(tsac);
            end
            
            if EyetrackerConnected
                edfstring = ['t' num2str(trial) '_reachTarget'];
                Eyelink('Message', edfstring);
            end 
            
            [TargetHit, EyePosition] = checkwindow(imageRandPos(1), imageRandPos(2), TargetWindow);
            
            % Compute response time
            tStartSaccade = GetSecs;
            RT = (tStartSaccade-startrt);
            RTvector(trial) = RT;
            responseMade = 1;           
            
            saccadePositionX = EyePosition(1);
            saccadePositionY = EyePosition(2);
            
            disp(['trial: ' num2str(trial)])
            disp(['X: ' num2str(EyePosition(1))])
            disp(['Y: ' num2str(EyePosition(2))])
            disp(['RT: ' num2str(RT) ' seconds'])
            
            % Write saccade positions to vector
            saccadePosVector(trial, 1) = saccadePositionX;
            saccadePosVector(trial, 2) = saccadePositionY;
            
            % Send a message to edf file
            if EyetrackerConnected
                edfstring = ['r' num2str(trial) '_responseCollected'];
                Eyelink('Message', edfstring);
            end
        end
        
        [~, ~, keyCode] = KbCheck(responseKeyboard);
        if (keyCode(escapeKey) == 1)
            Eyelink('Stoprecording');
            Eyelink('Closefile');
            Eyelink('ShutDown');
            Screen('CloseAll');
            % Save data file
            save(datafileName, 'PicIDVector', 'RTvector',...
                'ACCvector', 'GenderVector', 'OrientationVector', 'picOnsetVector',...
                'maskDurationVector', 'PosVector', 'saccadePosVector', 'thetaRhoVector', 'CWVector');
            % Receive edf file
            eyelink_receive_file(filenameEyetracker);
            return
        end     
    end
    
    % Clear screen after subjects respond
    Screen('DrawTexture', window, backTex);
    Screen('Flip', window);
    
    % Compute variables
    if TargetHit == 1
        correct = correct + 1;
        ACC = 1;
    else
        wrong = wrong + 1;
        ACC = 0;
    end
    
    Screen('DrawTexture', window, backTex);
    
    if ACC == 1
        Screen('TextSize', window, 20);
        DrawFormattedText(window, 'Correct', 'center', 'center', green);
    else
        Screen('TextSize', window, 20);
        DrawFormattedText(window, 'Wrong', 'center', 'center', red);
    end
    Screen('Flip', window);
    
    if EyetrackerConnected
        edfstring = ['ALSA_trial' num2str(trial) '_fdbck'];
        Eyelink('Message', edfstring);
    end
    
    WaitSecs(feedbackTime);
    
    ACCvector(trial) = ACC;
    
    CWVector(trial, 1) = correct;
    CWVector(trial, 2) = wrong;
    
    imagePicID = NaN;
    imagePicID2 = NaN;
    imagePicIDRand = NaN;
    
    imageGender = NaN;
    imageGender2 = NaN;
    imageGenderRand = NaN;
    
    picOrientation = NaN;
    picOrientation2 = NaN;
    picOrientationRand = NaN;
    
    picOnset1 = NaN;
    picOnset2 = NaN;
    picOnset3 = NaN;
    
    maskDuration1 = NaN;
    maskDuration2 = NaN;
    
    theta1 = NaN;
    theta2 = NaN;
    
    RT = NaN;
    
    sampx1 = NaN;
    sampx1 = NaN;
    newx1 = NaN;
    newy1 = NaN;
    
    saccadePositionX = NaN;
    saccadePositionY = NaN;
    
end

% Save vectors to data file
save(datafileName, 'PicIDVector', 'RTvector',...
    'ACCvector', 'GenderVector', 'OrientationVector', 'picOnsetVector',...
    'maskDurationVector', 'PosVector', 'saccadePosVector', 'thetaRhoVector', 'CWVector');

%                      End of Experimentation
%--------------------------------------------------------------

% End screen
correctText = ['Correct: ' num2str(correct)];
wrongText = ['Wrong: ' num2str(wrong)];
DrawFormattedText(window, correctText, 'center', 'center', white);
DrawFormattedText(window, wrongText, 'center', 300, white);
Screen('Flip', window);
WaitSecs(3)

%----------------------------------------------------------------------
%                      End of Eye Tracking
%----------------------------------------------------------------------

% At end of experiment:
if EyetrackerConnected
    % send message to EDF file
    edfstring = 'EndExperiment';
    Eyelink('Message', edfstring);
    pause(0.1) % get another few samples into the data file
end

% At end of experiment IF EDF FILE IS RECORDED:
if EyetrackerConnected
    Eyelink('Stoprecording');
    Eyelink('Closefile');
    if ~DebugMode
        eyelink_receive_file(filenameEyetracker);
        disp(['Eyedata data saved under the name: ' datafileNameEyetracker])
    end
    Eyelink('ShutDown');
end

% Switch to low priority for after trial tasks
Priority(0);

% Bin the textures we used
Screen('CloseAll');

% Close the onscreen window
sca
return
