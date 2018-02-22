function [percents,investment,order] = ArcDemo3(inv_type)
% ArcDemo
%
% Demonstration of the function Screen('FillArc',...) on OSX
%
% Date of creation: 12/02/05
% Author: Kerstin Preuschoff, Caltech
%
% Previous versions:
%
% History:
% Small changes to make it OSX-ish by Mario Kleiner
%
% Presentation Sequence:
%   - the demo basically draws a pie chart (circle with 3 differently
%   colored arcs
%   - the circle is then partially covered by another arc
%

% Make sure we run on OpenGL Psychtoolbox
AssertOpenGL;

%inv_type= {'Children''s Education'; 'Future Travels'; 'Buying a House'; 'Retirement'; 'Healthcare'; 'Charity'; 'Wedding'; 'Buying a Car'; 'Electronics'; 'Entertainment'};
order = randperm(length(inv_type));
investment = inv_type(order);


try
    
    % keyboard setup
    KbName('UnifyKeyNames'); %this part is for getting the keyboard numbers so you can wait for a certain keypress later on
    leftkey = KbName('LeftArrow');
    rightkey = KbName('RightArrow');
    upkey = KbName('UpArrow');
    downkey = KbName('DownArrow');
    enterkey = KbName('Return');
    resetkey = KbName('r');
    normkey = KbName('n');
    stopkey = KbName('s');
    number_keys = 48:57; %hard coded, clash with cogent? use KbDemo to check numbers of keys
    
    % Open onscreen window with default settings:
    screenNumber = max(Screen('Screens'));
    [window,screenRect] = Screen('OpenWindow', screenNumber, 0, []);
    
    width = screenRect(3);
    height = screenRect(4);
    HideCursor;
    
    % define positions and angles
    font_sz = 35;
    sizeRect = 350;
    rightShift = 300;
    positionOfMainCircle = [width/2-sizeRect+rightShift height/2-sizeRect width/2+sizeRect+rightShift height/2+sizeRect];
    %aspect_ratio = width/height;
    sizeRect2 = sizeRect + 50;
    positionOfSelection = [width/2-sizeRect2+rightShift height/2-sizeRect2 width/2+sizeRect2+rightShift height/2+sizeRect2];
    numInvestments = length(investment);
    startAngle = repmat(360/numInvestments,1,numInvestments).*(0:numInvestments-1);   % the colors red, blue, green start
    % at 0, 100, 240 deg
    
    for i = numInvestments:-1:1
        if i == numInvestments
            sizeAngle(i) = 360-startAngle(end);
        else
            sizeAngle(i) = startAngle(i+1)-startAngle(i);
        end
    end
    
    %sizeAngle  = [startAngle(2) startAngle(3)-startAngle(2) 120] ; % the colors red, blue, green end at
    % 0+100=100, 100+140=240, 240+120=360 deg
    
    % define colors
    white = WhiteIndex(window) ;
    darkgray = white/2.2;
    black = [0 0 0];
    astrk = black;
    %red = [200 0 0] ;
    %green = [0 200 0] ;
    %blue = [0 0 200];
    
    % Clear screen to blue background:
    Screen('FillRect', window, [255 255 255]);
    Screen('Flip', window);
    
    textHeight = 10;
    color = [];
    % Draw filled arcs:
    for i = 1:numInvestments
        color = [color; [randi(255) randi(255) randi(255)]];
        textHeight(i+1) = textHeight(i) + height/numInvestments;
    end
    textHeight(numInvestments+1)=[];
    
    still_going=1;
    key=upkey;
    j=2;
    while still_going == 1
        for i = 1:numInvestments
            if (key==upkey && j==1 && i==1)
                Screen('FillArc',window, color(numInvestments,:),positionOfSelection,startAngle(numInvestments),sizeAngle(numInvestments));
            end
            
            if key==downkey && j==numInvestments && i==numInvestments
                Screen('FillArc',window, color(1,:),positionOfSelection,startAngle(1),sizeAngle(1));
            end
            
            if (key==upkey && j-1==i) || (key==downkey && j+1==i)
                Screen('FillArc',window, color(i,:),positionOfSelection,startAngle(i),sizeAngle(i));
            else
                Screen('FillArc',window, color(i,:),positionOfMainCircle,startAngle(i),sizeAngle(i));
            end
            Screen('TextSize', window, font_sz);
            DrawFormattedText(window, investment{i},'left', textHeight(i), color(i,:));
            spaces{i} = repmat(' ',1,length(investment{i})+1);
            if length(num2str(round(sizeAngle(i)/360*100)))==1
                text1 = sprintf('%02d%%', round(sizeAngle(i)/360*100));
                text1 = [spaces{i} text1];
            else
                text1 = sprintf('%d%%', round(sizeAngle(i)/360*100));
                text1 = [spaces{i} text1];
            end
            DrawFormattedText(window, text1,'left', textHeight(i), color(i,:));
        end
        
        if ismember(key,number_keys)
            DrawFormattedText(window, [spaces{j} '   *'],'left', textHeight(j), astrk);
            Screen('Flip', window);
        end
        
        if key == upkey
            if j==1
                j=numInvestments;
            else
                j=j-1;
            end
            DrawFormattedText(window, [spaces{j} '   *'],'left', textHeight(j), astrk);
            Screen('Flip', window);
        elseif key == downkey
            if j==numInvestments
                j=1;
            else
                j=j+1;
            end
            DrawFormattedText(window, [spaces{j} '   *'],'left', textHeight(j), astrk);
            Screen('Flip', window);
        elseif key == stopkey
            still_going=0;
        end
        [tDelta, tStart, key] = psytool_waitkeydown(inf, [upkey downkey stopkey number_keys resetkey normkey]);
        
        if ismember(key,number_keys)
            temp = num2str(round(sizeAngle(j)/360*100));
            number = key-number_keys(1);
            final_num = str2num([temp(end) num2str(number)]);
            orig_num = sizeAngle(j);
            sizeAngle(j) = final_num*3.6;
            take_num = sizeAngle(j) - orig_num;
            
            k=j;
%             while take_num~=0
%                 if k==length(sizeAngle)
%                     k=1;
%                 else
%                     k=k+1;
%                 end
%                 
%                 if sizeAngle(k)>= take_num
%                     %sizeAngle(k) = sizeAngle(k)-take_num;
%                     take_num = 0;
%                 else
%                     take_num = take_num-sizeAngle(k);
%                     sizeAngle(k) = 0;
%                 end
%             end
            
        elseif key == resetkey %reset all the numbers with resetkey
            startAngle = repmat(360/numInvestments,1,numInvestments).*(0:numInvestments-1); 
            for i = numInvestments:-1:1
                if i == numInvestments
                    sizeAngle(i) = 360-startAngle(end);
                else
                    sizeAngle(i) = startAngle(i+1)-startAngle(i);
                end
            end    
        elseif key == normkey %normalize pie chart
            sizeAngle = sizeAngle./sum(sizeAngle)*360;            
            
        end
        
        startAngle(1) = 0;
        for i = 2:numInvestments
            startAngle(i) = startAngle(i-1)+sizeAngle(i-1);
        end
        
    end
    
    percents = round(sizeAngle/360*100);
    
    % Flip to the screen
    Screen('Flip', window);
    
    % Here we load in an image from file.
    image = sprintf('Slide20.jpg');
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
    
    % Done. Show cursor and close window.
    ShowCursor;
    Screen('CloseAll');
    
catch
    % This section is executed in case an error happens in the
    % experiment code implemented between try and catch...
    ShowCursor;
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end


end
