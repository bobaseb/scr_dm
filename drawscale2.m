 %--------------------------------------------------------------------------------------------------
 function drawscale(w,width,height,scalelength,scalexoffset,currentpos)

 textstring{1} = '1mm';
 textstring{2} = '1cm';
 textstring{3} = '10cm';
 textstring{4} = '1m';
 textstring{5} = '10m';
 textstring{6} = '100m';
 textstring{7} = '1km';
 textstring{8} = '10km';

  Screen('DrawLine', w, [0], width/2-scalelength/2, height/2+scalexoffset, width/2+(scalelength/2)-1, height/2+scalexoffset, 4);
  
 for n = 1:8
     Screen('DrawLine', w, [0], width/2-scalelength/2+(n-1)*100, height/2+scalexoffset-5, width/2-scalelength/2+(n-1)*100, height/2+scalexoffset+5, 4);
     DrawFormattedText(w, textstring{n}, width/2-(10 + scalelength/2)+(n-1)*100, height/2+scalexoffset+10, 0);
 end
 
 Screen('DrawLine', w, [255 0 0], width/2+(scalelength/2)-1-currentpos, height/2+scalexoffset-40, width/2+(scalelength/2)-1-currentpos, height/2+scalexoffset, 8);
 Screen('DrawLine', w, [255 0 0], width/2+(scalelength/2)-1-currentpos+10, height/2+scalexoffset-10, width/2+(scalelength/2)-1-currentpos, height/2+scalexoffset, 8);
 Screen('DrawLine', w, [255 0 0], width/2+(scalelength/2)-1-currentpos-10, height/2+scalexoffset-10, width/2+(scalelength/2)-1-currentpos, height/2+scalexoffset, 8);

 end
