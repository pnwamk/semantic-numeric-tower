module Types.SyntacticOpTypesPlus where

import Types.Syntax

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
              , (real, real)
              , (inexactReal, inexactReal)
              , (inexactComplex, inexactComplex)
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
              , (inexactReal, inexactReal)
              , (nonpositiveReal, negativeReal)
              , (real, real)
              , (floatComplex, floatComplex)
              , (singleFloatComplex, singleFloatComplex)
              , (inexactComplex, inexactComplex)
              , (number, number)]))
  , ("abs", (UnOp
             [ (realZero, realZero)
             , (integer, nonnegativeInteger)
             , (rational, nonnegativeRational)
             , (float, nonnegativeFloat)
             , (singleFloat, nonnegativeSingleFloat)
             , (inexactReal, nonnegativeInexactReal)
             , ((Or [positiveReal, negativeReal]), positiveReal)
             , (real, nonnegativeReal)]))
    
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
            , (singleFloat, (Or [rational, singleFloat]), singleFloat)
            , ((Or [rational, singleFloat]), singleFloat, singleFloat)
            , (inexactReal, real, inexactReal)
            , (real, inexactReal, inexactReal)
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
            , (singleFloatComplex, (Or [rational, singleFloat, singleFloatComplex]), singleFloatComplex)
            , ((Or [rational, singleFloat, singleFloatComplex]), singleFloatComplex, singleFloatComplex)
            , (inexactComplex, (Or [rational, inexactReal, inexactComplex]), inexactComplex)
            , ((Or [rational, inexactReal, inexactComplex]), inexactComplex, inexactComplex)
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
            , (nonnegativeRational, nonpositiveRational, nonnegativeRational)
            , (negativeRational, nonnegativeRational, negativeRational)
            , (nonpositiveRational, nonnegativeRational, nonpositiveRational)
            , (float, real, float)
            , (real, float, float)
            , (singleFloat, (Or [singleFloat, rational]), singleFloat)
            , ((Or [singleFloat, rational]), singleFloat, singleFloat)
            , (inexactReal, (Or [inexactReal, rational]), inexactReal)
            , ((Or [inexactReal, rational]), inexactReal, inexactReal)
            , (real, real, real)
            , (exactNumber, exactNumber, exactNumber)
            , (floatComplex, number, floatComplex)
            , (number, floatComplex, floatComplex)
            , (singleFloatComplex, (Or [singleFloatComplex, exactNumber]), singleFloatComplex)
            , ((Or [singleFloatComplex, exactNumber]), singleFloatComplex, singleFloatComplex)
            , (inexactComplex, (Or [inexactComplex, exactNumber]), inexactComplex)
            , ((Or [inexactComplex, exactNumber]), inexactComplex, inexactComplex)
            , (number, number, number)]))

  , ("*", (BinOp
            [ (zero, number, zero)
            , (number, zero, zero)
            , (byte, byte, index)
            , (integer, integer, integer)
            , (positiveRational, positiveRational, positiveRational)
            , (negativeRational, negativeRational, positiveRational)
            , (negativeRational, positiveRational, negativeRational)
            , (positiveRational, negativeRational, negativeRational)
            , (rational, rational, rational)
            , (float, (Or [positiveReal, negativeReal]), float)
            , ((Or [positiveReal, negativeReal]), float, float)
            , (float, float, float)
            , (singleFloat, (Or [positiveRational, negativeRational, singleFloat]), singleFloat)
            , ((Or [positiveRational, negativeRational, singleFloat]), singleFloat, singleFloat)
            , (inexactReal, (Or [positiveRational, negativeRational, inexactReal]), inexactReal)
            , ((Or [positiveRational, negativeRational, inexactReal]), inexactReal, inexactReal)
            , (nonnegativeReal, nonnegativeReal, nonnegativeReal) -- (* +inf.0 0.0) -> +nan.0
            , (nonpositiveReal, nonpositiveReal, nonnegativeReal)
            , (nonpositiveReal, nonnegativeReal, nonpositiveReal)
            , (nonnegativeReal, nonpositiveReal, nonpositiveReal)
            , (real, real, real)
            , (floatComplex, (Or [inexactComplex, inexactReal, positiveRational, negativeRational]), floatComplex)
            , ((Or [inexactComplex, inexactReal, positiveRational, negativeRational]), floatComplex, floatComplex)
            , (singleFloatComplex, (Or [singleFloatComplex, singleFloat, positiveRational, negativeRational]), singleFloatComplex)
            , ((Or [singleFloatComplex, singleFloat, positiveRational, negativeRational]), singleFloatComplex, singleFloatComplex)
            , (inexactComplex, (Or [inexactComplex, inexactReal, positiveRational, negativeRational]), inexactComplex)
            , ((Or [inexactComplex, inexactReal, positiveRational, negativeRational]), inexactComplex, inexactComplex)
            , (number, number, number)]))

  , ("/", (BinOp
            [ (zero, number, zero)
            , (one, one, one)
            , (positiveRational, positiveRational, positiveRational)
            , (nonnegativeRational, nonnegativeRational, nonnegativeRational)
            , (negativeRational, negativeRational, positiveRational)
            , (negativeRational, positiveRational, negativeRational)
            , (positiveRational, negativeRational, negativeRational)
            , (nonpositiveRational, nonpositiveRational, nonnegativeRational)
            , (nonpositiveRational, nonnegativeRational, nonpositiveRational)
            , (nonnegativeRational, nonpositiveRational, nonpositiveRational)
            , (rational, rational, rational)
            , ((Or [positiveReal, negativeReal, float]), float, float)
            , (float, real, float) -- if any argument after the first is exact 0, not a problem
            , (singleFloat, (Or [positiveRational, negativeRational, singleFloat]), singleFloat)
            , ((Or [positiveRational, negativeRational, singleFloat]), singleFloat, singleFloat)
            , (inexactReal, (Or [positiveRational, negativeRational, inexactReal]), inexactReal)
            , ((Or [positiveRational, negativeRational, inexactReal]), inexactReal, inexactReal)
            , (positiveReal, positiveReal, nonnegativeReal)
            , (negativeReal, negativeReal, nonnegativeReal) -- 0.0 is non-neg, but doesn't preserve sign
            , (negativeReal, positiveReal, nonpositiveReal) -- idem
            , (positiveReal, negativeReal, nonpositiveReal) -- idem
            , (real, real, real)
            , ((Or [inexactComplex, inexactReal, positiveRational, negativeRational]), floatComplex, floatComplex)
            , (floatComplex, number, floatComplex) -- if any argument after the first is exact 0, not a problem
            , (singleFloatComplex, (Or [singleFloatComplex, singleFloat, positiveRational, negativeRational]), singleFloatComplex)
            , ((Or [singleFloatComplex, singleFloat, positiveRational, negativeRational]), singleFloatComplex, singleFloatComplex)
            , (inexactComplex, (Or [inexactComplex, inexactReal, positiveRational, negativeRational]), inexactComplex)
            , ((Or [inexactComplex, inexactReal, positiveRational, negativeRational]), inexactComplex, inexactComplex)
            , (number, number, number)]))

  , ("max", (BinOp
              [ (zero, zero, zero)
              , (one, one, one)
              , (one, zero, one)
              , (zero, one, one)
              , (positiveByte, byte, positiveByte)
              , (byte, positiveByte, positiveByte)
              , (positiveIndex, index, positiveIndex)
              , (index, positiveIndex, positiveIndex)
              , (positiveFixnum, fixnum, positiveFixnum)
              , (fixnum, positiveFixnum, positiveFixnum)
              , (nonnegativeFixnum, fixnum, nonnegativeFixnum)
              , (fixnum, nonnegativeFixnum, nonnegativeFixnum)
              , (index, index, index)
              , (negativeFixnum, negativeFixnum, negativeFixnum)
              , (nonpositiveFixnum, nonpositiveFixnum, nonpositiveFixnum)
              , (positiveFixnum, positiveFixnum, positiveFixnum)
              , (nonnegativeFixnum, nonnegativeFixnum, nonnegativeFixnum)
              , (fixnum, fixnum, fixnum)
              , (positiveInteger, integer, positiveInteger)
              , (integer, positiveInteger, positiveInteger)
              , (nonnegativeInteger, integer, nonnegativeInteger)
              , (integer, nonnegativeInteger, nonnegativeInteger)
              , (negativeInteger, negativeInteger, negativeInteger)
              , (nonpositiveInteger, nonpositiveInteger, nonpositiveInteger)
              , (positiveInteger, positiveInteger, positiveInteger)
              , (nonnegativeInteger, nonnegativeInteger, nonnegativeInteger)
              , (integer, integer, integer)
              , (positiveRational, rational, positiveRational)
              , (rational, positiveRational, positiveRational)
              , (nonnegativeRational, rational, nonnegativeRational)
              , (rational, nonnegativeRational, nonnegativeRational)
              , (negativeRational, negativeRational, negativeRational)
              , (nonpositiveRational, nonpositiveRational, nonpositiveRational)
              , (positiveRational, positiveRational, positiveRational)
              , (nonnegativeRational, nonnegativeRational, nonnegativeRational)
              , (rational, rational, rational)
              , (floatPositiveZero, floatPositiveZero, floatPositiveZero)
              , (floatNegativeZero, floatNegativeZero, floatNegativeZero)
              , (floatZero, floatZero, floatZero)
              , (positiveFloat, float, positiveFloat)
              , (float, positiveFloat, positiveFloat)
              , (nonnegativeFloat, float, nonnegativeFloat)
              , (float, nonnegativeFloat, nonnegativeFloat)
              , (negativeFloat, negativeFloat, negativeFloat)
              , (nonpositiveFloat, nonpositiveFloat, nonpositiveFloat)
              , (positiveFloat, positiveFloat, positiveFloat)
              , (nonnegativeFloat, nonnegativeFloat, nonnegativeFloat)
              , (float, float, float)
              , (singleFloatPositiveZero, singleFloatPositiveZero, singleFloatPositiveZero)
              , (singleFloatNegativeZero, singleFloatNegativeZero, singleFloatNegativeZero)
              , (singleFloatZero, singleFloatZero, singleFloatZero)
              , (positiveSingleFloat, positiveSingleFloat, positiveSingleFloat)
              , (positiveSingleFloat, singleFloat, positiveSingleFloat)
              , (singleFloat, positiveSingleFloat, positiveSingleFloat)
              , (nonnegativeSingleFloat, nonnegativeSingleFloat, nonnegativeSingleFloat)
              , (nonnegativeSingleFloat, singleFloat, nonnegativeSingleFloat)
              , (singleFloat, nonnegativeSingleFloat, nonnegativeSingleFloat)
              , (negativeSingleFloat, negativeSingleFloat, negativeSingleFloat)
              , (nonpositiveSingleFloat, nonpositiveSingleFloat, nonpositiveSingleFloat)
              , (singleFloat, singleFloat, singleFloat)
              , (inexactRealPositiveZero, inexactRealPositiveZero, inexactRealPositiveZero)
              , (inexactRealNegativeZero, inexactRealNegativeZero, inexactRealNegativeZero)
              , (inexactRealZero, inexactRealZero, inexactRealZero)
              , (positiveInexactReal, inexactReal, positiveInexactReal)
              , (inexactReal, positiveInexactReal, positiveInexactReal)
              , (nonnegativeInexactReal, inexactReal, nonnegativeInexactReal)
              , (inexactReal, nonnegativeInexactReal, nonnegativeInexactReal)
              , (negativeInexactReal, negativeInexactReal, negativeInexactReal)
              , (nonpositiveInexactReal, nonpositiveInexactReal, nonpositiveInexactReal)
              , (positiveInexactReal, positiveInexactReal, positiveInexactReal)
              , (nonnegativeInexactReal, nonnegativeInexactReal, nonnegativeInexactReal)
              , (inexactReal, inexactReal, inexactReal)
              , (realZero, realZero, realZero)
              , (positiveReal, real, positiveReal)
              , (real, positiveReal, positiveReal)
              , (nonnegativeReal, real, nonnegativeReal)
              , (real, nonnegativeReal, nonnegativeReal)
              , (negativeReal, negativeReal, negativeReal)
              , (nonpositiveReal, nonpositiveReal, nonpositiveReal)
              , (positiveReal, positiveReal, positiveReal)
              , (nonnegativeReal, nonnegativeReal, nonnegativeReal)
              , (real, real, real)]))

  , ("min", (BinOp
              [ (zero, zero, zero)
              , (one, one, one)
              , (zero, one, zero)
              , (one, zero, zero)
              , (positiveByte, positiveByte, positiveByte)
              , (byte, byte, byte)
              , (positiveIndex, positiveIndex, positiveIndex)
              , (index, index, index)
              , (positiveFixnum, positiveFixnum, positiveFixnum)
              , (nonnegativeFixnum, nonnegativeFixnum, nonnegativeFixnum)
              , (negativeFixnum, fixnum, negativeFixnum)
              , (fixnum, negativeFixnum, negativeFixnum)
              , (nonpositiveFixnum, fixnum, nonpositiveFixnum)
              , (fixnum, nonpositiveFixnum, nonpositiveFixnum)
              , (positiveByte, positiveInteger, positiveByte)
              , (positiveInteger, positiveByte, positiveByte)
              , (byte, nonnegativeInteger, byte)
              , (nonnegativeInteger, byte, byte)
              , (positiveFixnum, positiveInteger, positiveFixnum)
              , (positiveInteger, positiveFixnum, positiveFixnum)
              , (nonnegativeFixnum, nonnegativeInteger, nonnegativeFixnum)
              , (nonnegativeInteger, nonnegativeFixnum, nonnegativeFixnum)
              , (negativeFixnum, negativeFixnum, negativeFixnum)
              , (nonpositiveFixnum, nonpositiveFixnum, nonpositiveFixnum)
              , (fixnum, fixnum, fixnum)
              , (positiveInteger, positiveInteger, positiveInteger)
              , (nonnegativeInteger, nonnegativeInteger, nonnegativeInteger)
              , (negativeInteger, integer, negativeInteger)
              , (integer, negativeInteger, negativeInteger)
              , (nonpositiveInteger, integer, nonpositiveInteger)
              , (integer, nonpositiveInteger, nonpositiveInteger)
              , (negativeInteger, negativeInteger, negativeInteger)
              , (nonpositiveInteger, nonpositiveInteger, nonpositiveInteger)
              , (integer, integer, integer)
              , (positiveRational, positiveRational, positiveRational)
              , (nonnegativeRational, nonnegativeRational, nonnegativeRational)
              , (negativeRational, rational, negativeRational)
              , (rational, negativeRational, negativeRational)
              , (nonpositiveRational, rational, nonpositiveRational)
              , (rational, nonpositiveRational, nonpositiveRational)
              , (negativeRational, negativeRational, negativeRational)
              , (nonpositiveRational, nonpositiveRational, nonpositiveRational)
              , (rational, rational, rational)
              , (floatPositiveZero, floatPositiveZero, floatPositiveZero)
              , (floatNegativeZero, floatNegativeZero, floatNegativeZero)
              , (floatZero, floatZero, floatZero)
              , (positiveFloat, positiveFloat, positiveFloat)
              , (nonnegativeFloat, nonnegativeFloat, nonnegativeFloat)
              , (negativeFloat, float, negativeFloat)
              , (float, negativeFloat, negativeFloat)
              , (nonpositiveFloat, float, nonpositiveFloat)
              , (float, nonpositiveFloat, nonpositiveFloat)
              , (negativeFloat, negativeFloat, negativeFloat)
              , (nonpositiveFloat, nonpositiveFloat, nonpositiveFloat)
              , (float, float, float)
              , (singleFloatPositiveZero, singleFloatPositiveZero, singleFloatPositiveZero)
              , (singleFloatNegativeZero, singleFloatNegativeZero, singleFloatNegativeZero)
              , (singleFloatZero, singleFloatZero, singleFloatZero)
              , (positiveSingleFloat, positiveSingleFloat, positiveSingleFloat)
              , (nonnegativeSingleFloat, nonnegativeSingleFloat, nonnegativeSingleFloat)
              , (negativeSingleFloat, singleFloat, negativeSingleFloat)
              , (singleFloat, negativeSingleFloat, negativeSingleFloat)
              , (nonpositiveSingleFloat, singleFloat, nonpositiveSingleFloat)
              , (singleFloat, nonpositiveSingleFloat, nonpositiveSingleFloat)
              , (negativeSingleFloat, negativeSingleFloat, negativeSingleFloat)
              , (nonpositiveSingleFloat, nonpositiveSingleFloat, nonpositiveSingleFloat)
              , (singleFloat, singleFloat, singleFloat)
              , (inexactRealPositiveZero, inexactRealPositiveZero, inexactRealPositiveZero)
              , (inexactRealNegativeZero, inexactRealNegativeZero, inexactRealNegativeZero)
              , (inexactRealZero, inexactRealZero, inexactRealZero)
              , (positiveInexactReal, positiveInexactReal, positiveInexactReal)
              , (nonnegativeInexactReal, nonnegativeInexactReal, nonnegativeInexactReal)
              , (negativeInexactReal, inexactReal, negativeInexactReal)
              , (inexactReal, negativeInexactReal, negativeInexactReal)
              , (nonpositiveInexactReal, inexactReal, nonpositiveInexactReal)
              , (inexactReal, nonpositiveInexactReal, nonpositiveInexactReal)
              , (negativeInexactReal, negativeInexactReal, negativeInexactReal)
              , (nonpositiveInexactReal, nonpositiveInexactReal, nonpositiveInexactReal)
              , (inexactReal, inexactReal, inexactReal)
              , (realZero, realZero, realZero)
              , (positiveReal, positiveReal, positiveReal)
              , (nonnegativeReal, nonnegativeReal, nonnegativeReal)
              , (negativeReal, real, negativeReal)
              , (real, negativeReal, negativeReal)
              , (nonpositiveReal, real, nonpositiveReal)
              , (real, nonpositiveReal, nonpositiveReal)
              , (negativeReal, negativeReal, negativeReal)
              , (nonpositiveReal, nonpositiveReal, nonpositiveReal)
              , (real, real, real)]))

    
  , ("<", (BinOp
           [ -- general cases --
             -- -- -- -- -- -- -- -- --
             (realNoNaN, realNoNaN, bool)
           , (someNaN, real, F)
           , (real, someNaN, F)
             -- positive/nonpositive cases --
           , (nonpositiveRealNoNaN, positiveRealNoNaN, T)
           , (positiveReal, nonpositiveReal, F)
             -- zero/negative cases --
           , (negativeRealNoNaN, realZeroNoNaN, T)
           , (realZero, negativeReal, F)
           -- bounded type cases --
           , (negativeInfinity, And [realNoNaN, (Not negativeInfinity)], T)
           , (real, negativeInfinity, F)
           , (negativeIntegerNotFixnum, And [integer, (Not negativeIntegerNotFixnum)], T)
           , (And [integer, (Not negativeIntegerNotFixnum)], negativeIntegerNotFixnum, F)
           , (realZero, realZero, F)
           , (nonpositiveRealNoNaN, one, T)
           , (one, nonpositiveReal, F)
           , (one, one, F)
           , (one, And[positiveInteger, (Not one)], T)
           , (And[positiveInteger, (Not one)], one, F)
           , (byte, positiveIntegerNotByte, T)
           , (positiveIntegerNotByte, byte, F)
           , (index, positiveIntegerNotIndex, T)
           , (positiveIntegerNotIndex, index, F)
           , (fixnum, positiveIntegerNotFixnum, T)
           , (positiveIntegerNotFixnum, fixnum, F)
           , (And [realNoNaN, (Not positiveInfinity)], positiveInfinity, T)
           , (positiveInfinity, real, F)]))]
