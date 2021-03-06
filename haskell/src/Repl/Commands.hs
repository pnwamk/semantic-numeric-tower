module Repl.Commands where

-- this module defines some simple data structures to
-- represent parsed commands from the user

import qualified Types.Syntax as Stx
import Types.LazyBDD
import Types.Subtype
import Types.Metafunctions
import Data.Map (Map)
import qualified Data.Map as Map

data Cmd =
  -- is t empty?
    Inhabited Ty
  -- is t1 a subtype of t2?
  | Subtype Ty Ty
  -- first projection of t
  | FstProj Ty
  -- second projection of t
  | SndProj Ty
  -- return type when applying t1 to t2
  | FunApp Ty Ty
  -- given a value of type t1 applied to a value of type t2,
  -- what must the argument have been if a value of t3 is
  -- produced?
  | FunInv Ty Ty Ty
  -- define a new type alias
  | Let String Ty
    -- define new type aliases which can be mutually recursive
  | LetRec (Map String Stx.Ty)
  -- exit the Repl
  | Quit
  -- get help
  | Help
  deriving (Eq, Show, Ord)

no = "#false"
yes = "#true"
answerBool True = yes
answerBool False = no

answerMaybeTy Nothing = no
answerMaybeTy (Just t) = readBackTy t

execCmd :: Env -> Cmd -> (Env, String)
execCmd env (Inhabited t) = (env, answerBool $ not $ isEmpty t)
execCmd env (Subtype t1 t2) = (env, answerBool $ subtype t1 t2)
execCmd env (FstProj t) = (env, answerMaybeTy $ fstProj t)
execCmd env (SndProj t) = (env, answerMaybeTy $ sndProj t)
execCmd env (FunApp t1 t2) = (env, answerMaybeTy $ rngTy t1 t2)
execCmd env (FunInv t1 t2 t3) = (env, answerMaybeTy $ inTy t1 t2 t3)
execCmd env (Let name t) = (extend name t env, "(environment extended with " ++ name ++ ")")
execCmd env (LetRec bindings) =  (env', "(environment extended with " ++ show (Map.keys bindings) ++ ")")
  where env' = Map.foldrWithKey recExtend env bindings
        recExtend name t e = extend name (parseTy env' t) e
