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
    collatzCount k
        | k == 1        = 0
        | mod k 2 == 1  = 1 + collatzCount (3*k+1)
        | otherwise     = 1 + collatzCount (div k 2)

-- findList
findList :: Eq a => [a] -> [a] -> Maybe Int
findList l1 l2 
    | null indices  = Nothing
    | otherwise     = Just $ head indices where
        indices = [ x | x <- [0..len2-1], (sublist l2 x len1) == l1 ] where
            len1 = length l1
            len2 = length l2
            sublist l i size = take size $ drop i l


-- operator ##
(##) :: Eq a => [a] -> [a] -> Int
l1 ## l2 = length matches where
    matches = [ i | i <- [0..len-1], (l1 !! i) == (l2 !! i) ] where
        len = min (length l1) (length l2)


-- filterAB
filterAB :: (a -> Bool) -> [a] -> [b] -> [b]
filterAB _ _ [] = []
filterAB _ [] _ = []
filterAB p (a:as) (b:bs)
    | p a        = b:rest
    | otherwise  = rest where
        rest = filterAB p as bs


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

