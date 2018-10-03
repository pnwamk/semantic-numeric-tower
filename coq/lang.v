
Require Import CpdtTactics.
Require Import Bool.
Require Import Nat.
Require Import String.
Require Import List.
Import ListNotations.
Require Import Permutation.
Require Import Ensembles.
Require Import Classical_sets.

Set Implicit Arguments.

(* * * * * * * * * * * * * * * * * * * * * * * * *)
(*             A few useful tactics              *)
(* * * * * * * * * * * * * * * * * * * * * * * * *)

Ltac ifcase :=
  match goal with
  | [ |- context[if ?X then _ else _] ] => destruct X
  end.

Ltac ifcaseH :=
  match goal with
  | [ H : context[if ?X then _ else _] |- _ ] => destruct X
  end.

Ltac matchcase :=
  match goal with
  | [ |- context[match ?term with
                 | _ => _
                 end] ] => destruct term
  end.

Ltac matchcaseH :=
  match goal with
  | [ H: context[match ?term with
                 | _ => _
                 end] |- _ ] => destruct term
  end.


Ltac applyH :=
  match goal with
  | [H : _ -> _ |- _] => progress (apply H)
  end.

Ltac applyHinH :=
  match goal with
  | [H1 : _ -> _ , H2 : _ |- _] => apply H1 in H2
  end.


(**********************************************************)
(* Language Grammar                                       *)
(**********************************************************)

Inductive op : Set :=
  opAdd1
| opSub1
| opStrLen
| opNot
| opIsNat
| opIsStr
| opIsPair
| opIsProc
| opIsZero
| opError.
Hint Constructors op.

Inductive const : Set :=
  cNat  : nat -> const
| cStr  : string -> const
| cBool : bool -> const
| cOp   : op -> const.
Hint Constructors const.

Inductive bty : Set := btNat | btTrue | btFalse | btStr.
Hint Constructors bty.

Inductive ty : Set :=
  tAny   : ty
| tEmpty : ty
| tBase  : bty -> ty
| tProd  : ty -> ty -> ty
| tArrow : ty -> ty -> ty
| tOr    : ty -> ty -> ty
| tAnd   : ty -> ty -> ty
| tNot   : ty -> ty.
Hint Constructors ty.

Definition tTrue  := (tBase btTrue).
Definition tFalse := (tBase btFalse).
Definition tBool  := (tOr tTrue tFalse).
Definition tNat   := (tBase btNat).
Definition tStr   := (tBase btStr).

Inductive var : Set :=
  Var : nat -> var.
Hint Constructors var.

Inductive int : Set :=
  iBase : ty -> ty -> int
| iCons : ty -> ty -> int -> int.
Hint Constructors int.

Inductive exp : Set :=
  eVar   : var -> exp
| eConst : const -> exp
| eAbs   : var -> int -> var -> exp -> exp (* μf.{τ→τ ...}λx.e *)
| eApp   : exp -> exp -> exp
| ePair  : exp -> exp -> exp
| eFst   : exp -> exp
| eSnd   : exp -> exp
| eIf    : exp -> exp -> exp -> exp
| eLet   : var -> exp -> exp -> exp.
Hint Constructors exp.

Notation "(eNat n )"  := (eConst (cNat n)).
Notation "(eStr s )"  := (eConst (cStr s)).
Notation "(eBool b )" := (eConst (cBool b)).
Notation "(eOp o )"   := (eConst (cOp o)).


Inductive val : Set :=
  vConst : const -> val
| vPair  : val -> val -> val
| vClos  : rho -> var -> int -> var -> exp -> val
with
rho : Set :=
  rhoNull  : rho
| rhoCons  : var -> val -> rho -> rho.
Hint Constructors val rho.

Notation "(vNat n )"  := (vConst (cNat n)).
Notation "(vStr s )"  := (vConst (cStr s)).
Notation "(vBool b )" := (vConst (cBool b)).
Notation "(vOp o )"   := (vConst (cOp o)).

Inductive path : Set :=
  pVar : var -> path
| pFst : path -> path
| pSnd : path -> path.
Hint Constructors path.

Inductive obj : Set :=
  oTop  : obj
| oBot  : obj
| oPath : path -> obj.
Hint Constructors obj.

Notation "(oFst p )"  := (oPath (pFst p)).
Notation "(oSnd p )"  := (oPath (pSnd p)).
Notation "(oVar x )"  := (oPath (pVar x)).


Inductive prop : Set :=
  Trivial : prop
| Absurd  : prop
| And     : prop -> prop -> prop
| Or      : prop -> prop -> prop
| Is      : path -> ty -> prop
| Eq      : path -> path -> prop.
Hint Constructors prop.

Definition gamma := list prop.
Hint Unfold gamma.

Inductive tres : Set :=
  Res : ty -> prop -> prop -> obj -> tres.
Hint Constructors tres.

Inductive failure : Set := fError | fStuck | fTimeout.
Hint Constructors failure.

Inductive result : Set :=
  rVal  : val -> result
| rFail : failure -> result.
Hint Constructors result.

Notation rError   := (rFail fError).
Notation rStuck   := (rFail fStuck).
Notation rTimeout := (rFail fTimeout).

Hint Resolve PeanoNat.Nat.eq_dec.
Hint Resolve string_dec.
Hint Resolve bool_dec.


Definition op_dec : forall (x y : op),
    {x = y} + {x <> y}.
Proof. decide equality. Defined.
Hint Resolve op_dec.

Definition const_dec : forall (x y : const),
    {x = y} + {x <> y}.
Proof. decide equality. Defined.
Hint Resolve const_dec.

Definition bty_dec : forall (x y : bty),
    {x = y} + {x <> y}.
Proof. decide equality. Defined.
Hint Resolve bty_dec.

Definition ty_dec : forall (x y : ty),
    {x = y} + {x <> y}.
Proof. decide equality. Defined.
Hint Resolve ty_dec.

Definition var_dec : forall (x y : var),
    {x = y} + {x <> y}.
Proof. decide equality. Defined.
Hint Resolve var_dec.

Definition int_dec : forall (x y : int),
    {x = y} + {x <> y}.
Proof. decide equality. Defined.
Hint Resolve int_dec.

Definition exp_dec : forall (x y : exp),
    {x = y} + {x <> y}.
Proof. decide equality. Defined.
Hint Resolve exp_dec.

Fixpoint val_dec (x y : val) : { x = y } + { x <> y }
with
rho_dec (x y : rho) : { x = y } + { x <> y }.
Proof.
  decide equality.
  decide equality.
Defined.
Hint Resolve val_dec rho_dec.

Definition path_dec : forall (x y : path),
    {x = y} + {x <> y}.
Proof. decide equality. Defined.
Hint Resolve path_dec.

Definition obj_dec : forall (x y : obj),
    {x = y} + {x <> y}.
Proof. decide equality. Defined.
Hint Resolve obj_dec.

Definition prop_dec : forall (x y : prop),
    {x = y} + {x <> y}.
Proof. decide equality. Defined.
Hint Resolve prop_dec.

Definition tres_dec : forall (x y : tres),
    {x = y} + {x <> y}.
Proof. decide equality. Defined.
Hint Resolve tres_dec.

Definition failure_dec : forall (x y : failure),
    {x = y} + {x <> y}.
Proof. decide equality. Defined.
Hint Resolve failure_dec.

Definition result_dec : forall (x y : result),
    {x = y} + {x <> y}.
Proof. decide equality. Defined.
Hint Resolve result_dec.

(**********************************************************)
(* Dynamic Semantics                                      *)
(**********************************************************)

Definition apply_op (o:op) (v:val) : result :=
  match o , v with
  | opAdd1   , (vNat n)          => rVal (vNat (n + 1))
  | opAdd1   , _                 => rStuck
  | opSub1   , (vNat n)          => rVal (vNat (n - 1))
  | opSub1   , _                 => rStuck
  | opStrLen , (vStr s)          => rVal (vNat (String.length s))
  | opStrLen , _                 => rStuck
  | opNot    , (vBool false)     => rVal (vBool true)
  | opNot    , _                 => rVal (vBool false)
  | opIsNat  , (vNat _)          => rVal (vBool true)
  | opIsNat  , _                 => rVal (vBool false)
  | opIsStr  , (vStr _)          => rVal (vBool true)
  | opIsStr  , _                 => rVal (vBool false)
  | opIsPair , (vPair _ _)       => rVal (vBool true)
  | opIsPair , _                 => rVal (vBool false)
  | opIsProc , (vOp _)           => rVal (vBool true)
  | opIsProc , (vClos _ _ _ _ _) => rVal (vBool true)
  | opIsProc , _                 => rVal (vBool false)
  | opIsZero , (vNat 0)          => rVal (vBool true)
  | opIsZero , (vNat _)          => rVal (vBool false)
  | opIsZero , _                 => rStuck
  | opError  , (vStr s)          => rError
  | opError  , _                 => rStuck
  end.
Hint Unfold apply_op.

Fixpoint var_lookup (r:rho) (x:var) : result :=
  match r with
  | rhoNull       => rStuck
  | rhoCons y v r' => if var_dec x y
                      then rVal v
                      else var_lookup r' x
  end.
Hint Unfold var_lookup.

Fixpoint path_lookup (r:rho) (π:path) : result :=
  match π with
  | (pVar x) => var_lookup r x
  | (pFst π') =>
    match (path_lookup r π') with
    | (rVal (vPair v _)) => rVal v
    | _ => rStuck
    end
  | (pSnd π') =>
    match (path_lookup r π') with
    | (rVal (vPair _ v)) => rVal v
    | _ => rStuck
    end
  end.
Hint Unfold path_lookup.

Inductive NonOp : const -> Prop :=
| NO_Nat : forall n, NonOp (cNat n)
| NO_Str : forall s, NonOp (cStr s)
| NO_Bool : forall b, NonOp (cBool b).
Hint Constructors NonOp.

Inductive NonPair : val -> Prop :=
| NP_Const : forall c, NonPair (vConst c)
| NP_Clos : forall r f i x e, NonPair (vClos r f i x e).
Hint Constructors NonPair.


Inductive ValOf : nat -> rho -> exp -> result -> Prop :=
| V_Timeout : forall r e,
    ValOf O r e rTimeout
| V_Var : forall n r x,
    ValOf (S n) r (eVar x) (var_lookup r x)
| V_Const : forall n r c,
    ValOf (S n) r (eConst c) (rVal (vConst c))
| V_Abs : forall n r f i x e,
    ValOf (S n) r (eAbs f i x e) (rVal (vClos r f i x e))
| V_App_Fail1 : forall n r e1 e2 f,
    ValOf n r e1 (rFail f) ->
    ValOf (S n) r (eApp e1 e2) (rFail f)
| V_App_Fail2 : forall n r e1 e2 c,
    ValOf n r e1 (rVal (vConst c)) ->
    NonOp c ->
    ValOf (S n) r (eApp e1 e2) rStuck
| V_App_Fail3 : forall n r e1 e2 v1 f,
    ValOf n r e1 (rVal v1) ->
    ValOf n r e2 (rFail f) ->
    ValOf (S n) r (eApp e1 e2) (rFail f)
| V_App_Op : forall n r e1 e2 o1 v2,
    ValOf n r e1 (rVal (vOp o1)) ->
    ValOf n r e2 (rVal v2) ->
    ValOf (S n) r (eApp e1 e2) (apply_op o1 v2)
| V_App_Clos : forall n r e1 e2 r' f i x e' v2 r'' res,
    ValOf n r e1 (rVal (vClos r' f i x e')) ->
    ValOf n r e2 (rVal v2) ->
    r'' = (rhoCons x v2 (rhoCons f (vClos r' f i x e') r')) ->
    ValOf n r'' e' res ->
    ValOf (S n) r (eApp e1 e2) res
| V_Pair_Fail1 : forall n r e1 e2 f,
    ValOf n r e1 (rFail f) ->
    ValOf (S n) r (ePair e1 e2) (rFail f)
| V_Pair_Fail2 : forall n r e1 e2 v1 f,
    ValOf n r e1 (rVal v1) ->
    ValOf n r e2 (rFail f) ->
    ValOf (S n) r (ePair e1 e2) (rFail f)
| V_Pair : forall n r e1 e2 v1 v2,
    ValOf n r e1 (rVal v1) ->
    ValOf n r e2 (rVal v2) ->
    ValOf (S n) r (ePair e1 e2) (rVal (vPair v1 v2))
| V_Fst_Fail1 : forall n r e f,
    ValOf n r e (rFail f) ->
    ValOf (S n) r (eFst e) (rFail f)
| V_Fst_Fail2 : forall n r e v,
    ValOf n r e (rVal v) ->
    NonPair v ->
    ValOf (S n) r (eFst e) rStuck
| V_Fst : forall n r e v1 v2,
    ValOf n r e (rVal (vPair v1 v2)) ->
    ValOf (S n) r (eFst e) (rVal v1)
| V_Snd_Fail1 : forall n r e f,
    ValOf n r e (rFail f) ->
    ValOf (S n) r (eSnd e) (rFail f)
| V_Snd_Fail2 : forall n r e v,
    ValOf n r e (rVal v) ->
    NonPair v ->
    ValOf (S n) r (eSnd e) rStuck
| V_Snd : forall n r e v1 v2,
    ValOf n r e (rVal (vPair v1 v2)) ->
    ValOf (S n) r e (rVal v2)
| V_If_Fail1 : forall n r e1 e2 e3 f,
    ValOf n r e1 (rFail f) ->
    ValOf (S n) r (eIf e1 e2 e3) (rFail f)
| V_If_NonFalse : forall n r e1 e2 e3 v1 res,
    ValOf n r e1 (rVal v1) ->
    v1 <> (vBool false) ->
    ValOf n r e2 res ->
    ValOf (S n) r (eIf e1 e2 e3) res
| V_If_False : forall n r e1 e2 e3 res,
    ValOf n r e1 (rVal (vBool false)) ->
    ValOf n r e3 res ->
    ValOf (S n) r (eIf e1 e2 e3) res
| V_Let_Fail : forall n r x e1 e2 f,
    ValOf n r e1 (rFail f) ->
    ValOf (S n) r (eLet x e1 e2) (rFail f)
| V_Let : forall n r x e1 e2 v1 res,
    ValOf n r e1 (rVal v1) ->
    ValOf n (rhoCons x v1 r) e2 res ->
    ValOf (S n) r (eLet x e1 e2) res.
Hint Constructors ValOf.

Fixpoint eval (fuel:nat) (r:rho) (expr:exp) : result :=
  match fuel with
  | O => rTimeout
  | S n =>
    match expr with
    | eVar x => var_lookup r x
    | eConst c => rVal (vConst c)
    | eAbs f i x e => rVal (vClos r f i x e)
    | eApp e1 e2 =>
      match (eval n r e1) , (eval n r e2) with
      | rFail f, _ => rFail f
      | _, rFail f => rFail f
      | rVal v1, rVal v2 =>
        match v1 with
        | vConst (cOp o) => apply_op o v2
        | vClos r f i x e =>
          let r' := rhoCons x v2 (rhoCons f v1 r) in
          eval n r' e
        | _ => rStuck
        end
      end
    | ePair e1 e2 =>
      match (eval n r e1) , (eval n r e2) with
      | rFail f, _ => rFail f
      | _, rFail f => rFail f
      | rVal v1, rVal v2 => rVal (vPair v1 v2)
      end
    | eFst e =>
      match (eval n r e) with
      | rFail f => rFail f
      | rVal (vPair v1 v2) => rVal v1
      | rVal _ => rStuck
      end
    | eSnd e =>
      match (eval n r e) with
      | rFail f => rFail f
      | rVal (vPair v1 v2) => rVal v2
      | rVal _ => rStuck
      end
    | eIf e1 e2 e3 =>
      match (eval n r e1) with
      | rFail f => rFail f
      | rVal (vBool false) => eval n r e3
      | rVal _ => eval n r e2
      end
    | eLet x e1 e2 =>
      match (eval n r e1) with
      | rFail f => rFail f
      | rVal v => eval n (rhoCons x v r) e2
      end
    end 
  end.

(* TODO? May be interesting, may not. *)
Lemma ValOf_iff_eval : forall n r e res,
    ValOf n r e res <-> eval n r e = res.
Proof.
  Admitted.

(**********************************************************)
(* Subtyping                                              *)
(**********************************************************)

(* the domain types are denoted into *)
Axiom tInterp : ty -> (Ensemble val).
Axiom interp_tAny : tInterp tAny = (Full_set val).
Hint Rewrite interp_tAny.
Axiom interp_tEmpty : tInterp tEmpty = (Empty_set val).
Hint Rewrite interp_tEmpty.
Axiom interp_tOr : forall t1 t2,
    tInterp (tOr t1 t2) = Union val (tInterp t1) (tInterp t2).
Hint Rewrite interp_tOr.
Axiom interp_tAnd : forall t1 t2,
    tInterp (tAnd t1 t2) = Intersection val (tInterp t1) (tInterp t2).
Hint Rewrite interp_tAnd.
Axiom interp_tNot : forall t,
    tInterp (tNot t) = Setminus val (Full_set val) (tInterp t).
Hint Rewrite interp_tNot.
Axiom interp_tTrue : tInterp tTrue = (Singleton val (vConst (cBool true))).
Hint Rewrite interp_tTrue.
Axiom interp_tFalse : tInterp tFalse = (Singleton val (vConst (cBool false))).
Hint Rewrite interp_tFalse.
Axiom interp_tNat_exists : forall (v:val),
    In val (tInterp tNat) v ->
    exists (n:nat), v = (vConst (cNat n)).
Axiom interp_tNat_full : forall (n:nat),
    In val (tInterp tNat) (vConst (cNat n)).
Hint Resolve interp_tNat_full.
Axiom interp_tStr_exists : forall (v:val),
    In val (tInterp tStr) v ->
    exists (s:string), v = (vConst (cStr s)).
Axiom interp_tStr_full : forall (s:string),
    In val (tInterp tStr) (vConst (cStr s)).
Hint Resolve interp_tStr_full.
Axiom interp_tProd_exists : forall (t1 t2:ty) (v:val),
    In val (tInterp (tProd t1 t2)) v ->
    exists (v1 v2:val), v = (vPair v1 v2)
                        /\ In val (tInterp t1) v1
                        /\ In val (tInterp t2) v2.
Axiom interp_tProd_full : forall (v1 v2:val) (t1 t2:ty),
    In val (tInterp t1) v1 ->
    In val (tInterp t2) v2 ->
    In val (tInterp (tProd t1 t2)) (vPair v1 v2).
Hint Resolve interp_tProd_full.

Inductive ValOfTy : rho -> exp -> ty -> Prop :=
| VOT_Timeout :   forall r e t,
    (forall n, ValOf n r e rTimeout) ->
    ValOfTy r e t
| VOT_Error :   forall r e t,
    (exists n, ValOf n r e rError) ->
    ValOfTy r e t
| VOT_Val :   forall r e t,
    (exists n v, ValOf n r e (rVal v)
                 /\ In val (tInterp t) v) ->
    ValOfTy r e t.
Hint Constructors ValOfTy.

Inductive ApplyVal : val -> val -> result -> Prop :=
| Apply_Op : forall o v res,
    apply_op o v = res ->
    ApplyVal (vOp o) v res
| Apply_Error : forall r f i x e v,
    (exists n, ValOf n (rhoCons x v (rhoCons f (vClos r f i x e) r))
                     e
                     rError) ->
    ApplyVal (vClos r f i x e) v rError
| Apply_Stuck : forall r f i x e v,
    (exists n, ValOf n (rhoCons x v (rhoCons f (vClos r f i x e) r))
                     e
                     rStuck) ->
    ApplyVal (vClos r f i x e) v rStuck
| Apply_Val : forall r f i x e v,
    (exists n v, ValOf n (rhoCons x v (rhoCons f (vClos r f i x e) r))
                       e
                       (rVal v)) ->
    ApplyVal (vClos r f i x e) v rStuck
| Apply_Timeout : forall r f i x e v,
    (forall n, ValOf n (rhoCons x v (rhoCons f (vClos r f i x e) r))
                     e
                     rTimeout) ->
    ApplyVal (vClos r f i x e) v rTimeout.
Hint Constructors ApplyVal.

Inductive ValMaps : val -> ty -> ty -> Prop :=
| Maps : forall v t1 t2,
    (forall v1,
        In val (tInterp t1) v1 ->
        ApplyVal v v1 rTimeout
        \/ ApplyVal v v1 rError
        \/ (exists v2, ApplyVal v v1 (rVal v2)
                       /\ In val (tInterp t2) v2)) ->
    ValMaps v t1 t2.
Hint Constructors ValMaps.

Axiom interp_tArrow_exists : forall (t1 t2:ty) (v:val),
    In val (tInterp (tArrow t1 t2)) v ->
    ValMaps v t1 t2.
Axiom interp_tArrow_full : forall (v:val) (t1 t2:ty),
    ValMaps v t1 t2 ->
    In val (tInterp (tArrow t1 t2)) v.


Inductive Subtype : ty -> ty -> Prop :=
| ST : forall t1 t2,
    Included val (tInterp t1) (tInterp t2) ->
    Subtype t1 t2.
Hint Constructors Subtype.

Inductive IsEmpty : ty -> Prop :=
| IE : forall t,
    (tInterp t) = (Empty_set val) ->
    IsEmpty t.
Hint Constructors IsEmpty.

Axiom empty_dec : forall (t: ty), {IsEmpty t} + {~ IsEmpty t}.

Inductive Subobj : obj -> obj -> Prop :=
| SO_Refl : forall o,
    Subobj o o
| SO_Bot : forall o,
    Subobj oBot o
| SO_Top : forall o,
    Subobj o oTop.
Hint Constructors Subobj.

(* (SubstPath π1 π π' π2 *)
(* π1[π ↦ π'] = π2 but where the substitution is optional *)
Inductive SubstPath : path -> path -> path -> path -> Prop :=
| SPath_Refl : forall π1 π π',
    SubstPath π1 π π' π1
| SPath_Swap : forall π π',
    SubstPath π π π' π'
| SPath_Fst : forall π1 π π' π2,
    SubstPath π1 π π' π2 ->
    SubstPath (pFst π1) π π' (pFst π2)
| SPath_Snd : forall π1 π π' π2,
    SubstPath π1 π π' π2 ->
    SubstPath (pSnd π1) π π' (pSnd π2).


(* (SubstProp p1 π π' p2)  *)
(* p1[π ↦ π'] = p2 but where the substitution is optional *)
Inductive SubstProp : prop -> path -> path -> prop -> Prop :=
| SProp_Refl : forall p π π',
    SubstProp p π π' p
| SProp_And : forall p1 p2 p1' p2' π π',
    SubstProp p1 π π' p1' ->
    SubstProp p2 π π' p2' ->
    SubstProp (And p1 p2) π π' (And p1' p2')
| SProp_Or : forall p1 p2 p1' p2' π π',
    SubstProp p1 π π' p1' ->
    SubstProp p2 π π' p2' ->
    SubstProp (Or p1 p2) π π' (Or p1' p2')
| SProp_Is : forall π1 π1' π π' t1,
    SubstPath π1 π π' π1' ->
    SubstProp (Is π1 t1) π π' (Is π1' t1)
| SProp_Eq : forall π1 π1' π2 π2' π π',
    SubstPath π1 π π' π1' ->
    SubstPath π2 π π' π2' ->
    SubstProp (Eq π1 π2) π π' (Eq π1' π2').

Inductive Proves : gamma -> prop -> Prop :=
| P_Atom : forall Γ p,
    List.In p Γ ->
    Proves Γ p
| P_Trivial : forall Γ,
    Proves Γ Trivial
| P_Combine : forall Γ π t1 t2,
    Proves Γ (Is π t1) ->
    Proves Γ (Is π t2) ->
    Proves Γ (Is π (tAnd t1 t2))
| P_Empty : forall Γ π p,
    Proves Γ (Is π tEmpty) ->
    Proves Γ p
| P_Sub : forall Γ π t1 t2,
    Proves Γ (Is π t1) ->
    Subtype t1 t2 ->
    Proves Γ (Is π t2)
| P_Fst : forall Γ π t,
    Proves Γ (Is (pFst π) t) ->
    Proves Γ (Is π (tProd t tAny))
| P_Snd : forall Γ π t,
    Proves Γ (Is (pSnd π) t) ->
    Proves Γ (Is π (tProd tAny t))       
| P_Absurd : forall Γ p,
    Proves Γ Absurd ->
    Proves Γ p
| P_AndE_L : forall Γ p1 p2,
    Proves Γ (And p1 p2) ->
    Proves Γ p1
| P_AndE_R : forall Γ p1 p2,
    Proves Γ (And p1 p2) ->
    Proves Γ p2
| P_AndI : forall Γ p1 p2,
    Proves Γ p1 ->
    Proves Γ p2 ->
    Proves Γ (And p1 p2)
| P_OrE : forall Γ p1 p2 p,
    Proves Γ (Or p1 p2) ->
    Proves (p1::Γ) p ->
    Proves (p2::Γ) p ->
    Proves Γ p
| P_OrI_L : forall Γ p1 p2,
    Proves Γ p1 ->
    Proves Γ (Or p1 p2)
| P_OrI_R : forall Γ p1 p2,
    Proves Γ p2 ->
    Proves Γ (Or p1 p2)
| P_Refl : forall Γ π t,
    Proves Γ (Is π t) ->
    Proves Γ (Eq π π)
| P_Subst : forall Γ π π' p q,
    Proves Γ (Eq π π') ->
    Proves Γ p ->
    SubstProp p π π' q ->
    Proves Γ q.
Hint Constructors Proves.

Fixpoint isa (o:obj) (t:ty) : prop :=
  if empty_dec t
  then Absurd
  else match o with
       | oPath π => Is π t
       | oTop => Trivial
       | oBot => Absurd    
       end.
Hint Unfold isa.

Definition maybeFst (o:obj) : obj :=
  match o with
  | oTop => oTop
  | oBot => oBot
  | oPath π => oPath (pFst π)
  end.
Hint Unfold maybeFst.

Definition maybeSnd (o:obj) : obj :=
  match o with
  | oTop => oTop
  | oBot => oBot
  | oPath π => oPath (pSnd π)
  end.
Hint Unfold maybeSnd.

Inductive Subres : gamma -> tres -> tres -> Prop :=
| SR_Sub : forall Γ t1 p1 q1 o1 t2 p2 q2 o2,
    Subtype t1 t2 ->
    Subobj o1 o2 ->
    Proves ((isa o1 (tAnd t1 (tNot tFalse)))::Γ) p2 ->
    Proves ((isa o1 (tAnd t1 tFalse))::Γ) q2 ->
    Subres Γ (Res t1 p1 q1 o1) (Res t2 p2 q2 o2)
| SR_Absurd : forall Γ t1 p1 q1 o1,
    Proves ((isa o1 (tAnd t1 (tNot tFalse)))::Γ) Absurd ->
    Proves ((isa o1 (tAnd t1 tFalse))::Γ) Absurd ->
    Subres Γ (Res t1 p1 q1 o1) (Res tEmpty Absurd Absurd oBot)
| SR_False : forall Γ t1 p1 q1 o1,
    Proves ((isa o1 (tAnd t1 (tNot tFalse)))::p1::Γ) Absurd ->
    Subres Γ (Res t1 p1 q1 o1) (Res (tAnd t1 tFalse) Absurd q1 o1)
| SR_NonFalse : forall Γ t1 p1 q1 o1,
    Proves ((isa o1 (tAnd t1 tFalse))::q1::Γ) Absurd ->
    Subres Γ (Res t1 p1 q1 o1) (Res (tAnd t1 (tNot tFalse)) p1 Absurd o1).
Hint Constructors Subres.


Definition predicate (t : ty) :=
  (tAnd (tArrow       t  tTrue)
        (tArrow (tNot t) tFalse)).
Hint Unfold predicate.

Definition op_type (o:op) : ty :=
  match o with
    opAdd1   => (tArrow tNat tNat)
  | opSub1   => (tArrow tNat tNat)
  | opStrLen => (tArrow tStr tNat)
  | opNot    => predicate tFalse
  | opIsNat  => predicate tNat
  | opIsStr  => predicate tStr
  | opIsPair => predicate (tProd tAny tAny)
  | opIsProc => predicate (tArrow tEmpty tAny)
  | opIsZero => tArrow tNat tBool
  | opError  => tArrow tStr tEmpty
  end.
Hint Unfold op_type.

Definition const_type (c:const) : ty :=
  match c with
  | cNat _  => tNat
  | cStr _  => tStr
  | cBool b => if b
               then tTrue
               else tFalse
  | cOp o => op_type o
  end.
Hint Unfold const_type.

Definition const_tres (c:const) : tres :=
  match c with
  | cBool false => (Res tFalse Absurd Trivial oTop)
  | _ => (Res (const_type c) Trivial Absurd oTop)
  end.
Hint Unfold const_tres.

Inductive InInterface : ty -> ty -> int -> Prop :=
| InI_Base : forall t1 t2,
    InInterface t1 t2 (iBase t1 t2)
| InI_First : forall t1 t2 i,
    InInterface t1 t2 (iCons t1 t2 i)
| InI_Rest : forall t1 t2 t3 t4 i,
    InInterface t1 t2 i ->
    InInterface t1 t2 (iCons t3 t4 i).
Hint Constructors InInterface.

Fixpoint int_to_ty (i:int) : ty :=
  match i with
  | (iBase t1 t2) => tArrow t1 t2
  | (iCons t1 t2 i') => (tAnd (tArrow t1 t2) (int_to_ty i'))
  end.
Hint Unfold int_to_ty.

Fixpoint fvsPath (π:path) : list var :=
  match π with
  | pVar x => [x]
  | pFst π' => fvsPath π'
  | pSnd π' => fvsPath π'
  end.
Hint Unfold fvsPath.

Fixpoint fvsP (p:prop) : list var :=
  match p with
  | Trivial => []
  | Absurd => []
  | And p1 p2 => (fvsP p1) ++ (fvsP p2)
  | Or p1 p2 => (fvsP p1) ++ (fvsP p2)
  | Is π t => fvsPath π
  | Eq π π' => (fvsPath π) ++ (fvsPath π')
  end.
Hint Unfold fvsP.

Fixpoint fvs (Γ:gamma) : list var :=
  match Γ with
  | [] => []
  | p::ps => (fvsP p) ++ (fvs ps)
  end.
Hint Unfold fvs.

Axiom Pred : ty -> ty -> ty -> ty -> Prop.
Axiom Pred_prop : forall funty argty tpos tneg,
    Pred funty argty tpos tneg ->
    forall v1 v2 v3,
      In val (tInterp funty) v1 ->
      In val (tInterp argty) v2 ->
      ApplyVal v1 v2 (rVal v3) ->
      (v3 <> (vBool false) /\ In val (tInterp tpos) v2)
      \/
      (v3 = (vBool false) /\ In val (tInterp tneg) v2).

Definition objOr (o1 o2:obj) : obj :=
  match o1 , o2 with
  | o1 , oBot => o1
  | oBot , o2 => o2
  | _, _ => if obj_dec o1 o2
            then o1
            else oTop
  end.
Hint Unfold objOr.

Definition tresOr (r1 r2:tres) : tres :=
  match r1, r2 with
  | (Res t1 p1 q1 o1), (Res t2 p2 q2 o2) =>
    (Res (tOr t1 t2) (Or p1 p2) (Or q1 q2) (objOr o1 o2))
  end.
Hint Unfold tresOr.

Definition alias (x : var) (R:tres) : prop :=
  match R with
  | (Res _ _ _ oBot) => Absurd
  | (Res _ _ _ (oPath π)) => Eq (pVar x) π
  | (Res t p q oTop) =>
    let p' := And p (Is (pVar x) (tAnd t (tNot tFalse))) in
    let q' := And q (Is (pVar x) (tAnd t tFalse)) in
    And (Is (pVar x) t) (Or p' q')
  end.
Hint Unfold alias.

Inductive TypeOf : gamma -> exp -> tres -> Prop :=
| T_Var : forall Γ x π t R,
    Proves Γ (Eq (pVar x) π) ->
    Proves Γ (Is π t) ->
    Subres Γ
           (Res t
                (Is π (tAnd t (tNot tFalse)))
                (Is π (tAnd t tFalse))
                (oPath π))
           R ->
    TypeOf Γ (eVar x) R 
| T_Const : forall Γ c R,
    Subres Γ (const_tres c) R ->
    TypeOf Γ (eConst c) R
| T_Abs : forall Γ f i x e fty t t' R,
    x <> f ->
    ~ List.In x (fvs Γ) ->
    ~ List.In f (fvs Γ) ->
    fty = (int_to_ty i) ->
    t = (tAnd fty (tNot t')) ->
    ~ (Subtype t tEmpty) ->
    (forall t1 t2,
        InInterface t1 t2 i ->
        TypeOf ((Is (pVar x) t1)::(Is (pVar f) fty)::Γ)
               e
               (Res t2 Trivial Trivial oTop)) ->
    Subres Γ (Res fty Trivial Absurd oTop) R ->
    TypeOf Γ (eAbs f i x e) R
| T_App : forall Γ e1 e2 t1 t2 o2 t tpos tneg R,
    TypeOf Γ e1 (Res t1 Trivial Trivial oTop) ->
    TypeOf Γ e2 (Res t2 Trivial Trivial o2) ->
    Subtype t1 (tArrow t2 t) ->
    Pred t1 t2 tpos tneg ->
    Subres Γ (Res t (isa o2 tpos) (isa o2 tneg) oTop) R ->
    TypeOf Γ (eApp e1 e2) R
| T_Pair : forall Γ e1 e2 t1 t2 R,
    TypeOf Γ e1 (Res t1 Trivial Trivial oTop) ->
    TypeOf Γ e2 (Res t2 Trivial Trivial oTop) ->
    Subres Γ (Res (tProd t1 t2) Trivial Absurd oTop) R ->
    TypeOf Γ (ePair e1 e2) R
| T_Fst : forall Γ e t t1 t2 o R,
    TypeOf Γ e (Res t Trivial Trivial oTop) ->
    Subtype t (tProd t1 t2) ->
    Subres Γ (Res t1 Trivial Trivial (maybeFst o)) R ->
    TypeOf Γ (eFst e) R
| T_Snd : forall Γ e t t1 t2 o R,
    TypeOf Γ e (Res t Trivial Trivial oTop) ->
    Subtype t (tProd t1 t2) ->
    Subres Γ (Res t2 Trivial Trivial (maybeSnd o)) R->
    TypeOf Γ (eSnd e) R
| T_If : forall Γ e1 e2 e3 t1 R2 R3 p1 q1 o1 R,
    TypeOf Γ e1 (Res t1 p1 q1 o1) ->
    TypeOf ((isa o1 (tAnd t1 (tNot tFalse)))::p1::Γ) e2 R2 ->
    TypeOf ((isa o1 (tAnd t1 tFalse))::q1::Γ) e3 R3 ->
    Subres Γ (tresOr R2 R3) R ->
    TypeOf Γ (eIf e1 e2 e3) R
| T_Let : forall Γ x e1 e2 R1 R2 R,
    ~ List.In x (fvs Γ) ->
    TypeOf Γ e1 R1 ->
    TypeOf ((alias x R1)::Γ) e2 R2 ->
    Subres Γ R2 R ->
    TypeOf Γ (eLet x e1 e2) R.
Hint Constructors TypeOf.


Ltac same_rVal :=
  match goal with
  | [H : rVal _ = rVal _ |- _] => inversion H; subst
  end.

Inductive Sat : rho -> prop -> Prop :=
| M_Trivial : forall r,
    Sat r Trivial
| M_And : forall p q r,
    Sat r p ->
    Sat r q ->
    Sat r (And p q)
| M_Or_L : forall p q r,
    Sat r p ->
    Sat r (Or p q)
| M_Or_R : forall p q r,
    Sat r q ->
    Sat r (Or p q)
| M_Is : forall π t r v,
    path_lookup r π = rVal v ->
    In val (tInterp t) v ->
    Sat r (Is π t)
| M_Eq : forall π1 π2 v r,
    path_lookup r π1 = rVal v ->
    path_lookup r π2 = rVal v ->
    Sat r (Eq π1 π2).
Hint Constructors Sat.


Lemma SubstPath_lookup_eq : forall r π1 π1' π π' v,
    SubstPath π1 π π' π1' ->
    path_lookup r π = rVal v ->
    path_lookup r π' = rVal v ->
    path_lookup r π1 = path_lookup r π1'.
Proof.
  intros r π1 π1' π π' v Hsub.
  generalize dependent r.
  induction Hsub; crush.
Qed.  
  
Lemma Sat_transport : forall r p π π' q,
    SubstProp p π π' q ->
    Sat r p ->
    Sat r (Eq π π') ->
    Sat r q.
Proof.
  intros r p π π' q Hsubst.
  generalize dependent r.
  induction Hsubst.
  {
    (* SProp_Refl *)
    crush.
  }
  {
    (* SProp_And *)
    intros r Hand Heq.
    inversion Hand; subst.
    intuition.
  }
  {
    (* SProp_Or *)
    intros r Hor Heq.
    inversion Hor; subst; intuition.
  }
  {
    (* SProp_Is *)
    intros r His Heq.
    inversion Heq; subst.
    inversion His; subst.
    assert (path_lookup r π1 = path_lookup r π1') as Heq1
        by (eapply SubstPath_lookup_eq; eassumption).
    assert (path_lookup r π1' = rVal v0) as Heq0 by crush.
    econstructor; eauto.
  }
  {
    (* SProp_Eq *)
    intros r Heq Heq'.
    inversion Heq; subst.
    inversion Heq'; subst.
    assert (path_lookup r π1 = path_lookup r π1') as Heq1
        by (eapply SubstPath_lookup_eq; eassumption).
    assert (path_lookup r π1' = rVal v) as Heq1' by crush.
    assert (path_lookup r π2 = path_lookup r π2') as Heq2
        by (eapply SubstPath_lookup_eq; eassumption).
    assert (path_lookup r π2' = rVal v) as Heq2' by crush.
    econstructor; eauto.
  }
Qed.  

Lemma lemma1 : forall Γ p r,
    Proves Γ p ->
    Forall (Sat r) Γ ->
    Sat r p.
Proof.
  intros Γ p r Hproves.
  generalize dependent r.
  induction Hproves; intros r Hsat.
  { (* P_Atom *)
    eapply Forall_forall; eassumption.
  }
  { (* P_Trivial *)
    crush.
  }
  { (* P_Combine *)
    assert (Sat r (Is π t1)) as H1 by auto.
    assert (Sat r (Is π t2)) as H2 by auto.
    inversion H1. inversion H2. subst.
    assert (v = v0) as Heq by crush. subst.
    eapply M_Is. eassumption. crush.
  }
  { (* P_Empty *)
    assert (Sat r (Is π tEmpty)) as H by auto.
    inversion H. subst. rewrite interp_tEmpty in *.
    match goal with
    | [H: In val (Empty_set val) _ |- _] => inversion H
    end.
  }
  { (* P_Sub *)
    assert (Sat r (Is π t1)) as Ht1 by auto.
    inversion Ht1; subst.
    econstructor. eassumption.
    match goal with
    | [H: Subtype _ _ |- _] => inversion H; crush
    end.
  }
  { (* P_Fst *)
    assert (Sat r (Is (pFst π) t)) as H by auto.
    inversion H; subst.
    assert (exists v', path_lookup r π = rVal (vPair v v')) as H'.
    {
      simpl in *. destruct (path_lookup r π); crush.
      destruct v0;
        try match goal with
            | [ H : rStuck = rVal _ |- _] => inversion H; crush
            end.
      same_rVal.
      exists v0_2.
      reflexivity.      
    }
    destruct H' as [v' Hv'].
    eapply (M_Is π r Hv').
    apply interp_tProd_full; auto.
    rewrite interp_tAny.
    constructor.
  }
  { (* P_Snd *)
    assert (Sat r (Is (pSnd π) t)) as H by auto.
    inversion H; subst.
    assert (exists v', path_lookup r π = rVal (vPair v' v)) as H'.
    {
      simpl in *. destruct (path_lookup r π); crush.
      destruct v0;
        try match goal with
            | [ H : rStuck = rVal _ |- _] => inversion H; crush
            end.
      same_rVal.
      exists v0_1.
      reflexivity.      
    }
    destruct H' as [v' Hv'].
    eapply (M_Is π r Hv').
    apply interp_tProd_full; auto.
    rewrite interp_tAny.
    constructor.
  }
  { (* P_Absurd *)
    assert (Sat r Absurd) as Hnope by auto.
    inversion Hnope.
  }
  { (* P_AndE_L *)
    assert (Sat r (And p1 p2)) as Hsat' by auto.
    inversion Hsat'; auto.
  }
  { (* P_AndE_R *)
    assert (Sat r (And p1 p2)) as Hsat' by auto.
    inversion Hsat'; auto.
  }
  { (* P_AndI *)
    crush.
  }
  { (* P_OrE *)
    assert (Sat r (Or p1 p2)) as Hsat' by auto.
    inversion Hsat'; subst; intuition.
  }
  { (* P_OrI_L *)
    apply M_Or_L. auto.
  }
  { (* P_OrI_R *)
    apply M_Or_R. auto.
  }
  { (* P_Refl *)
    assert (Sat r (Is π t)) as Hsat' by auto.
    inversion Hsat'; subst.
    eapply M_Eq; eauto.
  }
  { (* P_Subst *)
    assert (Sat r (Eq π π')) as Heq by auto.
    assert (Sat r p) as Hp by auto.
    eapply Sat_transport; eauto.    
  }
Qed.  

Inductive ObjSatVal : rho -> obj -> val -> Prop :=
| OSV_Top : forall r v,
    ObjSatVal r oTop v
| OSV_Path : forall r v π,
    path_lookup r π = (rVal v) ->
    ObjSatVal r (oPath π) v.
Hint Constructors ObjSatVal.

Inductive SatProps : rho -> val -> prop -> prop -> Prop :=
| SP_False : forall r p q,
    Sat r q ->
    SatProps r (vBool false) p q
| SP_NonFalse : forall r p q v,
    v <> (vBool false) ->
    Sat r p ->
    SatProps r v p q.
Hint Constructors SatProps.

Lemma lemma2 : forall Γ e t p q o r n res,
      TypeOf Γ e (Res t p q o) ->
      Forall (Sat r) Γ ->
      ValOf n r e res ->
      (exists v,
          res = rVal v
          /\ ObjSatVal r o v
          /\ SatProps r v p q
          /\ In val (tInterp t) v)
      \/ res = rError
      \/ res = rTimeout.
Proof.
  intros Γ e t p q o r n res Htype Hsat Hvalof.
  induction Hvalof.
  { (* V_Timeout *)
    right. right. reflexivity.
  }
  { (* V_Var *)
    left.
    inversion Htype; subst.
    {
      (* BOOKMARK

MAYBE WE NEED A LEMMA FOR SUBRES? *)
      assert (Sat r (Eq (pVar x) π)) as Heq
          by (eapply lemma1; eauto).
      inversion Heq; subst.
      assert (Sat r (Is π t)) as HIs
          by (eapply lemma1; eauto).
      inversion HIs; subst.
      assert (v0 = v) as Hveq by crush. subst.
      exists v. crush.
      destruct (val_dec v (vBool false)) as [Hvfalse | Hvnonfalse].
      {
        subst.
        apply SP_False.
        eapply M_Is. eassumption.
        crush.
      }
      {
        apply SP_NonFalse. assumption.
        eapply M_Is. eassumption.
        crush.
        apply Intersection_intro; auto.
        apply Setminus_intro.
        constructor.
        intros Hcontra.
        inversion Hcontra.
        crush.
      }
    }
    {
      
    }
  }
  {
    (* V_Const *)
  }
  {
    (* V_Abs *)
  }
  {
    (* V_App_Fail1 *)
  }
  {
    (* V_App_Fail2 *)
  }
  {
    (* V_App_Fail3 *)
  }
  {
    (* V_App_Op *)
  }
  {
    (* V_App_Clos *)
  }
  {
    (* V_Pair_Fail1 *)
  }
  {
    (* V_Pair_Fail2 *)
  }
  {
    (* V_Pair *)
  }
  {
    (* V_Fst_Fail1 *)
  }
  {
    (* V_Fst_Fail2 *)
  }
  {
    (* V_Fst *)
  }
  {
    (* V_Snd_Fail1 *)
  }
  {
    (* V_Snd_Fail2 *)
  }
  {
    (* V_Snd *)
  }
  {
    (* V_If_Fail1 *)
  }
  {
    (* V_If_NonFalse *)
  }
  {
    (* V_If_False *)
  }
  {
    (* V_Let_Fail *)
  }
  {
    (* V_Let *)
  }
Admitted.

  
