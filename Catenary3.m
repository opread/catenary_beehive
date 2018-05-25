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


# numeric search for the corresponding y for a given x in an 2 dim matrix
function result = find_y_in_matrix(mat,x)
  i = 3;
    while (i <= rows(mat))
      if (mat(i-1,1) < x && mat(i,1) >= x)
        result =  mat(i,2)
        
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
hive_height = 40;
hive_max_width = 45;  #+ wood 
wood_width = 2.4;

for a = 5.30
  for w =1.20
  
  [x, y] = catenary(s, w, a);;
    # draw the catenary curve
    fig = figure;
    ax1 = subplot(2,1,1);
    title(sprintf("Params a,w: %0.2f,%0.2f",a,w));
    hold on;
    plot(ax1,x,y);
    axis([-35 45 0 hive_height]);
    C = [x; y]';
    #save myfile.mat C;

    A = [,];
    for h = 0:wood_width:44
      i = 3;
      while (i <= rows(C))
         if (C(i-1,2) < h && C(i,2) >= h)
           new_row = [C(i,1), C(i,2)];
           # add lines on the curve graph
            %% plot a line between two points using plot([x1,x2],[y1,y2])
            plot(ax1,[-30,25],[h,h]);
            text(26, h-(wood_width/2), sprintf("R,h (%0.2f, %0.2f)",C(i,1),h));
            
            hold on;           
           A = [A; new_row];
         endif  
        i++;
      endwhile
        
    end
    

    #close();

  end

end

# plot frames
ax2 = subplot(2,1,2);
hold on;
plot(ax2, x,y);
axis([-35 45 0 hive_height]);
yend = 0;

# 3.8 cm distance between honeycombs
for x = -19 :3.8:20 
     
    #find the y for the intersection between the frame and the hive side, 
    # add +2 to make room to the bees
    ystart = 40
    
    #considering maxlength as the diff between Ystart and wood_width -2
    
    
    yend = max(find_y_in_matrix(C,x) +2, wood_width +2);    
    plot(ax2,[x x], [ystart yend]);   

    h = text(x, 45, sprintf("(%0.2f, %0.2f)",x, ystart - yend));
    # get_nearest_y
    set(h,'Rotation',90);
end

    print(fig, sprintf("Catenary_a_w_%0.2f_%0.2f.jpg",a,w), '-dpng')
