function [X_Adjust] = SolveVolumeEquations()
syms a b c;

% These equations come from additive distance between the elements
eqn1 = a == b -0.59;
eqn2 = b == a -2.20;
eqn3 = a == c -4.82;
eqn4 = c == a +4.78;
eqn5 = b == c -6.08;
eqn6 = c == b +5.59;
eqn7 = a == 0;  % This one is set or it won't solve

[A,B] = equationsToMatrix([eqn1, eqn2, eqn3, eqn4, eqn5, eqn6, eqn7], [a, b, c]);
%Could have used multiplicative properties to generate second set of unique
%equations for each pair.  But, it won't work since baseline was set at 0.
%eqn4 = a == b*2/3;
%X = linsolve(A,B);

% Solution is exactly specified, but inconsistent.
% Have to do this (see Handout)
% https://en.wikipedia.org/wiki/Consistent_and_inconsistent_equations

X = inv((A.'*A))*A.'*B;

% X will return the volume that the sounds currently equal, or are perceived to be.  
% In order to get them equivalent, we need to find out how much to adjust
% them relative to the same referrent

ref = 5;  % All sounds will be adjusted so that perceived at this volume
X_Adjust = ref - X;

end