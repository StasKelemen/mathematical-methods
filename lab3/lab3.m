pkg load symbolic



#AUTOMATE loss function & size of matrixe
##cols = 6;
##rows = 3;
##syms M positive integer;
##F = sym([-2 1 0 0 0 M]);
##F = sym([-2 -1 0 0 0]);

#INPUT LOSS FUNCTION & SIZE OF MATRIXES
cols = input("How many variables do you have? ");
rows = input("How many restrictions do you have? ");
syms M positive integer;
inp = input("\nEnter coefficient of your loss function: ", "s");
F = cellfun('sym', strsplit(inp, " "));

#---------------------------------------------------

#AUTOMATE restrictions
##restrictions = sym([ 2 1 1 0 0 0 8
##                 1 3 0 -1 0 1 6
##                 -2 2 0 -1 1 0 3 ]);
##restrictions = sym([ -1 1 1 0 0 2
##                 3 0 -2 1 0 3
##                 1 0 3 0 1 12 ]);


#INPUT RESTRICTIONS 
restrictions = {};        
for i = 1:rows
  printf("\nEnter %d restriction:\n", i);
  inp = input(" ", "s");
  temp = cellfun("str2double", strsplit(inp, " "));
  for j = 1:cols+1
    restrictions(i, j) = temp(j);
  endfor
endfor

#---------------------------------------------------

#SPECIAL FORM
ans = yes_or_no("Did you enter initial form?");
if (ans == 1)
  printf("Enter %i signs '<=' or '>=' which respond your restrictions: ", rows);
  restr_string = input("", "s");
  restr = strsplit(restr_string, " ");
  check_zero = 0;
  last_vars = {};
  for i = 1:rows
    last_vars(end+1) = restrictions(i, end);
  endfor
  restrictions(:, end) = [];
  disp(restrictions);
  check_zero = 0;
  for i = 1:rows
    if (strcmp(restr(i), '<=') == 1)
      if (check_zero != 0)
        restrictions(i, end+1) = 0;
      endif
      restrictions(i, end+1) = 1;
      check_zero++;
    endif  
  endfor
  disp(restrictions);
  disp(check_zero);
  morethan_arr = [];
  for i = 1:rows
    if (strcmp(restr(i), '>=') == 1)
      morethan_arr(end + 1) = i;
      if (check_zero != 0)
        restrictions(i, end+1) = 0;
      endif
      restrictions(i, end+1) = -1;
      check_zero++;
    endif
  endfor
  disp(restrictions);
  for i = 1:rows
    restrictions(i, end+1) = last_vars(i);
  endfor
  disp(restrictions);
  restrictions = cell2mat(restrictions);
  restrictions = sym(restrictions);
  for i = 1:length(morethan_arr)
    max = 0;
    if (restrictions(morethan_arr(i), cols+1) > max)
      max = restrictions(morethan_arr(i), cols+1);
      max_index = morethan_arr(i);
      in_max_index = i;
    endif
  endfor  
  if (in_max_index == length(morethan_arr))
    subtrahend_index = length(morethan_arr)-1;
  elseif (in_max_index < length(morethan_arr))
    subtrahend_index = in_max_index+1;
  endif
  for i = 1:length(morethan_arr)
    for j = 1:cols+1
      temp = restrictions(max_index, j) - restrictions(morethan_arr(subtrahend_index), j);
      restrictions(morethan_arr(subtrahend_index),j) = temp;
    endfor
  endfor
  restrictions(morethan_arr(subtrahend_index), end+1) = 1;
  for i = 1:check_zero
    if (i == check_zero)
      F(end+1) = M;
    else
      F(end+1) = 0;
    endif
  endfor
endif

disp(F);
disp(restrictions);

#---------------------------------------------------

#FIND OF BASIS
check_same = cell(rows, cols);
check_same(:) = 0;
basis = sym([]);
for i = 1:rows
  for j = 1:cols
    if (restrictions(i, j) != 0)
      check_same(i,j) = 1;
    endif
  endfor
endfor
for i = 1:rows
  for j = 1:cols
    flag = 0;
    if (restrictions(i, j) == 1)
      for checker = 1:rows
        if (checker != i)
          if (check_same{checker,j} == 0)
            flag += 1;
          endif
        endif
      endfor
      if (flag == rows-1)
        basis(end + 1) = j;
      endif
    endif    
  endfor
endfor

printf("\nBasis variables are:");
disp(basis);

#---------------------------------------------------

#FIND MARKS & FUNCTION VALUE AT THE CORNER POINT
matrix_marks = zeros(1,cols);
marks = sym(matrix_marks);
for i = 1:cols
  for j = 1:rows
    marks(i) += F(basis(j))*restrictions(j,i);
  endfor
  marks(i) -= F(i);
endfor

printf("Marks are:");
marks = sym(marks);
disp(marks);

standart_point = zeros(1,cols);
point = sym(standart_point);
for i = 1:cols
  basis_flag = 0;
  for j = 1:rows 
    if (i == basis(j))
      basis_flag = 1;
      point(i) = restrictions(j,cols+1);
    endif
  endfor
  if (basis_flag == 0)
    point(i) = 0;    
  endif
endfor

standart_corner = 0;
corner = sym(standart_corner);
for i = 1:cols
  corner += F(i)*point(i);
endfor

printf("Corner point: ");
disp(corner);

#---------------------------------------------------

#{
ANALYSE:
1)CHECK MARKS
2) CHECK COLS WITH POS MARK AND ALL NEG ELEMENTS
3) RETURNS BASIS VARS WHICH SHOULD BE INCLUDED OR EXCLUDED
#}

function retval = analyse(F, marks, rows, cols, restrictions, basis)
  retval = 0;
  syms M positive integer;
  pos_marks = sym([]);
  neg_marks = 0;
  count_pos_marks = 0;
  syms M;
  for i = 1:cols
    c = sym2poly(marks(i), M);
    if (c(1) <= 0)
      neg_marks += 1;
    else
      pos_marks(end+1,1) = marks(i);
      pos_marks(end,2) = i;
      count_pos_marks++;
    endif
    if (neg_marks == cols)
      retval = 1;
      return;
    endif 
  endfor
  
  for i = 1:count_pos_marks
    check_allnotpos = 0;
    for j = 1:rows
      if (restrictions(j, pos_marks(i, 2)) <= 0)
        check_allnotpos++;
      endif
    endfor
    if (check_allnotpos == rows)  
      puts("Unlimited function below");
      retval = 1;
      return;
    endif
  endfor
  
  #Check if there is 'M' in loss function
  check_M = 0;
  for i = 1:cols
    if (strcmp(strvcat(F(i)),'M') == 1)
      check_M = 1;
      break
    endif
  endfor
  if (check_M == 1)
    str_pos_marks = sym([]);
    for i = 1:count_pos_marks
      temp_str = strvcat(pos_marks(i,1));
      temp_str2 = strrep(temp_str,'M','999999');
      str_pos_marks(i) = sym(temp_str2);
    endfor
  else
    str_pos_marks = sym([]);
    for i = 1:count_pos_marks
      str_pos_marks(i) = pos_marks(i,1);
    endfor  
  endif
  
  max = 0;
  for i = 1:count_pos_marks
    if (str_pos_marks(i) > max)
      max = str_pos_marks(i);
      index_include_var = pos_marks(i, 2);
    endif
  endfor
  
  min = inf;
  for i = 1:length(basis)
    if (restrictions(i,index_include_var) <= 0)
      continue
    endif
    temp = restrictions(i,cols+1)/restrictions(i,index_include_var);
    if (temp < min)
      min = temp;
      index_exclude_var = basis(i);
    endif
  endfor
  
  retval = sym([index_include_var, index_exclude_var]);
  
  return;
endfunction

#---------------------------------------------------

#CONSTRUCT SIMPLEX TABLES
  marks(end + 1) = sym(corner);
  simplex_table = sym([restrictions; marks]);
  result = sym([]);
  table_counter = 0;
while(1)
  result = analyse(F, marks, rows, cols, restrictions, basis);
  if (result == 1)
    break;
  else
    puts("\nVars [include, exclude]: ");
    disp(result);
  endif
  solve_col = result(1);
  for i = 1:length(basis)
    if (basis(i) == result(2))
      solve_row = i;
    endif
  endfor
  
  printf("\nSolve row: %i", solve_row);
  printf("\nSolve column: %s\n", strvcat(solve_col));
  
  if (table_counter == 0)
    printf("\nIntial table:\n\n");
    disp(simplex_table);
  endif
  
  div = simplex_table(solve_row, solve_col);
  for i = 1:cols+1
    simplex_table(solve_row, i) /=  div;
  endfor
  coeff = sym([]);
  for i = 1:rows+1
    coeff(i) = simplex_table(i, solve_col);
  endfor
  for i = 1:rows+1
    if (i == solve_row)
      continue
    endif
    for j = 1:cols+1     
        simplex_table(i,j) -=  simplex_table(solve_row,j)*coeff(i);      
    endfor  
  endfor
  
  printf('\nSimplex table %d:\n\n', ++table_counter);
  disp(simplex_table);
  
  for i = 1:cols+1
    marks(i) = simplex_table(rows+1, i);
  endfor
  for i = 1:rows
    for j = 1:cols+1
      restrictions(i,j) = simplex_table(i,j);
    endfor
  endfor
  
  #New basis
  for i = 1:length(basis)
    if (basis(i) == result(2))
      basis(i) = result(1);
    endif
  endfor
  
endwhile

#---------------------------------------------------

#SOLUTION POINT AND FUNCTION VALUE IN THIS POINT
# + CHECK FOR NON-ZERO ARTIFICIAL VARS
standart_final_point = zeros(1,cols);
final_point = sym(standart_final_point);
for i = 1:length(basis)
  for j = 1:cols
    if (basis(i) == j)
      final_point(j) = simplex_table(i,cols+1);
    endif
  endfor
endfor

artificial_array = sym([]);
for i = 1:cols
  if(strcmp(strvcat(F(i)),'M') == 1)
     artificial_array(end+1) = i;
  endif
endfor
  
death_flag = 0;
artificial_var_notzero = sym([]);
for j = 1:length(artificial_array)
  if (final_point(artificial_array(j)) != 0)
    death_flag++;
    artificial_var_notzero(end+1, 1) = final_point(artificial_array(j));
    artificial_var_notzero(end, 2) = artificial_array(j);
  endif
endfor


puts("\nPoint of solution:\n");
disp(final_point);
if (death_flag == 0)
  printf("Task is done!\nFunction value at the point: %s\n", strvcat(simplex_table(rows+1,cols+1)));
elseif (death_flag > 0)
  puts("\nTask have no solutions:\n");
  for i = 1:death_flag
    printf("Artificial var x%s = %s != 0\n", strvcat(artificial_var_notzero(i,2)), strvcat(artificial_var_notzero(i,1)));
  endfor
endif