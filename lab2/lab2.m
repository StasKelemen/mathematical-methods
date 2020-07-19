pkg load symbolic

#Налаштування графіку
figure;
grid on;
hold on;
d = title ('Графічний розв’язок');
set (d, "fontsize", 18);

#Вісь ординат і абсцис
x1 = linspace(-5, 15);
x2 = 0+0*x1;
k1=x1;
j1=x2;
plot(x1,x2, "linewidth", 2.5);
x2 = linspace(-20, 30);
x1 = 0+0*x2;
k2=x1;
j2=x2;
plot(x1,x2,";x2=0;", "linewidth", 2.5);
labels = [xlabel("x1"), ylabel("x2")];
set (labels, "fontsize", 16);

#Побудова області допусимих значень
x1 = linspace(-5, 15);
j3 = 14 - x1;
j4 = -3 + (3/5)*x1;
j5 = 7 - (5/3)*x1;
plot(
  x1, j3,";x1+x2=14;",
  x1, j4,";3x1-5x2=15;",
  x1, j5,";5x1+3x2=21;"
);

plot(
  [0,4.2],[7,0],";ОДЗ;", "color",  'k', "linewidth", 3,
  [4.2,5],[0,0], 'k', "linewidth", 3,
  [5,10.625],[0,3.375], 'k', "linewidth", 3,
  [10.625,0],[3.375,14], 'k', "linewidth", 3,
  [0,0],[14,7], 'k', "linewidth", 3
);

#Вектор нормалі
syms x1 x2;
f = 7*x1 + 1*x2;
a1 = cast(diff(f, x1), "double");
a2 = cast(diff(f, x2), "double");
plot(a1, a2,";Нормаль;", "marker", '>', "linewidth", 2, "color", 'g', "markerfacecolor", 'g');
plot([0,a1],[0,a2], "linewidth", 2, "color", 'g');

#Ліня рівню
x1 = linspace(-2, 2);
x2 = -6.99*x1;
plot(x1,x2,";Ліня рівню;", "color", [0.02 0.97 1]);
x2 = -6.99*x1 + 7;
plot(x1,x2, "linestyle", "--", "color", [0.51 0.75 0.66]);

#Мінімум функції
scatter (0, 7, "r", "filled");
t = text (0.2, 7.5, "A(0,7)");
set (t, "fontsize", 14);

#Значення функції цілі у точці
result = 7 * 0 + 1 * 7;
printf("Значення функції цілі в точці: %.1f\n", result);


#Легенда
h = legend();
legend (h, "location", "northeastoutside");
set (h, "fontsize", 18);








