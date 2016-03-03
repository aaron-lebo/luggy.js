module Main where

foreign import data IRC :: !
foreign import data Client :: *
foreign import newClient :: forall e. String -> String -> {channels :: Array String} -> Eff (irc :: IRC | e) Client 
foreign import addListener :: forall e e2. Client -> String -> Fn3 String String String (Eff e Unit) -> Eff (irc :: IRC | e2) Unit
foreign import process :: forall e. Client -> String -> String -> String -> Eff (irc :: IRC | e) Unit

import Prelude
import Control.Bind
import Control.Monad.Eff
import Control.Monad.Eff.Console
import Data.Function

main = do
  c <- newClient "irc.oftc.net" "luggy" {channels: ["#utdlug"]}
  addListener c "message" (mkFn3 \from to message -> (process c from to message))
