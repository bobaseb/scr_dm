function [ number ] = num_input( number_keys, bkey, nkey )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

outkey = bkey;
while outkey==bkey
    
    % Flip to the screen
    Screen('Flip', window);
    
    [~, ~, key] = psytool_waitkeydown(inf, number_keys);
    digit1 = num2str(find(ismember(number_keys,key))-1);
    
    % Draw all the text in one go
    Screen('TextSize', window, font_sz_small);
    DrawFormattedText(window, [acc1 acc2 acc3 acc4 acc5 acc6 '\n' spaces digit1 '.'], xCenter*0.1,...
        screenYpixels * 0.25, white);
    
    % Flip to the screen
    Screen('Flip', window);
    
    [~, ~, key] = psytool_waitkeydown(inf, number_keys);
    digit2 = num2str(find(ismember(number_keys,key))-1);
    
    % Draw all the text in one go
    Screen('TextSize', window, font_sz_small);
    DrawFormattedText(window, [acc1 acc2 acc3 acc4 acc5 acc6 '\n' spaces digit1 '.' digit2], xCenter*0.1,...
        screenYpixels * 0.25, white);
    
    % Flip to the screen
    Screen('Flip', window);
    
    [~, ~, outkey] = psytool_waitkeydown(inf, [bkey nkey]);
end

number = str2num([digit1 digit2]);

end

