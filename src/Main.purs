module Main where

foreign import extractUrls :: String -> Array String

import Prelude
import Control.Bind
import Control.Monad.Eff
import Control.Monad.Eff.Console
import Data.Foreign (readString)
import Data.Identity
import Node.Buffer (toString)
import Node.Encoding (Encoding(UTF8))
import Node.ChildProcess
import Node.Stream

handle :: forall w e. Writable w e -> Array String -> Eff e Unit 
handle sin urls = do
  writeString sin UTF8 "abc" do
    end sin do
      log "done"

main = do
  irc <- spawn "irc" ["irc.oftc.net", "#utdluggy", "luggy"] defaultSpawnOptions
  onData (stdout irc) $ toString UTF8 >=> extractUrls >>> handle (stdin irc)
  onExit irc \exit ->
    case exit of
      _ -> log $ show exit
