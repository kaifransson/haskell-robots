module Parsing
    ( parseDirectionString
    ) where

import           Control.Monad.State
import           Prelude             hiding (Left, Right)

import           Robots

parseDirectionString :: State String [Direction]
parseDirectionString = do
    s <- get
    if null s
        then return []
        else do
            let (c:cs) = s
            let mdir = case c of
                    '^' -> Just Up
                    'V' -> Just Down
                    '<' -> Just Left
                    '>' -> Just Right
                    _   -> Nothing
            case mdir of
                Nothing    -> return []
                (Just dir) -> do
                    put cs
                    next <- parseDirectionString
                    return $ dir:next
