
% Prevent Octave from thinking that this
% is a function file:
1;
clear all;

############# Helper functions used in the program #####################

  # function that calculate triangle sides with Pythagorean theorem
function [a, b, c] = pitagora(a=0 ,b=0, c=0)

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

  
## calculate catenary curve
function [x, y] = catenary(s,w,a) 
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
save_img  = false;


# dimensions
hive_height = 45;
hive_max_width = 45;  #+ wood 
wood_width = 2.4;

for a = 5.23
    for w =1.20
  
  [x, y] = catenary(s, w, a);;
    # draw the catenary curve
    fig = figure(1);
    title(sprintf("Params a,w: %0.2f,%0.2f",a,w));
    hold on;
    plot(x,y);
    axis([-35 45 0 hive_height]);
    C = [x; y]';
    #save myfile.mat C;

    rings = [,];
    for h = 0:wood_width:hive_height
      i = 3;
      while (i <= rows(C))
         if (C(i-1,2) < h && C(i,2) >= h)
           new_row = [C(i,1), C(i,2)];
           # add lines on the curve graph
            %% plot a line between two points using plot([x1,x2],[y1,y2])
            plot([-30,25],[h,h]);
            text(26, h-(wood_width/2), sprintf("R,h (%0.2f, %0.2f)",C(i,1),h));
            
            hold on;           
            rings = [rings; new_row];
         endif  
        i++;
      endwhile
        
    end
    
    #print picture
    config_txt = sprintf("Catenary_a_w_%0.2f_%0.2f.jpg",a,w)
    if save_img == true
        print(config_txt, '-dpng');
    end
    hold off;
    #close();

  end

end

###### 2 Calculate frames positioning +  positioning ############################
fig = figure(2);
hold on;
plot(x,y);
axis([-35 hive_height 0 hive_height+10]);
yend = 0;

frames_height=[];

# 3.8 cm distance between honeycombs

for cur_height = -19 :3.8:19  
    #find the y for the intersection between the frame and the hive side, 
    # add +2 to make room to the bees
    ystart = rings(length(rings),2);
    
    #considering maxlength as the diff between Ystart and wood_width -2
    yend = max(find_y_in_matrix(C,cur_height) +2, wood_width +2);    
    
    plot([cur_height cur_height], [ystart yend]);   
    h = text(cur_height, hive_height, sprintf("(%0.2f, %0.2f)",cur_height, ystart - yend));
    # get_nearest_y
    set(h,'Rotation',90);
    
    #append the new frame to frames matrix
    new_frame = [ystart - yend, cur_height];
    frames_height=[frames_height; new_frame];
end
    if save_img == true
        print(sprintf("Frames_position_in_hive_%0.2f_%0.2f.jpg",a,w), '-dpng');
    end
        
hold off;


#### 3 Calculate the frames shapes ###############

#selet the positiv values as the calculations are the same
frames_height=frames_height(frames_height(:,2)>=0,:);

# 3.1 iterate through each distinct frame raduis (on top) and calculate the frame dimensions and area

frames_sections = [];
frames_area = [];
shrink_frame_width = 1.5;
frame_wood_width  = 1;
  #     -1.8-
  # 0.5 ||||||||||  |
  #          ||||| 1.8
  #          |||||  |
woodtop_height  = 1.8;
woodtop_shoulder_width = 0.5;
woodtop_shoulder = 1.8;
woodtop_shoulder_cut = woodtop_shoulder - woodtop_shoulder_width ;


for i = length(frames_height):-1:1
  % find the circle bow length for each ring
  cur_frame_radius = frames_height(i,2);
  cur_frame_height = frames_height(i,1);
  ring_index = length(rings); # ring from the top 
  top_ring = ring_index;
  axis([-35 60 0 50]);; 
  
  while (ring_index>1) 
    cur_ring_radius = rings(ring_index,1);
    
    if cur_frame_radius == 0
      frame_section_tmp = cur_ring_radius - shrink_frame_width;
      
    elseif cur_ring_radius - cur_frame_radius <0.5
     # the frame exceeds the currrnt ring, we stop
      break
    else
      frame_section_tmp =  pitagora(a=0, b = cur_frame_radius, c = cur_ring_radius)-shrink_frame_width;
    end
    
    # add frames section data into a vector for later use
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

# identify unique frames by the position given by radius
unique_frames =  unique(frames(:,1));

# pass through each distinct frame shape
countfig=2;
for i = length(unique_frames):-1:1
  countfig+=1;
  cur_frame = frames(frames(:,1)==i,:);
  cur_frame_height = cur_frame(1,2);
  cur_frame_radius = cur_frame(1,3);
  fig = figure(countfig);
 
  hold on;
  
  # draw the current frame (wip)
  ## draw  vertical line from 0 to height


  # plot frame sections for each ring paralel to the hive side
  xtmp = [];
  ytmp = [];
  yadjfactor = hive_height - cur_frame_height;  % we want to plot from y=0 by subtracting yadjfactor
  
  # pass through each ring, skip the 1st one (as we place antivarroa bottom there)
  cur_ring=length(cur_frame);

  for tmp_y = 0:wood_width:hive_height-yadjfactor
    tmp_x = cur_frame(cur_ring,5);
   
    ytmp = [ytmp tmp_y];
    xtmp = [xtmp tmp_x]; # we make the frame a little smaller, by "shrink" cm
  
    # plot points 
    plot(tmp_x,tmp_y,'rx')  
    plot(tmp_x-frame_wood_width ,tmp_y,'rx') 
     
    # plot the current frame section
    line([-tmp_x tmp_x], [tmp_y tmp_y]); 
    
    # add point coordinates
    text( tmp_x + 1,  tmp_y, sprintf("(%0.2f, %0.2f)",tmp_x, tmp_y));
    cur_ring-=1;
  end 
  #plot points after adjusting the size by shrink param
  
  # draw the frame outer margins
  plot(xtmp,ytmp);
  plot(-xtmp,ytmp); 
  
  # draw the frame inner margins

  plot(xtmp-frame_wood_width,ytmp);
  plot(-xtmp+frame_wood_width,ytmp);    
  
  # frame height vertical line
  line([0 0], [0 cur_frame_height]);
  cur_frame_maxwidth = xtmp(1,5);

# dadant top bar dimensions
  text( 10,  tmp_y+3, sprintf("woodtop height: %0.2f" ,woodtop_height));
  text( 10,  tmp_y+4, sprintf("woodtop shoulder width: %0.2f" ,woodtop_shoulder_width));  
  text( 10,  tmp_y+5, sprintf("woodtop shoulder length: %0.2f" ,woodtop_shoulder));  
  text( 10,  tmp_y+6, sprintf("woodtop shoulder cut: %0.2f" ,woodtop_shoulder_cut));  

#shoulder on the right
  line([tmp_x tmp_x], [tmp_y tmp_y+woodtop_shoulder_cut]);
  line([tmp_x tmp_x+woodtop_shoulder], [tmp_y+woodtop_shoulder_cut tmp_y+woodtop_shoulder_cut]);   
  line([tmp_x+woodtop_shoulder tmp_x+woodtop_shoulder], 
    [tmp_y+woodtop_shoulder_cut tmp_y+woodtop_shoulder_cut+woodtop_shoulder_width]);  

#long woodtop
  line([tmp_x+woodtop_shoulder -tmp_x-woodtop_shoulder], 
    [tmp_y+woodtop_shoulder_cut+woodtop_shoulder_width tmp_y+woodtop_shoulder_cut+woodtop_shoulder_width]);  

#shoulder on the left 
  line([-tmp_x-woodtop_shoulder -tmp_x-woodtop_shoulder], 
    [tmp_y+woodtop_shoulder_cut+woodtop_shoulder_width tmp_y+woodtop_shoulder_cut]);
  line([-tmp_x-woodtop_shoulder -tmp_x], 
    [tmp_y+woodtop_shoulder_cut tmp_y+woodtop_shoulder_cut]);      
  line([-tmp_x -tmp_x], [tmp_y+woodtop_shoulder_cut tmp_y]);
  
  title(sprintf("Frame: %0.0f, w: %0.1f, h: %0.1f radius: %0.1f",i,xtmp(length(xtmp)),cur_frame_height,cur_frame_radius));
  hold off;
  # calculate area by approximation = summing trapezoid segments areas
  segm = length(ytmp);
  frame_area = 0;
  tmp_area = 0;
  for k = segm:-1:2
   segm_a = 2*(xtmp(k)-frame_wood_width);
   segm_b = 2*(xtmp(k-1)-frame_wood_width);
   segm_h = wood_width;
   tmp_area = ((segm_a + segm_b)* segm_h) / 2;
   frame_area = frame_area + tmp_area;
  end
  text(-tmp_x ,  tmp_y+3, sprintf("Frame area: %0.2f cm2" ,frame_area));  
  frames_area = [frames_area [i,cur_frame_height,cur_frame_radius,frame_area]];
  


  # save frames
   if save_img == true
      print(sprintf("Frame_%0.0f.jpg",countfig-2), '-dpng');
   end
end

### sum frames area
#each frame is used twice, except the center one
total_area=0;
frames_area = transpose(reshape(frames_area, 4 , length(frames_area)/4));
frames_area = round(frames_area*10^n)/10^n;
total_area =sum(frames_area(:,4)) + sum(frames_area(1:length(frames_area)-1,4)); 

disp(config_txt);
disp(sprintf("Total_area: %0.0f.",total_area));

figure(1);
text(5,5, sprintf("Total area: %0.0f.",total_area)); 
print(config_txt, '-dpng');
