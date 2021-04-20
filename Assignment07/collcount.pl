% collcount.pl
% Andrew S. Ng
% Started: 2021-04-19
%
% For CS 331 Spring 2021
% Collatz count predicate for
% Assignment 7, Exercise 4


% collcount/2
% collcount(+n, ?c)
collcount(1, 0).
collcount(N, C) :-    % N is even.
    N > 1,
    N mod 2 =:= 0,
    NN is N / 2,
    collcount(NN, CC),
    C is CC + 1.
collcount(N, C) :-    % N is odd.
    N > 1,
    N mod 2 =\= 0,
    NN is 3 * N + 1,
    collcount(NN, CC),
    C is CC + 1.

