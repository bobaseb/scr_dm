% basic script to demonstrate a sliding scale
 % happens to be a log scale but could easily be modified to be a linear scale
 % DHB 17/7/14

 close all;
 KbName('UnifyKeyNames');

 scalexoffset = 306;
 scalelength = 700;

 try
     
     oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
     oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
         
     screens=Screen('Screens');
     screenNumber=max(screens);
     
     rect = [100 100 912 912];
     w=Screen('OpenWindow',screenNumber,128,rect);
     ST.greylevel = 128;
     
     [width, height] = Screen('WindowSize', w);
     Screen('FillRect',w, ST.greylevel);
     Screen('Flip', w);
     
     fontsize = 15;
     Screen('TextSize', w, fontsize);
     
     currentpos = ceil(rand*scalelength);
     SetMouse(width/2,height/2+349-currentpos,w);     % set the mouse pointer to the appropriate location for the random size
     counter = 0;
     
     breakcode = 0;
     while ~breakcode
         counter = counter + 1;
         
         exitcode = 0;
         while ~exitcode
             
             Screen('FillRect',w, ST.greylevel);
            
             drawscale2(w,width,height,scalelength,scalexoffset,currentpos);
             
             Screen('Flip', w);
             
             [x,y,buttons] = GetMouse;
             currentpos = (scalelength+1)-round(scalelength*(x/width));
             currentpos = min(currentpos, scalelength);
             currentpos = max(currentpos, 0);
             
             [keyIsDown, secs, keyCode] = KbCheck;
             
             if buttons(1) || keyCode(KbName('LeftArrow'))
                 exitcode = 1;
             elseif buttons(2) || keyCode(KbName('RightArrow'))
                 exitcode = 1;
             elseif keyCode(KbName('Escape'))
                 exitcode = 1;
                 breakcode = 1;
             end
             
         end
         Screen('FillRect',w, ST.greylevel);
         Screen('Flip', w);
         
         
         perceivedlengths(counter) = 10^((scalelength-currentpos)/100);
         WaitSecs(0.5);
     end
 catch
     
     lasterr
     
 end

 Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
 Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
 Screen('CloseAll');

 perceivedlengths'

% end
