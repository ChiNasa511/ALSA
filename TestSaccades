% MATLAB Arbitrarily Learned Sensorimotor Assocation Project
%
% Chinasa T. Okolo
% HHMI EXROP
% Shadlen Lab
% Edited by Danique Jeurissen

EyetrackerConnected=true;

if EyetrackerConnected
    [filenameEyetracker, el] = eyelink_ini_az('TSacc',round(1*255),round(0.1*255) );
end

dbstop if error
commandwindow;

% Set the screen number to the external secondary monitor if one is connected
screenNumber = max(Screen('Screens'));

% Define black, white and grey
white = WhiteIndex(screenNumber);
grey = white/2;
black = BlackIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, white, [], 32, 2);

% Flip to clear
Screen('Flip', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set the text size
Screen('TextSize', window, 20);
spaceKey = KbName('space');
escapeKey = KbName('ESCAPE');
RestrictKeysForKbCheck([spaceKey escapeKey]);

% Set the color of our dot to full black
dotColor = [0 0 0];

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Place dot in center of screen
allPos = [xCenter yCenter];

% Dot size in pixels
dotSizePix = 20;
DebugMode=false;
[screenXpixels, screenYpixels] = Screen('WindowSize', window);


PointDistance=250;

% at the start of your experiment, you want to know what the current center
% of fixation is, you use this to correct all other samples you receive
% from the eyetracker:
% you can do this also when z is pressed.
if EyetrackerConnected
    goodcentre = 0;
    fails = 0;
    FixText = 'Fixate on the fixation point and press space bar';
    while ~goodcentre
        Screen('DrawText', window, FixText, screenXpixels/4, screenYpixels/4, black);
        %Screen('FillOval', window, white);
        Screen('DrawDots', window, allPos, dotSizePix, dotColor, [], 2);
        Screen('Flip', window);
        %disp('Line53')
        keyPress = 0;
        [~, ~, keyCode] = KbCheck(5);
        %disp('Line 56 - keyboard checked')
        %find(keyCode) % 44 on keyboard 5 is space bar for subject
        if (keyCode(spaceKey) == 1)
            keyPress = 1;
            %disp('spacebar')
            %cgpencol(0,0,0)
            %cgtext(message,0,200)
            %cgpencol(bggrey,bggrey,bggrey)
            %cgellipse(0,0,30,30,[0,0,0],'f')
            %cgellipse(0,0,10,10,[lightgrey,lightgrey,lightgrey],'f')
            %cgflip(lightgrey,lightgrey,lightgrey)
            %[empty,kp] = cgkeymap;
            %if length(find(kp)) == 1 % check if any key is pressed
            %    if find(kp)==57 % press space at this point to save eyeposition for this calibration point
            if Eyelink('NewFloatSampleAvailable') > 0
                evt = Eyelink('NewestFloatSample');
                % evt 1 for left and 2 for right eye (?)
                centreFixation=[evt.gx(2) evt.gy(2)];% ask subject to stare at the fixation and press space, measure gaze coordinates x and y of newest event
                % eyes can be missing
                if evt.gx(2) < -10000 % pupil is not measured
                    goodcentre = 0; % pupils are not at right fixation point
                    fails = fails+1; % counter, calibration failed
                    if fails == 1 % if calibration failed, try again
                        FixText = 'Try again';
                    elseif fails == 2
                        FixText = 'No eyesignal: Ask for help';
                    elseif fails > 2
                        FixText = 'No eyesignal: Ask for help and try again';
                    end
                else
                    goodcentre = 1;
                end
            end
            %elseif find(kp) == 1 % esc, close program
        elseif (keyCode(escapeKey) ==1)
            if EyetrackerConnected
                Eyelink('Stoprecording');
                Eyelink('Closefile');
                Eyelink('ShutDown');
            end
            Screen('CloseAll')
            sca
            %cgshut
            disp(['Matlab data saved under the name: ' Datafilename])
            return
        end
        %end
    end
else
    centreFixation=[0 0];
end


% if EyetrackerConnected
%     Eyelink('Stoprecording');
%     Eyelink('Closefile');
%     eyelink_receive_file(filenameEyetracker)
%     eval(['!rename ',filenameEyetracker,'.edf ',DatafilenameEyetracker,'.edf'])
%     disp(['Eyedata data saved under the name: ' DatafilenameEyetracker])
%     Eyelink('ShutDown');
% end
% Screen('CloseAll')
% sca
% disp('Line 120')
% return


%cgflip(bggrey,bggrey,bggrey)
%cgflip(bggrey,bggrey,bggrey)
Screen('Flip', window);
Screen('Flip', window);

% cgellipse(0,0,15,15,[1 0 0],'f')
% cgellipse(-200,-200,15,15,[1 0 0],'f')
% cgellipse(200,200,15,15,[1 0 0],'f')
% cgellipse(200,-200,15,15,[1 0 0],'f')
% cgellipse(-200,200,15,15,[1 0 0],'f')
% cgflip(bggrey,bggrey,bggrey)


Screen('DrawDots', window, allPos, dotSizePix, dotColor, [], 2);
Screen('Flip', window);
ESCAPING=0;

while 1 && ~ESCAPING
    
    [Hit, Time, EyePosition] = checkwindowTestSaccade(0,0,60,centreFixation);
    % check here whether a saccade was made (receive information from eyelink)
    % if saccade message is received from eyelink...
    % then: get x and y position of fixation
    evtype = Eyelink('getnextdatatype');
    if (evtype == el.STARTFIX) % check for a new fixation outside of the fixation window (allow for small saccades within fixation window)
        [Hit,Time,EyePosition] = checkwindowTestSaccade(0,0,60,centreFixation);
        beep
        tStartSaccade=tic;
        tElapsed=toc(tStartSaccade);
        while tElapsed<0.02
            tElapsed=toc(tStartSaccade);
        end
        saccadePositionX=EyePosition(1);
        saccadePositionY=EyePosition(2);
        
        
        %         cgellipse(0,0,15,15,[1 0 0],'f')
        %         cgellipse(-PointDistance,-PointDistance,15,15,[1 0 0],'f')
        %         cgellipse(PointDistance,PointDistance,15,15,[1 0 0],'f')
        %         cgellipse(PointDistance,-PointDistance,15,15,[1 0 0],'f')
        %         cgellipse(-PointDistance,PointDistance,15,15,[1 0 0],'f')
        %         cgellipse(saccadePositionX,saccadePositionY,10,10,[0.1 0.1 1],'f')
        %         cgflip(bggrey,bggrey,bggrey)
        
        % fixation
        Screen('DrawDots', window, allPos, dotSizePix, dotColor, [], 2);
        % something to look at
        Screen('DrawDots', window, [700-200 525-200], dotSizePix, [0 0 255], [], 2);
        Screen('DrawDots', window, [700+200 525+200], dotSizePix, [0 0 255], [], 2);
        Screen('DrawDots', window, [700-200 525+200], dotSizePix, [0 0 255], [], 2);
        Screen('DrawDots', window, [700+200 525-200], dotSizePix, [0 0 255], [], 2);
        % recorded saccade end point
        Screen('DrawDots', window, [saccadePositionX saccadePositionY], dotSizePix, [255 0 0], [], 2);
        Screen('Flip', window);
              
    end % end of finding the start of saccade
    
    [~, ~, keyCode] = KbCheck(5);
    if (keyCode(escapeKey) == 1)
        ESCAPING=1
        Eyelink('Stoprecording');
        Eyelink('Closefile');
        Eyelink('ShutDown');
        Screen('CloseAll');
        return
    end % end the escape
end % end of while loop



