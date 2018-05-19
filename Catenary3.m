# Dadant
# top frame: 470 / 435 X 27
# frame height: 37 to 27 X 300 X 6
# |----|
# |____|
 
% Prevent Octave from thinking that this
% is a function file:
1;

function [x, y] = catenary(s,w,a) 
  
## calculate catenary curve
  x = s;
  # y=a*cosh((x)/a) - a;
    y = w*(cosh(x/a)-1);
end
% s, the length of the chain in increments 

s = [-50:0.01:50]; % meters


## http://www.beginningbeekeeping.com/BeeFaqs.htm
## one bee has max 5/8 inch length = 1.58 cm
## one bee weights a tenth of a gram = 1/10000
## lambda = nr of bees per meter * weigh of a bee

pl=1;
## I needed to tweak the T to get into a workable catenary shape

# dimensions
hive_height = 40;
hive_max_width = 45;  #+ wood 
wood_width = 2.4;

for a = 5:0.5:6
  subplot(2,2,pl);

  pl=pl+1
  for w =1.33
  title(sprintf("Params a,w: %0.2f,%0.2f",a,w));
  [x, y] = catenary(s, w, a);;
    # draw the catenary curve
    hold on;
    plot(x,y);
    axis([-35 45 0 hive_height]);
    C = [x; y]';
    #save myfile.mat C;

    A = [,];
    for h = 0:wood_width:40 
      i = 3;
      while (i <= rows(C))
         if (C(i-1,2) < h && C(i,2) >= h)
           new_row = [C(i,1), C(i,2)];
           # add lines on the curve graph
            %% plot a line between two points using plot([x1,x2],[y1,y2])
            plot([-30,25],[h,h]);
            text(26, h-(wood_width/2), sprintf("R,h (%0.2f, %0.2f)",C(i,1),h));
            
            hold on;           
           A = [A; new_row];
         endif  
        i++;
      endwhile
        
    end
    print -djpg catenaryHive.jpg

  end

end
