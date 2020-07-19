##distances = [inf 5 10 19 14
##            10 inf 3 11 20
##            12 15 inf 13 3
##            19 20 6 inf 12
##            19 9 5 12 inf];
##lc = 5;
##primary_lc = lc;
##primary_distances = distances;           

#---------------------------------------------------

#AN INPUT OF DISTANCES

lc = input("How many localities do you have? ");
puts("\nEnter distances:\n");
for i = 1:lc
  inp = input(" ", "s");
  temp = cellfun("str2num", strsplit(inp, " "));
  for j = 1:lc
    distances(i, j) = temp(j);
  endfor
endfor
primary_lc = lc;
primary_distances = distances;

#---------------------------------------------------

#REDUCTION

min = inf;
H0 = 0;
min_vect = [];
for k = 1:2
  #transpose matrix
  if (k == 2)
    distances = distances';
  endif
  for i = 1:lc
    for j = 1:lc
      if (distances(i, j) < min)
        min = distances(i, j);
      endif
    endfor
    min_vect(end+1) = min;
    min = inf;   
  endfor

  for i = 1:lc
    for j = 1:lc
      distances(i, j) -= min_vect(i);
    endfor
  endfor
  for i = 1:lc
    H0 += min_vect(i);
  endfor
  min_vect = [];
endfor

distances = distances';

puts("\nReduced matrix:\n");
disp(distances);
printf("\nH0 = %d", H0);

#---------------------------------------------------

#ADD EXTRA NUMERATION OF ROWS AND COlS FOR MONITORING
#CHANGES INDEPENDENTLY FROM REDUCTION OF DIMENSIONS

for i = 1:lc
  row_nums(i) = i;
  col_nums(i) = i;
endfor

#---------------------------------------------------

#

route = [];
for permanent = 1:100
  printf("\n\n------------------------\n\nStep %d\n", permanent);
  
  #REDUCTION CONSTANTS

  min = inf;
  min_vect = [];
  zero_check = 0;
  for k = 1:2
    #transpose matrix
    if (k == 2)
      distances = distances';
    endif
    for i = 1:lc
      for j = 1:lc
        if (distances(i, j) == 0)
          zero_check++;
        endif
        if (zero_check > 1)
          min = 0;
          break;
        elseif (distances(i, j) != 0 && distances(i, j) < min)
          min = distances(i, j);
        endif
      endfor
      min_vect(k, i) = min;
      min = inf;
      zero_check = 0;
    endfor
  endfor

  distances = distances';
  
  #ZEROS CALCULATE

  max_zero = 0;
  temp = 0;
  for i = 1:lc
    for j = 1:lc
      if (distances(i, j) == 0)
        temp = min_vect(1, i) + min_vect(2, j);
      endif
      if (temp > max_zero)
        max_zero = temp;
        max_i = i;
        max_j = j;
      endif
    endfor
  endfor
  
  #SHOW MATRIX ¹1
  puts("\n1.\n");
  disp(distances);
  
  printf("\ndi =");
  disp(min_vect(1, :));
  printf("\ndj =");
  disp(min_vect(2, :));
  
  
  
  #infinite to node in next table at coords (i,j)
  distances(max_i, max_j) = inf;
  
  #SHOW MATRIX ¹2
  puts("\n2.\n");
  disp(distances);
  
  #infinite to node in next table at reverse coords (j,i)
  distances(max_j, max_i) = inf;
  
  #DELETE i ROW & j COLUMN & INDEXES FIX
  distances(max_i, :) = [];
  distances(:, max_j) = [];
  
  fcoord_node = row_nums(max_i);
  scoord_node = col_nums(max_j);
  row_nums(max_i) = [];
  col_nums(max_j) = [];
  lc--;
  
  #LAST REDUCTION
  sum_for_H2 = 0;
  min = inf;
  #min_vect = [];
  for k = 1:2
    #transpose matrix
    if (k == 2)
      distances = distances';
    endif
    for i = 1:lc
      for j = 1:lc
        if (distances(i, j) < min)
          min = distances(i, j);
        endif
      endfor
      #min_vect(k, i) = min;
      if (min > 0)
        for j = 1:lc
          distances(i, j) -= min;
          
        endfor
        sum_for_H2 += min;
      endif
      min = inf;
    endfor
  endfor
  distances = distances';
  
  #SHOW MATRIX ¹3
  puts("\n3.\n");
  disp(distances);
  
  #CHECK INCLUDE
  H1 = H0 + max_zero;
  H2 = H0 + sum_for_H2;
  
  printf("\nH(%d*; %d*) = %d + %d = %d", max_i, max_j, H0, max_zero, H1);
  
  if (H2 <= H1)
    printf("\nH(%d; %d) = %d + %d = %d <= %d\n", max_i, max_j, H0, sum_for_H2, H2, H1);
    H0 = H2;
    #ADD NODE TO ROUTE
    route(end+1, 1) = fcoord_node;
    route(end, 2) = scoord_node;
  endif
  
  
  
  #CHECK STOP
  
  check_stop = 0;
  for i = 1:lc
    for j = 1:lc
      if (distances(i, j) == 0 || distances(i, j) == inf)
        check_stop++;
      endif
    endfor
  endfor
  if (check_stop == lc*lc)
    break;
  endif
  check_stop = 0;
  
endfor

#---------------------------------------------------

#FINDING LAST TWO ROUTES

#last-1 route
for i = 1:lc
  if (isinf(distances(1, i)) == 0)
    route(end+1, 1) = row_nums(1);
    route(end, 2) = col_nums(i);
  endif
endfor
 
#last route

for i = 1:lc
  if (col_nums(i) == route(1, 1))
    route(end+1, 1) = row_nums(2);
    route(end, 2) = col_nums(i);
  endif
endfor

#SORTING ROUTES

sorted_routes = [];
sorted_routes(end+1, 1) = route(1, 1);
sorted_routes(end, 2) = route(1, 2);
route(1, :) = [];
check_fullsorted = 1;
while (check_fullsorted < primary_lc)
  for i = 1:primary_lc-check_fullsorted
    if (sorted_routes(end, 2) == route(i, 1))
      sorted_routes(end+1, 1) = route(i, 1);
      sorted_routes(end, 2) = route(i, 2);
      route(i, :) = [];
      check_fullsorted++;
      break;
    endif
  endfor
endwhile

#DISPLAY ROUTE 
puts("\nRoute: ");
for i = 1:primary_lc
  if (i == primary_lc)
    printf("(%d,%d)\n", sorted_routes(i,1), sorted_routes(i,2));
  else
    printf("(%d,%d)->", sorted_routes(i,1), sorted_routes(i,2));
  endif
endfor

F = 0;
for i = 1:primary_lc
  F += primary_distances(sorted_routes(i,1), sorted_routes(i,2));
endfor
printf("F = %d\n", F);
















