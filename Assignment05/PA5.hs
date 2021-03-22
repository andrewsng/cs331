-- PA5.hs  INCOMPLETE
-- Glenn G. Chappell
-- 2021-03-16
--
-- For CS F331 / CSCE A331 Spring 2021
-- Solutions to Assignment 5 Exercise B

module PA5 where


-- collatzCounts
collatzCounts :: [Integer]
collatzCounts = map collatzCount [1..] where
    collatzCount k = collatzIter k 0 where
        collatzIter k n
            | k == 1  = n
            | odd k   = collatzIter (3*k+1) (n+1)
            | even k  = collatzIter (div k 2) (n+1)

-- findList
findList :: Eq a => [a] -> [a] -> Maybe Int
findList _ _ = Just 42  -- DUMMY; REWRITE THIS!!!


-- operator ##
(##) :: Eq a => [a] -> [a] -> Int
_ ## _ = 42  -- DUMMY; REWRITE THIS!!!


-- filterAB
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB _ _ bs = bs  -- DUMMY; REWRITE THIS!!!


-- sumEvenOdd
sumEvenOdd :: Num a => [a] -> (a, a)
{-
  The assignment requires sumEvenOdd to be written using a fold.
  Something like this:

    sumEvenOdd xs = fold* ... xs where
        ...

  Above, "..." should be replaced by other code. The "fold*" must be
  one of the following: foldl, foldr, foldl1, foldr1.
-}
sumEvenOdd _ = (0, 0)  -- DUMMY; REWRITE THIS!!!

