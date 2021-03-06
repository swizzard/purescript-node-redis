module Database.Redis.Commands.Program where

import Control.Monad.Writer (Writer, execWriter)
import Control.Monad.Writer.Class (tell)

import Data.Array (singleton)

import Database.Redis.Commands.Property (class Val, Key, Value, cast, value)

import Prelude ( class Applicative
               , class Apply
               , class Bind
               , class Functor
               , class Monad
               , Unit
               , pure
               , ($)
               , (<$>)
               , (<*>)
               , (<<<)
               , (>>=)
               )

data Rule = Property (Key Unit) (Array Value)

newtype QueryM a = S (Writer (Array Rule) a)

instance functorQueryM :: Functor QueryM where
  map f (S w) = S $ f <$> w

instance applyQueryM :: Apply QueryM where
  apply (S f) (S w) = S $ f <*> w

instance bindQueryM :: Bind QueryM where
  bind (S w) f = S $ w >>= (\(S w') -> w') <<< f

instance applicativeQueryM :: Applicative QueryM where
  pure = S <<< pure

instance monadQueryM :: Monad QueryM

runS :: forall a. QueryM a -> Array Rule
runS (S s) = execWriter s

rule :: Rule -> Query
rule = S <<< tell <<< singleton

type Query = QueryM Unit

key :: forall a. (Val a) => Key a -> a -> Query
key k v = rule $ Property (cast k) (value v)
