-- median.hs
-- Andrew S. Ng
-- Started: 2021-30-03
--
-- For CS 331 Spring 2021
-- Median program for Assignment 5 Exercise C

module Main where

import System.IO (stdout, hFlush)
import Data.List (sort)


-- ****** ACCEPTABLE INPUT *****************************
--
-- getList:
--   Input in getList will only accept a single integer,
--   or a completely empty line.
--
-- requestMedian:
--   Input in requestMedian will only accept the single 
--   character 'y' to repeat the program. Anything else
--   will end the program.
--
-- *****************************************************


-- getList
-- Inputs integers on each line, returning them in a list.
getList :: IO [Integer]
getList = do
    putStr "Enter number (blank line to end): "
    hFlush stdout
    line <- getLine
    if null line
        then return []
        else do
            rest <- getList
            return (read line:rest)


-- requestMedian
-- Calls main when input is 'y', otherwise prints goodbye.
requestMedian :: IO ()
requestMedian = do
    putStrLn ""
    putStr "Compute another median? [y/n] "
    hFlush stdout
    answer <- getLine
    if answer == "y"
        then main
        else putStrLn "Bye!"


-- main
-- Repeatedly input a list of integers, and print out the median.
main :: IO ()
main = do
    putStrLn ""
    putStrLn "Enter a list of integers, one on each line."
    putStrLn "I will compute the median of the list."
    putStrLn ""
    hFlush stdout
    list <- getList
    if null list
        then do
            putStrLn "Empty list - no median"
            requestMedian
        else do
            let index = div (length list) 2
            putStr "Median: "
            print (sort list !! index)
            requestMedian

