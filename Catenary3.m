# Dadant
# top frame: 470 / 435 X 27
# frame height: 37 to 27 X 300 X 6
# |----|
# |____|

 
% Prevent Octave from thinking that this
% is a function file:
1;

function [a, b, c] = pitagora(a=0 ,b=0, c=0)
  # function that calculate triangle sides with pitagora
  if length(find([a,b,c]>0)) < 2
      error ("not enough input arguments");
    else
      if c == 0 
          c = (a**2 + b**2)**(1/2);
       elseif a==0
         a = (c**2 - b**2)**(1/2);
       else 
         b = (c**2 - a**2)**(1/2);     
       end 
    end
end
     
pitagora(a=1,b=0,c=3)

function [x, y] = catenary(s,w,a) 
  
## calculate catenary curve
  x = s;
  # y=a*cosh((x)/a) - a;
    y = w*(cosh(x/a)-1);
end


# numeric search for the corresponding y for a given x in an 2 dim matrix
function result = find_y_in_matrix(mat,x)
  i = 3;
    while (i <= rows(mat))
      if (mat(i-1,1) < x && mat(i,1) >= x)
        result =  mat(i,2);
        break
      endif  
      i += 1;
    end
end     
        
# numeric search for the corresponding x for a given y in an 2 dim matrix
function result = find_x_in_matrix(mat,y)
  i = 3;
    while (i <= rows(mat))
      if (mat(i-1,2) < y && mat(i,2) >= y)
        result =  mat(i,1);
        break
      endif  
      i += 1;
    end
end         
        




## http://www.beginningbeekeeping.com/BeeFaqs.htm
## one bee has max 5/8 inch length = 1.58 cm
## one bee weights a tenth of a gram = 1/10000
## lambda = nr of bees per meter * weigh of a bee


## I needed to tweak the T to get into a workable catenary shape
% s, the length of the chain in increments used to calculate the catenary
s = [-50:0.01:50]; % meters

# dimensions
hive_height = 45;
hive_max_width = 45;  #+ wood 
wood_width = 2.4;

for a = 5.23
  for w =1.20
  
  [x, y] = catenary(s, w, a);;
    # draw the catenary curve
    fig = figure(1);
    ax1 = subplot(2,1,1);
    title(sprintf("Params a,w: %0.2f,%0.2f",a,w));
    hold on;
    plot(ax1,x,y);
    axis([-35 45 0 hive_height]);
    C = [x; y]';
    #save myfile.mat C;

    rings = [,];
    for h = 0:wood_width:45
      i = 3;
      while (i <= rows(C))
         if (C(i-1,2) < h && C(i,2) >= h)
           new_row = [C(i,1), C(i,2)];
           # add lines on the curve graph
            %% plot a line between two points using plot([x1,x2],[y1,y2])
            plot(ax1,[-30,25],[h,h]);
            text(26, h-(wood_width/2), sprintf("R,h (%0.2f, %0.2f)",C(i,1),h));
            
            hold on;           
            rings = [rings; new_row];
         endif  
        i++;
      endwhile
        
    end
    

    #close();

  end

end

# plot frames positioning
ax2 = subplot(2,1,2);
hold on;
plot(ax2, x,y);
axis([-35 45 0 hive_height]);
yend = 0;

#store calculated frames in frames matrix
frames=[];

# 3.8 cm distance between honeycombs

for cur_height = -19 :3.8:19  
    #find the y for the intersection between the frame and the hive side, 
    # add +2 to make room to the bees
    ystart = rings(length(rings),2);
    
    #considering maxlength as the diff between Ystart and wood_width -2
    yend = max(find_y_in_matrix(C,cur_height) +2, wood_width +2);    
    
    plot(ax2,[cur_height cur_height], [ystart yend]);   
    h = text(cur_height, 45, sprintf("(%0.2f, %0.2f)",cur_height, ystart - yend));
    # get_nearest_y
    set(h,'Rotation',90);
    
    #append the new frame to frames matrix
    new_frame = [ystart - yend];
    frames=[frames; new_frame];
end
print(fig, sprintf("Catenary_a_w_%0.2f_%0.2f.jpg",a,w), '-dpng');
hold off



# plot distinct frames after rounding the values to 2 decimals

n=1;
shrink = 2;
frames=round(frames*10^n)/10^n;
uniqueframes = unique(frames);
fig = figure(2);
for i = 1:length(uniqueframes)
  ax3 = subplot(length(uniqueframes),1,i);
  axis([-35 45 0 hive_height]);
  title(sprintf("Frame size: %0.1f",uniqueframes(i)));
  hold on;
  yend = uniqueframes(i);
  line(ax3,[0 0], [ystart - uniqueframes(i) ystart]);

  # plot points on the side
  xtmp = [];
  ytmp = [];
  for cur_y = ystart - uniqueframes(i):wood_width:ystart
    cur_x = find_x_in_matrix(C,cur_y)
    ytmp = [ytmp cur_y];
    xtmp = [xtmp cur_x];
    text(cur_x+2, cur_y, sprintf("(%0.2f, %0.2f)",cur_x, cur_y));
  end 
  #plot points after adjusting the size by shrink param
  plot(ax3, xtmp-shrink,ytmp);

  plot(ax3, -xtmp+shrink,ytmp);  
  
end

