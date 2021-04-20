#lang scheme
; addpairs.scm
; Andrew S. Ng
; Started: 2021-04-19
; 
; For CS 331 Spring 2021
; Pair adding procedure for
; Assignment 7, Exercise 3


(define (addpairs . ns)
  (cond
    [(null? ns)        null]
    [(null? (cdr ns))  ns]
    [else              (cons 
                        (+ (car ns) (cadr ns))
                        (apply addpairs (cddr ns)))]
    )
  )

