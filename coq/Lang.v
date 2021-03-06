
Require Import CpdtTactics.
Require Import Bool.
Require Import Nat.
Require Import String.
Require Import Ensembles.
Require Import Classical_sets.
Require Import List.
Require Import Permutation.
Require Import ClassicalFacts.
Import ListNotations.

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

Ltac eapplyH :=
  match goal with
  | [H : _ -> _ |- _] => progress (eapply H)
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
| opIsProc
| opIsZero.
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
| tArrow : ty -> ty -> ty
| tOr    : ty -> ty -> ty
| tAnd   : ty -> ty -> ty
| tNot   : ty -> ty.
Hint Constructors ty.

Notation tTrue  := (tBase btTrue).
Notation tFalse := (tBase btFalse).
Notation tBool  := (tOr tTrue tFalse).
Notation tNat   := (tBase btNat).
Notation tStr   := (tBase btStr).

Inductive var : Set :=
  Var : nat -> var.
Hint Constructors var.

Definition interface := list (ty * ty).

Inductive exp : Set :=
  eVar   : var -> exp
| eVal   : val -> exp 
| eApp   : exp -> exp -> exp
| eIf    : exp -> exp -> exp -> exp

with

val : Set :=
  vConst : const -> val
| vAbs : var -> interface -> exp -> val.
  
  
Hint Constructors exp.

Definition vNat (n:nat) : val := (vConst (cNat n)).
Definition vStr (s:string) : val := (vConst (cStr s)).
Definition vBool (b:bool) : val := (vConst (cBool b)).
Definition vOp (o:op) : val := (vConst (cOp o)).

Inductive path : Set :=
| pVar : var -> path
| pVal : val -> path.
Hint Constructors path.

Inductive obj : Set :=
  oTop  : obj
| oPath : path -> obj.
Hint Constructors obj.

Inductive prop : Set :=
  Trivial : prop
| Absurd  : prop
| And     : prop -> prop -> prop
| Or      : prop -> prop -> prop
| Is      : path -> ty -> prop.
Hint Constructors prop.

Definition gamma := list prop.
Hint Unfold gamma.

Inductive tres : Set :=
  Res : ty -> prop -> prop -> obj -> tres.
Hint Constructors tres.

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

Definition int_dec : forall (x y : interface),
    {x = y} + {x <> y}.
Proof.
  Hint Resolve list_eq_dec.
  repeat decide equality.
Defined.
Hint Resolve int_dec.

Fixpoint exp_dec (x y : exp) : {x = y} + {x <> y}
with val_dec (x y : val) : {x = y} + {x <> y}.
Proof. decide equality. decide equality. Defined.
Hint Resolve exp_dec val_dec.

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

Fixpoint fvsO (o:obj) : list var :=
  match o with
  | oPath (pVar x) => [x]
  | _ => []
  end.
Hint Unfold fvsO.


Fixpoint fvsP (p:prop) : list var :=
  match p with
  | And p1 p2 => (fvsP p1) ++ (fvsP p2)
  | Or p1 p2 => (fvsP p1) ++ (fvsP p2)
  | Is (pVar x) t => [x]
  | _ => []
  end.
Hint Unfold fvsP.

Fixpoint fvsR (R:tres) : list var :=
  match R with
  | Res t p q (oPath (pVar x)) => [x] ++ (fvsP p) ++ (fvsP q)
  | Res t p q _ => (fvsP p) ++ (fvsP q)
  end.
Hint Unfold fvsP.


Fixpoint fvs (Γ:gamma) : list var :=
  match Γ with
  | [] => []
  | p::ps => (fvsP p) ++ (fvs ps)
  end.
Hint Unfold fvs.


(**********************************************************)
(* Dynamic Semantics                                      *)
(**********************************************************)

Definition apply_op (o:op) (arg:val) : option val :=
  match o , arg with
  | opAdd1   , (vConst (cNat n))      => Some (vConst (cNat (n + 1)))
  | opAdd1   , _                      => None
  | opSub1   , (vConst (cNat n))      => Some (vConst (cNat (n - 1)))
  | opSub1   , _                      => None
  | opStrLen , (vConst (cStr s))      => Some (vConst (cNat (String.length s)))
  | opStrLen , _                      => None
  | opNot    , (vConst (cBool false)) => Some (vConst (cBool true))
  | opNot    , _                      => Some (vConst (cBool false))
  | opIsNat  , (vConst (cNat _))      => Some (vConst (cBool true))
  | opIsNat  , _                      => Some (vConst (cBool false))
  | opIsStr  , (vConst (cStr _))      => Some (vConst (cBool true))
  | opIsStr  , _                      => Some (vConst (cBool false))
  | opIsProc , (vConst (cOp _))       => Some (vConst (cBool true))
  | opIsProc , (vAbs _ _ _)           => Some (vConst (cBool true))
  | opIsProc , _                      => Some (vConst (cBool false))
  | opIsZero , (vConst (cNat 0))      => Some (vConst (cBool true))
  | opIsZero , (vConst (cNat _))      => Some (vConst (cBool false))
  | opIsZero , _                      => None
  end.
Hint Unfold apply_op.

Fixpoint substitute (e:exp) (x:var) (v:val) : exp :=
  match e with
  | eVar y => if var_dec x y then (eVal v) else e
  | (eVal (vConst c)) => e
  | (eVal (vAbs y i e')) =>
    if var_dec x y then e
    else eVal (vAbs y i (substitute e' x v))
  | eApp e1 e2 => eApp (substitute e1 x v) (substitute e2 x v)
  | eIf e1 e2 e3 => eIf (substitute e1 x v)
                        (substitute e2 x v)
                        (substitute e3 x v)
  end.

Inductive Step : exp -> exp -> Prop :=
| S_App_Cong1 : forall e1 e1' e2,
    Step e1 e1' ->
    Step (eApp e1 e2) (eApp e1' e2)
| S_App_Cong2 : forall v e2 e2',
    Step e2 e2' ->
    Step (eApp (eVal v) e2) (eApp (eVal v) e2')
| S_App_Op : forall o v v',
    apply_op o v = Some v' ->
    Step (eApp (eVal (vOp o)) (eVal v)) (eVal v')
| S_App_Abs : forall i x body v e',
    e' = substitute body x v ->
    Step (eApp (eVal (vAbs x i body)) (eVal v)) e'
| S_If_Cong : forall e1 e1' e2 e3,
    Step e1 e1' ->
    Step (eIf e1 e2 e3) (eIf e1' e2 e3)
| S_If_False : forall e e',
    Step (eIf (eVal (vBool false)) e e') e'
| S_If_NonFalse : forall v e e',
    v <> (vBool false) ->
    Step (eIf (eVal v) e e') e.
Hint Constructors Step.


Inductive Steps : exp -> exp -> Prop :=
| S_Null : forall e,
    Steps e e
| S_Cons : forall e1 e2 e3,
    Step e1 e2 ->
    Steps e2 e3 ->
    Steps e1 e3.
Hint Constructors Steps.

Lemma S_Trans : forall e1 e2 e3,
    Steps e1 e2 ->
    Steps e2 e3 ->
    Steps e1 e3.
Proof.
  intros e1 e2 e3 H12.
  generalize dependent e3.
  induction H12.
  {
    crush.
  }
  {
    intros e4 H34.
    eapply S_Cons. eassumption.
    applyH. assumption.
  }
Qed.  
  
(**********************************************************)
(* Subtyping                                              *)
(**********************************************************)

Notation "x '∈' T" :=
  (Ensembles.In val T x) (at level 55, right associativity).
Notation "x '∉' T" :=
  (~ Ensembles.In val T x) (at level 55, right associativity).

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
Axiom interp_tTrue : tInterp tTrue = (Singleton val (vBool true)).
Hint Rewrite interp_tTrue.
Axiom interp_tFalse : tInterp tFalse = (Singleton val (vBool false)).
Hint Rewrite interp_tFalse.
Axiom interp_tNat_exists : forall (v:val),
    v ∈ (tInterp tNat) ->
    exists (n:nat), v = (vConst (cNat n)).
Axiom interp_tNat_full : forall (n:nat),
    (vConst (cNat n)) ∈ (tInterp tNat).
Hint Resolve interp_tNat_full.
Axiom interp_tStr_exists : forall (v:val),
    v ∈ (tInterp tStr) ->
    exists (s:string), v = (vConst (cStr s)).
Axiom interp_tStr_full : forall (s:string),
    (vConst (cStr s)) ∈ (tInterp tStr).
Hint Resolve interp_tStr_full.

Notation "A '⊆' B" :=
  (Included val A B) (at level 55, right associativity).

Definition Subtype (t1 t2:ty) : Prop := (tInterp t1) ⊆ (tInterp t2).


Definition IsEmpty (t: ty) := (tInterp t) = (Empty_set val).
Hint Unfold IsEmpty.

Axiom empty_dec : forall (t: ty), {IsEmpty t} + {~ IsEmpty t}.
Axiom domain : ty -> option ty.
Axiom codomain : ty -> option ty.

Axiom domain_tArrow : forall t1 t2, domain (tArrow t1 t2) = Some t1.
Axiom codomain_tArrow : forall t1 t2, codomain (tArrow t1 t2) = Some t2.

Lemma Subtype_refl : forall t, Subtype t t.
Proof. crush. Qed.

Lemma Subtype_trans : forall t1 t2 t3,
    Subtype t1 t2 ->
    Subtype t2 t3 ->
    Subtype t1 t3.
Proof.
  intros.
  unfold Subtype in *.
  crush.
Qed.

Lemma Subtype_tAnd_L : forall t1 t2 t3,
    Subtype t1 t2 ->
    Subtype (tAnd t1 t3) (tAnd t2 t3).
Proof.
  intros t1 t2 t3 H12.
  unfold Subtype.
  intros x Hx.
  crush.
  apply Intersection_inv in Hx.
  crush.
Qed.

Lemma Subtype_tAnd_LL : forall t1 t2 t3 t4,
    Subtype t1 t2 ->
    Subtype (tAnd t2 t3) t4 ->
    Subtype (tAnd t1 t3) t4.
Proof.
Admitted.

Lemma Subtype_Empty : forall t1 t2,
    Subtype t1 t2 ->
    IsEmpty t2 ->
    IsEmpty t1.
Proof.
  intros.
  unfold Subtype in *.
  unfold IsEmpty in *. rewrite H0 in H.
  crush.
Qed.

Lemma Subtype_tAnd_LFalse : forall t1 t2,
    Subtype (tAnd t1 tFalse) t2 ->
    Subtype (tAnd t1 tFalse) (tAnd t2 tFalse).
Proof.
Admitted.

Lemma Subtype_tAnd_LNotFalse : forall t1 t2,
    Subtype (tAnd t1 (tNot tFalse)) t2 ->
    Subtype (tAnd t1 (tNot tFalse)) (tAnd t2 (tNot tFalse)).
Proof.
Admitted.

Lemma Subtype_L_tAnd : forall t1 t2 t3,
    Subtype t1 t3 ->
    Subtype (tAnd t1 t2) t3.
Proof.
  intros.
  unfold Subtype in *.
  intros x Hx.
  rewrite interp_tAnd in Hx.
  apply Intersection_inv in Hx. crush.
Qed.

Inductive Subobj : gamma -> obj -> obj -> Prop :=
| SO_Refl : forall Γ o,
    Subobj Γ o o
| SO_Abs : forall Γ x y e e' i,
    Subobj Γ (oPath (pVal (vAbs x i e))) (oPath (pVal (vAbs y i e')))
| SO_Top : forall Γ o,
    Subobj Γ o oTop.
Hint Constructors Subobj.

Lemma Subobj_trans : forall Γ o1 o2 o3,
    Subobj Γ o1 o2 ->
    Subobj Γ o2 o3 ->
    Subobj Γ o1 o3.
Proof.
  intros Γ o1 o2 o3 H12.
  generalize dependent o3.
  induction H12; crush.
  inversion H; crush.
  inversion H; crush.
Qed.

Inductive WellFormedProp : gamma -> prop -> Prop :=
| WFP : forall Γ p,
    incl (fvsP p) (fvs Γ) ->
    WellFormedProp Γ p.
Hint Constructors WellFormedProp.



Inductive Proves : gamma -> prop -> Prop :=
| P_Atom : forall Γ p,
    In p Γ ->
    Proves Γ p
| P_Trivial : forall Γ,
    Proves Γ Trivial
| P_Combine : forall Γ x t1 t2,
    Proves Γ (Is x t1) ->
    Proves Γ (Is x t2) ->
    Proves Γ (Is x (tAnd t1 t2))
| P_Empty : forall Γ π p t,
    IsEmpty t ->
    Proves Γ (Is π t) ->
    incl (fvsP p) (fvs Γ) ->
    Proves Γ p
| P_Val : forall Γ v t,
    v ∈ (tInterp t) ->
    Proves Γ (Is (pVal v) t)
| P_Sub : forall Γ x t1 t2,
    Proves Γ (Is x t1) ->
    Subtype t1 t2 ->
    Proves Γ (Is x t2)
| P_Absurd : forall Γ p,
    Proves Γ Absurd ->
    incl (fvsP p) (fvs Γ) ->
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
    incl (fvsP p2) (fvs Γ) ->
    Proves Γ (Or p1 p2)
| P_OrI_R : forall Γ p1 p2,
    Proves Γ p2 ->
    incl (fvsP p1) (fvs Γ) ->
    Proves Γ (Or p1 p2).
Hint Constructors Proves.

Inductive Entails : list prop -> list prop -> Prop :=
| Ent : forall Γ Γ',
    Forall (Proves Γ) Γ' ->
    incl (fvs Γ') (fvs Γ) ->
    Entails Γ Γ'.
Hint Constructors Entails.

Lemma Proves_dec : forall Γ p,
    Proves Γ p \/ ~ Proves Γ p.
Proof.
Admitted.
  
Lemma P_Cut : forall Γ p q,
    Proves Γ p ->
    Proves (p::Γ) q ->
    Proves Γ q.
Proof.
Admitted.


Lemma P_Env_Cut : forall Γ Γ' p,
    Forall (Proves Γ) Γ' ->
    Proves Γ' p ->
    Proves Γ p.
Proof.
Admitted.


Lemma Proves_sound : ~ Proves [] Absurd.
Proof.
Admitted.

Lemma fvs_inP_inΓ : forall x p Γ,
    In x (fvsP p) ->
    In p Γ ->
    In x (fvs Γ).
Proof.
  intros x p Γ Hin1 Hin2.
  induction Γ.
  {
    inversion Hin2.
  }
  {
    inversion Hin2; subst.
    simpl.
    apply in_app_iff. left. auto.
    simpl.
    apply in_app_iff. right. auto.        
  }
Qed.

Hint Unfold incl.

Lemma fvs_incl : forall Γ Γ',
    incl Γ Γ' ->
    incl (fvs Γ) (fvs Γ').
Proof.
  intros Γ.
  induction Γ; crush.
  unfold incl. intros b Hb. apply in_app_iff in Hb. destruct Hb.
  assert (In a Γ') as HIn by
        (apply H; left; auto).
  eapply fvs_inP_inΓ. eassumption. assumption.
  apply IHΓ.
  unfold incl. intros x Hx.
  apply H.
  right; auto. assumption.
Qed.

Lemma P_Subset : forall Γ Γ' p,
    Proves Γ p ->
    incl Γ Γ' ->
    Proves Γ' p.
Proof with crush.
  intros Γ Γ' p Hproves.
  generalize dependent Γ'. 
  induction Hproves...
  {
    eapply P_Empty... assumption. 
    eapply incl_tran. eassumption.
    apply fvs_incl. assumption.
  }
  {
    eapply P_Sub...
  }
  {
    apply P_Absurd.
    applyH. auto.
    eapply incl_tran. eassumption.
    apply fvs_incl. assumption.
  }
  {
    eapply P_AndE_L...
  }
  {
    eapply P_AndE_R...
  }
  {
    eapply P_OrE...
  }
  {
    eapply P_OrI_L; auto. eapply incl_tran.
    eassumption. apply fvs_incl. assumption.
  }
  {
    eapply P_OrI_R; auto. eapply incl_tran.
    eassumption. apply fvs_incl. assumption.
  }
Qed.

Lemma Proves_fvs_incl : forall Γ p,
    Proves Γ p ->
    incl (fvsP p) (fvs Γ).
Proof.
  intros Γ p Hp.
  induction Hp; crush.
  {
    intros x Hx.
    eapply fvs_inP_inΓ; eauto.
  }
  {
    eapply incl_tran. eassumption.
    apply incl_app; crush.
  }
Qed.    
  

Definition isa (o:obj) (t:ty) : prop :=
  match o with
  | oPath π => Is π t
  | oTop => if empty_dec t then Absurd else Trivial
  end.
Hint Unfold isa.


Inductive WellFormedRes : gamma -> tres -> Prop :=
| WFR : forall Γ R,
    incl (fvsR R) (fvs Γ) ->
    WellFormedRes Γ R.
Hint Constructors WellFormedRes.

Inductive Subres : gamma -> tres -> tres -> Prop :=
| SR_Sub : forall Γ t1 p1 q1 o1 t2 p2 q2 o2,
    WellFormedRes Γ (Res t1 p1 q1 o1) ->
    Subtype t1 t2 ->
    Subobj Γ o1 o2 ->
    Proves ((isa o1 (tAnd t1 (tNot tFalse)))::p1::Γ) p2 ->
    Proves ((isa o1 (tAnd t1 tFalse))::q1::Γ) q2 ->
    WellFormedRes Γ (Res t2 p2 q2 o2) ->
    Subres Γ (Res t1 p1 q1 o1) (Res t2 p2 q2 o2).
Hint Constructors Subres.


Lemma Subobj_Weakening : forall Γ Γ' o1 o2,
    Subobj Γ o1 o2 ->
    incl Γ Γ' ->
    Subobj Γ' o1 o2.
Proof with crush.
  intros Γ Γ' o1 o2 Hsub Hincl.
  destruct Hsub...
Qed.

Lemma Subtype_tAnds_False_trans : forall t1 t2 t3,
    Subtype (tAnd t1 tFalse) t2 ->
    Subtype (tAnd t2 tFalse) t3 ->
    Subtype (tAnd t1 tFalse) t3.
Proof.
Admitted.
  
Lemma Proves_incl : forall Γ Γ',
    incl Γ' Γ ->
    Forall (Proves Γ) Γ'.
Proof.
Admitted.

Lemma Subres_refl : forall Γ R,
    WellFormedRes Γ R ->
    Subres Γ R R.
Proof.
  intros Γ R Hwfr.
  destruct R.
  apply SR_Sub; crush.
Qed.
  
Lemma Subres_trans : forall Γ R1 R2 R3,
    Subres Γ R1 R2 ->
    Subres Γ R2 R3 ->
    Subres Γ R1 R3.
Proof.
Admitted.

(**********************************************************)
(* Type System                                            *)
(**********************************************************)

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
  | opIsProc => predicate (tArrow tEmpty tAny)
  | opIsZero => tArrow tNat tBool
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
  | cBool false => (Res tFalse Absurd Trivial (oPath (pVal (vConst c))))
  | _ => (Res (const_type c) Trivial Absurd (oPath (pVal (vConst c))))
  end.
Hint Unfold const_tres.

Inductive InInterface : ty -> ty -> interface -> Prop :=
| InI_First : forall t1 t2 i,
    InInterface t1 t2 ((t1,t2)::i)
| InI_Rest : forall t1 t2 t3 t4 i,
    InInterface t1 t2 i ->
    InInterface t1 t2 ((t3,t4)::i).
Hint Constructors InInterface.

Fixpoint interface_ty (i:interface) : ty :=
  match i with
  | [] => tArrow tEmpty tAny
  | (t1,t2)::i' => (tAnd (tArrow t1 t2)
                         (interface_ty i'))
  end.
Hint Unfold interface_ty.

Fixpoint neg_interface_ty (i:interface) : ty :=
  match i with
  | [] => tAny
  | (t1,t2)::i' => (tAnd (tNot (tArrow t1 t2))
                         (neg_interface_ty i'))
  end.
Hint Unfold interface_ty.


Axiom pred_inv : ty -> ty -> (ty * ty).
(* Metafunction to determine what types a function
   is a predicate for. In another module we formally
   define and prove properties about such an algorithm.
   For this module, we just keep this abstract.  *)

Inductive TypeOf : gamma -> exp -> tres -> Prop :=
| T_Var : forall Γ x t R,
    Proves Γ (Is (pVar x) t) ->
    Subres Γ
           (Res t
                (Is (pVar x) (tAnd t (tNot tFalse)))
                (Is (pVar x) (tAnd t tFalse))
                (oPath (pVar x)))
           R ->
    WellFormedRes Γ R ->
    TypeOf Γ (eVar x) R 
| T_Const : forall Γ c R,
    Subres Γ (const_tres c) R ->
    WellFormedRes Γ R ->
    TypeOf Γ (eVal (vConst c)) R
| T_Abs : forall Γ x i i' e t R,
    ~ In x (fvs Γ) ->
    t = (tAnd (interface_ty i) (neg_interface_ty i')) ->
    ~ IsEmpty t ->
    (forall t1 t2,
        InInterface t1 t2 i ->
        TypeOf ((Is (pVar x) t1)::Γ) e (Res t2 Trivial Trivial oTop)) ->
    Subres Γ (Res t Trivial Absurd (oPath (pVal (vAbs x i e)))) R ->
    WellFormedRes Γ R ->
    TypeOf Γ (eVal (vAbs x i e)) R
| T_App : forall Γ e1 e2 t1 t2 o2 t tpos tneg R,
    TypeOf Γ e1 (Res t1 Trivial Trivial oTop) ->
    TypeOf Γ e2 (Res t2 Trivial Trivial o2) ->
    Subtype t1 (tArrow t2 t) ->
    pred_inv t1 t2 = (tpos , tneg) ->
    Subres Γ (Res t (isa o2 tpos) (isa o2 tneg) oTop) R ->
    WellFormedRes Γ R ->
    TypeOf Γ (eApp e1 e2) R
| T_If : forall Γ e1 e2 e3 t1 p1 q1 o1 R,
    TypeOf Γ e1 (Res t1 p1 q1 o1) ->
    TypeOf ((isa o1 (tAnd t1 (tNot tFalse)))::p1::Γ) e2 R ->
    TypeOf ((isa o1 (tAnd t1 tFalse))::q1::Γ) e3 R ->
    WellFormedRes Γ R ->
    TypeOf Γ (eIf e1 e2 e3) R.
Hint Constructors TypeOf.

Inductive TypeOfVal : val -> ty -> Prop :=
| TOV : forall v t,
    TypeOf [] (eVal v) (Res t Trivial Trivial oTop) ->
    TypeOfVal v t.
Hint Constructors TypeOfVal.

(* See Inv.v for details/proofs/etc about function inversion. *)
Axiom pred_inv_props : forall funty argty tpos tneg,
    pred_inv funty argty = (tpos, tneg) ->
    forall v1 v2 v3,
      TypeOfVal v1 funty ->
      TypeOfVal v2 argty ->
      Steps (eApp (eVal v1) (eVal v2)) (eVal v3) ->
      ((v3 <> (vBool false) /\ TypeOfVal v2 tpos)
       \/
       (v3 = (vBool false) /\ TypeOfVal v2 tneg)).


(*
  Consider fty ≤ fty' examples:

  1)  (A ∪ B) → C  ≤  A → C

  2)  (A → True)∩(¬A → False)  <:  Any → Bool

  And consider pred_inv(fty,  Any) = (tpos,  tneg)
  and          pred_inv(fty', Any) = (tpos', tneg')

  For example 1:
     pred_inv((A ∪ B) → C, Any) = ((A ∪ B), (A ∪ B))
     pred_inv(A → C,       Any) = (A, A)
     
     So fty ≤ fty', tpos' ≤ tpos, and tneg' ≤ tneg.
     
  For example 2:
     pred_inv((A → True)∩(¬A → False), Any) = (A, ¬A)
     pred_inv(Any → Bool,              Any) = (Any, Any)
     
     So fty ≤ fty', tpos ≤ tpos', and tneg ≤ tneg'.

*)


Axiom pred_inv_tNat_tNat :
  pred_inv (tArrow tNat tNat) tNat = (tNat, tEmpty).
Axiom pred_inv_tStr_tNat :
  pred_inv (tArrow tStr tNat) tStr = (tStr, tEmpty).
Axiom pred_inv_tNat_tBool :
  pred_inv (tArrow tNat tBool) tNat = (tNat, tNat).
Axiom pred_inv_predicate : forall t,
  pred_inv (predicate t) tAny = (t, (tNot t)).

Axiom domain_predicate : forall t, domain (predicate t) = Some tAny.
Axiom codomain_predicate : forall t, codomain (predicate t) = Some tBool.


Lemma Pred_pos_arg : forall funty argty tpos tneg,
    pred_inv funty argty = (tpos, tneg) ->
    Subtype tpos argty.
Proof.
Admitted.

Lemma Pred_neg_arg : forall funty argty tpos tneg,
    pred_inv funty argty = (tpos, tneg) ->
    Subtype tneg argty.
Proof.  
Admitted.
  

(**********************************************************)
(* Soundness                                              *)
(**********************************************************)

Lemma TypeOf_arrow_val : forall v t t1 t2,
    TypeOf [] (eVal v) (Res t Trivial Trivial oTop) ->
    Subtype t (tArrow t1 t2) ->
    (exists o, v = (vOp o))
    \/ (exists x i e, v = (vAbs x i e)).
Proof.
Admitted.

Lemma TypeOf_Op_Subtype : forall Γ o t,
    TypeOf Γ (eVal (vOp o)) (Res t Trivial Trivial oTop) ->
    Subtype (op_type o) t.
Proof.
Admitted.

Lemma Subtype_tArrow_dom : forall t1 t2 t3 t4,
    Subtype (tArrow t1 t2) (tArrow t3 t4) ->
    Subtype t3 t1.
Proof.
Admitted.

Lemma Subtype_tArrow_cdom : forall t1 t2 t3 t4,
    Subtype (tArrow t1 t2) (tArrow t3 t4) ->
    Subtype t2 t4.
Proof.
Admitted.

Lemma tArrow_R_dom_sub : forall t1 t2 t t',
    Subtype t (tArrow t1 t2) ->
    domain t = Some t' ->
    Subtype t1 t'.
Proof.
Admitted.

Lemma tArrow_R_cdom_sub : forall t1 t2 t t',
    Subtype t (tArrow t1 t2) ->
    codomain t = Some t' ->
    Subtype t' t2.
Proof.
Admitted.


Lemma TypeOf_Sub_type : forall Γ e t1 t2 p q o,
    TypeOf Γ e (Res t1 p q o) ->
    Subtype t1 t2 ->
    TypeOf Γ e (Res t2 p q o).
Proof.
Admitted.


Lemma TypeOf_tNat : forall Γ v p q o,
    TypeOf Γ (eVal v) (Res tNat p q o) ->
    exists n, v = vConst (cNat n).
Proof.
Admitted.

Lemma TypeOf_cNat_obj : forall Γ n t p q o,
    TypeOf Γ (eVal (vNat n)) (Res t p q o) ->
    o = oTop.
Proof.
Admitted.
  
Lemma TypeOf_tStr : forall Γ v p q o,
    TypeOf Γ (eVal v) (Res tStr p q o) ->
    exists s, v = vConst (cStr s).
Proof.
Admitted.

Lemma TypeOf_tTrue : forall Γ v p q o,
    TypeOf Γ (eVal v) (Res tTrue p q o) ->
    v = vConst (cBool true).
Proof.
Admitted.

Lemma TypeOf_tFalse : forall Γ v p q o,
    TypeOf Γ (eVal v) (Res tFalse p q o) ->
    v = vConst (cBool false).
Proof.
Admitted.

Lemma Empty_neq_tBase : forall bty1 bty2,
    bty1 <> bty2 ->
    IsEmpty (tAnd (tBase bty1) (tBase bty2)).
Proof.
Admitted.

Lemma tNat_not_tFalse_not_empty : ~ IsEmpty (tAnd tNat (tNot tFalse)).
Proof.
Admitted.

Lemma tNat_tFalse_empty : IsEmpty (tAnd tNat tFalse).
Proof.
Admitted.

Lemma tStr_not_tFalse_not_empty : ~ IsEmpty (tAnd tStr (tNot tFalse)).
Proof.
Admitted.

Lemma tStr_tFalse_empty : IsEmpty (tAnd tStr tFalse).
Proof.
Admitted.


Lemma TypeOf_Nat_lower_bound : forall Γ n t p q o,
    TypeOf Γ (eVal (vNat n)) (Res t p q o) ->
    Subtype tNat t.
Proof.
Admitted.

Lemma tNat_not_empty : forall t,
    Subtype tNat t ->
    ~ IsEmpty t.
Proof.
Admitted.

Lemma tNat_and_tFalse_not_empty : forall t,
    Subtype tNat t ->
    ~ IsEmpty (tAnd t (tNot tFalse)).
Proof.
Admitted.



Lemma Progress_App_op : forall t1 t2 o2 t tpos tneg R v2 o,
    TypeOf [] (eVal v2) (Res t2 Trivial Trivial o2) ->
    TypeOf [] (eVal (vOp o)) (Res t1 Trivial Trivial oTop) ->
    pred_inv t1 t2 = (tpos, tneg) ->
    WellFormedRes [] R ->
    Subres [] (Res t (isa o2 tpos) (isa o2 tneg) oTop) R ->
    Subtype (op_type o) (tArrow t2 t) ->
    (exists e' : exp, Step (eApp (eVal (vOp o)) (eVal v2)) e').
Proof with crush.
  intros funty argty o2 t tpos tneg R v2 o Hfunty Hargty
         Hpred Hwfr Hsres Hargsub.
  destruct o; simpl in *.
  { (* opAdd1 *)
    assert (Subtype argty tNat) as Hargty2
        by (eapply Subtype_tArrow_dom; eassumption).
    assert (exists n, v2 = vConst (cNat n)) as Hex
        by (eapply TypeOf_tNat; eapply TypeOf_Sub_type; eauto; crush).
    destruct Hex as [n Hn]; subst.
    exists (eVal (vNat (n + 1))).
    apply S_App_Op...
  }
  { (* opSub1 *)
    assert (Subtype argty tNat) as Hargty2
        by (eapply Subtype_tArrow_dom; eassumption).
    assert (exists n, v2 = vConst (cNat n)) as Hex
        by (eapply TypeOf_tNat; eapply TypeOf_Sub_type; eauto; crush).
    destruct Hex as [n Hn]; subst.
    exists (eVal (vNat (n - 1))).
    apply S_App_Op...
  }
  { (* opStrLen *)
    assert (Subtype argty tStr) as Hargty2
        by (eapply Subtype_tArrow_dom; eassumption).
    assert (exists s, v2 = vConst (cStr s)) as Hex
        by (eapply TypeOf_tStr; eapply TypeOf_Sub_type; eauto; crush).
    destruct Hex as [s Hs]; subst.
    exists (eVal (vNat (String.length s))).
    apply S_App_Op...
  }
  { (* opNot *)
    destruct (val_dec v2 (vBool false)) as [Hfalse | Hnonfalse].
    {
      exists (eVal (vBool true)).
      apply S_App_Op...
    }
    {
      exists (eVal (vBool false)).
      apply S_App_Op; destruct v2; simpl;
        repeat first[matchcase | ifcase | crush]...
    }
  }
  { (* opIsNat *)
    destruct v2.
    destruct c; try solve[exists (eVal (vBool false));
                                 apply S_App_Op; simpl;
                                 repeat first[matchcase | ifcase | crush]].
    { (* vNat *)
      exists (eVal (vBool true)); apply S_App_Op...
    }
    { (* vAbs *)
      exists (eVal (vBool false)).
      apply S_App_Op; simpl;
        repeat first[matchcase | ifcase | crush]...
    }
  }
  { (* opIsStr *)
    destruct v2.
    destruct c; try solve[exists (eVal (vBool false));
                                 apply S_App_Op; simpl;
                                 repeat first[matchcase | ifcase | crush]].
    { (* vStr *)
      exists (eVal (vBool true)); apply S_App_Op...
    }
    { (* vAbs *)
      exists (eVal (vBool false)).
      apply S_App_Op; simpl;
        repeat first[matchcase | ifcase | crush]...
    }
  }
  { (* opIsProc *)
    destruct v2.
    destruct c; try solve[exists (eVal (vBool false));
                                 apply S_App_Op; simpl;
                                 repeat first[matchcase | ifcase | crush]].
    { (* vOp *)
      exists (eVal (vBool true)); apply S_App_Op...
    }
    { (* vAbs *)
      exists (eVal (vBool true)); apply S_App_Op...
    }
  }
  { (* opIsZero *)
    assert (Subtype argty tNat) as Hargty2
        by (eapply Subtype_tArrow_dom; eassumption).
    assert (exists n, v2 = vConst (cNat n)) as Hex
        by (eapply TypeOf_tNat; eapply TypeOf_Sub_type; eauto; crush).
    destruct Hex as [n Hn]; subst.
    destruct n.
    exists (eVal (vBool true)); apply S_App_Op...
    exists (eVal (vBool false)); apply S_App_Op...
  }
Qed.


Lemma Progress : forall Γ e R,
    Γ = [] ->
    TypeOf Γ e R ->
    (exists v, e = (eVal v)) \/ (exists e', Step e e').
Proof with crush.
  intros Γ e R Hlive Htype.
  induction Htype; subst.
  { (* T_Var *)
    assert (incl (fvsP (Is (pVar x) t)) (fvs [])) as Hcrazy.
    {
      apply Proves_fvs_incl. assumption.
    }
    simpl in *.
    unfold incl in Hcrazy.
    assert (In x []) as crazy.
    {
      apply Hcrazy. left; auto.
    }
    inversion crazy.
  }
  {
    left. exists (vConst c). reflexivity.
  }
  {
    left. exists (vAbs x i e). reflexivity.
  }
  {
    right. intuition.
    {
      match goal with
      | [H : (exists _, e1 = eVal _) |- _] =>  destruct H as [v1 Hv1]
      end.
      match goal with
      | [H : (exists _, e2 = eVal _) |- _] =>  destruct H as [v2 Hv2]
      end.
      subst.
      assert ((exists o : op, v1 = (vOp o))
              \/ (exists x i e, v1 = vAbs x i e))
        as Hv1opts.
      {
        eapply TypeOf_arrow_val. eassumption. eassumption.
      }
      destruct Hv1opts as [[o Ho] | [x [i [e Habs]]]]; subst.
      { 
        eapply Progress_App_op; eauto.
        eapply Subtype_trans.
        eapply TypeOf_Op_Subtype. eassumption. assumption.
      }
      { (* (vAbs x i e) *)
        exists (substitute e x v2). crush.
      }
    }
    {
      match goal with
      | [H : (exists _, Step _ _) |- _]
        =>  destruct H as [e1' Hstep1]
      end.
      exists (eApp e1' e2). apply S_App_Cong1...
    }
    {
      match goal with
      | [H : (exists _, _ = eVal _) |- _]
        =>  destruct H as [v1 Hv1]
      end.
      subst.
      match goal with
      | [H : (exists _, Step _ _) |- _]
        =>  destruct H as [e2' Hstep2]
      end.
      exists (eApp (eVal v1) e2'). apply S_App_Cong2...
    }
    {
      match goal with
      | [H : (exists _, Step _ _) |- _]
        =>  destruct H as [e1' Hstep1]
      end.
      exists (eApp e1' e2). apply S_App_Cong1...
    }
  }
  {
    intuition.
    match goal with
    | [H : (exists _, _ = eVal _) |- _]
      =>  destruct H as [v1 Hv1]
    end.
    subst.
    destruct (val_dec v1 (vBool false)) as [Htrue | Hfalse].
    {
      subst. right. exists e3. apply S_If_False.
    }
    {
      right. exists e2. apply S_If_NonFalse...
    }
    match goal with
    | [H : (exists _, Step _ _) |- _]
      =>  destruct H as [e1' Hstep1]
    end.
    right. exists (eIf e1' e2 e3). apply S_If_Cong...
  }
Qed.  

Lemma Typeof_type_subsume : forall Γ e t p q o t',
    TypeOf Γ e (Res t p q o) ->
    Subtype t t' ->
    TypeOf Γ e (Res t' p q o).
Proof with crush.
  intros Γ e t p q o t' Htype Hsub.
  remember (Res t p q o) as R.
  induction Htype; subst.
  { (* eVar *)
    assert (WellFormedRes Γ (Res t' p q o)) as Hwfr
        by match goal with
           | [ H : WellFormedRes _ _ |- _]
             => inversion H; crush
           end.
    eapply T_Var... eassumption.
    eapply Subres_trans... eassumption.
    apply SR_Sub...    
  }
  { (* vConst *)
    assert (WellFormedRes Γ (Res t' p q o)) as Hwfr
        by match goal with
           | [ H : WellFormedRes _ _ |- _]
             => inversion H; crush
           end.
    eapply T_Const... 
    eapply Subres_trans... eassumption.
    apply SR_Sub...    
  }
  { (* vAbs *)
    assert (WellFormedRes Γ (Res t' p q o)) as Hwfr
        by match goal with
           | [ H : WellFormedRes _ _ |- _]
             => inversion H; crush
           end.
    eapply T_Abs...
    applyH. eassumption.
    eapply Subres_trans... eassumption.
    apply SR_Sub...
  }
  { (* eApp *)
    assert (WellFormedRes Γ (Res t' p q o)) as Hwfr
        by match goal with
           | [ H : WellFormedRes _ _ |- _]
             => inversion H; crush
           end.
    eapply T_App...
    assumption. eassumption. eassumption.
    eapply Subres_trans... eassumption.
    apply SR_Sub...
  }
  { (* eIf *)
    assert (WellFormedRes Γ (Res t' p q o)) as Hwfr
        by match goal with
           | [ H : WellFormedRes _ _ |- _]
             => inversion H; crush
           end.
    eapply T_If.
    eassumption. applyH... applyH...
    assumption.
  }
Qed.


Inductive SimpleRes : tres -> Prop :=
| SRes : forall t p q,
    (p = Trivial \/ p = Absurd) ->
    (q = Trivial \/ q = Absurd) ->
    SimpleRes (Res t p q oTop).
Hint Constructors SimpleRes.

Lemma TypeOf_minimal : forall e R,
    TypeOf [] e R ->
    exists R', Subres [] R' R /\ SimpleRes R'.
Proof.
Admitted.

Lemma TypeOf_oTop : forall e t p q o,
    TypeOf [] e (Res t p q o) ->
    o = oTop.
Proof.
Admitted.

Lemma T_Subsume : forall Γ e R R',
    TypeOf Γ e R ->
    Subres Γ R R' ->
    TypeOf Γ e R'.
Proof.
Admitted.

Lemma SimpleRes_WellFormedRes : forall Γ R,
    SimpleRes R ->
    WellFormedRes Γ R.
Proof.
Admitted.

Lemma TypeOf_WellFormedRes : forall Γ e R,
    TypeOf Γ e R ->
    WellFormedRes Γ R.
Proof.
Admitted.

Lemma TypeOfVal_lower_bound : forall c t p q o t',
    TypeOf [] (eVal (vConst c)) (Res t p q o) ->
    const_type c = t' ->
    Subtype t' t.
Proof.
Admitted.

Lemma TypeOfVal_NonEmpty : forall v t,
    TypeOfVal v t ->
    ~ IsEmpty t.
Proof.
Admitted.


Lemma pred_single_tArrow_R : forall t,
  Subtype (predicate t) (tArrow tAny tBool).
Proof.
Admitted.

Lemma some_tNat_dec : forall v,
    (exists n, v = (vConst (cNat n)))
    \/ forall n, ~ v = (vConst (cNat n)).
Proof.
Admitted.

Lemma some_tStr_dec : forall v,
    (exists s, v = (vConst (cStr s)))
    \/ forall s, ~ v = (vConst (cStr s)).
Proof.
Admitted.

Lemma some_Proc_dec : forall v,
    (exists o, v = (vConst (cOp o)))
    \/
    (exists x i e, v = (vAbs x i e))
    \/
    ((forall o, v <> (vConst (cOp o)))
     /\ (forall x i e, v <> (vAbs x i e))).
Proof.
Admitted.



Lemma pred_inv_supertype : forall fty t1 t2 tpos tneg,
    pred_inv fty t1 = (tpos, tneg) ->
    Subtype fty (tArrow t1 t2) ->
    ((IsEmpty tpos -> IsEmpty (tAnd t2 (tNot tFalse)))
     /\
     (IsEmpty tneg -> IsEmpty (tAnd t2 tFalse))).
Proof.
Admitted.
(* Proof:

  f ∈ fty
  v ∈ t1

  and (pred_inv fty t1) = (tpos, tneg)

  then
  if (f v) = v' and v' ≠ false then v ∈ tpos
  if (f v) = false             then v ∈ tneg

  - - - - - - - - - - - - - - - -

  if fty ≤ t1 → t2, then (f v) ∈ t2

  - - - - - - - - - - - - - - - -

  (Conclusion 1)
  if tpos = ∅, can there ∃b ∈ (t2 ∩ ¬False)? if so then
  there exists a g ∈ t1 → t2 s.t. for some v ∈ t1,
  (g v) = b, but b ∈ tpos then (since it is in (t2 ∩ ¬False))
  which is impossible, so (t2 ∩ ¬False) = ∅.
  

  (Conclusion 2)
  if tneg = ∅, can there ∃b ∈ (t2 ∩ False)? if so then
  there exists a g ∈ t1 → t2 s.t. for some v ∈ t1,
  (g v) = b, but b ∈ tneg then (since it is in (t2 ∩ False))
  which is impossible, so (t2 ∩ False) = ∅.

 *)


Lemma empty_tAnd_L : forall t1 t2,
    IsEmpty t1 ->
    IsEmpty (tAnd t1 t2).
Proof.
Admitted.

Lemma TypeOf_tArrow_body : forall Γ x i body t1 t2 p q o,
    TypeOf Γ (eVal (vAbs x i body)) (Res (tArrow t1 t2) p q o) ->
    TypeOf ((Is (pVar x) t1)::Γ) body (Res t2 p q o).
Proof.
Admitted.


Lemma Subres_weakening : forall Γ R1 R2 x t,
    Subres (Is (pVar x) t :: Γ) R1 R2 ->
    ~ In x (fvs Γ) ->
    WellFormedRes Γ R1 ->
    WellFormedRes Γ R2 ->
    Subres Γ R1 R2.
Proof.
Admitted.

Lemma Subres_weaken : forall Γ p R1 R2,
    Subres Γ R1 R2 ->
    Subres (p::Γ) R1 R2.
Proof.
Admitted.

Lemma Proves_not_free_sub : forall x Γ t t',
    ~ In x (fvs Γ) ->
    Proves (Is (pVar x) t :: Γ) (Is (pVar x) t') ->
    Subtype t t'.
Proof.
Admitted.

Lemma TypeOfVal_False : forall t,
    TypeOfVal (vBool false) t ->
    Subtype tFalse t.
Proof.
Admitted.

Lemma WellFormed_then : forall Γ t p q o,
    WellFormedRes Γ (Res t p q o) ->
    incl (fvsP p) (fvs Γ).
Proof. Admitted.
Lemma WellFormed_else : forall Γ t p q o,
    WellFormedRes Γ (Res t p q o) ->
    incl (fvsP q) (fvs Γ).
Proof. Admitted.
Lemma WellFormed_obj : forall Γ t p q o,
    WellFormedRes Γ (Res t p q o) ->
    incl (fvsO o) (fvs Γ).
Proof. Admitted.

Lemma NoAbsurd_Is_Val : forall Γ v x t,
    TypeOfVal v t ->
    ~ Proves Γ Absurd ->
    ~ Proves (Is x t :: Γ) Absurd.
Proof.
Admitted.

Lemma Proves_lemma3 : forall y t t1 Γ,
    Subtype tFalse t ->
    ~ Proves (Is y t1 :: Γ) Absurd ->
    Proves (Is y (tAnd t tFalse)
               :: Is y (tAnd t tFalse)
               :: Is y t1
               :: Γ)
           Absurd ->
    False.
Proof.
Admitted.

Lemma Subtype_tFalse_tAnd_trans : forall t t',
    Subtype tFalse t ->
    Subtype (tAnd t tFalse) t' ->
    Subtype tFalse t'.
Proof.
Admitted.

Lemma TypeOfVal_TypeOf : forall Γ v t,
    TypeOfVal v t ->
    TypeOf Γ (eVal v) (Res t Trivial Trivial oTop).
Proof.
Admitted.

Lemma TypeOfVal_Sub : forall v t t',
    TypeOfVal v t ->
    Subtype t t' ->
    TypeOfVal v t'.
Proof.
Admitted.

Lemma T_Empty_env : forall Γ v t,
    TypeOfVal v t ->
    TypeOf Γ (eVal v) (Res t Trivial Trivial oTop).
Proof.
Admitted.

Lemma Proves_lemma4 : forall y t1 t Γ p,
    Proves (isa (oPath (pVar y)) (tAnd t (tNot tFalse))
                :: Is (pVar y) (tAnd t (tNot tFalse))
                :: Is (pVar y) t1
                :: Γ)
           p -> 
    Proves (Is (pVar y) t1
               :: isa oTop (tAnd t (tNot tFalse))
               :: Trivial
               :: Γ)
           p.
Proof.
Admitted.
Lemma Proves_lemma5 : forall y t1 t Γ q,
    Proves  (isa (oPath (pVar y)) (tAnd t tFalse)
                 :: Is (pVar y) (tAnd t tFalse)
                 :: Is (pVar y) t1
                 :: Γ)
            q ->
    Proves (Is (pVar y) t1 :: isa oTop (tAnd t tFalse) :: Trivial :: Γ) q.
Proof.
Admitted.

Lemma Proves_lemma6 : forall Γ t1 t y,
    ~ IsEmpty t ->
    ~ Proves (Is (pVar y) t1 :: Γ) Absurd ->
    (~ (Proves (isa (oPath (pVar y)) (tAnd t (tNot tFalse))
                    :: Is (pVar y) (tAnd t (tNot tFalse))
                    :: Is (pVar y) t1
                    :: Γ)
               Absurd)
     \/ ~ (Proves (isa (oPath (pVar y)) (tAnd t tFalse)
                       :: Is (pVar y) (tAnd t tFalse)
                       :: Is (pVar y) t1
                       :: Γ)
                  Absurd)).
Proof.
Admitted.

Lemma NonEmpty_floor : forall t1 t2,
    Subtype t1 t2 ->
    ~ IsEmpty t1 ->
    ~ IsEmpty t2.
Proof.
Admitted.

Lemma val_Is_dec : forall v t,
    {TypeOfVal v t} + {TypeOfVal v (tNot t)}.
Proof.
Admitted.


Fixpoint eraseP (p:prop) (x:var) (v:val) : prop :=
  match p with
   | Trivial => Trivial
   | Absurd => Absurd
   | Is π t => if path_dec (pVar x) π
               then if val_Is_dec v t
                    then Trivial
                    else Absurd
               else Is π t
   | And p q => And (eraseP p x v) (eraseP q x v)
   | Or p q  => Or (eraseP p x v) (eraseP q x v)
  end.

Definition eraseO (o:obj) (x:var) (v:val) : obj :=
  match o with
  | oTop => oTop
  | oPath π => if path_dec (pVar x) π
               then oPath (pVal v)
               else oPath π
  end.

Definition eraseR (R:tres) (x:var) (v:val) : tres :=
  match R with
  | Res t p q o => Res t (eraseP p x v) (eraseP q x v) (eraseO o x v)
  end.

Fixpoint eraseΓ (Γ:list prop) (x:var) (v:val) : list prop :=
  match Γ with
  | [] => []
  | p::ps => (eraseP p x v)::(eraseΓ ps x v)
  end.

Lemma incl_dedup_cons : forall A (x:A) l1 l2,
    incl l1 (x :: x :: l2) ->
    incl l1 (x :: l2).
Proof.
Admitted.

Lemma incl_eraseP : forall p x t Γ,
    incl (fvsP p) (x :: fvs Γ) ->
    incl (fvsP (eraseP p x t)) (fvs Γ).
Proof.
Admitted.

Lemma Proves_weakening_cons : forall p q Γ,
    Proves Γ q ->
    Proves (p::Γ) q.
Proof.
Admitted.

Lemma Proves_swap_head : forall p q r Γ,
    Proves (p::q::Γ) r ->
    Proves (q::p::Γ) r.
Proof.
Admitted.

Lemma Proves_combine_Is_tAnd : forall x t t1 t' p Γ,
    Subtype t1 t ->
    Proves (Is x (tAnd t t') :: Is x t1 :: Γ) p ->
    Proves (Is x (tAnd t1 t') :: Γ) p.
Proof.
Admitted.
Lemma eraseP_false : forall x t Γ p,
    Proves (Is (pVar x) (tAnd t tFalse) :: Γ) p ->
    Proves Γ (eraseP p x (vConst (cBool false))).
Proof.
Admitted.
Lemma eraseP_nonfalse : forall x t Γ p v,
    Proves (Is (pVar x) (tAnd t (tNot tFalse)) :: Γ) p ->
    v <> (vConst (cBool false)) ->
    Proves Γ (eraseP p x v).
Proof.
Admitted.
Lemma WellFormedRes_eraseR : forall Γ x t v R,
    WellFormedRes (Is (pVar x) t :: Γ) R ->
    WellFormedRes Γ (eraseR R x v).
Proof.
Admitted.

Lemma TypeOf_Val_NonFalse : forall v t Γ,
    TypeOfVal v t ->
    v <> vConst (cBool false) ->
    TypeOf Γ (eVal v) (Res t Trivial Absurd (oPath (pVal v))).
Proof.
Admitted.

Lemma Proves_neq_cons : forall x y t1 t2 Γ,
    ~ In x (fvs Γ) ->
    Proves ((Is (pVar x) t1)::Γ) (Is (pVar y) t2) ->
    x <> y ->
    Proves Γ (Is (pVar y) t2).
Proof.
Admitted.

Lemma eraseR_Subres : forall x t v Γ R R',
    TypeOfVal v t ->
    ~ In x (fvs Γ) ->
    Subres (Is (pVar x) t :: Γ) R R' ->
    ~ In x (fvsR R) ->
    Subres Γ R (eraseR R' x v).
Proof.
Admitted.

Lemma WellFormedRes_const : forall Γ c,
    WellFormedRes Γ (const_tres c).
Proof.
Admitted.

Lemma WellFormedRes_weakening : forall p Γ R,
    WellFormedRes Γ R ->
    WellFormedRes (p::Γ) R.
Proof.
Admitted.


Lemma Proves_eraseP : forall Γ x t p v,
    ~ In x (fvs Γ) ->
    TypeOfVal v t ->
    Proves (Is (pVar x) t :: Γ) p ->
    Proves Γ (eraseP p x v).
Proof.
Admitted.
(* Proof:
Since x only appears in the prop (Is x t), then all provable
atoms (Is x t') in p are provable because t ≤ t', so when we
erase all occurrances of x with v, all of the provable
statements will become Trivial and the non-provable will
become Absurd, and thus Proves Γ (eraseP p x v).*)

Lemma Proves_weaken_triv : forall Γ p,
    Proves Γ p ->
    Proves (Trivial :: Γ) p.
Proof.
Admitted.

Lemma Proves_strengthen_triv : forall Γ p,
    Proves (Trivial :: Γ) p ->
    Proves Γ p.
Proof.
Admitted.


Lemma Proves_tAnd_L : forall π t1 t2 Γ p,
    Proves (Is π t1 :: Is π t2 :: Γ) p ->
    Proves (Is π (tAnd t1 t2) :: Γ) p.
Proof.
Admitted.

Lemma var_dec_if : forall T x (e1 e2:T),
    (if var_dec x x then e1 else e2) = e1.
Proof.
  intros.
  ifcase; crush.
Qed.

Lemma eraseO_pVar : forall x v,
    (eraseO (oPath (pVar x)) x v) = (oPath (pVal v)).
Proof.
Admitted.

Lemma Proves_eraseP_val1 : forall x Γ p v t1,
    Proves (Is (pVar x) t1::Γ) p ->
    Proves ((Is (pVal v) t1)::Γ) (eraseP p x v).
Proof.
Admitted.

Lemma Proves_eraseP_val2 : forall x Γ p v t1 t2,
    Proves (Is (pVar x) (tAnd t1 t2)::Γ) p ->
    TypeOfVal v t2 ->
    Proves ((Is (pVal v) t1)::Γ) (eraseP p x v).
Proof.
Admitted.

Lemma eraseO_neq : forall o x v t,
    o <> oPath (pVar x) ->
    (isa (eraseO o x v) t) = (isa o t).
Proof.
Admitted.

Lemma WFR_lemma1 : forall Γ t o t1 t2 x v,
    WellFormedRes
      Γ (eraseR (Res t (isa o t1) (isa o t2) oTop) x v) ->
    WellFormedRes
      Γ (Res t (isa (eraseO o x v) t1) (isa (eraseO o x v) t2) oTop).
Proof.
Admitted.

Lemma not_In_lemma1 : forall o x t Γ,
    ~ In x (fvs Γ) ->
    o <> oPath (pVar x) ->
    ~ In x (fvsP (isa o t) ++ fvs Γ).
Proof.
Admitted.

Lemma Proves_type_entails : forall Γ Γ' x v p,
    Proves Γ p ->
    Entails (eraseΓ Γ' x v) (eraseΓ Γ x v) ->
    Proves Γ' p.
Proof.
Admitted.

Lemma Entails_erase_head_member : forall Γ1 Γ2 p x v,
    Entails (eraseΓ (p::Γ1) x v) (eraseΓ Γ2 x v) ->
    Entails (eraseΓ (p::Γ1) x v) (eraseΓ (p::Γ2) x v).
Proof.
Admitted.

Lemma Entails_erase_weaken : forall Γ1 Γ2 p x v,
    Entails (eraseΓ Γ1 x v) (eraseΓ Γ2 x v) ->
    Entails (eraseΓ (p::Γ1) x v) (eraseΓ Γ2 x v).
Proof.
Admitted.

Lemma WellFormedRes_erase_entails : forall Γ Γ' R x v t,
    WellFormedRes Γ R ->
    Entails (eraseΓ (Is (pVar x) t :: Γ') x v)
            (eraseΓ Γ x v) ->
    WellFormedRes (Is (pVar x) t :: Γ') R.
Proof.
Admitted.

Lemma Subres_erase_entails : forall Γ Γ' R1 R2 x v t,
    Subres Γ R1 R2 ->
    Entails (eraseΓ (Is (pVar x) t :: Γ') x v)
            (eraseΓ Γ x v) ->
    Subres (Is (pVar x) t :: Γ') R1 R2.
Proof.
Admitted.

Lemma Proves_Entails_lemma1 : forall z tv v Γ Γ' p1 p1',
    Entails (eraseΓ (Is (pVar z) tv :: Γ') z v) (eraseΓ Γ z v) ->
    Proves (p1' :: Γ') (eraseP p1 z v) ->
    Entails (eraseΓ (Is (pVar z) tv :: p1' :: Γ') z v)
            (eraseΓ (p1 :: Γ) z v).
Proof.
Admitted.

Lemma not_In_Wf_then : forall z Γ' t p q o,
    ~ In z (fvs Γ') ->
    WellFormedRes Γ' (Res t p q o) ->
    ~ In z (fvs (p::Γ')).
Proof.
Admitted.

Lemma not_In_Wf_else : forall z Γ' t p q o,
    ~ In z (fvs Γ') ->
    WellFormedRes Γ' (Res t p q o) ->
    ~ In z (fvs (q::Γ')).
Proof.
Admitted.

Lemma TypeOf_Entails_body : forall x Γ Γ' v tv t1 e t2,
    TypeOfVal v tv ->
    TypeOf (Is (pVar x) t1 :: Γ) e (Res t2 Trivial Trivial oTop) ->
    Entails (eraseΓ (Is (pVar x) tv :: Γ') x v) (eraseΓ Γ x v) ->
    ~ In x (fvs Γ) ->
    ~ In x (fvs Γ') ->
    TypeOf (Is (pVar x) t1 :: Γ') e (Res t2 Trivial Trivial oTop).
Proof.
Admitted.

Lemma Subres_entails_eraseR : forall Γ Γ' x i i' e R v tv,
    Subres Γ
           (Res (tAnd (interface_ty i) (neg_interface_ty i'))
                Trivial Absurd
                (oPath (pVal (vAbs x i e))))
           R ->
    Entails (eraseΓ (Is (pVar x) tv :: Γ') x v) (eraseΓ Γ x v) ->
    ~ In x (fvs Γ) ->
    ~ In x (fvs Γ') ->
    Subres Γ'
           (Res (tAnd (interface_ty i) (neg_interface_ty i')) Trivial Absurd
                (oPath (pVal (vAbs x i e)))) (eraseR R x v).
Proof.
Admitted.

Lemma Entails_erase_swap_left : forall p q Γ x v Γ',
    Entails (eraseΓ (q::p::Γ) x v)
            (eraseΓ Γ' x v) ->
    Entails (eraseΓ (p::q::Γ) x v)
            (eraseΓ Γ' x v).
Proof.
Admitted.

Lemma not_In_erase_incl : forall Γ Γ' x z v t,
    ~ In x (fvs Γ) ->
    z <> x ->
    incl (fvs (eraseΓ Γ z v)) (fvs (eraseΓ (Is (pVar z) t :: Γ') z v)) ->
    ~ In x (fvs Γ').
Proof.
Admitted.

Lemma Proves_Entails1 : forall z t1 v tv q Γ Γ',
    Proves (isa (oPath (pVar z)) t1 :: Γ) q ->
    Entails (eraseΓ (Is (pVar z) tv :: Γ') z v) (eraseΓ Γ z v) ->
    TypeOfVal v tv ->
    ~ In z (fvs Γ') ->
    Proves (Is (pVar z) t1 :: Is (pVar z) tv :: Γ') q.
Proof.
Admitted.

Lemma incl_fvsP_eraseP1 : forall x v t1 t2 Γ' Γ p,
    Entails (eraseΓ (Is (pVar x) t1 :: Γ') x v) (eraseΓ Γ x v) ->
    Proves (Absurd :: Is (pVar x) t2 :: Γ) p ->
    incl (fvsP (eraseP p x v)) (fvs Γ').
Proof.
Admitted.


Lemma Proves_swap : forall p q Γ r,
    Proves (p::q::Γ) r ->
    Proves (q::p::Γ) r.
Proof.
Admitted.

Lemma isa_oTop_options : forall t,
    (isa oTop t = Trivial) \/ (isa oTop t = Absurd).
Proof.
Admitted.
Lemma incl_fvsP_eraseP2 : forall z v tv Γ Γ' t p o,
    Entails (eraseΓ (Is (pVar z) tv :: Γ') z v) (eraseΓ Γ z v) ->
    o <> oPath (pVar z) ->
    incl (fvsP (eraseP p z v)) (fvsP (isa o t) ++ fvs Γ').
Proof.
Admitted.

Lemma not_In_then : forall Γ' t1' p1' q1' o1' z,
    WellFormedRes Γ' (Res t1' p1' q1' o1') ->
    ~ In z (fvs Γ') ->
    ~ In z (fvs (isa o1' (tAnd t1' (tNot tFalse)) :: p1' :: Γ')).
Proof.
Admitted.
Lemma not_In_else : forall Γ' t1' p1' q1' o1' z,
    WellFormedRes Γ' (Res t1' p1' q1' o1') ->
    ~ In z (fvs Γ') ->
    ~ In z (fvs (isa o1' (tAnd t1' tFalse) :: q1' :: Γ')).
Proof.
Admitted.

Lemma Proves_Entails_lemma2 : forall z tv v o1 o1' t1' Γ Γ' p1 p1',
    Entails (eraseΓ (Is (pVar z) tv :: Γ') z v) (eraseΓ Γ z v) ->
    Subobj Γ' o1' (eraseO o1 z v) ->
    Proves (isa o1' t1' :: p1' :: Γ')
           (eraseP p1 z v) ->
    Entails (eraseΓ (Is (pVar z) tv :: p1' :: Γ') z v)
            (eraseΓ (p1 :: Γ) z v).
Proof.
Admitted.

Lemma Entails_then : forall o1 o1' t1' p1' Γ' p1 z v tv t1 Γ,
    Proves (isa o1' (tAnd t1' (tNot tFalse)) :: p1' :: Γ')
           (eraseP p1 z v) ->
    Entails (eraseΓ (Is (pVar z) tv :: p1' :: Γ') z v)
            (eraseΓ (p1 :: Γ) z v) ->
    Subobj Γ' o1' (eraseO o1 z v) ->
    ~ In z (fvs Γ') ->
    Entails
      (eraseΓ
         (Is (pVar z) tv
             :: isa o1' (tAnd t1' (tNot tFalse))
             :: p1'
             :: Γ')
         z v)
      (eraseΓ (isa o1 (tAnd t1 (tNot tFalse)) :: p1 :: Γ) z v).
Proof.
Admitted.
Lemma Entails_else : forall o1 o1' t1' q1' Γ' q1 z v tv t1 Γ,
    Proves (isa o1' (tAnd t1' tFalse) :: q1' :: Γ')
           (eraseP q1 z v) ->
    Entails (eraseΓ (Is (pVar z) tv :: q1' :: Γ') z v)
            (eraseΓ (q1 :: Γ) z v) ->
    Subobj Γ' o1' (eraseO o1 z v) ->
    ~ In z (fvs Γ') ->
    Entails
      (eraseΓ
         (Is (pVar z) tv
             :: isa o1' (tAnd t1' tFalse)
             :: q1'
             :: Γ')
         z v)
      (eraseΓ (isa o1 (tAnd t1 tFalse) :: q1 :: Γ) z v).
Proof.
Admitted.


Lemma Substitution : forall Γ' body R,
    TypeOf Γ' body R ->
    forall Γ z v t1,
      ~ In z (fvs Γ) ->
      Entails (eraseΓ ((Is (pVar z) t1)::Γ) z v) (eraseΓ Γ' z v) -> 
    TypeOfVal v t1 ->
    (exists R',
        TypeOf Γ (substitute body z v) R'
        /\ Subres Γ R' (eraseR R z v)).
Proof with crush.
  intros Γ body R Hbody.
  induction Hbody; intros Γ' z v tv Hfree Hproves Hv.
  { (* T_Var *)
    simpl.      
    destruct (var_dec z x); subst.
    { (* z = x *)
      assert (Proves (Is (pVar x) tv :: Γ') (Is (pVar x) t)) as Hp
          by (eapply Proves_type_entails; eauto).
      assert (Subtype tv t) as Hsub
          by (eapply Proves_not_free_sub; eassumption).      
      destruct (val_dec v (vConst (cBool false))) as [Heq | Hneq].
      { (* v = vConst (cBool false) *)
        exists (Res tv Absurd Trivial (oPath (pVal (vConst (cBool false)))));
          split.
        inversion Hv; subst.
        constructor. constructor. crush.
        match goal with
        | [ H : TypeOf _ (eVal (vConst (cBool false))) _ |- _]
          => inversion H
        end; subst.
        match goal with
        | [ H : Subres _ (const_tres (cBool false)) _ |- _]
          => inversion H
        end; subst.
        all: try solve[crush].
        destruct R.
        match goal with
        | [ H : Subres _ _ _ |- _] => inversion H
        end; subst.
        constructor. crush.
        eapply Subtype_trans; eassumption.
        match goal with
        | [ H : Subobj _ _ _ |- _] => inversion H
        end; subst.
        simpl.
        ifcase...
        simpl. crush.
        apply P_Absurd. crush. simpl.
        assert (incl (fvsP p) (fvs (Is (pVar x) (tAnd t (tNot tFalse))
                                       ::(Is (pVar x) tv)
                                       ::Γ')))
          as Hincl.
        {
          eapply Proves_fvs_incl.
          eapply Proves_type_entails. eassumption.
          apply Entails_erase_head_member.
          apply Entails_erase_head_member.
          apply Entails_erase_weaken.
          eassumption.
        }
        simpl in Hincl.
        apply incl_dedup_cons in Hincl.
        apply incl_eraseP. assumption.
        assert (Subtype tFalse tv) as Htv.
        {
          inversion Hv; subst.
          eapply TypeOfVal_lower_bound. eassumption.
          crush.
        }          
        assert (Proves (Is (pVar x) (tAnd tv tFalse) :: Γ') p0) as Hp0.
        {
          eapply Proves_combine_Is_tAnd. eassumption.
          eapply Proves_type_entails. eassumption.
          apply Entails_erase_head_member.
          apply Entails_erase_head_member.
          apply Entails_erase_weaken.
          eassumption.
        }
        eapply eraseP_false.
        apply Proves_swap_head.
        apply Proves_weakening_cons.
        apply Proves_swap. apply Proves_weakening_cons.
        eassumption.
        assert (WellFormedRes Γ' (eraseR (Res t0 p p0 o)
                                         x
                                         (vConst (cBool false)))).
        {
          eapply WellFormedRes_eraseR.
          eapply WellFormedRes_erase_entails; eassumption.
        }
        crush.
      }
      { (* v <> vConst (cBool false) *)
        exists (Res tv Trivial Absurd (oPath (pVal v)));
          split.
        inversion Hv; subst.
        apply TypeOf_Val_NonFalse...
        destruct R.
        match goal with
        | [ H : Subres _ _ _ |- _] => inversion H
        end; subst.
        constructor. crush.
        eapply Subtype_trans; eassumption.
        match goal with
        | [ H : Subobj _ _ _ |- _] => inversion H
        end; subst.
        simpl.
        ifcase...
        simpl. crush.
        apply Proves_weakening_cons.
        assert (Proves ((Is (pVar x) (tAnd tv (tNot tFalse)))::Γ') p) as Hp'.
        {
          eapply Proves_combine_Is_tAnd. eassumption.
          eapply Proves_type_entails. eassumption.
          apply Entails_erase_head_member.
          apply Entails_erase_head_member.
          apply Entails_erase_weaken.
          eassumption.
        }
        eapply eraseP_nonfalse; eauto.
        apply Proves_swap. apply Proves_weakening_cons. eassumption.
        apply P_Absurd. crush.
        simpl.
        assert (incl (fvsP p0) (fvs (Is (pVar x) (tAnd t tFalse)
                                        ::(Is (pVar x) tv)
                                        ::Γ')))
          as Hincl.
        {
          eapply Proves_fvs_incl.
          eapply Proves_type_entails. eassumption.
          apply Entails_erase_head_member.
          apply Entails_erase_head_member.
          apply Entails_erase_weaken.
          eassumption.
        }
        simpl in Hincl.
        apply incl_dedup_cons in Hincl.
        apply incl_eraseP. assumption.
        assert (WellFormedRes Γ' (eraseR (Res t0 p p0 o)
                                         x
                                         v)).
        {
          eapply WellFormedRes_eraseR.
          eapply WellFormedRes_erase_entails; eassumption.
        }
        crush.
      }
    }
    { (* z <> x *)
      exists (Res t
                  (Is (pVar x) (tAnd t (tNot tFalse)))
                  (Is (pVar x) (tAnd t tFalse))
                  (oPath (pVar x))).
      assert (Proves Γ' (Is (pVar x) t)) as Hy.
      {
        eapply Proves_neq_cons. eassumption.
        eapply Proves_type_entails. eassumption.
        eassumption. assumption.
      }
      assert (incl (fvsP (Is (pVar x) t)) (fvs Γ')) as Hincl by
            (eapply Proves_fvs_incl; crush).
      split.
      eapply T_Var. eassumption.
      apply Subres_refl.
      constructor... constructor...
      eapply eraseR_Subres; eauto.
      eapply Subres_erase_entails. eassumption. eassumption.
      crush.
    }
  }
  { (* T_Const *)
    simpl.
    exists (const_tres c). split. constructor. apply Subres_refl.
    apply WellFormedRes_const. apply WellFormedRes_const.
    eapply eraseR_Subres; eauto.
    eapply Subres_erase_entails. eassumption. eassumption.
    intros contra.
    destruct c; crush.
    repeat ifcaseH...
  }
  { (* T_Abs *)
    simpl.
    destruct (var_dec z x) as [Heq | Hneq].
    { (* z <> x *)
      exists (Res t Trivial Absurd (oPath (pVal (vAbs x i e)))); split.
      subst.
      eapply T_Abs; auto. eassumption.
      intros t1 t2 Hin.
      eapply TypeOf_Entails_body. eauto.
      applyH. assumption. assumption. assumption. assumption.
      apply Subres_refl.
      crush. crush. subst.
      eapply Subres_entails_eraseR; eauto.
    }
    { (* z = x *)
      exists (Res (tAnd (interface_ty i) (neg_interface_ty i'))
                  Trivial Absurd (oPath (pVal (vAbs x i (substitute e z v))))).
      split.
      eapply T_Abs.
      inversion Hproves; subst.
      eapply not_In_erase_incl; eauto.
      eassumption.
      assumption.
      intros dom cdom HInt.
      assert (exists R' : tres,
                 TypeOf ((Is (pVar x) dom)::Γ') (substitute e z v) R' /\
                 Subres ((Is (pVar x) dom)::Γ') R' (Res cdom Trivial Trivial oTop))
        as Hex.
      {
        eapplyH. eassumption.
        simpl.
        apply and_not_or; split. crush. assumption.
        apply Entails_erase_swap_left.
        apply Entails_erase_head_member.
        apply Entails_erase_weaken.
        eassumption.
        assumption.
      }
      destruct Hex as [R' [Htype Hsres]].
      eapply T_Subsume; eassumption.
      subst.
      apply Subres_refl. crush. crush.
      assert (Subres (Is (pVar z) tv :: Γ')
                     (Res (tAnd (interface_ty i) (neg_interface_ty i'))
                          Trivial
                          Absurd
                          (oPath (pVal (vAbs x i (substitute e z v)))))
                     (Res (tAnd (interface_ty i) (neg_interface_ty i'))
                          Trivial
                          Absurd
                          (oPath (pVal (vAbs x i e))))) as Hsres.
      {
        constructor...
      }
      assert (Subres (Is (pVar z) tv :: Γ')
                     (Res (tAnd (interface_ty i) (neg_interface_ty i'))
                          Trivial
                          Absurd
                          (oPath (pVal (vAbs x i (substitute e z v)))))
                     R)
        as Hsres'.
      {
        eapply Subres_trans. eassumption. subst.
        eapply Subres_erase_entails. eassumption. eassumption.
      }
      eapply eraseR_Subres. eassumption.
      assumption. assumption. crush.
    }
  }
  { (* T_App *)
    assert (exists R' : tres,
               TypeOf Γ' (substitute e1 z v) R' /\
               Subres Γ' R' (eraseR (Res t1 Trivial Trivial oTop) z v))
      as Hlhs by (eapplyH; eauto).
    destruct Hlhs as [Rl [Hltype Hlsub]].
    assert (exists R' : tres,
               TypeOf Γ' (substitute e2 z v) R' /\
               Subres Γ' R' (eraseR (Res t2 Trivial Trivial o2) z v))
      as Hrhs by (eapplyH; eauto).
    destruct Hrhs as [Rr [Hrtype Hrsub]].
    exists (eraseR R z v).
    simpl.
    split.
    eapply T_App.
    eapply T_Subsume; eassumption.
    eapply T_Subsume; eassumption.
    eassumption. eassumption.
    match goal with
    | [ H : Subres Γ _ R |- _ ] =>
      inversion H; subst
    end.
    destruct (obj_dec o2 (oPath (pVar z))) as [Ho2 | Ho2]; subst.
    { (* o2 = (oVar z) *)
      unfold isa.
      rewrite eraseO_pVar.
      match goal with
      | [ H : Subobj Γ oTop _ |- _]
        => inversion H; subst
      end.
      simpl.
      constructor. crush. assumption. crush.
      { (* Proves (isa oTop (tAnd t (tNot tFalse)) :: Is (pVal v) tpos :: Γ')
                  (eraseP p2 z v)*)
        unfold isa in *.
        destruct (empty_dec (tAnd t (tNot tFalse))).
        {
          apply P_Absurd. crush. simpl.
          eapply incl_fvsP_eraseP1; eauto.
        }
        {
          apply Proves_weaken_triv.
          assert (Proves (Is (pVar z) tpos :: Is (pVar z) tv :: Γ') p2)
            as Hp2.
          {
            eapply Proves_Entails1.
            apply Proves_strengthen_triv. eassumption. eassumption.
            assumption. assumption.
          }
          apply Proves_tAnd_L in Hp2.
          eapply (Proves_eraseP_val2); eassumption.
        }
      }
      { (* Proves (isa oTop (tAnd t tFalse) :: Is (pVal v) tneg :: Γ') 
                  (eraseP q2 z v) *) 
        unfold isa in *.
        destruct (empty_dec (tAnd t tFalse)).
        {
          apply P_Absurd. crush. simpl.
          eapply incl_fvsP_eraseP1; eauto.
        }
        {
          apply Proves_weaken_triv.
          assert (Proves (Is (pVar z) tneg :: Is (pVar z) tv :: Γ') q2)
            as Hq2.
          {
            eapply Proves_Entails1.
            apply Proves_strengthen_triv. eassumption. eassumption.
            assumption. assumption.
          }
          apply Proves_tAnd_L in Hq2.
          eapply (Proves_eraseP_val2); eassumption.
        }
      }
      { (* WellFormedRes Γ' (Res t3 (eraseP p2 z v) (eraseP q2 z v) oTop) *)
        assert (WellFormedRes Γ' (eraseR (Res t3 p2 q2 oTop) z v)).
        {
          eapply WellFormedRes_eraseR.
          eapply WellFormedRes_erase_entails; eauto.
        }
        crush.
      }
      { (* Subres Γ' (Res t (Is (pVal v) tpos) (Is (pVal v) tneg) oTop)
                     (eraseR (Res t3 p2 q2 oTop) z v) *)
        simpl.
        constructor. crush. assumption. crush.
        unfold isa in *.
        destruct (empty_dec (tAnd t (tNot tFalse))).
        {
          apply P_Absurd. crush. simpl.
          eapply incl_fvsP_eraseP1; eauto.
        }
        {
          apply Proves_weaken_triv.
          assert (Proves (Is (pVar z) tpos :: Is (pVar z) tv :: Γ') p2)
            as Hp2.
          {
            eapply Proves_Entails1.
            apply Proves_strengthen_triv. eassumption. eassumption.
            assumption. assumption.
          }
          apply Proves_tAnd_L in Hp2.
          eapply (Proves_eraseP_val2); eassumption.
        }
        unfold isa in *.
        destruct (empty_dec (tAnd t tFalse)).
        {
          apply P_Absurd. crush. simpl.
          eapply incl_fvsP_eraseP1; eauto.
        }
        {
          apply Proves_weaken_triv.
          assert (Proves (Is (pVar z) tneg :: Is (pVar z) tv :: Γ') q2)
            as Hq2.
          {
            eapply Proves_Entails1.
            apply Proves_strengthen_triv. eassumption. eassumption.
            assumption. assumption.
          }
          apply Proves_tAnd_L in Hq2.
          eapply (Proves_eraseP_val2); eassumption.
        }
        assert (WellFormedRes Γ' (eraseR (Res t3 p2 q2 oTop) z v)).
        {
          eapply WellFormedRes_eraseR.
          eapply WellFormedRes_erase_entails; eauto.
        }
        crush.
      }
    }
    { (* o2 <> (oVar z) *)
      constructor.
      assert (WellFormedRes
                Γ' (eraseR (Res t (isa o2 tpos) (isa o2 tneg) oTop) z v))
        as Hwfr.
      {
        eapply WellFormedRes_eraseR.
        eapply WellFormedRes_erase_entails; eauto.
      }
      eapply WFR_lemma1... assumption.
      match goal with
      | [ H : Subobj Γ oTop _ |- _] => inversion H
      end; subst.
      simpl. crush. crush.
      erewrite eraseO_neq; try eassumption.
      assert (isa oTop (tAnd t (tNot tFalse)) = Trivial
              \/ isa oTop (tAnd t (tNot tFalse)) = Absurd)
        as Hopts by apply isa_oTop_options.
      destruct Hopts as [Heq | Heq]; rewrite Heq in *.
      { (* isa oTop (tAnd t (tNot tFalse)) = Trivial *)
        apply Proves_weaken_triv.
        match goal with
          [ H : Proves (Trivial :: _ :: Γ) p2 |- _]
          => apply Proves_strengthen_triv in H
        end.
        assert (Proves (Is (pVar z) tv :: isa o2 tpos :: Γ') p2) as Hp2'.
        {
          eapply Proves_type_entails; eauto.
          eapply Entails_erase_swap_left.
          eapply Entails_erase_head_member.
          eapply Entails_erase_weaken.
          eassumption.
        }
        eapply Proves_eraseP. simpl. 
        eapply not_In_lemma1; eauto.
        eassumption.
        assumption.
      }
      { (* isa oTop (tAnd t (tNot tFalse)) = Absurd *)
        apply P_Absurd. crush. simpl.
        eapply incl_fvsP_eraseP2; eauto.
      }
      erewrite eraseO_neq; try eassumption.
      assert (isa oTop (tAnd t tFalse) = Trivial
              \/ isa oTop (tAnd t tFalse) = Absurd)
        as Hopts by apply isa_oTop_options.
      destruct Hopts as [Heq | Heq]; rewrite Heq in *.
      { (* isa oTop (tAnd t tFalse) = Trivial *)
        apply Proves_weaken_triv.
        match goal with
          [ H : Proves (Trivial :: _ :: Γ) q2 |- _]
          => apply Proves_strengthen_triv in H
        end.
        assert (Proves (Is (pVar z) tv :: isa o2 tneg :: Γ') q2) as Hq2'.
        {
          eapply Proves_type_entails; eauto.
          eapply Entails_erase_swap_left.
          eapply Entails_erase_head_member.
          eapply Entails_erase_weaken.
          eassumption.
        }
        eapply Proves_eraseP. simpl. 
        eapply not_In_lemma1; eauto.
        eassumption.
        assumption.
      }
      { (* isa oTop (tAnd t tFalse) = Absurd *)
        apply P_Absurd. crush. simpl.
        eapply incl_fvsP_eraseP2; eauto.
      }
      assert (WellFormedRes Γ' (eraseR (Res t3 p2 q2 o0) z v)).
      {
        eapply WellFormedRes_eraseR.
        eapply WellFormedRes_erase_entails; eauto.
      }
      crush.
    }
    eapply WellFormedRes_eraseR.
    eapply WellFormedRes_erase_entails; eauto.
    apply Subres_refl.
    eapply WellFormedRes_eraseR.
    eapply WellFormedRes_erase_entails; eauto.
  }
  { (* T_If *)
    assert (exists R' : tres,
               TypeOf Γ' (substitute e1 z v) R' /\
               Subres Γ' R' (eraseR (Res t1 p1 q1 o1) z v))
      as IH1 by (eapply IHHbody1; eauto).
    destruct IH1 as [[t1' p1' q1' o1'] [Ht1 Hsub1]].
    simpl in Hsub1.
    inversion Hsub1; subst.
    assert (Entails (eraseΓ (Is (pVar z) tv::p1'::Γ') z v)
                    (eraseΓ (p1 :: Γ) z v))
      as Hp by (eapply Proves_Entails_lemma2; eauto).
    assert (exists R' : tres,
               TypeOf ((isa o1' (tAnd t1' (tNot tFalse)))::p1'::Γ')
                      (substitute e2 z v) R' /\
               Subres ((isa o1' (tAnd t1' (tNot tFalse)))::p1'::Γ')
                      R'
                      (eraseR R z v))
      as IH2.
    {
      eapply IHHbody2; eauto.
      eapply not_In_then; eauto.
      eapply Entails_then; eauto.
    }
    destruct IH2 as [R2' [Ht2 Hsub2]].
    assert (TypeOf ((isa o1' (tAnd t1' (tNot tFalse)))::p1'::Γ')
                   (substitute e2 z v)
                   (eraseR R z v))
      as Ht2'.
    {
      eapply T_Subsume; eassumption.
    }
    assert (Entails (eraseΓ (Is (pVar z) tv::q1'::Γ') z v)
                    (eraseΓ (q1 :: Γ) z v))
      as Hq by (eapply Proves_Entails_lemma2; eauto).
    assert (exists R' : tres,
               TypeOf ((isa o1' (tAnd t1' tFalse))::q1'::Γ')
                      (substitute e3 z v)
                      R' /\
               Subres ((isa o1' (tAnd t1' tFalse))::q1'::Γ')
                      R'
                      (eraseR R z v))
      as IH3.
    {
      eapply IHHbody3; eauto.
      eapply not_In_else; eauto.
      eapply Entails_else; eauto.
    }
    destruct IH3 as [R3' [Ht3 Hsub3]].
    assert (TypeOf ((isa o1' (tAnd t1' tFalse))::q1'::Γ')
                   (substitute e3 z v)
                   (eraseR R z v))
      as Ht3'.
    {
      eapply T_Subsume; eassumption.
    }
    exists (eraseR R z v); split.
    simpl.
    eapply T_If; try eassumption.
    eapply WellFormedRes_eraseR.
    eapply WellFormedRes_erase_entails; eassumption.
    apply Subres_refl.
    eapply WellFormedRes_eraseR.
    eapply WellFormedRes_erase_entails; eassumption.
  }
Qed.  
  
Lemma Proves_lemma1 : forall t2 tpos tneg t' o' p' q' x t,
    ~ IsEmpty t2 ->
    (IsEmpty tpos -> IsEmpty (tAnd t (tNot tFalse))) ->
    (IsEmpty tneg -> IsEmpty (tAnd t tFalse)) ->
    Proves [Is x t2; isa o' (tAnd t' (tNot tFalse)); p'] (isa oTop tpos) ->
    Proves [Is x t2; isa o' (tAnd t' tFalse); q'] (isa oTop tneg) ->
    ((Proves [isa o' (tAnd t' (tNot tFalse)); p'] (isa oTop tpos))
     /\
     (Proves [isa o' (tAnd t' tFalse); q'] (isa oTop tneg))).
Proof.
Admitted.


Lemma Entails_refl : forall Γ,
    Entails Γ Γ.
Proof.
Admitted.


Lemma If_then_impl : forall o1 t1 e2 R o1' t1' p1 p1',
    TypeOf [isa o1 (tAnd t1 (tNot tFalse)); p1] e2 R ->
    Subobj [] o1' o1 ->
    Proves [isa o1' (tAnd t1' (tNot tFalse)); p1'] p1 ->
    TypeOf [isa o1' (tAnd t1' (tNot tFalse)); p1'] e2 R.
Proof.
Admitted.
Lemma If_else_impl : forall o1 t1 e3 R o1' t1' q1 q1',
    TypeOf [isa o1 (tAnd t1 tFalse); q1] e3 R ->
    Subobj [] o1' o1 ->
    Proves [isa o1' (tAnd t1' tFalse); q1'] q1 ->
    TypeOf [isa o1' (tAnd t1' tFalse); q1'] e3 R.
Proof.
Admitted.

Lemma If_else_TypeOf : forall t1 p1 q1 o1 e' R,
    TypeOf [] (eVal (vBool false)) (Res t1 p1 q1 o1) ->
    TypeOf [isa o1 (tAnd t1 tFalse); q1] e' R ->
    TypeOf [] e' R.
Proof.
Admitted.
Lemma If_then_TypeOf : forall t1 p1 q1 o1 e' R v,
    TypeOf [] (eVal v) (Res t1 p1 q1 o1) ->
    v <> (vBool false) ->
    TypeOf [isa o1 (tAnd t1 (tNot tFalse)); p1] e' R ->
    TypeOf [] e' R.
Proof.
Admitted.


Lemma Preservation : forall e e' R,
    TypeOf [] e R ->
    Step e e' ->
    exists R', TypeOf [] e' R'
               /\ Subres [] R' R.
Proof with crush.
  intros e e' R Htype.  
  generalize dependent e'.
  remember [] as Γ.
  induction Htype;
    intros e' Hstep;
    try solve[inversion Hstep].
  { (* T_App *)
    subst.
    assert (o2 = oTop) as Ho2 by (eapply TypeOf_oTop; eassumption). subst.
    exists (Res t (isa oTop tpos) (isa oTop tneg) oTop).
    split.
    inversion Hstep; subst.
    { (* (e1 e2) --> (e1' e2) *)
      assert (exists R' : tres,
                 TypeOf [] e1' R'
                 /\ Subres [] R' (Res t1 Trivial Trivial oTop))
        as IH1 by crush.
      destruct IH1 as [[t1' p1' q1' o1'] [Htype1' HSR1']].
      subst.
      eapply T_App. eapply T_Subsume. eassumption. eassumption.
      eassumption. eassumption. eassumption. apply Subres_refl.
      apply SimpleRes_WellFormedRes...
      repeat ifcase; crush. repeat ifcase; crush.
      constructor; crush. repeat ifcase; crush.
    }
    { (* (v e2) --> (v e2') *)
      assert (exists R' : tres,
                 TypeOf [] e2' R'
                 /\ Subres [] R' (Res t2 Trivial Trivial oTop))
        as IH2 by crush.
      destruct IH2 as [[t2' p2' q2' o2'] [Htype2' HSR2']].
      eapply T_App. eassumption.
      eapply T_Subsume. eassumption. eassumption.
      eassumption. eassumption. apply Subres_refl.
      apply SimpleRes_WellFormedRes...
      repeat ifcase; crush. repeat ifcase; crush.
      constructor; crush. repeat ifcase; crush.
    }
    { (* (o v) --> v'   where Some v' = apply_op o v *)
      destruct o.
      { (* opAdd1 *)
        assert (Subtype (op_type opAdd1) t1) as Hopt
            by (eapply TypeOf_Op_Subtype; eauto).
        simpl in *.
        assert (Subtype (tArrow tNat tNat) (tArrow t2 t)) as
            Hopsub by (eapply Subtype_trans; eauto).
        (* the result is a supertype of the op result *)
        assert (Subtype tNat t) as Hcdom
            by (eapply Subtype_tArrow_cdom; eauto).
        (* the arg type is a subtype of the domain *)
        assert (Subtype t2 tNat) as Hdom
            by (eapply Subtype_tArrow_dom; eauto).
        clear Hopsub.
        (* if the arg is a subtype of tNat, it must be a nat *)
        assert (exists n, v = vConst (cNat n)) as Hnat
            by (eapply TypeOf_tNat; eapply TypeOf_Sub_type; eauto).
        destruct Hnat as [n Hn].
        subst.
        match goal with
        | [ H : Some (vConst (cNat _)) = Some _ |- _]
          => inversion H; subst
        end.
        assert (Subtype tNat t2) as Ht2low by
              (eapply TypeOfVal_lower_bound; eauto).
        assert (TypeOfVal (vOp opAdd1) t1) as Hval1 by crush.
        assert (TypeOfVal (vNat n) t2) as Hval2 by crush.
        assert (((vNat (n + 1)) <> (vBool false) /\ TypeOfVal (vNat n) tpos)
                \/ ((vNat (n + 1)) = (vBool false) /\ TypeOfVal (vNat n) tneg))
          as Hres.
        {
          eapply pred_inv_props; try eassumption.
          eapply S_Cons. eassumption. apply S_Null.
        }
        destruct Hres as [[Hneq Htpos] | [Heq Htneg]].
        {
          assert (~ IsEmpty tpos) as Hnmt
              by (eapply TypeOfVal_NonEmpty; eauto).
          eapply T_Subsume. apply T_Const. simpl. apply Subres_refl.
          crush. crush.
          apply SR_Sub...
          ifcase. contradiction. apply P_Trivial. apply P_Absurd...
          ifcase; crush.
          ifcase...
          repeat ifcase...
        }
        {
          inversion Heq.
        }
      }
      { (* opSub1 *)
        assert (Subtype (op_type opSub1) t1) as Hopt
            by (eapply TypeOf_Op_Subtype; eauto).
        simpl in *.
        assert (Subtype (tArrow tNat tNat) (tArrow t2 t)) as
            Hopsub by (eapply Subtype_trans; eauto).
        (* the result is a supertype of the op result *)
        assert (Subtype tNat t) as Hcdom
            by (eapply Subtype_tArrow_cdom; eauto).
        (* the arg type is a subtype of the domain *)
        assert (Subtype t2 tNat) as Hdom
            by (eapply Subtype_tArrow_dom; eauto).
        clear Hopsub.
        (* if the arg is a subtype of tNat, it must be a nat *)
        assert (exists n, v = vConst (cNat n)) as Hnat
            by (eapply TypeOf_tNat; eapply TypeOf_Sub_type; eauto).
        destruct Hnat as [n Hn].
        subst.
        match goal with
        | [ H : Some (vConst (cNat _)) = Some _ |- _]
          => inversion H; subst
        end.
        assert (Subtype tNat t2) as Ht2low by
              (eapply TypeOfVal_lower_bound; eauto).
        assert (TypeOfVal (vOp opSub1) t1) as Hval1 by crush.
        assert (TypeOfVal (vNat n) t2) as Hval2 by crush.
        assert (((vNat (n - 1)) <> (vBool false) /\ TypeOfVal (vNat n) tpos)
                \/ ((vNat (n - 1)) = (vBool false) /\ TypeOfVal (vNat n) tneg))
          as Hres.
        {
          eapply pred_inv_props; try eassumption.
          eapply S_Cons. eassumption. apply S_Null.
        }
        destruct Hres as [[Hneq Htpos] | [Heq Htneg]].
        {
          assert (~ IsEmpty tpos) as Hnmt
              by (eapply TypeOfVal_NonEmpty; eauto).
          eapply T_Subsume. apply T_Const. simpl. apply Subres_refl.
          crush. crush.
          apply SR_Sub...
          ifcase. contradiction. apply P_Trivial.
          apply P_Absurd... ifcase; crush.
          ifcase...
          repeat ifcase...
        }
        {
          inversion Heq.
        }
      }
      { (* opSub1 *)
        assert (Subtype (op_type opStrLen) t1) as Hopt
            by (eapply TypeOf_Op_Subtype; eauto).
        simpl in *.
        assert (Subtype (tArrow tStr tNat) (tArrow t2 t)) as
            Hopsub by (eapply Subtype_trans; eauto).
        (* the result is a supertype of the op result *)
        assert (Subtype tNat t) as Hcdom
            by (eapply Subtype_tArrow_cdom; eauto).
        (* the arg type is a subtype of the domain *)
        assert (Subtype t2 tStr) as Hdom
            by (eapply Subtype_tArrow_dom; eauto).
        clear Hopsub.
        (* if the arg is a subtype of tNat, it must be a nat *)
        assert (exists s, v = vConst (cStr s)) as Hstr
            by (eapply TypeOf_tStr; eapply TypeOf_Sub_type; eauto).
        destruct Hstr as [s Hs].
        subst.
        match goal with
        | [ H : Some (vConst (cNat _)) = Some _ |- _]
          => inversion H; subst
        end.
        assert (Subtype tStr t2) as Ht2low by
              (eapply TypeOfVal_lower_bound; eauto).
        assert (TypeOfVal (vOp opStrLen) t1) as Hval1 by crush.
        assert (TypeOfVal (vStr s) t2) as Hval2 by crush.
        assert (((vNat (String.length s)) <> (vBool false)
                 /\ TypeOfVal (vStr s) tpos)
                \/ ((vNat (String.length s)) = (vBool false)
                    /\ TypeOfVal (vStr s) tneg))
          as Hres.
        {
          eapply pred_inv_props; try eassumption.
          eapply S_Cons. eassumption. apply S_Null.
        }
        destruct Hres as [[Hneq Htpos] | [Heq Htneg]].
        {
          assert (~ IsEmpty tpos) as Hnmt
              by (eapply TypeOfVal_NonEmpty; eauto).
          eapply T_Subsume. apply T_Const. simpl. apply Subres_refl.
          crush. crush.
          apply SR_Sub...
          ifcase. contradiction. apply P_Trivial. apply P_Absurd...
          ifcase; crush.
          ifcase...
          repeat ifcase...
        }
        {
          inversion Heq.
        }
      }
      { (* opNot *)
        assert (Subtype (op_type opNot) t1) as Hopt
            by (eapply TypeOf_Op_Subtype; eauto).
        simpl in *.
        assert (Subtype (predicate tFalse) (tArrow t2 t)) as Hopsub
            by (eapply Subtype_trans; eassumption).
        (* the result is a supertype of the op result *)
        assert (Subtype tBool t) as Hcdom.
        {
          eapply tArrow_R_cdom_sub. eassumption.
          apply codomain_predicate.
        }
        (* if the arg is a subtype of tNat, it must be a nat *)
        assert ((v' = (vConst (cBool true))) \/ (v' = (vConst (cBool false))))
          as Hvoptions.
        {
          destruct v;
          try match goal with
              | [ H : TypeOf _ (eVal (vConst ?c)) _ |- _] => destruct c
              end;
          try match goal with
              | [ H : (if ?b then Some _ else Some _) = Some _ |- _]
                => destruct b
              end;
          try match goal with
              | [ H : Some (vConst (cBool _)) = Some _ |- _]
                => inversion H; crush
              end.
        }
        assert (TypeOfVal (vOp opNot) t1) as Hval1 by crush.
        assert (TypeOfVal v t2) as Hval2 by crush.
        assert ((v' <> (vBool false) /\ TypeOfVal v tpos)
                \/ (v' = (vBool false) /\ TypeOfVal v tneg))
          as Hres.
        {
          eapply pred_inv_props. eassumption. eassumption.
          eassumption.
          eapply S_Cons. eassumption. apply S_Null.
        }
        destruct Hvoptions; subst.
        { (* v' = vConst (cBool true) *)
          destruct Hres as [[Hneq Htpos] | [Heq Htneg]].
          {
            assert (~ IsEmpty tpos) as Hpos
                by (eapply TypeOfVal_NonEmpty; eauto).
            eapply T_Subsume. apply T_Const. simpl. apply Subres_refl.
            crush. crush.
            apply SR_Sub...
            assert (Subtype tTrue tBool) as Hsubbby by (unfold Subtype; crush).
            eapply Subtype_trans; eauto.
            destruct (empty_dec tpos)...
            assert (IsEmpty (tAnd tTrue tFalse)) as Hmt
                by (apply Empty_neq_tBase; crush).
            ifcase... ifcase; crush.
            repeat ifcase...
          }
          {
            inversion Heq.
          }
        }
        { (* v' = vConst (cBool false) *)
          destruct Hres as [[Hneq Htpos] | [Heq Htneg]].
          {
            assert False as impossible by (apply Hneq; reflexivity).
            contradiction.
          }
          {
            assert (~ IsEmpty tneg) as Hneg
                by (eapply TypeOfVal_NonEmpty; eauto).
            eapply T_Subsume. apply T_Const. simpl. apply Subres_refl...
            crush.
            apply SR_Sub...
            assert (Subtype tFalse tBool) as Hsubbby by (unfold Subtype; crush).
            eapply Subtype_trans; eauto.
            destruct (empty_dec tpos)...
            destruct (empty_dec tneg)...
            repeat ifcase...
          }
        }
      }
      { (* opIsNat *)
        assert (Subtype (op_type opIsNat) t1) as Hopt
            by (eapply TypeOf_Op_Subtype; eauto).
        simpl in *.
        assert (Subtype (predicate tNat) (tArrow t2 t)) as Hopsub
            by (eapply Subtype_trans; eassumption).
        (* the result is a supertype of the op result *)
        assert (Subtype tBool t) as Hcdom.
        {
          eapply tArrow_R_cdom_sub. eassumption.
          apply codomain_predicate.
        }
        (* if the arg is a subtype of tNat, it must be a nat *)
        assert ((v' = (vConst (cBool true))) \/ (v' = (vConst (cBool false))))
          as Hvoptions.
        {
          destruct v;
          try match goal with
              | [ H : TypeOf _ (eVal (vConst ?c)) _ |- _] => destruct c
              end;
          try match goal with
              | [ H : (if ?b then Some _ else Some _) = Some _ |- _]
                => destruct b
              end;
          try match goal with
              | [ H : Some (vConst (cBool _)) = Some _ |- _]
                => inversion H; crush
              end.
        }
        assert (TypeOfVal (vOp opIsNat) t1) as Hval1 by crush.
        assert (TypeOfVal v t2) as Hval2 by crush.
        assert ((v' <> (vBool false) /\ TypeOfVal v tpos)
                \/ (v' = (vBool false) /\ TypeOfVal v tneg))
          as Hres.
        {
          eapply pred_inv_props. eassumption. eassumption.
          eassumption.
          eapply S_Cons. eassumption. apply S_Null.
        }
        destruct Hvoptions; subst.
        { (* v' = vConst (cBool true) *)
          destruct Hres as [[Hneq Htpos] | [Heq Htneg]].
          {
            assert (~ IsEmpty tpos) as Hpos
                by (eapply TypeOfVal_NonEmpty; eauto).
            eapply T_Subsume. apply T_Const. simpl. apply Subres_refl...
            crush. apply SR_Sub...
            assert (Subtype tTrue tBool) as Hsubbby by (unfold Subtype; crush).
            eapply Subtype_trans; eauto.
            destruct (empty_dec tpos)...
            assert (IsEmpty (tAnd tTrue tFalse)) as Hmt
                by (apply Empty_neq_tBase; crush).
            ifcase... ifcase; crush.
            repeat ifcase...
          }
          {
            inversion Heq.
          }
        }
        { (* v' = vConst (cBool false) *)
          destruct Hres as [[Hneq Htpos] | [Heq Htneg]].
          {
            assert False as impossible by (apply Hneq; reflexivity).
            contradiction.
          }
          {
            assert (~ IsEmpty tneg) as Hneg
                by (eapply TypeOfVal_NonEmpty; eauto).
            eapply T_Subsume. apply T_Const. simpl. apply Subres_refl...
            crush. apply SR_Sub...
            assert (Subtype tFalse tBool) as Hsubbby by (unfold Subtype; crush).
            eapply Subtype_trans; eauto.
            destruct (empty_dec tpos)...
            destruct (empty_dec tneg)...
            repeat ifcase...
          }
        }
      }
      { (* opIsStr *)
        assert (Subtype (op_type opIsStr) t1) as Hopt
            by (eapply TypeOf_Op_Subtype; eauto).
        simpl in *.
        assert (Subtype (predicate tStr) (tArrow t2 t)) as Hopsub
            by (eapply Subtype_trans; eassumption).
        (* the result is a supertype of the op result *)
        assert (Subtype tBool t) as Hcdom.
        {
          eapply tArrow_R_cdom_sub. eassumption.
          apply codomain_predicate.
        }
        (* if the arg is a subtype of tNat, it must be a nat *)
        assert ((v' = (vConst (cBool true))) \/ (v' = (vConst (cBool false))))
          as Hvoptions.
        {
          destruct v;
          try match goal with
              | [ H : TypeOf _ (eVal (vConst ?c)) _ |- _] => destruct c
              end;
          try match goal with
              | [ H : (if ?b then Some _ else Some _) = Some _ |- _]
                => destruct b
              end;
          try match goal with
              | [ H : Some (vConst (cBool _)) = Some _ |- _]
                => inversion H; crush
              end.
        }
        assert (TypeOfVal (vOp opIsStr) t1) as Hval1 by crush.
        assert (TypeOfVal v t2) as Hval2 by crush.
        assert ((v' <> (vBool false) /\ TypeOfVal v tpos)
                \/ (v' = (vBool false) /\ TypeOfVal v tneg))
          as Hres.
        {
          eapply pred_inv_props. eassumption. eassumption.
          eassumption. eapply S_Cons. eassumption. apply S_Null.
        }
        destruct Hvoptions; subst.
        { (* v' = vConst (cBool true) *)
          destruct Hres as [[Hneq Htpos] | [Heq Htneg]].
          {
            assert (~ IsEmpty tpos) as Hpos
                by (eapply TypeOfVal_NonEmpty; eauto).
            eapply T_Subsume. apply T_Const. simpl. apply Subres_refl...
            crush. apply SR_Sub...
            assert (Subtype tTrue tBool) as Hsubbby by (unfold Subtype; crush).
            eapply Subtype_trans; eauto.
            destruct (empty_dec tpos)...
            assert (IsEmpty (tAnd tTrue tFalse)) as Hmt
                by (apply Empty_neq_tBase; crush).
            ifcase... ifcase; crush.
            repeat ifcase...
          }
          {
            inversion Heq.
          }
        }
        { (* v' = vConst (cBool false) *)
          destruct Hres as [[Hneq Htpos] | [Heq Htneg]].
          {
            assert False as impossible by (apply Hneq; reflexivity).
            contradiction.
          }
          {
            assert (~ IsEmpty tneg) as Hneg
                by (eapply TypeOfVal_NonEmpty; eauto).
            eapply T_Subsume. apply T_Const. simpl. apply Subres_refl...
            crush. apply SR_Sub...
            assert (Subtype tFalse tBool) as Hsubbby by (unfold Subtype; crush).
            eapply Subtype_trans; eauto.
            destruct (empty_dec tpos)...
            destruct (empty_dec tneg)...
            repeat ifcase...
          }
        }
      }
      { (* opIsProc *)
        assert (Subtype (op_type opIsProc) t1) as Hopt
            by (eapply TypeOf_Op_Subtype; eauto).
        simpl in *.
        assert (Subtype (predicate (tArrow tEmpty tAny)) (tArrow t2 t))
          as Hopsub by (eapply Subtype_trans; eassumption).
        (* the result is a supertype of the op result *)
        assert (Subtype tBool t) as Hcdom.
        {
          eapply tArrow_R_cdom_sub. eassumption.
          apply codomain_predicate.
        }
        (* if the arg is a subtype of tNat, it must be a nat *)
        assert ((v' = (vConst (cBool true))) \/ (v' = (vConst (cBool false))))
          as Hvoptions.
        {
          destruct v;
          try match goal with
              | [ H : TypeOf _ (eVal (vConst ?c)) _ |- _] => destruct c
              end;
          try match goal with
              | [ H : (if ?b then Some _ else Some _) = Some _ |- _]
                => destruct b
              end;
          try match goal with
              | [ H : Some (vConst (cBool _)) = Some _ |- _]
                => inversion H; crush
              end.
        }
        assert (TypeOfVal (vOp opIsProc) t1) as Hval1 by crush.
        assert (TypeOfVal v t2) as Hval2 by crush.
        assert ((v' <> (vBool false) /\ TypeOfVal v tpos)
                \/ (v' = (vBool false) /\ TypeOfVal v tneg))
          as Hres.
        {
          eapply pred_inv_props. eassumption. eassumption.
          eassumption.
          eapply S_Cons. eassumption. apply S_Null.
        }
        destruct Hvoptions; subst.
        { (* v' = vConst (cBool true) *)
          destruct Hres as [[Hneq Htpos] | [Heq Htneg]].
          {
            assert (~ IsEmpty tpos) as Hpos
                by (eapply TypeOfVal_NonEmpty; eauto).
            eapply T_Subsume. apply T_Const. simpl. apply Subres_refl...
            crush. apply SR_Sub...
            assert (Subtype tTrue tBool) as Hsubb by (unfold Subtype; crush).
            eapply Subtype_trans; eauto.
            destruct (empty_dec tpos)...
            assert (IsEmpty (tAnd tTrue tFalse)) as Hmt
                by (apply Empty_neq_tBase; crush).
            ifcase... ifcase; crush.
            repeat ifcase...
          }
          {
            inversion Heq.
          }
        }
        { (* v' = vConst (cBool false) *)
          destruct Hres as [[Hneq Htpos] | [Heq Htneg]].
          {
            assert False as impossible by (apply Hneq; reflexivity).
            contradiction.
          }
          {
            assert (~ IsEmpty tneg) as Hneg
                by (eapply TypeOfVal_NonEmpty; eauto).
            eapply T_Subsume. apply T_Const. simpl. apply Subres_refl...
            crush. apply SR_Sub...
            assert (Subtype tFalse tBool) as Hsubbby by (unfold Subtype; crush).
            eapply Subtype_trans; eauto.
            destruct (empty_dec tpos)...
            destruct (empty_dec tneg)...
            repeat ifcase...
          }
        }
      }
      { (* opIsZero *)
        assert (Subtype (op_type opIsZero) t1) as Hopt
            by (eapply TypeOf_Op_Subtype; eauto).
        simpl in *.
        assert (Subtype (tArrow tNat tBool) (tArrow t2 t)) as
            Hopsub by (eapply Subtype_trans; eauto).
        (* the result is a supertype of the op result *)
        assert (Subtype tBool t) as Hcdom
            by (eapply Subtype_tArrow_cdom; eauto).
        (* the arg type is a subtype of the domain *)
        assert (Subtype t2 tNat) as Hdom
            by (eapply Subtype_tArrow_dom; eauto).
        clear Hopsub.
        (* if the arg is a subtype of tNat, it must be a nat *)
        assert (exists n, v = vConst (cNat n)) as Hnat
            by (eapply TypeOf_tNat; eapply TypeOf_Sub_type; eauto).
        destruct Hnat as [n Hn].
        subst.
        assert (exists b, v' = (vConst (cBool b))) as Hbool
            by (destruct n; match goal with
                            | [ H : Some (vConst (cBool ?b)) = Some _ |- _]
                              => exists b; inversion H; crush
                            end).
        destruct Hbool as [b Hb]; subst.
        assert (Subtype tNat t2) as Ht2low by
              (eapply TypeOfVal_lower_bound; eauto).
        assert (TypeOfVal (vOp opIsZero) t1) as Hval1 by crush.
        assert (TypeOfVal (vNat n) t2) as Hval2 by crush.
        assert (((vConst (cBool b)) <> (vBool false)
                 /\ TypeOfVal (vNat n) tpos)
                \/ ((vConst (cBool b)) = (vBool false)
                    /\ TypeOfVal (vNat n) tneg))
          as Hres.
        {
          eapply pred_inv_props; try eassumption.
          eapply S_Cons. eassumption. apply S_Null.
        }
        destruct Hres as [[Hneq Htpos] | [Heq Htneg]].
        {
          assert (~ IsEmpty tpos) as Hnmt
              by (eapply TypeOfVal_NonEmpty; eauto).
          eapply T_Subsume. apply T_Const. simpl. apply Subres_refl...
          ifcase... ifcase... ifcase... 
          apply SR_Sub...
          assert (Subtype tTrue tBool) as Hsubb by (unfold Subtype; crush).
          eapply Subtype_trans; eauto.
          ifcase. apply P_Absurd... apply P_Trivial.
          ifcase...
          repeat ifcase...
        }
        {
          inversion Heq; subst.
          assert (~ IsEmpty tneg) as Hnmt
              by (eapply TypeOfVal_NonEmpty; eauto).
          eapply T_Subsume. apply T_Const. simpl. apply Subres_refl...
          crush.
          apply SR_Sub...
          assert (Subtype tFalse tBool) as Hsubb by (unfold Subtype; crush).
          eapply Subtype_trans; eauto.
          ifcase. apply P_Absurd... apply P_Absurd... ifcase; crush.
          ifcase...
          repeat ifcase... repeat ifcase...
        }
      }
    }
    { (* vAbs *)
      clear IHHtype1. clear IHHtype2.
      assert (TypeOf [] (eVal (vAbs x i body))
                     (Res (tArrow t2 t) Trivial Trivial oTop))
        as Hfun by (eapply T_Subsume; try eassumption; apply SR_Sub; crush).
      clear Htype1.
      assert (TypeOf [] (eVal v) (Res t2 Trivial Trivial oTop))
        as Harg by assumption. clear Htype2.
      assert (TypeOf [Is (pVar x) t2] body (Res t Trivial Trivial oTop))
        as Hbody by (eapply TypeOf_tArrow_body; eauto).
      assert (((IsEmpty tpos -> IsEmpty (tAnd t (tNot tFalse)))
               /\
               (IsEmpty tneg -> IsEmpty (tAnd t tFalse))))
        as Hinv by (eapply pred_inv_supertype; eassumption).
      destruct Hinv as [Hinvp Hinvn].
      assert (exists R',
                 TypeOf [] (substitute body x v) R'
                 /\ Subres [] R' (eraseR (Res t
                                              (isa oTop tpos)
                                              (isa oTop tneg)
                                              oTop)
                                         x
                                         v))
        as Hsub.
      {
        inversion Hfun; subst.
        eapply Substitution.
        eapply T_Subsume.
        eauto.
        assert (Subres [Is (pVar x) t2]
                       (Res t (isa oTop tpos) (isa oTop tneg) oTop)
                       R)
          as Hsub1 by (apply Subres_weaken; auto).
        assert (Subres [Is (pVar x) t2]
                       (Res t Trivial Trivial oTop)
                       (Res t (isa oTop tpos) (isa oTop tneg) oTop))
          as Hsub2.
        {
          constructor. crush. apply Subtype_refl. crush.
          unfold isa.
          destruct (empty_dec tpos).
          {
            intuition.
            destruct (empty_dec (tAnd t (tNot tFalse))).
            {
              apply P_Absurd...
            }
            {
              contradiction.
            }
          }
          {
            apply P_Trivial.
          }
          unfold isa.
          destruct (empty_dec tneg).
          {
            intuition.
            destruct (empty_dec (tAnd t tFalse)).
            {
              apply P_Absurd...
            }
            {
              contradiction.
            }
          }
          {
            apply P_Trivial.
          }
          crush. ifcase...
          crush. repeat ifcase...
          ifcase...
        }
        assumption.
        crush.
        apply Entails_refl.
        constructor; crush.
      }
      destruct Hsub as [R' [Htype Hsub]].
      eapply T_Subsume. eassumption.
      crush.
      repeat ifcase...
    }
    assumption.
  }
  { (* T_If *)
    clear IHHtype2. clear IHHtype3.
    inversion Hstep; subst.
    { (* e1 --> e1' *)
      exists R; split.
      assert (exists R' : tres,
                 TypeOf [] e1' R'
                 /\ Subres [] R' (Res t1 p1 q1 o1))
        as H1 by (eapply IHHtype1; eauto).
      destruct H1 as [[t1' p1' q1' o1'] [Htype1' Hsub1']].
      inversion Hsub1'; subst.
      eapply T_If.
      eassumption.
      eapply If_then_impl; eauto.
      eapply If_else_impl; eauto.
      assumption.
      apply Subres_refl.
      assumption.
    }
    { (* (eIf false e2 e3) --> e3 *)
      exists R; split.
      eapply If_else_TypeOf; eauto.
      apply Subres_refl.
      assumption.
    }
    { (* (eIf non-false e2 e3) --> e2 *)
      exists R; split.
      eapply If_then_TypeOf; eauto.
      apply Subres_refl.
      assumption.      
    }
  }
Qed.
