% Clear the workspace and the screen
close all;
clear all;
clc;
sca
Screen('Preference', 'SkipSyncTests', 1);

fullscreen = 0; %0 for small window, 1 for fullscreen
smallscreen = [0 0 960 600]; %if using small window, change values according to screen resolution
shimmer_on = 0; %1 for connected, 0 for not connected
debug = 0; %skip instructions, less trials, etc
skipExp1 = 0; %skip Experiment I
skipExp2 = 1; %skip Experiment II
skipExp3 = 1; %skip Experiment III

addpath(genpath(cd)); %adds subdirectories for easy access

inv_type = {'Children''s Education'; 'Future Travels'; 'Buying a House'; 'Retirement'; 'Healthcare'; 'Charity'; 'Wedding'; 'Buying a Car'; 'Electronics'; 'Entertainment'};

% keyboard setup
KbName('UnifyKeyNames'); %this part is for getting the keyboard numbers so you can wait for a certain keypress later on
leftkey = KbName('LeftArrow');
rightkey = KbName('RightArrow');
bkey = KbName('b');
nkey = KbName('n');
shimmer_key1 = KbName('s');
shimmer_key2 = KbName('h');
number_keys = 48:57; %hard coded, clash with cogent? use KbDemo to check numbers of keys

font_sz = 50; % font size for experiment I (divided by 2 later on)
font_sz2 = 30; % font size for experiment II

% experiment timings
DATA.params.fix_time = 1000; %milliseconds for wait() function
DATA.params.inv_time = 1000; %investment type
DATA.params.return_time = 1000; %advisor vs self
DATA.params.wait_time = 500; %blank (bg) screen between each flip
DATA.params.imagine_time = 5000;
DATA.params.font_size = font_sz;

% questions

questions = {'Is this relevant to you?'... %binary
    'How likely is what you imagined to happen?'...       % 0% to 100%
    'When will it happen?'...                %numeric input, time
    'How emotionally arousing is the image?'... %sliding scale
    'How good/bad is the image?'...            %sliding scale
    'How vivid is your image?'...             %sliding scale
    'How important is this for you?'...        %sliding scale
    'How willing are you to forgo daily conveniences \n in order to save up for this?'}; %sliding scale

DATA.questions = questions;

questions2 = {'(use the left and right arrow keys)'...
    'From 1% to 100%'...
    '(years from now)'...
    'On a scale from 1 (not arousing) to 100 (very arousing)'...
    'On a scale from 1 (very bad) to 100 (very good)'...
    'On a scale from 1 (not vivid) to 100 (very vivid)'...
    'On a scale from 1 (not important) to 100 (very important)'...
    'On a scale from 1 (not willing) to 100 (very willing)'};

DATA.questions2 = questions2;

for i = 1:length(inv_type)
    pairs = randperm(8);
    DATA.q_pairs.(sprintf('inv%d',i)) = reshape(pairs,2,4)'; %ask two questions on each trial
    q_list.(sprintf('inv%d',i)) = pairs; %ask two questions on each trial
end

DATA.q_series = q_list;

% trial structure
trials_per_type = length(questions);
trials = repmat(1:length(inv_type),1,trials_per_type/2);
trials = trials(randperm(length(trials)));
trials_list = trials;

DATA.trials = trials;

rand_binary = [ones(1,length(inv_type)/2) ones(1,length(inv_type)/2)*2];
rand_binary = rand_binary(randperm(length(rand_binary)));

DATA.leftright = rand_binary;
DATA.relevant =[]; %initializes placeholder for binary decisions
DATA.relevant_whichInv = [];  %initializes placeholder to match up binary decisions with investment type

all_answers = nan(length(questions),length(inv_type)); %initialize a matrix without numbers to hold all answers
all_answers_RT = nan(length(questions),length(inv_type)); %initialize a matrix without numbers to hold RTs
all_conf1 = nan(length(questions),length(inv_type));
all_conf1_RT = nan(length(questions),length(inv_type));
%% subject parameters
if debug==0
    age = input('please enter you age: ');
    sex = input('please enter you sex (M/F): ', 's');
    sub = input('please enter subject number: ');
    glasses = input('Is subject wearing glasses during experiment? (y/n)','s');
    filename = sprintf('choicePhisPilot%d',sub);
    DATA.params.age = age;
    DATA.params.sex = upper(sex);
    DATA.params.subNo = sub;
    DATA.params.glasses = glasses;
    DATA.params.when_start = datestr(now,30);% when was the script started?
    comPort = num2str(input('comport: '));
else
    filename = 'choicePhisDebugData';
    if skipExp1 == 0
        comPort = num2str(input('comport: '));
        trials = trials(1:3);
    end
end

%% setup shimmer
if shimmer_on==1
shimmer = ShimmerHandleClass(comPort);                                     % Define shimmer as a ShimmerHandle Class instance with comPort1
SensorMacros = SetEnabledSensorsMacrosClass;                               % assign user friendly macros for setenabledsensors
shimmer.connect
shimmer.setsamplingrate(51.2);                                         % Set the shimmer sampling rate to 51.2Hz
shimmer.setinternalboard('GSR');                                      % Set the shimmer internal daughter board to '9DOF'
shimmer.disableallsensors;                                             % disable all sensors
shimmer.setenabledsensors(SensorMacros.GSR,1);
shimmer.start
DELAY_PERIOD = 0.2;                                                        % A delay period of time in seconds between data read operations
captureDuration = DATA.params.imagine_time/1000;

if (shimmer.connect)   
    disp('success, shimmer connected!')
else
    error('failure, shimmer not connected')
end

end
allData = [];
timings=[];

%% setup psychtoolbox
%PsychJavaTrouble % for dynamic Java stuff of PsychToolbox
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Select the external screen if it is present, else revert to the native
% screen
screenNumber = max(screens);

% Define black, white and grey
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
grey = white / 2;
bg = white;
fg = black;

% Open an on screen window and color it bg
if fullscreen==0
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, bg, smallscreen);
elseif fullscreen==1
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, bg, [], [], [], [], [], [], kPsychGUIWindow);
end

% Set the blend funciton for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);

%% start experiment

if debug==0 %only show instructions when not debugging
    % show instructions
    for i = 1:12
        % Here we load in an image from file.
        image = sprintf('Slide%d.jpg',i);
        theImage = imread(image);
        
        % Make the image into a texture
        imageTexture = Screen('MakeTexture', window, theImage);
        
        % Draw the image to the screen, unless otherwise specified PTB will draw
        % the texture full size in the center of the screen.
        Screen('DrawTextures', window, imageTexture, [], []);
        
        % Flip to the screen
        Screen('Flip', window);
        
        % Wait for a key press
        KbStrokeWait;
    end
end

confTime_End=[];
confTime_Start=[];
ratingTime_End=[];
ratingTime_Start=[];
invTime=[];
if skipExp1 == 0
    HideCursor;
	
	startvar = 'this is the shimmer startfile';
	save('startfile','startvar')
	
    j=0; %extra counter
    for i = 1:length(trials)
        j=j+1;
        %% show fixation cross
        
        % Here we set the size of the arms of our fixation cross
        fixCrossDimPix = 40;
        
        % Now we set the coordinates (these are all relative to zero we will let
        % the drawing routine center the cross in the center of our monitor for us)
        xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
        yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
        allCoords = [xCoords; yCoords];
        
        % Set the line width for our fixation cross
        lineWidthPix = 4;
        
        % Draw the fixation cross in fg, set it to the center of our screen and
        % set good quality antialiasing
        Screen('DrawLines', window, allCoords,lineWidthPix, fg, [xCenter yCenter], 2);
        
        % Flip to the screen
        Screen('Flip', window);
        
        wait(DATA.params.fix_time)
        
        % Flip to the screen
        Screen('Flip', window);
        
        wait(DATA.params.wait_time)
        
        %% show investment type
        %line0 = sprintf('This investment will be for %s', char(inv_type(block_vec(trial))));
        line0 = char(inv_type(trials_list(1)));
        
        % Draw all the text in one go
        Screen('TextSize', window, font_sz);
        DrawFormattedText(window, 'Please Imagine:','center', screenYpixels * 0.1, fg);
        DrawFormattedText(window, line0,'center', screenYpixels * 0.25, fg);
        
        invTime = [invTime; clock];
        
        if shimmer_on==1
        elapsedTime = 0;                                                   % Reset to 0
        tic;                                                               % Start timer
        Screen('Flip', window);
        timeStamp = [];
        while (elapsedTime < captureDuration)
            pause(DELAY_PERIOD);                                           % Pause for this period of time on each iteration to allow data to arrive in the buffer
            [newData,signalNameArray,signalFormatArray,signalUnitArray] = shimmer.getdata('c');   % Read the latest data from shimmer data buffer, signalFormatArray defines the format of the data and signalUnitArray the unit
            if ~isempty(newData)
                timeStampNew = newData(:,1);                               % get timestamps
                timeStamp = [timeStamp; timeStampNew];
            end
            allData = [allData; newData];
            
            elapsedTime = elapsedTime + toc;                               % Stop timer and add to elapsed time
            timings = [timings [elapsedTime; length(newData)]];
            tic;                                                           % Start timer
        end
        
        elapsedTime = elapsedTime + toc;                                   % Stop timer
        fprintf('The percentage of received packets: %d \n',shimmer.getpercentageofpacketsreceived(timeStamp)); % Detect loss packets
        DATA.GSR.(sprintf('trial%d',i)).timings = [timings; cumsum(timings(2,:))];
        DATA.GSR.(sprintf('trial%d',i)).allData = allData;
        allData=[];
        timings=[];
        else
            Screen('Flip', window);
            wait(DATA.params.imagine_time)
        end
        
        %% show text rating questions (first question)
        
        % Lets write three lines of text, the first and second right after one
        % another, and the third with a line space in between. To add line spaces
        % we use the special characters "\n"
        
        line1a = char(inv_type(trials_list(1)));
        q_num(j) = q_list.(sprintf('inv%d',trials_list(1)))(1);
        line2a = questions{q_num(j)};
        line3a = questions2{q_num(j)};
        
        ratingTime_Start = [ratingTime_Start; clock];
        
        if q_num(j)==1
            % Draw all the text in one go
            Screen('TextSize', window, font_sz/2);
            DrawFormattedText(window, line1a,'center', screenYpixels * 0.2, fg);
            DrawFormattedText(window, line2a,'center', screenYpixels * 0.3, fg);
            DrawFormattedText(window, line3a,'center', screenYpixels * 0.4, fg);
            
            if rand_binary(1)==1
                DrawFormattedText(window, 'No',screenXpixels * 0.25, screenYpixels * 0.5, fg);
                DrawFormattedText(window, 'Yes',screenXpixels * 0.75, screenYpixels * 0.5, fg);
                % Flip to the screen
                Screen('Flip', window);
            else
                DrawFormattedText(window, 'Yes',screenXpixels * 0.25, screenYpixels * 0.5, fg);
                DrawFormattedText(window, 'No',screenXpixels * 0.75, screenYpixels * 0.5, fg);
                % Flip to the screen
                Screen('Flip', window);
            end
            
            % Wait for choice
            [tDelta, tStart, key] = psytool_waitkeydown(inf, [leftkey rightkey]);
            if ((key==leftkey) && (rand_binary(1)==2)) || ((key==rightkey) && (rand_binary(1)==1))
                DATA.relevant = [DATA.relevant 1]; %1 is yes for relevant
                number(j) = 1;
            else
                DATA.relevant = [DATA.relevant 0]; %0 is no for relevant
                number(j) = 0;
            end
            
            DATA.relevant_whichInv = [DATA.relevant_whichInv q_num(j)];
            DATA.rt(j)=tDelta; %save reaction times
            rand_binary(1)=[];
        else
            outkey = bkey;
            tic;
            while outkey==bkey
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, [line1a '\n\n' line2a '\n\n' line3a], 'center',screenYpixels * 0.2, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, key] = psytool_waitkeydown(inf, number_keys);
                digit1 = num2str(find(ismember(number_keys,key))-1);
                
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, [line1a '\n\n' line2a '\n\n' line3a '\n\n' digit1], 'center',screenYpixels * 0.2, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, key] = psytool_waitkeydown(inf, number_keys);
                digit2 = num2str(find(ismember(number_keys,key))-1);
                
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, [line1a '\n\n' line2a '\n\n' line3a '\n\n' digit1 digit2], 'center',screenYpixels * 0.2, fg);
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, 'Are you sure? (press "b" to go back or "n" for next trial)', 'center',screenYpixels * 0.7, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, outkey] = psytool_waitkeydown(inf, [bkey nkey]);
            end
            
            number(j) = str2num([digit1 digit2]);
            DATA.rt(j)=toc; %save reaction times
        end
        
        all_answers(q_num(j),trials_list(1)) = number(j);
        all_answers_RT(q_num(j),trials_list(1)) = DATA.rt(j);     
        ratingTime_End = [ratingTime_End; clock];
        %% confidence rating 1a
        
        if q_num(j)==1 || q_num(j)==8
            confTime_Start = [confTime_Start; clock];
            outkey = bkey;
            tic;
            while outkey==bkey
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, ['Confidence Rating' '\n\n' '0 (not confident) to 100 (very confident)'], 'center',screenYpixels * 0.2, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, key] = psytool_waitkeydown(inf, number_keys);
                digit1 = num2str(find(ismember(number_keys,key))-1);
                
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, ['Confidence Rating' '\n\n' '0 (not confident) to 100 (very confident)' '\n\n' digit1], 'center',screenYpixels * 0.2, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, key] = psytool_waitkeydown(inf, number_keys);
                digit2 = num2str(find(ismember(number_keys,key))-1);
                
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, ['Confidence Rating' '\n\n' '0 (not confident) to 100 (very confident)' '\n\n' digit1 digit2], 'center',screenYpixels * 0.2, fg);
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, 'Are you sure? (press "b" to go back or "n" to keep going)', 'center',screenYpixels * 0.7, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, outkey] = psytool_waitkeydown(inf, [bkey nkey]);
            end
            
            all_conf1(q_num(j),trials_list(1)) = str2num([digit1 digit2]);
            all_conf1_RT(q_num(j),trials_list(1)) = toc;
            confTime_End = [confTime_End; clock];
        end
        
        % (housekeeping)
        q_list.(sprintf('inv%d',trials_list(1)))(1) = [];
        j=j+1;
        %% show text rating questions (second question)
        
        % Lets write three lines of text, the first and second right after one
        % another, and the third with a line space in between. To add line spaces
        % we use the special characters "\n"
        
        line1a = char(inv_type(trials_list(1)));
        q_num(j) = q_list.(sprintf('inv%d',trials_list(1)))(1);
        line2a = questions{q_num(j)};
        line3a = questions2{q_num(j)};
        
        ratingTime_Start = [ratingTime_Start; clock];
        
        if q_num(j)==1
            % Draw all the text in one go
            Screen('TextSize', window, font_sz/2);
            DrawFormattedText(window, line1a,'center', screenYpixels * 0.2, fg);
            DrawFormattedText(window, line2a,'center', screenYpixels * 0.3, fg);
            DrawFormattedText(window, line3a,'center', screenYpixels * 0.4, fg);
            
            if rand_binary(1)==1
                DrawFormattedText(window, 'No',screenXpixels * 0.25, screenYpixels * 0.5, fg);
                DrawFormattedText(window, 'Yes',screenXpixels * 0.75, screenYpixels * 0.5, fg);
                % Flip to the screen
                Screen('Flip', window);
            else
                DrawFormattedText(window, 'Yes',screenXpixels * 0.25, screenYpixels * 0.5, fg);
                DrawFormattedText(window, 'No',screenXpixels * 0.75, screenYpixels * 0.5, fg);
                % Flip to the screen
                Screen('Flip', window);
            end
            
            % Wait for choice
            [tDelta, tStart, key] = psytool_waitkeydown(inf, [leftkey rightkey]);
            if ((key==leftkey) && (rand_binary(1)==2)) || ((key==rightkey) && (rand_binary(1)==1))
                DATA.relevant = [DATA.relevant 1]; %1 is yes for relevant
                number(j) = 1;
            else
                DATA.relevant = [DATA.relevant 0]; %0 is no for relevant
                number(j) = 0;
            end
            
            DATA.relevant_whichInv = [DATA.relevant_whichInv q_num(j)];
            DATA.rt(j)=tDelta; %save reaction times
            rand_binary(1)=[];
        else
            outkey = bkey;
            tic;
            while outkey==bkey
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, [line1a '\n\n' line2a '\n\n' line3a], 'center',screenYpixels * 0.2, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, key] = psytool_waitkeydown(inf, number_keys);
                digit1 = num2str(find(ismember(number_keys,key))-1);
                
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, [line1a '\n\n' line2a '\n\n' line3a '\n\n' digit1], 'center',screenYpixels * 0.2, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, key] = psytool_waitkeydown(inf, number_keys);
                digit2 = num2str(find(ismember(number_keys,key))-1);
                
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, [line1a '\n\n' line2a '\n\n' line3a '\n\n' digit1 digit2], 'center',screenYpixels * 0.2, fg);
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, 'Are you sure? (press "b" to go back or "n" to keep going)', 'center',screenYpixels * 0.7, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, outkey] = psytool_waitkeydown(inf, [bkey nkey]);
            end
            
            number(j) = str2num([digit1 digit2]);
            DATA.rt(j)=toc; %save reaction times
        end
        
        all_answers(q_num(j),trials_list(1)) = number(j);
        all_answers_RT(q_num(j),trials_list(1)) = DATA.rt(j);
        ratingTime_End = [ratingTime_End; clock];
        %% confidence rating 1b
        
        if q_num(j)==1 || q_num(j)==8
            confTime_Start = [confTime_Start; clock];
            outkey = bkey;
            tic;
            while outkey==bkey
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, ['Confidence Rating' '\n\n' '0 (not confident) to 100 (very confident)'], 'center',screenYpixels * 0.2, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, key] = psytool_waitkeydown(inf, number_keys);
                digit1 = num2str(find(ismember(number_keys,key))-1);
                
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, ['Confidence Rating' '\n\n' '0 (not confident) to 100 (very confident)' '\n\n' digit1], 'center',screenYpixels * 0.2, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, key] = psytool_waitkeydown(inf, number_keys);
                digit2 = num2str(find(ismember(number_keys,key))-1);
                
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, ['Confidence Rating' '\n\n' '0 (not confident) to 100 (very confident)' '\n\n' digit1 digit2], 'center',screenYpixels * 0.2, fg);
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, 'Are you sure? (press "b" to go back or "n" to keep going)', 'center',screenYpixels * 0.7, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, outkey] = psytool_waitkeydown(inf, [bkey nkey]);
            end
            
            all_conf1(q_num(j),trials_list(1)) = str2num([digit1 digit2]);
            all_conf1_RT(q_num(j),trials_list(1)) = toc; %save reaction times
            confTime_End = [confTime_End; clock];
        end
        
        
        
        % end trial (housekeeping)
        q_list.(sprintf('inv%d',trials_list(1)))(1) = [];
        trials_list(1) = [];
    end
    %% END experiment I
    if shimmer_on==1
    shimmer.stop;                                                       %stop streaming from shimmer
    shimmer.disconnect;                                                    % Disconnect from shimmer
    end
    
    DATA.number = number;
    DATA.q_num = q_num;
    DATA.all_answers = all_answers;
    DATA.all_answers_RT = all_answers_RT;
    DATA.all_conf1 = all_conf1;
    DATA.all_conf1_RT = all_conf1_RT;
    DATA.confTime_End = confTime_End;
    DATA.confTime_Start = confTime_Start;
    DATA.ratingTime_End = ratingTime_End;
    DATA.ratingTime_Start = ratingTime_Start;
    DATA.invTime = invTime;
    
    % save data
    save(filename,'DATA')
    
	%creates file that stops shimmer if shimmer is being run externally
	stopvar = 'this is the shimmer stopfile';
	save('stopfile','stopvar')
	
    % call in experimenter to turn off shimmer
    DrawFormattedText(window, 'Please call in the experimenter to turn off the GSR recording device.', 'center', screenYpixels * 0.1, fg);
    Screen('Flip', window);
    [~, ~, outkey] = psytool_waitkeydown(inf, shimmer_key1);
    [~, ~, outkey] = psytool_waitkeydown(inf, shimmer_key2);
    
    ShowCursor;
end

pause(5) %wait a bit so the shimmer shuts down, the delete shimmer start/stop files
delete('startfile.m')
delete('stopfile.m')

if skipExp2==0
    %% Start Experiment II
    HideCursor;
    
    if debug==0 %only show instructions when not debugging
        % show instructions
        for i = 13:16
            % Here we load in an image from file.
            image = sprintf('Slide%d.jpg',i);
            theImage = imread(image);
            
            % Make the image into a texture
            imageTexture = Screen('MakeTexture', window, theImage);
            
            % Draw the image to the screen, unless otherwise specified PTB will draw
            % the texture full size in the center of the screen.
            Screen('DrawTextures', window, imageTexture, [], []);
            
            % Flip to the screen
            Screen('Flip', window);
            
            % Wait for a key press
            KbStrokeWait;
        end
    end
    
    % setup experiment parameters
    stims_exp2=[];
    for i = length(inv_type):-1:1
        stims_exp2 = [stims_exp2 [1:i-1; ones(1,i-1)*i]];
    end
    
    stims_exp2 = [stims_exp2 stims_exp2];
    stims_exp2_block1 = stims_exp2(:,randperm(length(stims_exp2)));
    stims_exp2_block2 = stims_exp2(:,randperm(length(stims_exp2)));
    
    DATA.trials2_block1 = stims_exp2_block1;
    DATA.trials2_block2 = stims_exp2_block2;
    DATA.trials2 = [DATA.trials2_block1 DATA.trials2_block2];
    
    if debug==1
        stims_exp2=stims_exp2(:,1:3);
    end
    
    fg = black;
    
    for block = 1:2
        for trial = 1:length(stims_exp2)
            %% show fixation cross
            
            % Here we set the size of the arms of our fixation cross
            fixCrossDimPix = 40;
            
            % Now we set the coordinates (these are all relative to zero we will let
            % the drawing routine center the cross in the center of our monitor for us)
            xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
            yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
            allCoords = [xCoords; yCoords];
            
            % Set the line width for our fixation cross
            lineWidthPix = 4;
            
            % Draw the fixation cross in black, set it to the center of our screen and
            % set good quality antialiasing
            Screen('DrawLines', window, allCoords,lineWidthPix, black, [xCenter yCenter], 2);
            
            % Flip to the screen
            Screen('Flip', window);
            
            wait(DATA.params.fix_time)
            
            % Flip to the screen
            Screen('Flip', window);
            
            wait(DATA.params.wait_time)
            %% show text
            
            invLeft = DATA.(sprintf('trials2_block%d',block))(1,trial); %left presentation
            invRight = DATA.(sprintf('trials2_block%d',block))(2,trial); %right presentation
            
            % Draw all the text in one go
            Screen('TextSize', window, font_sz2);
            
            DrawFormattedText(window, 'You have 100 pounds to invest in:', 'center', screenYpixels * 0.1, fg);
            
            DrawFormattedText(window, char(inv_type(invLeft)), xCenter*0.25, screenYpixels * 0.25, fg);
            
            DrawFormattedText(window, char(inv_type(invRight)), xCenter*1.25, screenYpixels * 0.25, fg);
            
            % Flip to the screen
            Screen('Flip', window);
            
            % Wait for choice
            [tDelta, tStart, key] = psytool_waitkeydown(inf, [leftkey rightkey]);
            DATA.(sprintf('rt2_block%d',block))(trial)=tDelta; %save reaction times
            
            if key==leftkey
                DATA.(sprintf('choice2_block%d',block))(trial)=1; %left is coded as 1
                DATA.(sprintf('choice2b_block%d',block))(trial)=invLeft; %save investment ID too
            else
                DATA.(sprintf('choice2_block%d',block))(trial)=0; %right is coded as 0
                DATA.(sprintf('choice2b_block%d',block))(trial)=invRight; %save investment ID too
            end
            
            %% confidence rating 2
            
            outkey = bkey;
            tic;
            while outkey==bkey
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, ['Confidence Rating' '\n\n' '0 (not confident) to 100 (very confident)'], 'center',screenYpixels * 0.2, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, key] = psytool_waitkeydown(inf, number_keys);
                digit1 = num2str(find(ismember(number_keys,key))-1);
                
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, ['Confidence Rating' '\n\n' '0 (not confident) to 100 (very confident)' '\n\n' digit1], 'center',screenYpixels * 0.2, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, key] = psytool_waitkeydown(inf, number_keys);
                digit2 = num2str(find(ismember(number_keys,key))-1);
                
                % Draw all the text in one go
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, ['Confidence Rating' '\n\n' '0 (not confident) to 100 (very confident)' '\n\n' digit1 digit2], 'center',screenYpixels * 0.2, fg);
                Screen('TextSize', window, font_sz/2);
                DrawFormattedText(window, 'Are you sure? (press "b" to go back or "n" to keep going)', 'center',screenYpixels * 0.7, fg);
                
                % Flip to the screen
                Screen('Flip', window);
                
                [~, ~, outkey] = psytool_waitkeydown(inf, [bkey nkey]);
            end
            
            conf2(trial) = str2num([digit1 digit2]);
            DATA.(sprintf('conf2_block%d',block))(trial) = conf2(trial);
            DATA.(sprintf('conf2_rt_block%d',block))(trial)=toc; %save reaction times
        end
        % Draw all the text in one go
        Screen('TextSize', window, font_sz/2);
        DrawFormattedText(window, 'End of block. Please take a break. \n Press any key to continue', 'center', screenYpixels * 0.25, fg);
        
        % Flip to the screen
        Screen('Flip', window);
        
        % Wait for a key press
        KbStrokeWait;
    end
    
    % save data
    save(filename,'DATA')
    ShowCursor;
end

if skipExp3 == 0
    %% start pie chart task
    % show instructions
    for i = 17:19
        % Here we load in an image from file.
        image = sprintf('Slide%d.jpg',i);
        theImage = imread(image);
        
        % Make the image into a texture
        imageTexture = Screen('MakeTexture', window, theImage);
        
        % Draw the image to the screen, unless otherwise specified PTB will draw
        % the texture full size in the center of the screen.
        Screen('DrawTextures', window, imageTexture, [], []);
        
        % Flip to the screen
        Screen('Flip', window);
        
        % Wait for a key press
        KbStrokeWait;
    end
    
    % Clear the screen
    sca;
    
    [percents,investment,order] = ArcDemo3(inv_type);
    [~,i]=sort(order);
    DATA.percents = percents(i);
    DATA.investment_pie1 = investment;
    DATA.investment_pie2 = order;
    
    % save data
    save(filename,'DATA')
end

sca;