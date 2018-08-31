module Types.SemanticOpTypes where

import Types.LazyBDD
import Types.NumericTower

opTypes :: [(String, OpSpec)]
opTypes =
  [ ("add1", (UnOp
              [ (zero, one)
              , (one, byte)
              , (byte, index)
              , (index, fixnum)
              , (integer, integer)
              , (rational, rational)
              , (float, float)
              , (singleFloat, singleFloat)
              , (floatComplex, floatComplex)
              , (singleFloatComplex, singleFloatComplex)
              , (nonpositiveFixnum, fixnum)
              , (negativeInteger, nonpositiveInteger)
              , (nonnegativeReal, positiveReal)
              , (number, number)]))
  , ("sub1", (UnOp
              [ (one, zero)
              , (positiveByte, byte)
              , (positiveIndex, index)
              , (nonnegativeFixnum, fixnum)
              , (positiveInteger, nonnegativeInteger)
              , (integer, integer)
              , (rational, rational)
              , (float, float)
              , (singleFloat, singleFloat)
              , (nonpositiveReal, negativeReal)
              , (floatComplex, floatComplex)
              , (singleFloatComplex, singleFloatComplex)
              , (number, number)]))
  , ("abs", (UnOp
             [ (realZero, realZero)
             , (integer, nonnegativeInteger)
             , (rational, nonnegativeRational)
             , (float, nonnegativeFloat)
             , (singleFloat, nonnegativeSingleFloat)
             , ((tyOr' mtEnv [positiveReal, negativeReal]), positiveReal)]))
    
  , ("+", (BinOp
            [ (byte, byte, index)
            , (index, index, nonnegativeFixnum)
            , (negativeFixnum, one, nonpositiveFixnum)
            , (one, negativeFixnum, nonpositiveFixnum)
            , (nonpositiveFixnum, nonnegativeFixnum, fixnum)
            , (nonnegativeFixnum, nonpositiveFixnum, fixnum)
            , (integer, integer, integer)
            , (float, real, float)
            , (real, float, float)
            , (singleFloat, (tyOr' mtEnv [rational, singleFloat]), singleFloat)
            , ((tyOr' mtEnv [rational, singleFloat]), singleFloat, singleFloat)
            , (positiveReal, nonnegativeReal, positiveReal)
            , (nonnegativeReal, positiveReal, positiveReal)
            , (negativeReal, nonpositiveReal, negativeReal)
            , (nonpositiveReal, negativeReal, negativeReal)
            , (nonnegativeReal, nonnegativeReal, nonnegativeReal)
            , (nonpositiveReal, nonpositiveReal, nonpositiveReal)
            , (real, real, real)
            , (exactNumber, exactNumber, exactNumber)
            , (floatComplex, number, floatComplex)
            , (number, floatComplex, floatComplex)
            , (float, inexactComplex, floatComplex)
            , (inexactComplex, float, floatComplex)
            , (singleFloatComplex, (tyOr' mtEnv [rational, singleFloat, singleFloatComplex]), singleFloatComplex)
            , ((tyOr' mtEnv [rational, singleFloat, singleFloatComplex]), singleFloatComplex, singleFloatComplex)
            , (number, number, number)])) 
    
  , ("-", (BinOp
            [ (zero, positiveReal, negativeReal) -- negation pattern
            , (zero, nonnegativeReal, nonpositiveReal) -- negation pattern
            , (zero, negativeReal, positiveReal) -- negation pattern
            , (zero, nonpositiveReal, nonnegativeReal) -- negation pattern
            , (one, one, zero)
            , (positiveByte, one, byte)
            , (positiveIndex, one, index)
            , (positiveInteger, one, nonnegativeInteger)
            , (nonnegativeFixnum, nonnegativeFixnum, fixnum)
            , (negativeFixnum, nonpositiveFixnum, fixnum)
            , (integer, integer, integer)
            , (positiveRational, nonpositiveRational, positiveRational)
            , (negativeRational, nonnegativeRational, negativeRational)
            , (float, real, float)
            , (real, float, float)
            , (singleFloat, (tyOr' mtEnv [singleFloat, rational]), singleFloat)
            , ((tyOr' mtEnv [singleFloat, rational]), singleFloat, singleFloat)
            , (real, real, real)
            , (exactNumber, exactNumber, exactNumber)
            , (floatComplex, number, floatComplex)
            , (number, floatComplex, floatComplex)
            , (singleFloatComplex, (tyOr' mtEnv [singleFloatComplex, exactNumber]), singleFloatComplex)
            , ((tyOr' mtEnv [singleFloatComplex, exactNumber]), singleFloatComplex, singleFloatComplex)
            , (number, number, number)]))

  , ("*", (BinOp
            [ (zero, number, zero)
            , (number, zero, zero)
            , (byte, byte, index)
            , (integer, integer, integer)
            , (tyAnd' mtEnv [rational, (tyNot mtEnv zero)], tyAnd' mtEnv [rational, (tyNot mtEnv zero)], tyAnd' mtEnv [rational, (tyNot mtEnv zero)])
            , (float, (tyOr' mtEnv [positiveReal, negativeReal]), float)
            , ((tyOr' mtEnv [positiveReal, negativeReal]), float, float)
            , (float, float, float)
            , (singleFloat, (tyOr' mtEnv [positiveRational, negativeRational, singleFloat]), singleFloat)
            , ((tyOr' mtEnv [positiveRational, negativeRational, singleFloat]), singleFloat, singleFloat)
            , (inexactReal, inexactReal, inexactReal)
            , (nonnegativeReal, nonnegativeReal, nonnegativeReal) -- (* +inf.0 0.0) -> +nan.0
            , (nonpositiveReal, nonpositiveReal, nonnegativeReal)
            , (nonpositiveReal, nonnegativeReal, nonpositiveReal)
            , (nonnegativeReal, nonpositiveReal, nonpositiveReal)
            , (floatComplex, (tyOr' mtEnv [inexactComplex, inexactReal, positiveRational, negativeRational]), floatComplex)
            , ((tyOr' mtEnv [inexactComplex, inexactReal, positiveRational, negativeRational]), floatComplex, floatComplex)
            , (singleFloatComplex, (tyOr' mtEnv [singleFloatComplex, singleFloat, positiveRational, negativeRational]), singleFloatComplex)
            , ((tyOr' mtEnv [singleFloatComplex, singleFloat, positiveRational, negativeRational]), singleFloatComplex, singleFloatComplex)
            , (inexactComplex, (tyOr' mtEnv [inexactComplex, inexactReal, positiveRational, negativeRational]), inexactComplex)
            , ((tyOr' mtEnv [inexactComplex, inexactReal, positiveRational, negativeRational]), inexactComplex, inexactComplex)
            , (number, number, number)]))

  , ("/", (BinOp
            [ (number, zero, emptyTy)
            , (zero, number, zero)
            , (one, one, one)
            , (tyAnd' mtEnv [rational, (tyNot mtEnv zero)], tyAnd' mtEnv [rational, (tyNot mtEnv zero)], tyAnd' mtEnv [rational, (tyNot mtEnv zero)])
            , ((tyOr' mtEnv [positiveReal, negativeReal, float]), float, float)
            , (float, real, float) -- if any argument after the first is exact 0, not a problem
            , (singleFloat, (tyOr' mtEnv [positiveRational, negativeRational, singleFloat]), singleFloat)
            , ((tyOr' mtEnv [positiveRational, negativeRational, singleFloat]), singleFloat, singleFloat)
            , (inexactReal, inexactReal, inexactReal)
            , (positiveReal, positiveReal, nonnegativeReal)
            , (negativeReal, negativeReal, nonnegativeReal) -- 0.0 is non-neg, but doesn't preserve sign
            , (negativeReal, positiveReal, nonpositiveReal) -- idem
            , (positiveReal, negativeReal, nonpositiveReal) -- idem
            , ((tyOr' mtEnv [inexactComplex, inexactReal, positiveRational, negativeRational]), floatComplex, floatComplex)
            , (floatComplex, number, floatComplex) -- if any argument after the first is exact 0, not a problem
            , (singleFloatComplex, (tyOr' mtEnv [singleFloatComplex, singleFloat, positiveRational, negativeRational]), singleFloatComplex)
            , ((tyOr' mtEnv [singleFloatComplex, singleFloat, positiveRational, negativeRational]), singleFloatComplex, singleFloatComplex)
            , (inexactComplex, (tyOr' mtEnv [inexactComplex, inexactReal, positiveRational, negativeRational]), inexactComplex)
            , ((tyOr' mtEnv [inexactComplex, inexactReal, positiveRational, negativeRational]), inexactComplex, inexactComplex)
            , (number, number, number)]))

  , ("max", (BinOp
              [ (one, one, one)
              , (one, zero, one)
              , (zero, one, one)
              , (positiveByte, byte, positiveByte)
              , (byte, positiveByte, positiveByte)
              , (index, index, index)
              , (fixnum, fixnum, fixnum)
              , (integer, integer, integer)
              , (rational, rational, rational)
              , (float, float, float)
              , (singleFloat, singleFloat, singleFloat)
              , (inexactRealPositiveZero, inexactRealPositiveZero, inexactRealPositiveZero)
              , (inexactRealNegativeZero, inexactRealNegativeZero, inexactRealNegativeZero)
              , (inexactReal, inexactReal, inexactReal)
              , (positiveReal, real, positiveReal)
              , (real, positiveReal, positiveReal)
              , (nonnegativeReal, real, nonnegativeReal)
              , (real, nonnegativeReal, nonnegativeReal)
              , (negativeReal, negativeReal, negativeReal)
              , (nonpositiveReal, nonpositiveReal, nonpositiveReal)]))

  , ("min", (BinOp
              [ (one, one, one)
              , (index, index, index)
              , (byte, nonnegativeInteger, byte)
              , (nonnegativeInteger, byte, byte)
              , (nonnegativeFixnum, nonnegativeInteger, nonnegativeFixnum)
              , (nonnegativeInteger, nonnegativeFixnum, nonnegativeFixnum)
              , (fixnum, fixnum, fixnum)
              , (integer, integer, integer)
              , (rational, rational, rational)
              , (float, float, float)
              , (singleFloat, singleFloat, singleFloat)
              , (inexactRealPositiveZero, inexactRealPositiveZero, inexactRealPositiveZero)
              , (inexactRealNegativeZero, inexactRealNegativeZero, inexactRealNegativeZero)
              , (inexactReal, inexactReal, inexactReal)
              , (positiveReal, positiveReal, positiveReal)
              , (nonnegativeReal, nonnegativeReal, nonnegativeReal)
              , (negativeReal, real, negativeReal)
              , (real, negativeReal, negativeReal)
              , (nonpositiveReal, real, nonpositiveReal)
              , (real, nonpositiveReal, nonpositiveReal)]))

    
  , ("<", (BinOp
           [ -- general cases --
             -- -- -- -- -- -- -- -- --
             (realNoNaN, realNoNaN, boolTy)
           , (someNaN, real, falseTy)
           , (real, someNaN, falseTy)
             -- positive/nonpositive cases --
           , (nonpositiveRealNoNaN, positiveRealNoNaN, trueTy)
           , (positiveReal, nonpositiveReal, falseTy)
             -- zero/negative cases --
           , (negativeRealNoNaN, realZeroNoNaN, trueTy)
           , (realZero, negativeReal, falseTy)
           -- bounded type cases --
           , (negativeInfinity, tyAnd' mtEnv [realNoNaN, (tyNot mtEnv negativeInfinity)], trueTy)
           , (real, negativeInfinity, falseTy)
           , (negativeIntegerNotFixnum, tyAnd' mtEnv [integer, (tyNot mtEnv negativeIntegerNotFixnum)], trueTy)
           , (tyAnd' mtEnv [integer, (tyNot mtEnv negativeIntegerNotFixnum)], negativeIntegerNotFixnum, falseTy)
           , (realZero, realZero, falseTy)
           , (one, one, falseTy)
           , (one, tyAnd' mtEnv [positiveInteger, (tyNot mtEnv one)], trueTy)
           , (tyAnd' mtEnv [positiveInteger, (tyNot mtEnv one)], one, falseTy)
           , (byte, positiveIntegerNotByte, trueTy)
           , (positiveIntegerNotByte, byte, falseTy)
           , (index, positiveIntegerNotIndex, trueTy)
           , (positiveIntegerNotIndex, index, falseTy)
           , (fixnum, positiveIntegerNotFixnum, trueTy)
           , (positiveIntegerNotFixnum, fixnum, falseTy)
           , (tyAnd' mtEnv [realNoNaN, (tyNot mtEnv positiveInfinity)], positiveInfinity, trueTy)
           , (positiveInfinity, real, falseTy)]))
    
  , ("<=", (BinOp
           [ -- general cases --
             -- -- -- -- -- -- -- -- --
             (realNoNaN, realNoNaN, boolTy)
           , (someNaN, real, falseTy)
           , (real, someNaN, falseTy)
             -- negative cases --
           , (negativeRealNoNaN, nonnegativeRealNoNaN, trueTy)
           , (nonnegativeRealNoNaN, negativeRealNoNaN, falseTy)
           -- zero cases
           , (realZeroNoNaN, realZeroNoNaN, trueTy)
             -- positive cases --
           , (nonpositiveRealNoNaN, positiveRealNoNaN, trueTy)
           , (positiveRealNoNaN, nonpositiveRealNoNaN, falseTy)
           -- bounded type cases --
           , (negativeInfinity, realNoNaN, trueTy)
           , (tyAnd' mtEnv [realNoNaN, (tyNot mtEnv negativeInfinity)], negativeInfinity, falseTy)
           , (negativeIntegerNotFixnum, tyAnd' mtEnv [integer, (tyNot mtEnv negativeIntegerNotFixnum)], trueTy)
           , (tyAnd' mtEnv [integer, (tyNot mtEnv negativeIntegerNotFixnum)], negativeIntegerNotFixnum, falseTy)
           , (one, positiveInteger, trueTy)
           , (tyAnd' mtEnv [positiveInteger, (tyNot mtEnv one)], one, falseTy)
           , (byte, positiveIntegerNotByte, trueTy)
           , (positiveIntegerNotByte, byte, falseTy)
           , (index, positiveIntegerNotIndex, trueTy)
           , (positiveIntegerNotIndex, index, falseTy)
           , (fixnum, positiveIntegerNotFixnum, trueTy)
           , (positiveIntegerNotFixnum, fixnum, falseTy)
           , (realNoNaN, positiveInfinity, trueTy)
           , (positiveInfinity, tyAnd' mtEnv [realNoNaN, (tyNot mtEnv positiveInfinity)], falseTy)]))

  , ("=", (BinOp
            [ (someNaN, number, falseTy)
            , (number, someNaN, falseTy)
            , (realZeroNoNaN, realZeroNoNaN, trueTy)
            , (tyAnd' mtEnv [number, (tyNot mtEnv realZeroNoNaN)], realZeroNoNaN, falseTy)
            , (realZeroNoNaN, tyAnd' mtEnv [number, (tyNot mtEnv realZeroNoNaN)], falseTy)
            , (tyAnd' mtEnv [exactNumber, (tyNot mtEnv one)], one, falseTy)
            , (one, tyAnd' mtEnv [exactNumber, (tyNot mtEnv one)], falseTy)
            , (tyAnd' mtEnv [exactNumber, (tyNot mtEnv byte)], byte, falseTy)
            , (byte, tyAnd' mtEnv [exactNumber, (tyNot mtEnv byte)], falseTy)
            , (tyAnd' mtEnv [exactNumber, (tyNot mtEnv index)], index, falseTy)
            , (index, tyAnd' mtEnv [exactNumber, (tyNot mtEnv index)], falseTy)
            , (tyAnd' mtEnv [exactNumber, (tyNot mtEnv fixnum)], fixnum, falseTy)
            , (fixnum, tyAnd' mtEnv [exactNumber, (tyNot mtEnv fixnum)], falseTy)
            , (tyAnd' mtEnv [exactNumber, (tyNot mtEnv integer)], integer, falseTy)
            , (integer, tyAnd' mtEnv [exactNumber, (tyNot mtEnv integer)], falseTy)
            , (tyAnd' mtEnv [exactNumber, (tyNot mtEnv rational)], rational, falseTy)
            , (rational, tyAnd' mtEnv [exactNumber, (tyNot mtEnv rational)], falseTy)
            , (nonpositiveReal, positiveReal, falseTy)
            , (positiveReal, nonpositiveReal, falseTy)
            , (nonnegativeReal, negativeReal, falseTy)
            , (negativeReal, nonnegativeReal, falseTy)
            , (number, number, boolTy)]))
  ]

