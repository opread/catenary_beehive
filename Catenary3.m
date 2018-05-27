
% Prevent Octave from thinking that this
% is a function file:
1;
clear all;

############# Helper functions used in the program #####################

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
        



####### 1 calculate the rings of the hive body  ####################
# Dadant
# top frame: 470 / 435 X 27
# frame height: 37 to 27 X 300 X 6
# |----|
# |____|

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

###### 2 Calculate frames positioning +  positioning ############################
ax2 = subplot(2,1,2);
hold on;
plot(ax2, x,y);
axis([-35 45 0 hive_height]);
yend = 0;

frames_height=[];

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
    new_frame = [ystart - yend, cur_height];
    frames_height=[frames_height; new_frame];
end
print(fig, sprintf("Catenary_a_w_%0.2f_%0.2f.jpg",a,w), '-dpng');
hold off


#### 3 Calculate the frames shapes ###############

#selet the positiv values as the calculations are the same
frames_height=frames_height(frames_height(:,2)>=0,:);

# iterate through each distinct frame raduis (on top) and calculate the frame dimensions and area
frames_sections = [];
shrink_frame_width = 1.5;

for i = length(frames_height):-1:1
  
  % find the circle bow length for each ring
  cur_frame_radius = frames_height(i,2);
  cur_frame_height = frames_height(i,1);
  ring_index = length(rings); # ring from the top 
  top_ring = ring_index;

  
  while (ring_index>1) 
    cur_ring_radius = rings(ring_index,1);
    
    if cur_frame_radius == 0
      frame_section_tmp = cur_ring_radius - shrink_frame_width;
      
    elseif cur_ring_radius - cur_frame_radius <0.5
     # the frame exceeds the currrnt ring, we stop
      break
    else
      frame_section_tmp =2*  pitagora(a=0, b = cur_frame_radius, c = cur_ring_radius)-shrink_frame_width;
    end
    
    # add data into a vector for later use
    # structure: index of frame, cur_frame_height, cur_frame_radius, cur_ring_radius, frame_section
    frames_sections = [frames_sections, [i, frames_height(i,1), cur_frame_radius, cur_ring_radius, frame_section_tmp]];
    ring_index -=1; 
  end
end  

# reshape the vection in a matrix with 5 colmns and n rows
frames = transpose(reshape(frames_sections, 5 , length(frames_sections)/5));

#round values to one decimal to nearest (mm)
n=2;
frames = round(frames*10^n)/10^n;
#the hive height
hive_height = rings(length(rings),2);

# plot distinct frames after rounding the values to 2 decimals
unique_frames =  unique(frames(:,1));
for i =1:length(unique_frames)

  cur_frame = frames(frames(:,1)==i,:)
  cur_frame_height = cur_frame(1,2);
  cur_frame_maxwidth = cur_frame(1,5);
  
  # one plot for each frame, 
  
# distinct frame shapes
  fig = figure(i+1);
  axis([-35 35 0  cur_frame(1,2)]);
  title(sprintf("Frame no: %0.0f, w: %0.1f, h: %0.1f",i,cur_frame_maxwidth,cur_frame_height));
  hold on;
  
  # draw the current frame (wip)
  ## draw  vertical line from 0 to height
  line([0 0], [0 cur_frame_height]);

  # plot frame sections for each ring paralel to the hive side
  xtmp = [];
  ytmp = [];
  yadjfactor = hive_height - cur_frame_height;  % we want to plot from y=0 by subtracting yadjfactor
  
  # pass through each ring, skip the 1st one (as we place antivarroa bottom there)
  cur_ring=length(cur_frame);
  for tmp_y = 2*wood_width:wood_width:hive_height-yadjfactor
    tmp_x = cur_frame(cur_ring,5);
   
    ytmp = [ytmp tmp_y];
    xtmp = [xtmp tmp_x]; # we make the frame a little smaller, by "shrink" cm
    
    
    text( tmp_x,  tmp_y, sprintf("(%0.2f, %0.2f)",tmp_x, tmp_y));
    cur_ring-=1;
  end 
  #plot points after adjusting the size by shrink param
  plot(xtmp,ytmp);
  plot(-xtmp,ytmp);  
  

end
