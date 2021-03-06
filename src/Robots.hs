module Robots
    ( Direction(..)
    , makeSimulation
    , step
    , totalPresentsDelivered
    , runUntilTermination
    , currentRobotPositions
    , housesWithAtLeast
    ) where

import           Data.List (group, sort)
import           Prelude   hiding (Left, Right)

data Direction
    = Up
    | Down
    | Left
    | Right
    deriving (Show, Eq)

newtype Robot
    = MkRobot { getRobot :: (Integer, Integer) }
    deriving (Show, Eq)

newtype Delivery
    = MkDelivery { getLocation :: (Integer, Integer) }
    deriving (Show, Eq, Ord)

data SimState
    = SimState { getRobots     :: [Robot]
               , getDeliveries :: [Delivery]
               , getMoves      :: [Direction]
               } deriving (Show, Eq)

newtype Simulation
    = MkSim { getState :: SimState }
    deriving (Show, Eq)

makeSimulation :: Int -> [Direction] -> Simulation
makeSimulation robots moves = let robs = replicate robots (MkRobot (0, 0))
                               in MkSim $ SimState robs [] moves

step :: Simulation -> Simulation
step (MkSim state)
    | null $ getRobots state = MkSim state
    | null $ getMoves state = MkSim state
    | otherwise = let (m:ms) = getMoves state
                      (r:rs) = getRobots state
                      dels = getDeliveries state
                      r' = move r m
                      dels' = if r' `notElem` rs
                                then MkDelivery (getRobot r') : dels
                                else dels
                      newState = MkSim state { getMoves = ms
                                             , getDeliveries = dels'
                                             , getRobots = rs ++ [r'] }
                   in newState

totalPresentsDelivered :: Simulation -> Integer
totalPresentsDelivered = fromIntegral . length . getDeliveries . getState

runUntilTermination :: Simulation -> Simulation
runUntilTermination = until done step
    where done = null . getMoves . getState

currentRobotPositions :: Simulation -> [(Integer, Integer)]
currentRobotPositions = fmap getRobot . getRobots . getState

housesWithAtLeast :: Integer -> Simulation -> Integer
housesWithAtLeast n sim = let groups = group . sort . getDeliveries . getState $ sim
                              amounts = fmap (fromIntegral . length) groups
                              atLeastN = filter (>= n) amounts
                           in fromIntegral . length $ atLeastN

move :: Robot -> Direction -> Robot
move robot dir = let (x, y) = getRobot robot
                  in MkRobot $ case dir of
                                Up    -> (x, y+1)
                                Down  -> (x, y-1)
                                Left  -> (x-1, y)
                                Right -> (x+1, y)
