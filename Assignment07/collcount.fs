\ collcount.fs
\ Andrew S. Ng
\ Started: 2021-04-19
\ 
\ For CS 331 Spring 2021
\ Collatz count word for
\ Assignment 7, Exercise 2


: collcount { n -- c }
  0
  begin
  n 1 > while
    n 2 mod 0 = if
      n 2 / to n
    else
      3 n * 1 + to n
    endif
    1 +
  repeat
;

