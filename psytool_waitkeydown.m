function [tDelta, tStart, key] = psytool_waitkeydown(t, keys)
% space key is: 32
switch nargin
    case 0
        t = inf; keys = [];
    case 1
        keys = [];
end
%waitkeydown
% wait for all keys to be released
% this is necessay otherwise it does not wait at all
while KbCheck; end

key = NaN;
tStart = GetSecs;
tEnd = tStart + t;
while GetSecs<tEnd
    [touch, ~, keyCode, ~] = KbCheck();
    if touch && (isempty(keys) || ismember(find(keyCode, 1, 'last' ), keys))
       key = find(keyCode, 1, 'last');
       break
    end
    WaitSecs(0.001);
end
tDelta = GetSecs - tStart;

end
