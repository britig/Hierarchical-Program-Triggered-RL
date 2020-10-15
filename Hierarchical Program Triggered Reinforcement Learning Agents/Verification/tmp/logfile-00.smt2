(get-info :version)
; (:version "4.8.9")
; Started: 2020-09-17 00:05:15
; Silicon.version: 1.1-SNAPSHOT (52a0809d+)
; Input file: nn_agent.py
; Verifier id: 00
; ------------------------------------------------------------
; Begin preamble
; ////////// Static preamble
; 
; ; /z3config.smt2
(set-option :print-success true) ; Boogie: false
(set-option :global-decls true) ; Boogie: default
(set-option :auto_config false) ; Usually a good idea
(set-option :smt.restart_strategy 0)
(set-option :smt.restart_factor |1.5|)
(set-option :smt.case_split 3)
(set-option :smt.delay_units true)
(set-option :smt.delay_units_threshold 16)
(set-option :nnf.sk_hack true)
(set-option :type_check true)
(set-option :smt.bv.reflect true)
(set-option :smt.mbqi false)
(set-option :smt.qi.eager_threshold 100)
(set-option :smt.qi.cost "(+ weight generation)")
(set-option :smt.qi.max_multi_patterns 1000)
(set-option :smt.phase_selection 0) ; default: 3, Boogie: 0
(set-option :sat.phase caching)
(set-option :sat.random_seed 0)
(set-option :nlsat.randomize true)
(set-option :nlsat.seed 0)
(set-option :nlsat.shuffle_vars false)
(set-option :fp.spacer.order_children 0) ; Not available with Z3 4.5
(set-option :fp.spacer.random_seed 0) ; Not available with Z3 4.5
(set-option :smt.arith.random_initial_value true) ; Boogie: true
(set-option :smt.random_seed 0)
(set-option :sls.random_offset true)
(set-option :sls.random_seed 0)
(set-option :sls.restart_init false)
(set-option :sls.walksat_ucb true)
(set-option :model.v2 true)
; 
; ; /preamble.smt2
(declare-datatypes () ((
    $Snap ($Snap.unit)
    ($Snap.combine ($Snap.first $Snap) ($Snap.second $Snap)))))
(declare-sort $Ref 0)
(declare-const $Ref.null $Ref)
(declare-sort $FPM)
(declare-sort $PPM)
(define-sort $Perm () Real)
(define-const $Perm.Write $Perm 1.0)
(define-const $Perm.No $Perm 0.0)
(define-fun $Perm.isValidVar ((p $Perm)) Bool
	(<= $Perm.No p))
(define-fun $Perm.isReadVar ((p $Perm) (ub $Perm)) Bool
    (and ($Perm.isValidVar p)
         (not (= p $Perm.No))
         (< p $Perm.Write)))
(define-fun $Perm.min ((p1 $Perm) (p2 $Perm)) Real
    (ite (<= p1 p2) p1 p2))
(define-fun $Math.min ((a Int) (b Int)) Int
    (ite (<= a b) a b))
(define-fun $Math.clip ((a Int)) Int
    (ite (< a 0) 0 a))
; ////////// Sorts
(declare-sort Seq<$Ref>)
(declare-sort Seq<PyType>)
(declare-sort Seq<Int>)
(declare-sort Seq<Measure$>)
(declare-sort Set<$Ref>)
(declare-sort Set<Int>)
(declare-sort Set<Seq<$Ref>>)
(declare-sort Set<Set<$Ref>>)
(declare-sort Set<$Snap>)
(declare-sort _Name)
(declare-sort SIFDomain<Ref>)
(declare-sort PyType)
(declare-sort _list_ce_helper)
(declare-sort Measure$)
(declare-sort $FVF<$Ref>)
(declare-sort $FVF<Seq<$Ref>>)
; ////////// Sort wrappers
; Declaring additional sort wrappers
(declare-fun $SortWrappers.IntTo$Snap (Int) $Snap)
(declare-fun $SortWrappers.$SnapToInt ($Snap) Int)
(assert (forall ((x Int)) (!
    (= x ($SortWrappers.$SnapToInt($SortWrappers.IntTo$Snap x)))
    :pattern (($SortWrappers.IntTo$Snap x))
    :qid |$Snap.$SnapToIntTo$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.IntTo$Snap($SortWrappers.$SnapToInt x)))
    :pattern (($SortWrappers.$SnapToInt x))
    :qid |$Snap.IntTo$SnapToInt|
    )))
(declare-fun $SortWrappers.BoolTo$Snap (Bool) $Snap)
(declare-fun $SortWrappers.$SnapToBool ($Snap) Bool)
(assert (forall ((x Bool)) (!
    (= x ($SortWrappers.$SnapToBool($SortWrappers.BoolTo$Snap x)))
    :pattern (($SortWrappers.BoolTo$Snap x))
    :qid |$Snap.$SnapToBoolTo$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.BoolTo$Snap($SortWrappers.$SnapToBool x)))
    :pattern (($SortWrappers.$SnapToBool x))
    :qid |$Snap.BoolTo$SnapToBool|
    )))
(declare-fun $SortWrappers.$RefTo$Snap ($Ref) $Snap)
(declare-fun $SortWrappers.$SnapTo$Ref ($Snap) $Ref)
(assert (forall ((x $Ref)) (!
    (= x ($SortWrappers.$SnapTo$Ref($SortWrappers.$RefTo$Snap x)))
    :pattern (($SortWrappers.$RefTo$Snap x))
    :qid |$Snap.$SnapTo$RefTo$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.$RefTo$Snap($SortWrappers.$SnapTo$Ref x)))
    :pattern (($SortWrappers.$SnapTo$Ref x))
    :qid |$Snap.$RefTo$SnapTo$Ref|
    )))
(declare-fun $SortWrappers.$PermTo$Snap ($Perm) $Snap)
(declare-fun $SortWrappers.$SnapTo$Perm ($Snap) $Perm)
(assert (forall ((x $Perm)) (!
    (= x ($SortWrappers.$SnapTo$Perm($SortWrappers.$PermTo$Snap x)))
    :pattern (($SortWrappers.$PermTo$Snap x))
    :qid |$Snap.$SnapTo$PermTo$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.$PermTo$Snap($SortWrappers.$SnapTo$Perm x)))
    :pattern (($SortWrappers.$SnapTo$Perm x))
    :qid |$Snap.$PermTo$SnapTo$Perm|
    )))
; Declaring additional sort wrappers
(declare-fun $SortWrappers.Seq<$Ref>To$Snap (Seq<$Ref>) $Snap)
(declare-fun $SortWrappers.$SnapToSeq<$Ref> ($Snap) Seq<$Ref>)
(assert (forall ((x Seq<$Ref>)) (!
    (= x ($SortWrappers.$SnapToSeq<$Ref>($SortWrappers.Seq<$Ref>To$Snap x)))
    :pattern (($SortWrappers.Seq<$Ref>To$Snap x))
    :qid |$Snap.$SnapToSeq<$Ref>To$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.Seq<$Ref>To$Snap($SortWrappers.$SnapToSeq<$Ref> x)))
    :pattern (($SortWrappers.$SnapToSeq<$Ref> x))
    :qid |$Snap.Seq<$Ref>To$SnapToSeq<$Ref>|
    )))
(declare-fun $SortWrappers.Seq<PyType>To$Snap (Seq<PyType>) $Snap)
(declare-fun $SortWrappers.$SnapToSeq<PyType> ($Snap) Seq<PyType>)
(assert (forall ((x Seq<PyType>)) (!
    (= x ($SortWrappers.$SnapToSeq<PyType>($SortWrappers.Seq<PyType>To$Snap x)))
    :pattern (($SortWrappers.Seq<PyType>To$Snap x))
    :qid |$Snap.$SnapToSeq<PyType>To$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.Seq<PyType>To$Snap($SortWrappers.$SnapToSeq<PyType> x)))
    :pattern (($SortWrappers.$SnapToSeq<PyType> x))
    :qid |$Snap.Seq<PyType>To$SnapToSeq<PyType>|
    )))
(declare-fun $SortWrappers.Seq<Int>To$Snap (Seq<Int>) $Snap)
(declare-fun $SortWrappers.$SnapToSeq<Int> ($Snap) Seq<Int>)
(assert (forall ((x Seq<Int>)) (!
    (= x ($SortWrappers.$SnapToSeq<Int>($SortWrappers.Seq<Int>To$Snap x)))
    :pattern (($SortWrappers.Seq<Int>To$Snap x))
    :qid |$Snap.$SnapToSeq<Int>To$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.Seq<Int>To$Snap($SortWrappers.$SnapToSeq<Int> x)))
    :pattern (($SortWrappers.$SnapToSeq<Int> x))
    :qid |$Snap.Seq<Int>To$SnapToSeq<Int>|
    )))
(declare-fun $SortWrappers.Seq<Measure$>To$Snap (Seq<Measure$>) $Snap)
(declare-fun $SortWrappers.$SnapToSeq<Measure$> ($Snap) Seq<Measure$>)
(assert (forall ((x Seq<Measure$>)) (!
    (= x ($SortWrappers.$SnapToSeq<Measure$>($SortWrappers.Seq<Measure$>To$Snap x)))
    :pattern (($SortWrappers.Seq<Measure$>To$Snap x))
    :qid |$Snap.$SnapToSeq<Measure$>To$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.Seq<Measure$>To$Snap($SortWrappers.$SnapToSeq<Measure$> x)))
    :pattern (($SortWrappers.$SnapToSeq<Measure$> x))
    :qid |$Snap.Seq<Measure$>To$SnapToSeq<Measure$>|
    )))
; Declaring additional sort wrappers
(declare-fun $SortWrappers.Set<$Ref>To$Snap (Set<$Ref>) $Snap)
(declare-fun $SortWrappers.$SnapToSet<$Ref> ($Snap) Set<$Ref>)
(assert (forall ((x Set<$Ref>)) (!
    (= x ($SortWrappers.$SnapToSet<$Ref>($SortWrappers.Set<$Ref>To$Snap x)))
    :pattern (($SortWrappers.Set<$Ref>To$Snap x))
    :qid |$Snap.$SnapToSet<$Ref>To$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.Set<$Ref>To$Snap($SortWrappers.$SnapToSet<$Ref> x)))
    :pattern (($SortWrappers.$SnapToSet<$Ref> x))
    :qid |$Snap.Set<$Ref>To$SnapToSet<$Ref>|
    )))
(declare-fun $SortWrappers.Set<Int>To$Snap (Set<Int>) $Snap)
(declare-fun $SortWrappers.$SnapToSet<Int> ($Snap) Set<Int>)
(assert (forall ((x Set<Int>)) (!
    (= x ($SortWrappers.$SnapToSet<Int>($SortWrappers.Set<Int>To$Snap x)))
    :pattern (($SortWrappers.Set<Int>To$Snap x))
    :qid |$Snap.$SnapToSet<Int>To$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.Set<Int>To$Snap($SortWrappers.$SnapToSet<Int> x)))
    :pattern (($SortWrappers.$SnapToSet<Int> x))
    :qid |$Snap.Set<Int>To$SnapToSet<Int>|
    )))
(declare-fun $SortWrappers.Set<Seq<$Ref>>To$Snap (Set<Seq<$Ref>>) $Snap)
(declare-fun $SortWrappers.$SnapToSet<Seq<$Ref>> ($Snap) Set<Seq<$Ref>>)
(assert (forall ((x Set<Seq<$Ref>>)) (!
    (= x ($SortWrappers.$SnapToSet<Seq<$Ref>>($SortWrappers.Set<Seq<$Ref>>To$Snap x)))
    :pattern (($SortWrappers.Set<Seq<$Ref>>To$Snap x))
    :qid |$Snap.$SnapToSet<Seq<$Ref>>To$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.Set<Seq<$Ref>>To$Snap($SortWrappers.$SnapToSet<Seq<$Ref>> x)))
    :pattern (($SortWrappers.$SnapToSet<Seq<$Ref>> x))
    :qid |$Snap.Set<Seq<$Ref>>To$SnapToSet<Seq<$Ref>>|
    )))
(declare-fun $SortWrappers.Set<Set<$Ref>>To$Snap (Set<Set<$Ref>>) $Snap)
(declare-fun $SortWrappers.$SnapToSet<Set<$Ref>> ($Snap) Set<Set<$Ref>>)
(assert (forall ((x Set<Set<$Ref>>)) (!
    (= x ($SortWrappers.$SnapToSet<Set<$Ref>>($SortWrappers.Set<Set<$Ref>>To$Snap x)))
    :pattern (($SortWrappers.Set<Set<$Ref>>To$Snap x))
    :qid |$Snap.$SnapToSet<Set<$Ref>>To$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.Set<Set<$Ref>>To$Snap($SortWrappers.$SnapToSet<Set<$Ref>> x)))
    :pattern (($SortWrappers.$SnapToSet<Set<$Ref>> x))
    :qid |$Snap.Set<Set<$Ref>>To$SnapToSet<Set<$Ref>>|
    )))
(declare-fun $SortWrappers.Set<$Snap>To$Snap (Set<$Snap>) $Snap)
(declare-fun $SortWrappers.$SnapToSet<$Snap> ($Snap) Set<$Snap>)
(assert (forall ((x Set<$Snap>)) (!
    (= x ($SortWrappers.$SnapToSet<$Snap>($SortWrappers.Set<$Snap>To$Snap x)))
    :pattern (($SortWrappers.Set<$Snap>To$Snap x))
    :qid |$Snap.$SnapToSet<$Snap>To$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.Set<$Snap>To$Snap($SortWrappers.$SnapToSet<$Snap> x)))
    :pattern (($SortWrappers.$SnapToSet<$Snap> x))
    :qid |$Snap.Set<$Snap>To$SnapToSet<$Snap>|
    )))
; Declaring additional sort wrappers
(declare-fun $SortWrappers._NameTo$Snap (_Name) $Snap)
(declare-fun $SortWrappers.$SnapTo_Name ($Snap) _Name)
(assert (forall ((x _Name)) (!
    (= x ($SortWrappers.$SnapTo_Name($SortWrappers._NameTo$Snap x)))
    :pattern (($SortWrappers._NameTo$Snap x))
    :qid |$Snap.$SnapTo_NameTo$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers._NameTo$Snap($SortWrappers.$SnapTo_Name x)))
    :pattern (($SortWrappers.$SnapTo_Name x))
    :qid |$Snap._NameTo$SnapTo_Name|
    )))
(declare-fun $SortWrappers.SIFDomain<Ref>To$Snap (SIFDomain<Ref>) $Snap)
(declare-fun $SortWrappers.$SnapToSIFDomain<Ref> ($Snap) SIFDomain<Ref>)
(assert (forall ((x SIFDomain<Ref>)) (!
    (= x ($SortWrappers.$SnapToSIFDomain<Ref>($SortWrappers.SIFDomain<Ref>To$Snap x)))
    :pattern (($SortWrappers.SIFDomain<Ref>To$Snap x))
    :qid |$Snap.$SnapToSIFDomain<Ref>To$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.SIFDomain<Ref>To$Snap($SortWrappers.$SnapToSIFDomain<Ref> x)))
    :pattern (($SortWrappers.$SnapToSIFDomain<Ref> x))
    :qid |$Snap.SIFDomain<Ref>To$SnapToSIFDomain<Ref>|
    )))
(declare-fun $SortWrappers.PyTypeTo$Snap (PyType) $Snap)
(declare-fun $SortWrappers.$SnapToPyType ($Snap) PyType)
(assert (forall ((x PyType)) (!
    (= x ($SortWrappers.$SnapToPyType($SortWrappers.PyTypeTo$Snap x)))
    :pattern (($SortWrappers.PyTypeTo$Snap x))
    :qid |$Snap.$SnapToPyTypeTo$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.PyTypeTo$Snap($SortWrappers.$SnapToPyType x)))
    :pattern (($SortWrappers.$SnapToPyType x))
    :qid |$Snap.PyTypeTo$SnapToPyType|
    )))
(declare-fun $SortWrappers._list_ce_helperTo$Snap (_list_ce_helper) $Snap)
(declare-fun $SortWrappers.$SnapTo_list_ce_helper ($Snap) _list_ce_helper)
(assert (forall ((x _list_ce_helper)) (!
    (= x ($SortWrappers.$SnapTo_list_ce_helper($SortWrappers._list_ce_helperTo$Snap x)))
    :pattern (($SortWrappers._list_ce_helperTo$Snap x))
    :qid |$Snap.$SnapTo_list_ce_helperTo$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers._list_ce_helperTo$Snap($SortWrappers.$SnapTo_list_ce_helper x)))
    :pattern (($SortWrappers.$SnapTo_list_ce_helper x))
    :qid |$Snap._list_ce_helperTo$SnapTo_list_ce_helper|
    )))
(declare-fun $SortWrappers.Measure$To$Snap (Measure$) $Snap)
(declare-fun $SortWrappers.$SnapToMeasure$ ($Snap) Measure$)
(assert (forall ((x Measure$)) (!
    (= x ($SortWrappers.$SnapToMeasure$($SortWrappers.Measure$To$Snap x)))
    :pattern (($SortWrappers.Measure$To$Snap x))
    :qid |$Snap.$SnapToMeasure$To$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.Measure$To$Snap($SortWrappers.$SnapToMeasure$ x)))
    :pattern (($SortWrappers.$SnapToMeasure$ x))
    :qid |$Snap.Measure$To$SnapToMeasure$|
    )))
; Declaring additional sort wrappers
(declare-fun $SortWrappers.$FVF<$Ref>To$Snap ($FVF<$Ref>) $Snap)
(declare-fun $SortWrappers.$SnapTo$FVF<$Ref> ($Snap) $FVF<$Ref>)
(assert (forall ((x $FVF<$Ref>)) (!
    (= x ($SortWrappers.$SnapTo$FVF<$Ref>($SortWrappers.$FVF<$Ref>To$Snap x)))
    :pattern (($SortWrappers.$FVF<$Ref>To$Snap x))
    :qid |$Snap.$SnapTo$FVF<$Ref>To$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.$FVF<$Ref>To$Snap($SortWrappers.$SnapTo$FVF<$Ref> x)))
    :pattern (($SortWrappers.$SnapTo$FVF<$Ref> x))
    :qid |$Snap.$FVF<$Ref>To$SnapTo$FVF<$Ref>|
    )))
(declare-fun $SortWrappers.$FVF<Seq<$Ref>>To$Snap ($FVF<Seq<$Ref>>) $Snap)
(declare-fun $SortWrappers.$SnapTo$FVF<Seq<$Ref>> ($Snap) $FVF<Seq<$Ref>>)
(assert (forall ((x $FVF<Seq<$Ref>>)) (!
    (= x ($SortWrappers.$SnapTo$FVF<Seq<$Ref>>($SortWrappers.$FVF<Seq<$Ref>>To$Snap x)))
    :pattern (($SortWrappers.$FVF<Seq<$Ref>>To$Snap x))
    :qid |$Snap.$SnapTo$FVF<Seq<$Ref>>To$Snap|
    )))
(assert (forall ((x $Snap)) (!
    (= x ($SortWrappers.$FVF<Seq<$Ref>>To$Snap($SortWrappers.$SnapTo$FVF<Seq<$Ref>> x)))
    :pattern (($SortWrappers.$SnapTo$FVF<Seq<$Ref>> x))
    :qid |$Snap.$FVF<Seq<$Ref>>To$SnapTo$FVF<Seq<$Ref>>|
    )))
; ////////// Symbols
(declare-fun Set_in ($Ref Set<$Ref>) Bool)
(declare-fun Set_card (Set<$Ref>) Int)
(declare-const Set_empty Set<$Ref>)
(declare-fun Set_singleton ($Ref) Set<$Ref>)
(declare-fun Set_unionone (Set<$Ref> $Ref) Set<$Ref>)
(declare-fun Set_union (Set<$Ref> Set<$Ref>) Set<$Ref>)
(declare-fun Set_disjoint (Set<$Ref> Set<$Ref>) Bool)
(declare-fun Set_difference (Set<$Ref> Set<$Ref>) Set<$Ref>)
(declare-fun Set_intersection (Set<$Ref> Set<$Ref>) Set<$Ref>)
(declare-fun Set_subset (Set<$Ref> Set<$Ref>) Bool)
(declare-fun Set_equal (Set<$Ref> Set<$Ref>) Bool)
(declare-fun Set_in (Int Set<Int>) Bool)
(declare-fun Set_card (Set<Int>) Int)
(declare-const Set_empty Set<Int>)
(declare-fun Set_singleton (Int) Set<Int>)
(declare-fun Set_unionone (Set<Int> Int) Set<Int>)
(declare-fun Set_union (Set<Int> Set<Int>) Set<Int>)
(declare-fun Set_disjoint (Set<Int> Set<Int>) Bool)
(declare-fun Set_difference (Set<Int> Set<Int>) Set<Int>)
(declare-fun Set_intersection (Set<Int> Set<Int>) Set<Int>)
(declare-fun Set_subset (Set<Int> Set<Int>) Bool)
(declare-fun Set_equal (Set<Int> Set<Int>) Bool)
(declare-fun Set_in (Seq<$Ref> Set<Seq<$Ref>>) Bool)
(declare-fun Set_card (Set<Seq<$Ref>>) Int)
(declare-const Set_empty Set<Seq<$Ref>>)
(declare-fun Set_singleton (Seq<$Ref>) Set<Seq<$Ref>>)
(declare-fun Set_unionone (Set<Seq<$Ref>> Seq<$Ref>) Set<Seq<$Ref>>)
(declare-fun Set_union (Set<Seq<$Ref>> Set<Seq<$Ref>>) Set<Seq<$Ref>>)
(declare-fun Set_disjoint (Set<Seq<$Ref>> Set<Seq<$Ref>>) Bool)
(declare-fun Set_difference (Set<Seq<$Ref>> Set<Seq<$Ref>>) Set<Seq<$Ref>>)
(declare-fun Set_intersection (Set<Seq<$Ref>> Set<Seq<$Ref>>) Set<Seq<$Ref>>)
(declare-fun Set_subset (Set<Seq<$Ref>> Set<Seq<$Ref>>) Bool)
(declare-fun Set_equal (Set<Seq<$Ref>> Set<Seq<$Ref>>) Bool)
(declare-fun Set_in (Set<$Ref> Set<Set<$Ref>>) Bool)
(declare-fun Set_card (Set<Set<$Ref>>) Int)
(declare-const Set_empty Set<Set<$Ref>>)
(declare-fun Set_singleton (Set<$Ref>) Set<Set<$Ref>>)
(declare-fun Set_unionone (Set<Set<$Ref>> Set<$Ref>) Set<Set<$Ref>>)
(declare-fun Set_union (Set<Set<$Ref>> Set<Set<$Ref>>) Set<Set<$Ref>>)
(declare-fun Set_disjoint (Set<Set<$Ref>> Set<Set<$Ref>>) Bool)
(declare-fun Set_difference (Set<Set<$Ref>> Set<Set<$Ref>>) Set<Set<$Ref>>)
(declare-fun Set_intersection (Set<Set<$Ref>> Set<Set<$Ref>>) Set<Set<$Ref>>)
(declare-fun Set_subset (Set<Set<$Ref>> Set<Set<$Ref>>) Bool)
(declare-fun Set_equal (Set<Set<$Ref>> Set<Set<$Ref>>) Bool)
(declare-fun Set_in ($Snap Set<$Snap>) Bool)
(declare-fun Set_card (Set<$Snap>) Int)
(declare-const Set_empty Set<$Snap>)
(declare-fun Set_singleton ($Snap) Set<$Snap>)
(declare-fun Set_unionone (Set<$Snap> $Snap) Set<$Snap>)
(declare-fun Set_union (Set<$Snap> Set<$Snap>) Set<$Snap>)
(declare-fun Set_disjoint (Set<$Snap> Set<$Snap>) Bool)
(declare-fun Set_difference (Set<$Snap> Set<$Snap>) Set<$Snap>)
(declare-fun Set_intersection (Set<$Snap> Set<$Snap>) Set<$Snap>)
(declare-fun Set_subset (Set<$Snap> Set<$Snap>) Bool)
(declare-fun Set_equal (Set<$Snap> Set<$Snap>) Bool)
(declare-fun Seq_length (Seq<$Ref>) Int)
(declare-const Seq_empty Seq<$Ref>)
(declare-fun Seq_singleton ($Ref) Seq<$Ref>)
(declare-fun Seq_build (Seq<$Ref> $Ref) Seq<$Ref>)
(declare-fun Seq_index (Seq<$Ref> Int) $Ref)
(declare-fun Seq_append (Seq<$Ref> Seq<$Ref>) Seq<$Ref>)
(declare-fun Seq_update (Seq<$Ref> Int $Ref) Seq<$Ref>)
(declare-fun Seq_contains (Seq<$Ref> $Ref) Bool)
(declare-fun Seq_take (Seq<$Ref> Int) Seq<$Ref>)
(declare-fun Seq_drop (Seq<$Ref> Int) Seq<$Ref>)
(declare-fun Seq_equal (Seq<$Ref> Seq<$Ref>) Bool)
(declare-fun Seq_sameuntil (Seq<$Ref> Seq<$Ref> Int) Bool)
(declare-fun Seq_length (Seq<PyType>) Int)
(declare-const Seq_empty Seq<PyType>)
(declare-fun Seq_singleton (PyType) Seq<PyType>)
(declare-fun Seq_build (Seq<PyType> PyType) Seq<PyType>)
(declare-fun Seq_index (Seq<PyType> Int) PyType)
(declare-fun Seq_append (Seq<PyType> Seq<PyType>) Seq<PyType>)
(declare-fun Seq_update (Seq<PyType> Int PyType) Seq<PyType>)
(declare-fun Seq_contains (Seq<PyType> PyType) Bool)
(declare-fun Seq_take (Seq<PyType> Int) Seq<PyType>)
(declare-fun Seq_drop (Seq<PyType> Int) Seq<PyType>)
(declare-fun Seq_equal (Seq<PyType> Seq<PyType>) Bool)
(declare-fun Seq_sameuntil (Seq<PyType> Seq<PyType> Int) Bool)
(declare-fun Seq_length (Seq<Int>) Int)
(declare-const Seq_empty Seq<Int>)
(declare-fun Seq_singleton (Int) Seq<Int>)
(declare-fun Seq_build (Seq<Int> Int) Seq<Int>)
(declare-fun Seq_index (Seq<Int> Int) Int)
(declare-fun Seq_append (Seq<Int> Seq<Int>) Seq<Int>)
(declare-fun Seq_update (Seq<Int> Int Int) Seq<Int>)
(declare-fun Seq_contains (Seq<Int> Int) Bool)
(declare-fun Seq_take (Seq<Int> Int) Seq<Int>)
(declare-fun Seq_drop (Seq<Int> Int) Seq<Int>)
(declare-fun Seq_equal (Seq<Int> Seq<Int>) Bool)
(declare-fun Seq_sameuntil (Seq<Int> Seq<Int> Int) Bool)
(declare-fun Seq_range (Int Int) Seq<Int>)
(declare-fun Seq_length (Seq<Measure$>) Int)
(declare-const Seq_empty Seq<Measure$>)
(declare-fun Seq_singleton (Measure$) Seq<Measure$>)
(declare-fun Seq_build (Seq<Measure$> Measure$) Seq<Measure$>)
(declare-fun Seq_index (Seq<Measure$> Int) Measure$)
(declare-fun Seq_append (Seq<Measure$> Seq<Measure$>) Seq<Measure$>)
(declare-fun Seq_update (Seq<Measure$> Int Measure$) Seq<Measure$>)
(declare-fun Seq_contains (Seq<Measure$> Measure$) Bool)
(declare-fun Seq_take (Seq<Measure$> Int) Seq<Measure$>)
(declare-fun Seq_drop (Seq<Measure$> Int) Seq<Measure$>)
(declare-fun Seq_equal (Seq<Measure$> Seq<Measure$>) Bool)
(declare-fun Seq_sameuntil (Seq<Measure$> Seq<Measure$> Int) Bool)
(declare-fun Measure$create<Measure$> (Bool $Ref Int) Measure$)
(declare-fun Measure$guard<Bool> (Measure$) Bool)
(declare-fun Measure$key<Ref> (Measure$) $Ref)
(declare-fun Measure$value<Int> (Measure$) Int)
(declare-fun Low<Bool> ($Ref) Bool)
(declare-fun extends_<Bool> (PyType PyType) Bool)
(declare-fun issubtype<Bool> (PyType PyType) Bool)
(declare-fun isnotsubtype<Bool> (PyType PyType) Bool)
(declare-fun tuple_args<Seq<PyType>> (PyType) Seq<PyType>)
(declare-fun typeof<PyType> ($Ref) PyType)
(declare-fun get_basic<PyType> (PyType) PyType)
(declare-fun union_type_1<PyType> (PyType) PyType)
(declare-fun union_type_2<PyType> (PyType PyType) PyType)
(declare-fun union_type_3<PyType> (PyType PyType PyType) PyType)
(declare-fun union_type_4<PyType> (PyType PyType PyType PyType) PyType)
(declare-const object<PyType> PyType)
(declare-const list_basic<PyType> PyType)
(declare-fun list<PyType> (PyType) PyType)
(declare-fun list_arg<PyType> (PyType Int) PyType)
(declare-const set_basic<PyType> PyType)
(declare-fun set<PyType> (PyType) PyType)
(declare-fun set_arg<PyType> (PyType Int) PyType)
(declare-const dict_basic<PyType> PyType)
(declare-fun dict<PyType> (PyType PyType) PyType)
(declare-fun dict_arg<PyType> (PyType Int) PyType)
(declare-const int<PyType> PyType)
(declare-const float<PyType> PyType)
(declare-const bool<PyType> PyType)
(declare-const NoneType<PyType> PyType)
(declare-const Exception<PyType> PyType)
(declare-const traceback<PyType> PyType)
(declare-const str<PyType> PyType)
(declare-const bytes<PyType> PyType)
(declare-const tuple_basic<PyType> PyType)
(declare-fun tuple<PyType> (Seq<PyType>) PyType)
(declare-fun tuple_arg<PyType> (PyType Int) PyType)
(declare-const PSeq_basic<PyType> PyType)
(declare-fun PSeq<PyType> (PyType) PyType)
(declare-fun PSeq_arg<PyType> (PyType Int) PyType)
(declare-const PSet_basic<PyType> PyType)
(declare-fun PSet<PyType> (PyType) PyType)
(declare-fun PSet_arg<PyType> (PyType Int) PyType)
(declare-const PMultiset_basic<PyType> PyType)
(declare-fun PMultiset<PyType> (PyType) PyType)
(declare-fun PMultiset_arg<PyType> (PyType Int) PyType)
(declare-const slice<PyType> PyType)
(declare-const range<PyType> PyType)
(declare-const Iterator_basic<PyType> PyType)
(declare-fun Iterator<PyType> (PyType) PyType)
(declare-fun Iterator_arg<PyType> (PyType Int) PyType)
(declare-const Thread_0<PyType> PyType)
(declare-const LevelType<PyType> PyType)
(declare-const type<PyType> PyType)
(declare-const Place<PyType> PyType)
(declare-const __prim__Seq_type<PyType> PyType)
(declare-const NNAgent<PyType> PyType)
(declare-const Agent<PyType> PyType)
(declare-const Vehicle<PyType> PyType)
(declare-fun seq_ref_length<Int> (Seq<$Ref>) Int)
(declare-fun seq_ref_index<Ref> (Seq<$Ref> Int) $Ref)
(declare-fun _combine<_Name> (_Name _Name) _Name)
(declare-fun _single<_Name> (Int) _Name)
(declare-fun _get_combined_prefix<_Name> (_Name) _Name)
(declare-fun _get_combined_name<_Name> (_Name) _Name)
(declare-fun _get_value<Int> (_Name) Int)
(declare-fun _name_type<Bool> (_Name) Bool)
(declare-fun _is_single<Bool> (_Name) Bool)
(declare-fun _is_combined<Bool> (_Name) Bool)
; /field_value_functions_declarations.smt2 [Vehicle_id: Ref]
(declare-fun $FVF.domain_Vehicle_id ($FVF<$Ref>) Set<$Ref>)
(declare-fun $FVF.lookup_Vehicle_id ($FVF<$Ref> $Ref) $Ref)
(declare-fun $FVF.after_Vehicle_id ($FVF<$Ref> $FVF<$Ref>) Bool)
(declare-fun $FVF.loc_Vehicle_id ($Ref $Ref) Bool)
(declare-fun $FVF.perm_Vehicle_id ($FPM $Ref) $Perm)
(declare-const $fvfTOP_Vehicle_id $FVF<$Ref>)
; /field_value_functions_declarations.smt2 [list_acc: Seq[Ref]]
(declare-fun $FVF.domain_list_acc ($FVF<Seq<$Ref>>) Set<$Ref>)
(declare-fun $FVF.lookup_list_acc ($FVF<Seq<$Ref>> $Ref) Seq<$Ref>)
(declare-fun $FVF.after_list_acc ($FVF<Seq<$Ref>> $FVF<Seq<$Ref>>) Bool)
(declare-fun $FVF.loc_list_acc (Seq<$Ref> $Ref) Bool)
(declare-fun $FVF.perm_list_acc ($FPM $Ref) $Perm)
(declare-const $fvfTOP_list_acc $FVF<Seq<$Ref>>)
; /field_value_functions_declarations.smt2 [Vehicle_loc_x: Ref]
(declare-fun $FVF.domain_Vehicle_loc_x ($FVF<$Ref>) Set<$Ref>)
(declare-fun $FVF.lookup_Vehicle_loc_x ($FVF<$Ref> $Ref) $Ref)
(declare-fun $FVF.after_Vehicle_loc_x ($FVF<$Ref> $FVF<$Ref>) Bool)
(declare-fun $FVF.loc_Vehicle_loc_x ($Ref $Ref) Bool)
(declare-fun $FVF.perm_Vehicle_loc_x ($FPM $Ref) $Perm)
(declare-const $fvfTOP_Vehicle_loc_x $FVF<$Ref>)
; /field_value_functions_declarations.smt2 [Vehicle_loc_y: Ref]
(declare-fun $FVF.domain_Vehicle_loc_y ($FVF<$Ref>) Set<$Ref>)
(declare-fun $FVF.lookup_Vehicle_loc_y ($FVF<$Ref> $Ref) $Ref)
(declare-fun $FVF.after_Vehicle_loc_y ($FVF<$Ref> $FVF<$Ref>) Bool)
(declare-fun $FVF.loc_Vehicle_loc_y ($Ref $Ref) Bool)
(declare-fun $FVF.perm_Vehicle_loc_y ($FPM $Ref) $Perm)
(declare-const $fvfTOP_Vehicle_loc_y $FVF<$Ref>)
; /field_value_functions_declarations.smt2 [Vehicle_is_junction: Ref]
(declare-fun $FVF.domain_Vehicle_is_junction ($FVF<$Ref>) Set<$Ref>)
(declare-fun $FVF.lookup_Vehicle_is_junction ($FVF<$Ref> $Ref) $Ref)
(declare-fun $FVF.after_Vehicle_is_junction ($FVF<$Ref> $FVF<$Ref>) Bool)
(declare-fun $FVF.loc_Vehicle_is_junction ($Ref $Ref) Bool)
(declare-fun $FVF.perm_Vehicle_is_junction ($FPM $Ref) $Perm)
(declare-const $fvfTOP_Vehicle_is_junction $FVF<$Ref>)
; /field_value_functions_declarations.smt2 [NNAgent_vehicle_list: Ref]
(declare-fun $FVF.domain_NNAgent_vehicle_list ($FVF<$Ref>) Set<$Ref>)
(declare-fun $FVF.lookup_NNAgent_vehicle_list ($FVF<$Ref> $Ref) $Ref)
(declare-fun $FVF.after_NNAgent_vehicle_list ($FVF<$Ref> $FVF<$Ref>) Bool)
(declare-fun $FVF.loc_NNAgent_vehicle_list ($Ref $Ref) Bool)
(declare-fun $FVF.perm_NNAgent_vehicle_list ($FPM $Ref) $Perm)
(declare-const $fvfTOP_NNAgent_vehicle_list $FVF<$Ref>)
; /field_value_functions_declarations.smt2 [NNAgent_vehicle_list1: Ref]
(declare-fun $FVF.domain_NNAgent_vehicle_list1 ($FVF<$Ref>) Set<$Ref>)
(declare-fun $FVF.lookup_NNAgent_vehicle_list1 ($FVF<$Ref> $Ref) $Ref)
(declare-fun $FVF.after_NNAgent_vehicle_list1 ($FVF<$Ref> $FVF<$Ref>) Bool)
(declare-fun $FVF.loc_NNAgent_vehicle_list1 ($Ref $Ref) Bool)
(declare-fun $FVF.perm_NNAgent_vehicle_list1 ($FPM $Ref) $Perm)
(declare-const $fvfTOP_NNAgent_vehicle_list1 $FVF<$Ref>)
; /field_value_functions_declarations.smt2 [__previous: Seq[Ref]]
(declare-fun $FVF.domain___previous ($FVF<Seq<$Ref>>) Set<$Ref>)
(declare-fun $FVF.lookup___previous ($FVF<Seq<$Ref>> $Ref) Seq<$Ref>)
(declare-fun $FVF.after___previous ($FVF<Seq<$Ref>> $FVF<Seq<$Ref>>) Bool)
(declare-fun $FVF.loc___previous (Seq<$Ref> $Ref) Bool)
(declare-fun $FVF.perm___previous ($FPM $Ref) $Perm)
(declare-const $fvfTOP___previous $FVF<Seq<$Ref>>)
; Declaring symbols related to program functions (from program analysis)
(declare-fun tuple___val__ ($Snap $Ref) Seq<$Ref>)
(declare-fun tuple___val__%limited ($Snap $Ref) Seq<$Ref>)
(declare-fun tuple___val__%stateless ($Ref) Bool)
(declare-fun range___val__ ($Snap $Ref) Seq<Int>)
(declare-fun range___val__%limited ($Snap $Ref) Seq<Int>)
(declare-fun range___val__%stateless ($Ref) Bool)
(declare-fun tuple___len__ ($Snap $Ref) Int)
(declare-fun tuple___len__%limited ($Snap $Ref) Int)
(declare-fun tuple___len__%stateless ($Ref) Bool)
(declare-fun int___unbox__ ($Snap $Ref) Int)
(declare-fun int___unbox__%limited ($Snap $Ref) Int)
(declare-fun int___unbox__%stateless ($Ref) Bool)
(declare-fun __prim__bool___box__ ($Snap Bool) $Ref)
(declare-fun __prim__bool___box__%limited ($Snap Bool) $Ref)
(declare-fun __prim__bool___box__%stateless (Bool) Bool)
(declare-fun bool___unbox__ ($Snap $Ref) Bool)
(declare-fun bool___unbox__%limited ($Snap $Ref) Bool)
(declare-fun bool___unbox__%stateless ($Ref) Bool)
(declare-fun __prim__int___box__ ($Snap Int) $Ref)
(declare-fun __prim__int___box__%limited ($Snap Int) $Ref)
(declare-fun __prim__int___box__%stateless (Int) Bool)
(declare-fun range___len__ ($Snap $Ref) Int)
(declare-fun range___len__%limited ($Snap $Ref) Int)
(declare-fun range___len__%stateless ($Ref) Bool)
(declare-fun _isDefined ($Snap Int) Bool)
(declare-fun _isDefined%limited ($Snap Int) Bool)
(declare-fun _isDefined%stateless (Int) Bool)
(declare-fun tuple___getitem__ ($Snap $Ref Int) $Ref)
(declare-fun tuple___getitem__%limited ($Snap $Ref Int) $Ref)
(declare-fun tuple___getitem__%stateless ($Ref Int) Bool)
(declare-fun list___len__ ($Snap $Ref) Int)
(declare-fun list___len__%limited ($Snap $Ref) Int)
(declare-fun list___len__%stateless ($Ref) Bool)
(declare-fun str___val__ ($Snap $Ref) Int)
(declare-fun str___val__%limited ($Snap $Ref) Int)
(declare-fun str___val__%stateless ($Ref) Bool)
(declare-fun str___len__ ($Snap $Ref) Int)
(declare-fun str___len__%limited ($Snap $Ref) Int)
(declare-fun str___len__%stateless ($Ref) Bool)
(declare-fun range___stop__ ($Snap $Ref) Int)
(declare-fun range___stop__%limited ($Snap $Ref) Int)
(declare-fun range___stop__%stateless ($Ref) Bool)
(declare-fun range___start__ ($Snap $Ref) Int)
(declare-fun range___start__%limited ($Snap $Ref) Int)
(declare-fun range___start__%stateless ($Ref) Bool)
(declare-fun Measure$check ($Snap Seq<Measure$> $Ref Int) Bool)
(declare-fun Measure$check%limited ($Snap Seq<Measure$> $Ref Int) Bool)
(declare-fun Measure$check%stateless (Seq<Measure$> $Ref Int) Bool)
(declare-fun list___contains__ ($Snap $Ref $Ref) Bool)
(declare-fun list___contains__%limited ($Snap $Ref $Ref) Bool)
(declare-fun list___contains__%stateless ($Ref $Ref) Bool)
(declare-fun object___eq__ ($Snap $Ref $Ref) Bool)
(declare-fun object___eq__%limited ($Snap $Ref $Ref) Bool)
(declare-fun object___eq__%stateless ($Ref $Ref) Bool)
(declare-fun int___mul__ ($Snap Int Int) Int)
(declare-fun int___mul__%limited ($Snap Int Int) Int)
(declare-fun int___mul__%stateless (Int Int) Bool)
(declare-fun int___sub__ ($Snap Int Int) Int)
(declare-fun int___sub__%limited ($Snap Int Int) Int)
(declare-fun int___sub__%stateless (Int Int) Bool)
(declare-fun int___gt__ ($Snap Int Int) Bool)
(declare-fun int___gt__%limited ($Snap Int Int) Bool)
(declare-fun int___gt__%stateless (Int Int) Bool)
(declare-fun object___cast__ ($Snap PyType $Ref) $Ref)
(declare-fun object___cast__%limited ($Snap PyType $Ref) $Ref)
(declare-fun object___cast__%stateless (PyType $Ref) Bool)
(declare-fun range___sil_seq__ ($Snap $Ref) Seq<$Ref>)
(declare-fun range___sil_seq__%limited ($Snap $Ref) Seq<$Ref>)
(declare-fun range___sil_seq__%stateless ($Ref) Bool)
(declare-fun bool___eq__ ($Snap $Ref $Ref) Bool)
(declare-fun bool___eq__%limited ($Snap $Ref $Ref) Bool)
(declare-fun bool___eq__%stateless ($Ref $Ref) Bool)
(declare-fun int___lt__ ($Snap Int Int) Bool)
(declare-fun int___lt__%limited ($Snap Int Int) Bool)
(declare-fun int___lt__%stateless (Int Int) Bool)
(declare-fun Level ($Snap $Ref) $Perm)
(declare-fun Level%limited ($Snap $Ref) $Perm)
(declare-fun Level%stateless ($Ref) Bool)
(declare-fun _checkDefined ($Snap $Ref Int) $Ref)
(declare-fun _checkDefined%limited ($Snap $Ref Int) $Ref)
(declare-fun _checkDefined%stateless ($Ref Int) Bool)
(declare-fun tuple___create2__ ($Snap $Ref $Ref PyType PyType Int) $Ref)
(declare-fun tuple___create2__%limited ($Snap $Ref $Ref PyType PyType Int) $Ref)
(declare-fun tuple___create2__%stateless ($Ref $Ref PyType PyType Int) Bool)
(declare-fun Agent_execute_nn_control ($Snap $Ref) $Ref)
(declare-fun Agent_execute_nn_control%limited ($Snap $Ref) $Ref)
(declare-fun Agent_execute_nn_control%stateless ($Ref) Bool)
(declare-fun float___create__ ($Snap Int) $Ref)
(declare-fun float___create__%limited ($Snap Int) $Ref)
(declare-fun float___create__%stateless (Int) Bool)
(declare-fun set___contains__ ($Snap $Ref $Ref) Bool)
(declare-fun set___contains__%limited ($Snap $Ref $Ref) Bool)
(declare-fun set___contains__%stateless ($Ref $Ref) Bool)
(declare-fun int___eq__ ($Snap $Ref $Ref) Bool)
(declare-fun int___eq__%limited ($Snap $Ref $Ref) Bool)
(declare-fun int___eq__%stateless ($Ref $Ref) Bool)
(declare-fun list___getitem__ ($Snap $Ref $Ref) $Ref)
(declare-fun list___getitem__%limited ($Snap $Ref $Ref) $Ref)
(declare-fun list___getitem__%stateless ($Ref $Ref) Bool)
(declare-fun int___add__ ($Snap Int Int) Int)
(declare-fun int___add__%limited ($Snap Int Int) Int)
(declare-fun int___add__%stateless (Int Int) Bool)
(declare-fun str___create__ ($Snap Int Int) $Ref)
(declare-fun str___create__%limited ($Snap Int Int) $Ref)
(declare-fun str___create__%stateless (Int Int) Bool)
(declare-fun list___sil_seq__ ($Snap $Ref) Seq<$Ref>)
(declare-fun list___sil_seq__%limited ($Snap $Ref) Seq<$Ref>)
(declare-fun list___sil_seq__%stateless ($Ref) Bool)
(declare-fun range___create__ ($Snap Int Int Int) $Ref)
(declare-fun range___create__%limited ($Snap Int Int Int) $Ref)
(declare-fun range___create__%stateless (Int Int Int) Bool)
(declare-fun int___le__ ($Snap Int Int) Bool)
(declare-fun int___le__%limited ($Snap Int Int) Bool)
(declare-fun int___le__%stateless (Int Int) Bool)
; Snapshot variable to be used during function verification
(declare-fun s@$ () $Snap)
; Declaring predicate trigger functions
(declare-fun MustTerminate%trigger ($Snap $Ref) Bool)
(declare-fun MustInvokeBounded%trigger ($Snap $Ref) Bool)
(declare-fun MustInvokeUnbounded%trigger ($Snap $Ref) Bool)
(declare-fun _MaySet%trigger ($Snap $Ref Int) Bool)
; ////////// Uniqueness assumptions from domains
(assert (distinct object<PyType> list_basic<PyType> set_basic<PyType> dict_basic<PyType> int<PyType> float<PyType> bool<PyType> NoneType<PyType> Exception<PyType> traceback<PyType> str<PyType> bytes<PyType> tuple_basic<PyType> PSeq_basic<PyType> PSet_basic<PyType> PMultiset_basic<PyType> slice<PyType> range<PyType> Iterator_basic<PyType> Thread_0<PyType> LevelType<PyType> type<PyType> Place<PyType> __prim__Seq_type<PyType> NNAgent<PyType> Agent<PyType> Vehicle<PyType>))
; ////////// Axioms
(assert (forall ((s Seq<$Ref>)) (!
  (<= 0 (Seq_length s))
  :pattern ((Seq_length s))
  )))
(assert (= (Seq_length (as Seq_empty  Seq<$Ref>)) 0))
(assert (forall ((s Seq<$Ref>)) (!
  (implies (= (Seq_length s) 0) (= s (as Seq_empty  Seq<$Ref>)))
  :pattern ((Seq_length s))
  )))
(assert (forall ((e $Ref)) (!
  (= (Seq_length (Seq_singleton e)) 1)
  :pattern ((Seq_length (Seq_singleton e)))
  )))
(assert (forall ((s Seq<$Ref>) (e $Ref)) (!
  (= (Seq_length (Seq_build s e)) (+ 1 (Seq_length s)))
  :pattern ((Seq_length (Seq_build s e)))
  )))
(assert (forall ((s Seq<$Ref>) (i Int) (e $Ref)) (!
  (ite
    (= i (Seq_length s))
    (= (Seq_index (Seq_build s e) i) e)
    (= (Seq_index (Seq_build s e) i) (Seq_index s i)))
  :pattern ((Seq_index (Seq_build s e) i))
  )))
(assert (forall ((s1 Seq<$Ref>) (s2 Seq<$Ref>)) (!
  (implies
    (and
      (not (= s1 (as Seq_empty  Seq<$Ref>)))
      (not (= s2 (as Seq_empty  Seq<$Ref>))))
    (= (Seq_length (Seq_append s1 s2)) (+ (Seq_length s1) (Seq_length s2))))
  :pattern ((Seq_length (Seq_append s1 s2)))
  )))
(assert (forall ((e $Ref)) (!
  (= (Seq_index (Seq_singleton e) 0) e)
  :pattern ((Seq_index (Seq_singleton e) 0))
  )))
(assert (forall ((e1 $Ref) (e2 $Ref)) (!
  (= (Seq_contains (Seq_singleton e1) e2) (= e1 e2))
  :pattern ((Seq_contains (Seq_singleton e1) e2))
  )))
(assert (forall ((s Seq<$Ref>)) (!
  (= (Seq_append (as Seq_empty  Seq<$Ref>) s) s)
  :pattern ((Seq_append (as Seq_empty  Seq<$Ref>) s))
  )))
(assert (forall ((s Seq<$Ref>)) (!
  (= (Seq_append s (as Seq_empty  Seq<$Ref>)) s)
  :pattern ((Seq_append s (as Seq_empty  Seq<$Ref>)))
  )))
(assert (forall ((s1 Seq<$Ref>) (s2 Seq<$Ref>) (i Int)) (!
  (implies
    (and
      (not (= s1 (as Seq_empty  Seq<$Ref>)))
      (not (= s2 (as Seq_empty  Seq<$Ref>))))
    (ite
      (< i (Seq_length s1))
      (= (Seq_index (Seq_append s1 s2) i) (Seq_index s1 i))
      (= (Seq_index (Seq_append s1 s2) i) (Seq_index s2 (- i (Seq_length s1))))))
  :pattern ((Seq_index (Seq_append s1 s2) i))
  :pattern ((Seq_index s1 i) (Seq_append s1 s2))
  )))
(assert (forall ((s Seq<$Ref>) (i Int) (e $Ref)) (!
  (implies
    (and (<= 0 i) (< i (Seq_length s)))
    (= (Seq_length (Seq_update s i e)) (Seq_length s)))
  :pattern ((Seq_length (Seq_update s i e)))
  )))
(assert (forall ((s Seq<$Ref>) (i Int) (e $Ref) (j Int)) (!
  (ite
    (implies (and (<= 0 i) (< i (Seq_length s))) (= i j))
    (= (Seq_index (Seq_update s i e) j) e)
    (= (Seq_index (Seq_update s i e) j) (Seq_index s j)))
  :pattern ((Seq_index (Seq_update s i e) j))
  )))
(assert (forall ((s Seq<$Ref>) (e $Ref)) (!
  (=
    (Seq_contains s e)
    (exists ((i Int)) (!
      (and (<= 0 i) (and (< i (Seq_length s)) (= (Seq_index s i) e)))
      :pattern ((Seq_index s i))
      )))
  :pattern ((Seq_contains s e))
  )))
(assert (forall ((e $Ref)) (!
  (not (Seq_contains (as Seq_empty  Seq<$Ref>) e))
  :pattern ((Seq_contains (as Seq_empty  Seq<$Ref>) e))
  )))
(assert (forall ((s1 Seq<$Ref>) (s2 Seq<$Ref>) (e $Ref)) (!
  (=
    (Seq_contains (Seq_append s1 s2) e)
    (or (Seq_contains s1 e) (Seq_contains s2 e)))
  :pattern ((Seq_contains (Seq_append s1 s2) e))
  )))
(assert (forall ((s Seq<$Ref>) (e1 $Ref) (e2 $Ref)) (!
  (= (Seq_contains (Seq_build s e1) e2) (or (= e1 e2) (Seq_contains s e2)))
  :pattern ((Seq_contains (Seq_build s e1) e2))
  )))
(assert (forall ((s Seq<$Ref>) (n Int)) (!
  (implies (<= n 0) (= (Seq_take s n) (as Seq_empty  Seq<$Ref>)))
  :pattern ((Seq_take s n))
  )))
(assert (forall ((s Seq<$Ref>) (n Int) (e $Ref)) (!
  (=
    (Seq_contains (Seq_take s n) e)
    (exists ((i Int)) (!
      (and
        (<= 0 i)
        (and (< i n) (and (< i (Seq_length s)) (= (Seq_index s i) e))))
      :pattern ((Seq_index s i))
      )))
  :pattern ((Seq_contains (Seq_take s n) e))
  )))
(assert (forall ((s Seq<$Ref>) (n Int)) (!
  (implies (<= n 0) (= (Seq_drop s n) s))
  :pattern ((Seq_drop s n))
  )))
(assert (forall ((s Seq<$Ref>) (n Int) (e $Ref)) (!
  (=
    (Seq_contains (Seq_drop s n) e)
    (exists ((i Int)) (!
      (and
        (<= 0 i)
        (and (<= n i) (and (< i (Seq_length s)) (= (Seq_index s i) e))))
      :pattern ((Seq_index s i))
      )))
  :pattern ((Seq_contains (Seq_drop s n) e))
  )))
(assert (forall ((s1 Seq<$Ref>) (s2 Seq<$Ref>)) (!
  (=
    (Seq_equal s1 s2)
    (and
      (= (Seq_length s1) (Seq_length s2))
      (forall ((i Int)) (!
        (implies
          (and (<= 0 i) (< i (Seq_length s1)))
          (= (Seq_index s1 i) (Seq_index s2 i)))
        :pattern ((Seq_index s1 i))
        :pattern ((Seq_index s2 i))
        ))))
  :pattern ((Seq_equal s1 s2))
  )))
(assert (forall ((s1 Seq<$Ref>) (s2 Seq<$Ref>)) (!
  (implies (Seq_equal s1 s2) (= s1 s2))
  :pattern ((Seq_equal s1 s2))
  )))
(assert (forall ((s1 Seq<$Ref>) (s2 Seq<$Ref>) (n Int)) (!
  (=
    (Seq_sameuntil s1 s2 n)
    (forall ((i Int)) (!
      (implies (and (<= 0 i) (< i n)) (= (Seq_index s1 i) (Seq_index s2 i)))
      :pattern ((Seq_index s1 i))
      :pattern ((Seq_index s2 i))
      )))
  :pattern ((Seq_sameuntil s1 s2 n))
  )))
(assert (forall ((s Seq<$Ref>) (n Int)) (!
  (implies
    (<= 0 n)
    (ite
      (<= n (Seq_length s))
      (= (Seq_length (Seq_take s n)) n)
      (= (Seq_length (Seq_take s n)) (Seq_length s))))
  :pattern ((Seq_length (Seq_take s n)))
  )))
(assert (forall ((s Seq<$Ref>) (n Int) (i Int)) (!
  (implies
    (and (<= 0 i) (and (< i n) (< i (Seq_length s))))
    (= (Seq_index (Seq_take s n) i) (Seq_index s i)))
  :pattern ((Seq_index (Seq_take s n) i))
  :pattern ((Seq_index s i) (Seq_take s n))
  )))
(assert (forall ((s Seq<$Ref>) (n Int)) (!
  (implies
    (<= 0 n)
    (ite
      (<= n (Seq_length s))
      (= (Seq_length (Seq_drop s n)) (- (Seq_length s) n))
      (= (Seq_length (Seq_drop s n)) 0)))
  :pattern ((Seq_length (Seq_drop s n)))
  )))
(assert (forall ((s Seq<$Ref>) (n Int) (i Int)) (!
  (implies
    (and (<= 0 n) (and (<= 0 i) (< i (- (Seq_length s) n))))
    (= (Seq_index (Seq_drop s n) i) (Seq_index s (+ i n))))
  :pattern ((Seq_index (Seq_drop s n) i))
  )))
(assert (forall ((s Seq<$Ref>) (n Int) (i Int)) (!
  (implies
    (and (<= 0 n) (and (<= n i) (< i (Seq_length s))))
    (= (Seq_index (Seq_drop s n) (- i n)) (Seq_index s i)))
  :pattern ((Seq_index s i) (Seq_drop s n))
  )))
(assert (forall ((s Seq<$Ref>) (i Int) (e $Ref) (n Int)) (!
  (implies
    (and (<= 0 i) (and (< i n) (< n (Seq_length s))))
    (= (Seq_take (Seq_update s i e) n) (Seq_update (Seq_take s n) i e)))
  :pattern ((Seq_take (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<$Ref>) (i Int) (e $Ref) (n Int)) (!
  (implies
    (and (<= n i) (< i (Seq_length s)))
    (= (Seq_take (Seq_update s i e) n) (Seq_take s n)))
  :pattern ((Seq_take (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<$Ref>) (i Int) (e $Ref) (n Int)) (!
  (implies
    (and (<= 0 n) (and (<= n i) (< i (Seq_length s))))
    (= (Seq_drop (Seq_update s i e) n) (Seq_update (Seq_drop s n) (- i n) e)))
  :pattern ((Seq_drop (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<$Ref>) (i Int) (e $Ref) (n Int)) (!
  (implies
    (and (<= 0 i) (and (< i n) (< n (Seq_length s))))
    (= (Seq_drop (Seq_update s i e) n) (Seq_drop s n)))
  :pattern ((Seq_drop (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<$Ref>) (e $Ref) (n Int)) (!
  (implies
    (and (<= 0 n) (<= n (Seq_length s)))
    (= (Seq_drop (Seq_build s e) n) (Seq_build (Seq_drop s n) e)))
  :pattern ((Seq_drop (Seq_build s e) n))
  )))
(assert (forall ((s Seq<PyType>)) (!
  (<= 0 (Seq_length s))
  :pattern ((Seq_length s))
  )))
(assert (= (Seq_length (as Seq_empty  Seq<PyType>)) 0))
(assert (forall ((s Seq<PyType>)) (!
  (implies (= (Seq_length s) 0) (= s (as Seq_empty  Seq<PyType>)))
  :pattern ((Seq_length s))
  )))
(assert (forall ((e PyType)) (!
  (= (Seq_length (Seq_singleton e)) 1)
  :pattern ((Seq_length (Seq_singleton e)))
  )))
(assert (forall ((s Seq<PyType>) (e PyType)) (!
  (= (Seq_length (Seq_build s e)) (+ 1 (Seq_length s)))
  :pattern ((Seq_length (Seq_build s e)))
  )))
(assert (forall ((s Seq<PyType>) (i Int) (e PyType)) (!
  (ite
    (= i (Seq_length s))
    (= (Seq_index (Seq_build s e) i) e)
    (= (Seq_index (Seq_build s e) i) (Seq_index s i)))
  :pattern ((Seq_index (Seq_build s e) i))
  )))
(assert (forall ((s1 Seq<PyType>) (s2 Seq<PyType>)) (!
  (implies
    (and
      (not (= s1 (as Seq_empty  Seq<PyType>)))
      (not (= s2 (as Seq_empty  Seq<PyType>))))
    (= (Seq_length (Seq_append s1 s2)) (+ (Seq_length s1) (Seq_length s2))))
  :pattern ((Seq_length (Seq_append s1 s2)))
  )))
(assert (forall ((e PyType)) (!
  (= (Seq_index (Seq_singleton e) 0) e)
  :pattern ((Seq_index (Seq_singleton e) 0))
  )))
(assert (forall ((e1 PyType) (e2 PyType)) (!
  (= (Seq_contains (Seq_singleton e1) e2) (= e1 e2))
  :pattern ((Seq_contains (Seq_singleton e1) e2))
  )))
(assert (forall ((s Seq<PyType>)) (!
  (= (Seq_append (as Seq_empty  Seq<PyType>) s) s)
  :pattern ((Seq_append (as Seq_empty  Seq<PyType>) s))
  )))
(assert (forall ((s Seq<PyType>)) (!
  (= (Seq_append s (as Seq_empty  Seq<PyType>)) s)
  :pattern ((Seq_append s (as Seq_empty  Seq<PyType>)))
  )))
(assert (forall ((s1 Seq<PyType>) (s2 Seq<PyType>) (i Int)) (!
  (implies
    (and
      (not (= s1 (as Seq_empty  Seq<PyType>)))
      (not (= s2 (as Seq_empty  Seq<PyType>))))
    (ite
      (< i (Seq_length s1))
      (= (Seq_index (Seq_append s1 s2) i) (Seq_index s1 i))
      (= (Seq_index (Seq_append s1 s2) i) (Seq_index s2 (- i (Seq_length s1))))))
  :pattern ((Seq_index (Seq_append s1 s2) i))
  :pattern ((Seq_index s1 i) (Seq_append s1 s2))
  )))
(assert (forall ((s Seq<PyType>) (i Int) (e PyType)) (!
  (implies
    (and (<= 0 i) (< i (Seq_length s)))
    (= (Seq_length (Seq_update s i e)) (Seq_length s)))
  :pattern ((Seq_length (Seq_update s i e)))
  )))
(assert (forall ((s Seq<PyType>) (i Int) (e PyType) (j Int)) (!
  (ite
    (implies (and (<= 0 i) (< i (Seq_length s))) (= i j))
    (= (Seq_index (Seq_update s i e) j) e)
    (= (Seq_index (Seq_update s i e) j) (Seq_index s j)))
  :pattern ((Seq_index (Seq_update s i e) j))
  )))
(assert (forall ((s Seq<PyType>) (e PyType)) (!
  (=
    (Seq_contains s e)
    (exists ((i Int)) (!
      (and (<= 0 i) (and (< i (Seq_length s)) (= (Seq_index s i) e)))
      :pattern ((Seq_index s i))
      )))
  :pattern ((Seq_contains s e))
  )))
(assert (forall ((e PyType)) (!
  (not (Seq_contains (as Seq_empty  Seq<PyType>) e))
  :pattern ((Seq_contains (as Seq_empty  Seq<PyType>) e))
  )))
(assert (forall ((s1 Seq<PyType>) (s2 Seq<PyType>) (e PyType)) (!
  (=
    (Seq_contains (Seq_append s1 s2) e)
    (or (Seq_contains s1 e) (Seq_contains s2 e)))
  :pattern ((Seq_contains (Seq_append s1 s2) e))
  )))
(assert (forall ((s Seq<PyType>) (e1 PyType) (e2 PyType)) (!
  (= (Seq_contains (Seq_build s e1) e2) (or (= e1 e2) (Seq_contains s e2)))
  :pattern ((Seq_contains (Seq_build s e1) e2))
  )))
(assert (forall ((s Seq<PyType>) (n Int)) (!
  (implies (<= n 0) (= (Seq_take s n) (as Seq_empty  Seq<PyType>)))
  :pattern ((Seq_take s n))
  )))
(assert (forall ((s Seq<PyType>) (n Int) (e PyType)) (!
  (=
    (Seq_contains (Seq_take s n) e)
    (exists ((i Int)) (!
      (and
        (<= 0 i)
        (and (< i n) (and (< i (Seq_length s)) (= (Seq_index s i) e))))
      :pattern ((Seq_index s i))
      )))
  :pattern ((Seq_contains (Seq_take s n) e))
  )))
(assert (forall ((s Seq<PyType>) (n Int)) (!
  (implies (<= n 0) (= (Seq_drop s n) s))
  :pattern ((Seq_drop s n))
  )))
(assert (forall ((s Seq<PyType>) (n Int) (e PyType)) (!
  (=
    (Seq_contains (Seq_drop s n) e)
    (exists ((i Int)) (!
      (and
        (<= 0 i)
        (and (<= n i) (and (< i (Seq_length s)) (= (Seq_index s i) e))))
      :pattern ((Seq_index s i))
      )))
  :pattern ((Seq_contains (Seq_drop s n) e))
  )))
(assert (forall ((s1 Seq<PyType>) (s2 Seq<PyType>)) (!
  (=
    (Seq_equal s1 s2)
    (and
      (= (Seq_length s1) (Seq_length s2))
      (forall ((i Int)) (!
        (implies
          (and (<= 0 i) (< i (Seq_length s1)))
          (= (Seq_index s1 i) (Seq_index s2 i)))
        :pattern ((Seq_index s1 i))
        :pattern ((Seq_index s2 i))
        ))))
  :pattern ((Seq_equal s1 s2))
  )))
(assert (forall ((s1 Seq<PyType>) (s2 Seq<PyType>)) (!
  (implies (Seq_equal s1 s2) (= s1 s2))
  :pattern ((Seq_equal s1 s2))
  )))
(assert (forall ((s1 Seq<PyType>) (s2 Seq<PyType>) (n Int)) (!
  (=
    (Seq_sameuntil s1 s2 n)
    (forall ((i Int)) (!
      (implies (and (<= 0 i) (< i n)) (= (Seq_index s1 i) (Seq_index s2 i)))
      :pattern ((Seq_index s1 i))
      :pattern ((Seq_index s2 i))
      )))
  :pattern ((Seq_sameuntil s1 s2 n))
  )))
(assert (forall ((s Seq<PyType>) (n Int)) (!
  (implies
    (<= 0 n)
    (ite
      (<= n (Seq_length s))
      (= (Seq_length (Seq_take s n)) n)
      (= (Seq_length (Seq_take s n)) (Seq_length s))))
  :pattern ((Seq_length (Seq_take s n)))
  )))
(assert (forall ((s Seq<PyType>) (n Int) (i Int)) (!
  (implies
    (and (<= 0 i) (and (< i n) (< i (Seq_length s))))
    (= (Seq_index (Seq_take s n) i) (Seq_index s i)))
  :pattern ((Seq_index (Seq_take s n) i))
  :pattern ((Seq_index s i) (Seq_take s n))
  )))
(assert (forall ((s Seq<PyType>) (n Int)) (!
  (implies
    (<= 0 n)
    (ite
      (<= n (Seq_length s))
      (= (Seq_length (Seq_drop s n)) (- (Seq_length s) n))
      (= (Seq_length (Seq_drop s n)) 0)))
  :pattern ((Seq_length (Seq_drop s n)))
  )))
(assert (forall ((s Seq<PyType>) (n Int) (i Int)) (!
  (implies
    (and (<= 0 n) (and (<= 0 i) (< i (- (Seq_length s) n))))
    (= (Seq_index (Seq_drop s n) i) (Seq_index s (+ i n))))
  :pattern ((Seq_index (Seq_drop s n) i))
  )))
(assert (forall ((s Seq<PyType>) (n Int) (i Int)) (!
  (implies
    (and (<= 0 n) (and (<= n i) (< i (Seq_length s))))
    (= (Seq_index (Seq_drop s n) (- i n)) (Seq_index s i)))
  :pattern ((Seq_index s i) (Seq_drop s n))
  )))
(assert (forall ((s Seq<PyType>) (i Int) (e PyType) (n Int)) (!
  (implies
    (and (<= 0 i) (and (< i n) (< n (Seq_length s))))
    (= (Seq_take (Seq_update s i e) n) (Seq_update (Seq_take s n) i e)))
  :pattern ((Seq_take (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<PyType>) (i Int) (e PyType) (n Int)) (!
  (implies
    (and (<= n i) (< i (Seq_length s)))
    (= (Seq_take (Seq_update s i e) n) (Seq_take s n)))
  :pattern ((Seq_take (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<PyType>) (i Int) (e PyType) (n Int)) (!
  (implies
    (and (<= 0 n) (and (<= n i) (< i (Seq_length s))))
    (= (Seq_drop (Seq_update s i e) n) (Seq_update (Seq_drop s n) (- i n) e)))
  :pattern ((Seq_drop (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<PyType>) (i Int) (e PyType) (n Int)) (!
  (implies
    (and (<= 0 i) (and (< i n) (< n (Seq_length s))))
    (= (Seq_drop (Seq_update s i e) n) (Seq_drop s n)))
  :pattern ((Seq_drop (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<PyType>) (e PyType) (n Int)) (!
  (implies
    (and (<= 0 n) (<= n (Seq_length s)))
    (= (Seq_drop (Seq_build s e) n) (Seq_build (Seq_drop s n) e)))
  :pattern ((Seq_drop (Seq_build s e) n))
  )))
(assert (forall ((s Seq<Int>)) (!
  (<= 0 (Seq_length s))
  :pattern ((Seq_length s))
  )))
(assert (= (Seq_length (as Seq_empty  Seq<Int>)) 0))
(assert (forall ((s Seq<Int>)) (!
  (implies (= (Seq_length s) 0) (= s (as Seq_empty  Seq<Int>)))
  :pattern ((Seq_length s))
  )))
(assert (forall ((e Int)) (!
  (= (Seq_length (Seq_singleton e)) 1)
  :pattern ((Seq_length (Seq_singleton e)))
  )))
(assert (forall ((s Seq<Int>) (e Int)) (!
  (= (Seq_length (Seq_build s e)) (+ 1 (Seq_length s)))
  :pattern ((Seq_length (Seq_build s e)))
  )))
(assert (forall ((s Seq<Int>) (i Int) (e Int)) (!
  (ite
    (= i (Seq_length s))
    (= (Seq_index (Seq_build s e) i) e)
    (= (Seq_index (Seq_build s e) i) (Seq_index s i)))
  :pattern ((Seq_index (Seq_build s e) i))
  )))
(assert (forall ((s1 Seq<Int>) (s2 Seq<Int>)) (!
  (implies
    (and
      (not (= s1 (as Seq_empty  Seq<Int>)))
      (not (= s2 (as Seq_empty  Seq<Int>))))
    (= (Seq_length (Seq_append s1 s2)) (+ (Seq_length s1) (Seq_length s2))))
  :pattern ((Seq_length (Seq_append s1 s2)))
  )))
(assert (forall ((e Int)) (!
  (= (Seq_index (Seq_singleton e) 0) e)
  :pattern ((Seq_index (Seq_singleton e) 0))
  )))
(assert (forall ((e1 Int) (e2 Int)) (!
  (= (Seq_contains (Seq_singleton e1) e2) (= e1 e2))
  :pattern ((Seq_contains (Seq_singleton e1) e2))
  )))
(assert (forall ((s Seq<Int>)) (!
  (= (Seq_append (as Seq_empty  Seq<Int>) s) s)
  :pattern ((Seq_append (as Seq_empty  Seq<Int>) s))
  )))
(assert (forall ((s Seq<Int>)) (!
  (= (Seq_append s (as Seq_empty  Seq<Int>)) s)
  :pattern ((Seq_append s (as Seq_empty  Seq<Int>)))
  )))
(assert (forall ((s1 Seq<Int>) (s2 Seq<Int>) (i Int)) (!
  (implies
    (and
      (not (= s1 (as Seq_empty  Seq<Int>)))
      (not (= s2 (as Seq_empty  Seq<Int>))))
    (ite
      (< i (Seq_length s1))
      (= (Seq_index (Seq_append s1 s2) i) (Seq_index s1 i))
      (= (Seq_index (Seq_append s1 s2) i) (Seq_index s2 (- i (Seq_length s1))))))
  :pattern ((Seq_index (Seq_append s1 s2) i))
  :pattern ((Seq_index s1 i) (Seq_append s1 s2))
  )))
(assert (forall ((s Seq<Int>) (i Int) (e Int)) (!
  (implies
    (and (<= 0 i) (< i (Seq_length s)))
    (= (Seq_length (Seq_update s i e)) (Seq_length s)))
  :pattern ((Seq_length (Seq_update s i e)))
  )))
(assert (forall ((s Seq<Int>) (i Int) (e Int) (j Int)) (!
  (ite
    (implies (and (<= 0 i) (< i (Seq_length s))) (= i j))
    (= (Seq_index (Seq_update s i e) j) e)
    (= (Seq_index (Seq_update s i e) j) (Seq_index s j)))
  :pattern ((Seq_index (Seq_update s i e) j))
  )))
(assert (forall ((s Seq<Int>) (e Int)) (!
  (=
    (Seq_contains s e)
    (exists ((i Int)) (!
      (and (<= 0 i) (and (< i (Seq_length s)) (= (Seq_index s i) e)))
      :pattern ((Seq_index s i))
      )))
  :pattern ((Seq_contains s e))
  )))
(assert (forall ((e Int)) (!
  (not (Seq_contains (as Seq_empty  Seq<Int>) e))
  :pattern ((Seq_contains (as Seq_empty  Seq<Int>) e))
  )))
(assert (forall ((s1 Seq<Int>) (s2 Seq<Int>) (e Int)) (!
  (=
    (Seq_contains (Seq_append s1 s2) e)
    (or (Seq_contains s1 e) (Seq_contains s2 e)))
  :pattern ((Seq_contains (Seq_append s1 s2) e))
  )))
(assert (forall ((s Seq<Int>) (e1 Int) (e2 Int)) (!
  (= (Seq_contains (Seq_build s e1) e2) (or (= e1 e2) (Seq_contains s e2)))
  :pattern ((Seq_contains (Seq_build s e1) e2))
  )))
(assert (forall ((s Seq<Int>) (n Int)) (!
  (implies (<= n 0) (= (Seq_take s n) (as Seq_empty  Seq<Int>)))
  :pattern ((Seq_take s n))
  )))
(assert (forall ((s Seq<Int>) (n Int) (e Int)) (!
  (=
    (Seq_contains (Seq_take s n) e)
    (exists ((i Int)) (!
      (and
        (<= 0 i)
        (and (< i n) (and (< i (Seq_length s)) (= (Seq_index s i) e))))
      :pattern ((Seq_index s i))
      )))
  :pattern ((Seq_contains (Seq_take s n) e))
  )))
(assert (forall ((s Seq<Int>) (n Int)) (!
  (implies (<= n 0) (= (Seq_drop s n) s))
  :pattern ((Seq_drop s n))
  )))
(assert (forall ((s Seq<Int>) (n Int) (e Int)) (!
  (=
    (Seq_contains (Seq_drop s n) e)
    (exists ((i Int)) (!
      (and
        (<= 0 i)
        (and (<= n i) (and (< i (Seq_length s)) (= (Seq_index s i) e))))
      :pattern ((Seq_index s i))
      )))
  :pattern ((Seq_contains (Seq_drop s n) e))
  )))
(assert (forall ((s1 Seq<Int>) (s2 Seq<Int>)) (!
  (=
    (Seq_equal s1 s2)
    (and
      (= (Seq_length s1) (Seq_length s2))
      (forall ((i Int)) (!
        (implies
          (and (<= 0 i) (< i (Seq_length s1)))
          (= (Seq_index s1 i) (Seq_index s2 i)))
        :pattern ((Seq_index s1 i))
        :pattern ((Seq_index s2 i))
        ))))
  :pattern ((Seq_equal s1 s2))
  )))
(assert (forall ((s1 Seq<Int>) (s2 Seq<Int>)) (!
  (implies (Seq_equal s1 s2) (= s1 s2))
  :pattern ((Seq_equal s1 s2))
  )))
(assert (forall ((s1 Seq<Int>) (s2 Seq<Int>) (n Int)) (!
  (=
    (Seq_sameuntil s1 s2 n)
    (forall ((i Int)) (!
      (implies (and (<= 0 i) (< i n)) (= (Seq_index s1 i) (Seq_index s2 i)))
      :pattern ((Seq_index s1 i))
      :pattern ((Seq_index s2 i))
      )))
  :pattern ((Seq_sameuntil s1 s2 n))
  )))
(assert (forall ((s Seq<Int>) (n Int)) (!
  (implies
    (<= 0 n)
    (ite
      (<= n (Seq_length s))
      (= (Seq_length (Seq_take s n)) n)
      (= (Seq_length (Seq_take s n)) (Seq_length s))))
  :pattern ((Seq_length (Seq_take s n)))
  )))
(assert (forall ((s Seq<Int>) (n Int) (i Int)) (!
  (implies
    (and (<= 0 i) (and (< i n) (< i (Seq_length s))))
    (= (Seq_index (Seq_take s n) i) (Seq_index s i)))
  :pattern ((Seq_index (Seq_take s n) i))
  :pattern ((Seq_index s i) (Seq_take s n))
  )))
(assert (forall ((s Seq<Int>) (n Int)) (!
  (implies
    (<= 0 n)
    (ite
      (<= n (Seq_length s))
      (= (Seq_length (Seq_drop s n)) (- (Seq_length s) n))
      (= (Seq_length (Seq_drop s n)) 0)))
  :pattern ((Seq_length (Seq_drop s n)))
  )))
(assert (forall ((s Seq<Int>) (n Int) (i Int)) (!
  (implies
    (and (<= 0 n) (and (<= 0 i) (< i (- (Seq_length s) n))))
    (= (Seq_index (Seq_drop s n) i) (Seq_index s (+ i n))))
  :pattern ((Seq_index (Seq_drop s n) i))
  )))
(assert (forall ((s Seq<Int>) (n Int) (i Int)) (!
  (implies
    (and (<= 0 n) (and (<= n i) (< i (Seq_length s))))
    (= (Seq_index (Seq_drop s n) (- i n)) (Seq_index s i)))
  :pattern ((Seq_index s i) (Seq_drop s n))
  )))
(assert (forall ((s Seq<Int>) (i Int) (e Int) (n Int)) (!
  (implies
    (and (<= 0 i) (and (< i n) (< n (Seq_length s))))
    (= (Seq_take (Seq_update s i e) n) (Seq_update (Seq_take s n) i e)))
  :pattern ((Seq_take (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<Int>) (i Int) (e Int) (n Int)) (!
  (implies
    (and (<= n i) (< i (Seq_length s)))
    (= (Seq_take (Seq_update s i e) n) (Seq_take s n)))
  :pattern ((Seq_take (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<Int>) (i Int) (e Int) (n Int)) (!
  (implies
    (and (<= 0 n) (and (<= n i) (< i (Seq_length s))))
    (= (Seq_drop (Seq_update s i e) n) (Seq_update (Seq_drop s n) (- i n) e)))
  :pattern ((Seq_drop (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<Int>) (i Int) (e Int) (n Int)) (!
  (implies
    (and (<= 0 i) (and (< i n) (< n (Seq_length s))))
    (= (Seq_drop (Seq_update s i e) n) (Seq_drop s n)))
  :pattern ((Seq_drop (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<Int>) (e Int) (n Int)) (!
  (implies
    (and (<= 0 n) (<= n (Seq_length s)))
    (= (Seq_drop (Seq_build s e) n) (Seq_build (Seq_drop s n) e)))
  :pattern ((Seq_drop (Seq_build s e) n))
  )))
(assert (forall ((min_ Int) (max Int)) (!
  (ite
    (< min_ max)
    (= (Seq_length (Seq_range min_ max)) (- max min_))
    (= (Seq_length (Seq_range min_ max)) 0))
  :pattern ((Seq_length (Seq_range min_ max)))
  )))
(assert (forall ((min_ Int) (max Int) (i Int)) (!
  (implies
    (and (<= 0 i) (< i (- max min_)))
    (= (Seq_index (Seq_range min_ max) i) (+ min_ i)))
  :pattern ((Seq_index (Seq_range min_ max) i))
  )))
(assert (forall ((min_ Int) (max Int) (e Int)) (!
  (= (Seq_contains (Seq_range min_ max) e) (and (<= min_ e) (< e max)))
  :pattern ((Seq_contains (Seq_range min_ max) e))
  )))
(assert (forall ((s Seq<Measure$>)) (!
  (<= 0 (Seq_length s))
  :pattern ((Seq_length s))
  )))
(assert (= (Seq_length (as Seq_empty  Seq<Measure$>)) 0))
(assert (forall ((s Seq<Measure$>)) (!
  (implies (= (Seq_length s) 0) (= s (as Seq_empty  Seq<Measure$>)))
  :pattern ((Seq_length s))
  )))
(assert (forall ((e Measure$)) (!
  (= (Seq_length (Seq_singleton e)) 1)
  :pattern ((Seq_length (Seq_singleton e)))
  )))
(assert (forall ((s Seq<Measure$>) (e Measure$)) (!
  (= (Seq_length (Seq_build s e)) (+ 1 (Seq_length s)))
  :pattern ((Seq_length (Seq_build s e)))
  )))
(assert (forall ((s Seq<Measure$>) (i Int) (e Measure$)) (!
  (ite
    (= i (Seq_length s))
    (= (Seq_index (Seq_build s e) i) e)
    (= (Seq_index (Seq_build s e) i) (Seq_index s i)))
  :pattern ((Seq_index (Seq_build s e) i))
  )))
(assert (forall ((s1 Seq<Measure$>) (s2 Seq<Measure$>)) (!
  (implies
    (and
      (not (= s1 (as Seq_empty  Seq<Measure$>)))
      (not (= s2 (as Seq_empty  Seq<Measure$>))))
    (= (Seq_length (Seq_append s1 s2)) (+ (Seq_length s1) (Seq_length s2))))
  :pattern ((Seq_length (Seq_append s1 s2)))
  )))
(assert (forall ((e Measure$)) (!
  (= (Seq_index (Seq_singleton e) 0) e)
  :pattern ((Seq_index (Seq_singleton e) 0))
  )))
(assert (forall ((e1 Measure$) (e2 Measure$)) (!
  (= (Seq_contains (Seq_singleton e1) e2) (= e1 e2))
  :pattern ((Seq_contains (Seq_singleton e1) e2))
  )))
(assert (forall ((s Seq<Measure$>)) (!
  (= (Seq_append (as Seq_empty  Seq<Measure$>) s) s)
  :pattern ((Seq_append (as Seq_empty  Seq<Measure$>) s))
  )))
(assert (forall ((s Seq<Measure$>)) (!
  (= (Seq_append s (as Seq_empty  Seq<Measure$>)) s)
  :pattern ((Seq_append s (as Seq_empty  Seq<Measure$>)))
  )))
(assert (forall ((s1 Seq<Measure$>) (s2 Seq<Measure$>) (i Int)) (!
  (implies
    (and
      (not (= s1 (as Seq_empty  Seq<Measure$>)))
      (not (= s2 (as Seq_empty  Seq<Measure$>))))
    (ite
      (< i (Seq_length s1))
      (= (Seq_index (Seq_append s1 s2) i) (Seq_index s1 i))
      (= (Seq_index (Seq_append s1 s2) i) (Seq_index s2 (- i (Seq_length s1))))))
  :pattern ((Seq_index (Seq_append s1 s2) i))
  :pattern ((Seq_index s1 i) (Seq_append s1 s2))
  )))
(assert (forall ((s Seq<Measure$>) (i Int) (e Measure$)) (!
  (implies
    (and (<= 0 i) (< i (Seq_length s)))
    (= (Seq_length (Seq_update s i e)) (Seq_length s)))
  :pattern ((Seq_length (Seq_update s i e)))
  )))
(assert (forall ((s Seq<Measure$>) (i Int) (e Measure$) (j Int)) (!
  (ite
    (implies (and (<= 0 i) (< i (Seq_length s))) (= i j))
    (= (Seq_index (Seq_update s i e) j) e)
    (= (Seq_index (Seq_update s i e) j) (Seq_index s j)))
  :pattern ((Seq_index (Seq_update s i e) j))
  )))
(assert (forall ((s Seq<Measure$>) (e Measure$)) (!
  (=
    (Seq_contains s e)
    (exists ((i Int)) (!
      (and (<= 0 i) (and (< i (Seq_length s)) (= (Seq_index s i) e)))
      :pattern ((Seq_index s i))
      )))
  :pattern ((Seq_contains s e))
  )))
(assert (forall ((e Measure$)) (!
  (not (Seq_contains (as Seq_empty  Seq<Measure$>) e))
  :pattern ((Seq_contains (as Seq_empty  Seq<Measure$>) e))
  )))
(assert (forall ((s1 Seq<Measure$>) (s2 Seq<Measure$>) (e Measure$)) (!
  (=
    (Seq_contains (Seq_append s1 s2) e)
    (or (Seq_contains s1 e) (Seq_contains s2 e)))
  :pattern ((Seq_contains (Seq_append s1 s2) e))
  )))
(assert (forall ((s Seq<Measure$>) (e1 Measure$) (e2 Measure$)) (!
  (= (Seq_contains (Seq_build s e1) e2) (or (= e1 e2) (Seq_contains s e2)))
  :pattern ((Seq_contains (Seq_build s e1) e2))
  )))
(assert (forall ((s Seq<Measure$>) (n Int)) (!
  (implies (<= n 0) (= (Seq_take s n) (as Seq_empty  Seq<Measure$>)))
  :pattern ((Seq_take s n))
  )))
(assert (forall ((s Seq<Measure$>) (n Int) (e Measure$)) (!
  (=
    (Seq_contains (Seq_take s n) e)
    (exists ((i Int)) (!
      (and
        (<= 0 i)
        (and (< i n) (and (< i (Seq_length s)) (= (Seq_index s i) e))))
      :pattern ((Seq_index s i))
      )))
  :pattern ((Seq_contains (Seq_take s n) e))
  )))
(assert (forall ((s Seq<Measure$>) (n Int)) (!
  (implies (<= n 0) (= (Seq_drop s n) s))
  :pattern ((Seq_drop s n))
  )))
(assert (forall ((s Seq<Measure$>) (n Int) (e Measure$)) (!
  (=
    (Seq_contains (Seq_drop s n) e)
    (exists ((i Int)) (!
      (and
        (<= 0 i)
        (and (<= n i) (and (< i (Seq_length s)) (= (Seq_index s i) e))))
      :pattern ((Seq_index s i))
      )))
  :pattern ((Seq_contains (Seq_drop s n) e))
  )))
(assert (forall ((s1 Seq<Measure$>) (s2 Seq<Measure$>)) (!
  (=
    (Seq_equal s1 s2)
    (and
      (= (Seq_length s1) (Seq_length s2))
      (forall ((i Int)) (!
        (implies
          (and (<= 0 i) (< i (Seq_length s1)))
          (= (Seq_index s1 i) (Seq_index s2 i)))
        :pattern ((Seq_index s1 i))
        :pattern ((Seq_index s2 i))
        ))))
  :pattern ((Seq_equal s1 s2))
  )))
(assert (forall ((s1 Seq<Measure$>) (s2 Seq<Measure$>)) (!
  (implies (Seq_equal s1 s2) (= s1 s2))
  :pattern ((Seq_equal s1 s2))
  )))
(assert (forall ((s1 Seq<Measure$>) (s2 Seq<Measure$>) (n Int)) (!
  (=
    (Seq_sameuntil s1 s2 n)
    (forall ((i Int)) (!
      (implies (and (<= 0 i) (< i n)) (= (Seq_index s1 i) (Seq_index s2 i)))
      :pattern ((Seq_index s1 i))
      :pattern ((Seq_index s2 i))
      )))
  :pattern ((Seq_sameuntil s1 s2 n))
  )))
(assert (forall ((s Seq<Measure$>) (n Int)) (!
  (implies
    (<= 0 n)
    (ite
      (<= n (Seq_length s))
      (= (Seq_length (Seq_take s n)) n)
      (= (Seq_length (Seq_take s n)) (Seq_length s))))
  :pattern ((Seq_length (Seq_take s n)))
  )))
(assert (forall ((s Seq<Measure$>) (n Int) (i Int)) (!
  (implies
    (and (<= 0 i) (and (< i n) (< i (Seq_length s))))
    (= (Seq_index (Seq_take s n) i) (Seq_index s i)))
  :pattern ((Seq_index (Seq_take s n) i))
  :pattern ((Seq_index s i) (Seq_take s n))
  )))
(assert (forall ((s Seq<Measure$>) (n Int)) (!
  (implies
    (<= 0 n)
    (ite
      (<= n (Seq_length s))
      (= (Seq_length (Seq_drop s n)) (- (Seq_length s) n))
      (= (Seq_length (Seq_drop s n)) 0)))
  :pattern ((Seq_length (Seq_drop s n)))
  )))
(assert (forall ((s Seq<Measure$>) (n Int) (i Int)) (!
  (implies
    (and (<= 0 n) (and (<= 0 i) (< i (- (Seq_length s) n))))
    (= (Seq_index (Seq_drop s n) i) (Seq_index s (+ i n))))
  :pattern ((Seq_index (Seq_drop s n) i))
  )))
(assert (forall ((s Seq<Measure$>) (n Int) (i Int)) (!
  (implies
    (and (<= 0 n) (and (<= n i) (< i (Seq_length s))))
    (= (Seq_index (Seq_drop s n) (- i n)) (Seq_index s i)))
  :pattern ((Seq_index s i) (Seq_drop s n))
  )))
(assert (forall ((s Seq<Measure$>) (i Int) (e Measure$) (n Int)) (!
  (implies
    (and (<= 0 i) (and (< i n) (< n (Seq_length s))))
    (= (Seq_take (Seq_update s i e) n) (Seq_update (Seq_take s n) i e)))
  :pattern ((Seq_take (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<Measure$>) (i Int) (e Measure$) (n Int)) (!
  (implies
    (and (<= n i) (< i (Seq_length s)))
    (= (Seq_take (Seq_update s i e) n) (Seq_take s n)))
  :pattern ((Seq_take (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<Measure$>) (i Int) (e Measure$) (n Int)) (!
  (implies
    (and (<= 0 n) (and (<= n i) (< i (Seq_length s))))
    (= (Seq_drop (Seq_update s i e) n) (Seq_update (Seq_drop s n) (- i n) e)))
  :pattern ((Seq_drop (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<Measure$>) (i Int) (e Measure$) (n Int)) (!
  (implies
    (and (<= 0 i) (and (< i n) (< n (Seq_length s))))
    (= (Seq_drop (Seq_update s i e) n) (Seq_drop s n)))
  :pattern ((Seq_drop (Seq_update s i e) n))
  )))
(assert (forall ((s Seq<Measure$>) (e Measure$) (n Int)) (!
  (implies
    (and (<= 0 n) (<= n (Seq_length s)))
    (= (Seq_drop (Seq_build s e) n) (Seq_build (Seq_drop s n) e)))
  :pattern ((Seq_drop (Seq_build s e) n))
  )))
(assert (forall ((s Set<$Ref>)) (!
  (<= 0 (Set_card s))
  :pattern ((Set_card s))
  )))
(assert (forall ((e $Ref)) (!
  (not (Set_in e (as Set_empty  Set<$Ref>)))
  :pattern ((Set_in e (as Set_empty  Set<$Ref>)))
  )))
(assert (forall ((s Set<$Ref>)) (!
  (and
    (= (= (Set_card s) 0) (= s (as Set_empty  Set<$Ref>)))
    (implies
      (not (= (Set_card s) 0))
      (exists ((e $Ref)) (!
        (Set_in e s)
        :pattern ((Set_in e s))
        ))))
  :pattern ((Set_card s))
  )))
(assert (forall ((e $Ref)) (!
  (Set_in e (Set_singleton e))
  :pattern ((Set_singleton e))
  )))
(assert (forall ((e1 $Ref) (e2 $Ref)) (!
  (= (Set_in e1 (Set_singleton e2)) (= e1 e2))
  :pattern ((Set_in e1 (Set_singleton e2)))
  )))
(assert (forall ((e $Ref)) (!
  (= (Set_card (Set_singleton e)) 1)
  :pattern ((Set_card (Set_singleton e)))
  )))
(assert (forall ((s Set<$Ref>) (e $Ref)) (!
  (Set_in e (Set_unionone s e))
  :pattern ((Set_unionone s e))
  )))
(assert (forall ((s Set<$Ref>) (e1 $Ref) (e2 $Ref)) (!
  (= (Set_in e1 (Set_unionone s e2)) (or (= e1 e2) (Set_in e1 s)))
  :pattern ((Set_in e1 (Set_unionone s e2)))
  )))
(assert (forall ((s Set<$Ref>) (e1 $Ref) (e2 $Ref)) (!
  (implies (Set_in e1 s) (Set_in e1 (Set_unionone s e2)))
  :pattern ((Set_in e1 s) (Set_unionone s e2))
  )))
(assert (forall ((s Set<$Ref>) (e $Ref)) (!
  (implies (Set_in e s) (= (Set_card (Set_unionone s e)) (Set_card s)))
  :pattern ((Set_card (Set_unionone s e)))
  )))
(assert (forall ((s Set<$Ref>) (e $Ref)) (!
  (implies
    (not (Set_in e s))
    (= (Set_card (Set_unionone s e)) (+ (Set_card s) 1)))
  :pattern ((Set_card (Set_unionone s e)))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>) (e $Ref)) (!
  (= (Set_in e (Set_union s1 s2)) (or (Set_in e s1) (Set_in e s2)))
  :pattern ((Set_in e (Set_union s1 s2)))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>) (e $Ref)) (!
  (implies (Set_in e s1) (Set_in e (Set_union s1 s2)))
  :pattern ((Set_in e s1) (Set_union s1 s2))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>) (e $Ref)) (!
  (implies (Set_in e s2) (Set_in e (Set_union s1 s2)))
  :pattern ((Set_in e s2) (Set_union s1 s2))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>) (e $Ref)) (!
  (= (Set_in e (Set_intersection s1 s2)) (and (Set_in e s1) (Set_in e s2)))
  :pattern ((Set_in e (Set_intersection s1 s2)))
  :pattern ((Set_intersection s1 s2) (Set_in e s1))
  :pattern ((Set_intersection s1 s2) (Set_in e s2))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>)) (!
  (= (Set_union s1 (Set_union s1 s2)) (Set_union s1 s2))
  :pattern ((Set_union s1 (Set_union s1 s2)))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>)) (!
  (= (Set_union (Set_union s1 s2) s2) (Set_union s1 s2))
  :pattern ((Set_union (Set_union s1 s2) s2))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>)) (!
  (= (Set_intersection s1 (Set_intersection s1 s2)) (Set_intersection s1 s2))
  :pattern ((Set_intersection s1 (Set_intersection s1 s2)))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>)) (!
  (= (Set_intersection (Set_intersection s1 s2) s2) (Set_intersection s1 s2))
  :pattern ((Set_intersection (Set_intersection s1 s2) s2))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>)) (!
  (=
    (+ (Set_card (Set_union s1 s2)) (Set_card (Set_intersection s1 s2)))
    (+ (Set_card s1) (Set_card s2)))
  :pattern ((Set_card (Set_union s1 s2)))
  :pattern ((Set_card (Set_intersection s1 s2)))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>) (e $Ref)) (!
  (= (Set_in e (Set_difference s1 s2)) (and (Set_in e s1) (not (Set_in e s2))))
  :pattern ((Set_in e (Set_difference s1 s2)))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>) (e $Ref)) (!
  (implies (Set_in e s2) (not (Set_in e (Set_difference s1 s2))))
  :pattern ((Set_difference s1 s2) (Set_in e s2))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>)) (!
  (=
    (Set_subset s1 s2)
    (forall ((e $Ref)) (!
      (implies (Set_in e s1) (Set_in e s2))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_subset s1 s2))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>)) (!
  (=
    (Set_equal s1 s2)
    (forall ((e $Ref)) (!
      (= (Set_in e s1) (Set_in e s2))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_equal s1 s2))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>)) (!
  (implies (Set_equal s1 s2) (= s1 s2))
  :pattern ((Set_equal s1 s2))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>)) (!
  (=
    (Set_disjoint s1 s2)
    (forall ((e $Ref)) (!
      (or (not (Set_in e s1)) (not (Set_in e s2)))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_disjoint s1 s2))
  )))
(assert (forall ((s1 Set<$Ref>) (s2 Set<$Ref>)) (!
  (and
    (=
      (+
        (+ (Set_card (Set_difference s1 s2)) (Set_card (Set_difference s2 s1)))
        (Set_card (Set_intersection s1 s2)))
      (Set_card (Set_union s1 s2)))
    (=
      (Set_card (Set_difference s1 s2))
      (- (Set_card s1) (Set_card (Set_intersection s1 s2)))))
  :pattern ((Set_card (Set_difference s1 s2)))
  )))
(assert (forall ((s Set<Int>)) (!
  (<= 0 (Set_card s))
  :pattern ((Set_card s))
  )))
(assert (forall ((e Int)) (!
  (not (Set_in e (as Set_empty  Set<Int>)))
  :pattern ((Set_in e (as Set_empty  Set<Int>)))
  )))
(assert (forall ((s Set<Int>)) (!
  (and
    (= (= (Set_card s) 0) (= s (as Set_empty  Set<Int>)))
    (implies
      (not (= (Set_card s) 0))
      (exists ((e Int)) (!
        (Set_in e s)
        :pattern ((Set_in e s))
        ))))
  :pattern ((Set_card s))
  )))
(assert (forall ((e Int)) (!
  (Set_in e (Set_singleton e))
  :pattern ((Set_singleton e))
  )))
(assert (forall ((e1 Int) (e2 Int)) (!
  (= (Set_in e1 (Set_singleton e2)) (= e1 e2))
  :pattern ((Set_in e1 (Set_singleton e2)))
  )))
(assert (forall ((e Int)) (!
  (= (Set_card (Set_singleton e)) 1)
  :pattern ((Set_card (Set_singleton e)))
  )))
(assert (forall ((s Set<Int>) (e Int)) (!
  (Set_in e (Set_unionone s e))
  :pattern ((Set_unionone s e))
  )))
(assert (forall ((s Set<Int>) (e1 Int) (e2 Int)) (!
  (= (Set_in e1 (Set_unionone s e2)) (or (= e1 e2) (Set_in e1 s)))
  :pattern ((Set_in e1 (Set_unionone s e2)))
  )))
(assert (forall ((s Set<Int>) (e1 Int) (e2 Int)) (!
  (implies (Set_in e1 s) (Set_in e1 (Set_unionone s e2)))
  :pattern ((Set_in e1 s) (Set_unionone s e2))
  )))
(assert (forall ((s Set<Int>) (e Int)) (!
  (implies (Set_in e s) (= (Set_card (Set_unionone s e)) (Set_card s)))
  :pattern ((Set_card (Set_unionone s e)))
  )))
(assert (forall ((s Set<Int>) (e Int)) (!
  (implies
    (not (Set_in e s))
    (= (Set_card (Set_unionone s e)) (+ (Set_card s) 1)))
  :pattern ((Set_card (Set_unionone s e)))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>) (e Int)) (!
  (= (Set_in e (Set_union s1 s2)) (or (Set_in e s1) (Set_in e s2)))
  :pattern ((Set_in e (Set_union s1 s2)))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>) (e Int)) (!
  (implies (Set_in e s1) (Set_in e (Set_union s1 s2)))
  :pattern ((Set_in e s1) (Set_union s1 s2))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>) (e Int)) (!
  (implies (Set_in e s2) (Set_in e (Set_union s1 s2)))
  :pattern ((Set_in e s2) (Set_union s1 s2))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>) (e Int)) (!
  (= (Set_in e (Set_intersection s1 s2)) (and (Set_in e s1) (Set_in e s2)))
  :pattern ((Set_in e (Set_intersection s1 s2)))
  :pattern ((Set_intersection s1 s2) (Set_in e s1))
  :pattern ((Set_intersection s1 s2) (Set_in e s2))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>)) (!
  (= (Set_union s1 (Set_union s1 s2)) (Set_union s1 s2))
  :pattern ((Set_union s1 (Set_union s1 s2)))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>)) (!
  (= (Set_union (Set_union s1 s2) s2) (Set_union s1 s2))
  :pattern ((Set_union (Set_union s1 s2) s2))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>)) (!
  (= (Set_intersection s1 (Set_intersection s1 s2)) (Set_intersection s1 s2))
  :pattern ((Set_intersection s1 (Set_intersection s1 s2)))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>)) (!
  (= (Set_intersection (Set_intersection s1 s2) s2) (Set_intersection s1 s2))
  :pattern ((Set_intersection (Set_intersection s1 s2) s2))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>)) (!
  (=
    (+ (Set_card (Set_union s1 s2)) (Set_card (Set_intersection s1 s2)))
    (+ (Set_card s1) (Set_card s2)))
  :pattern ((Set_card (Set_union s1 s2)))
  :pattern ((Set_card (Set_intersection s1 s2)))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>) (e Int)) (!
  (= (Set_in e (Set_difference s1 s2)) (and (Set_in e s1) (not (Set_in e s2))))
  :pattern ((Set_in e (Set_difference s1 s2)))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>) (e Int)) (!
  (implies (Set_in e s2) (not (Set_in e (Set_difference s1 s2))))
  :pattern ((Set_difference s1 s2) (Set_in e s2))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>)) (!
  (=
    (Set_subset s1 s2)
    (forall ((e Int)) (!
      (implies (Set_in e s1) (Set_in e s2))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_subset s1 s2))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>)) (!
  (=
    (Set_equal s1 s2)
    (forall ((e Int)) (!
      (= (Set_in e s1) (Set_in e s2))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_equal s1 s2))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>)) (!
  (implies (Set_equal s1 s2) (= s1 s2))
  :pattern ((Set_equal s1 s2))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>)) (!
  (=
    (Set_disjoint s1 s2)
    (forall ((e Int)) (!
      (or (not (Set_in e s1)) (not (Set_in e s2)))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_disjoint s1 s2))
  )))
(assert (forall ((s1 Set<Int>) (s2 Set<Int>)) (!
  (and
    (=
      (+
        (+ (Set_card (Set_difference s1 s2)) (Set_card (Set_difference s2 s1)))
        (Set_card (Set_intersection s1 s2)))
      (Set_card (Set_union s1 s2)))
    (=
      (Set_card (Set_difference s1 s2))
      (- (Set_card s1) (Set_card (Set_intersection s1 s2)))))
  :pattern ((Set_card (Set_difference s1 s2)))
  )))
(assert (forall ((s Set<Seq<$Ref>>)) (!
  (<= 0 (Set_card s))
  :pattern ((Set_card s))
  )))
(assert (forall ((e Seq<$Ref>)) (!
  (not (Set_in e (as Set_empty  Set<Seq<$Ref>>)))
  :pattern ((Set_in e (as Set_empty  Set<Seq<$Ref>>)))
  )))
(assert (forall ((s Set<Seq<$Ref>>)) (!
  (and
    (= (= (Set_card s) 0) (= s (as Set_empty  Set<Seq<$Ref>>)))
    (implies
      (not (= (Set_card s) 0))
      (exists ((e Seq<$Ref>)) (!
        (Set_in e s)
        :pattern ((Set_in e s))
        ))))
  :pattern ((Set_card s))
  )))
(assert (forall ((e Seq<$Ref>)) (!
  (Set_in e (Set_singleton e))
  :pattern ((Set_singleton e))
  )))
(assert (forall ((e1 Seq<$Ref>) (e2 Seq<$Ref>)) (!
  (= (Set_in e1 (Set_singleton e2)) (= e1 e2))
  :pattern ((Set_in e1 (Set_singleton e2)))
  )))
(assert (forall ((e Seq<$Ref>)) (!
  (= (Set_card (Set_singleton e)) 1)
  :pattern ((Set_card (Set_singleton e)))
  )))
(assert (forall ((s Set<Seq<$Ref>>) (e Seq<$Ref>)) (!
  (Set_in e (Set_unionone s e))
  :pattern ((Set_unionone s e))
  )))
(assert (forall ((s Set<Seq<$Ref>>) (e1 Seq<$Ref>) (e2 Seq<$Ref>)) (!
  (= (Set_in e1 (Set_unionone s e2)) (or (= e1 e2) (Set_in e1 s)))
  :pattern ((Set_in e1 (Set_unionone s e2)))
  )))
(assert (forall ((s Set<Seq<$Ref>>) (e1 Seq<$Ref>) (e2 Seq<$Ref>)) (!
  (implies (Set_in e1 s) (Set_in e1 (Set_unionone s e2)))
  :pattern ((Set_in e1 s) (Set_unionone s e2))
  )))
(assert (forall ((s Set<Seq<$Ref>>) (e Seq<$Ref>)) (!
  (implies (Set_in e s) (= (Set_card (Set_unionone s e)) (Set_card s)))
  :pattern ((Set_card (Set_unionone s e)))
  )))
(assert (forall ((s Set<Seq<$Ref>>) (e Seq<$Ref>)) (!
  (implies
    (not (Set_in e s))
    (= (Set_card (Set_unionone s e)) (+ (Set_card s) 1)))
  :pattern ((Set_card (Set_unionone s e)))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>) (e Seq<$Ref>)) (!
  (= (Set_in e (Set_union s1 s2)) (or (Set_in e s1) (Set_in e s2)))
  :pattern ((Set_in e (Set_union s1 s2)))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>) (e Seq<$Ref>)) (!
  (implies (Set_in e s1) (Set_in e (Set_union s1 s2)))
  :pattern ((Set_in e s1) (Set_union s1 s2))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>) (e Seq<$Ref>)) (!
  (implies (Set_in e s2) (Set_in e (Set_union s1 s2)))
  :pattern ((Set_in e s2) (Set_union s1 s2))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>) (e Seq<$Ref>)) (!
  (= (Set_in e (Set_intersection s1 s2)) (and (Set_in e s1) (Set_in e s2)))
  :pattern ((Set_in e (Set_intersection s1 s2)))
  :pattern ((Set_intersection s1 s2) (Set_in e s1))
  :pattern ((Set_intersection s1 s2) (Set_in e s2))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>)) (!
  (= (Set_union s1 (Set_union s1 s2)) (Set_union s1 s2))
  :pattern ((Set_union s1 (Set_union s1 s2)))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>)) (!
  (= (Set_union (Set_union s1 s2) s2) (Set_union s1 s2))
  :pattern ((Set_union (Set_union s1 s2) s2))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>)) (!
  (= (Set_intersection s1 (Set_intersection s1 s2)) (Set_intersection s1 s2))
  :pattern ((Set_intersection s1 (Set_intersection s1 s2)))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>)) (!
  (= (Set_intersection (Set_intersection s1 s2) s2) (Set_intersection s1 s2))
  :pattern ((Set_intersection (Set_intersection s1 s2) s2))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>)) (!
  (=
    (+ (Set_card (Set_union s1 s2)) (Set_card (Set_intersection s1 s2)))
    (+ (Set_card s1) (Set_card s2)))
  :pattern ((Set_card (Set_union s1 s2)))
  :pattern ((Set_card (Set_intersection s1 s2)))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>) (e Seq<$Ref>)) (!
  (= (Set_in e (Set_difference s1 s2)) (and (Set_in e s1) (not (Set_in e s2))))
  :pattern ((Set_in e (Set_difference s1 s2)))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>) (e Seq<$Ref>)) (!
  (implies (Set_in e s2) (not (Set_in e (Set_difference s1 s2))))
  :pattern ((Set_difference s1 s2) (Set_in e s2))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>)) (!
  (=
    (Set_subset s1 s2)
    (forall ((e Seq<$Ref>)) (!
      (implies (Set_in e s1) (Set_in e s2))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_subset s1 s2))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>)) (!
  (=
    (Set_equal s1 s2)
    (forall ((e Seq<$Ref>)) (!
      (= (Set_in e s1) (Set_in e s2))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_equal s1 s2))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>)) (!
  (implies (Set_equal s1 s2) (= s1 s2))
  :pattern ((Set_equal s1 s2))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>)) (!
  (=
    (Set_disjoint s1 s2)
    (forall ((e Seq<$Ref>)) (!
      (or (not (Set_in e s1)) (not (Set_in e s2)))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_disjoint s1 s2))
  )))
(assert (forall ((s1 Set<Seq<$Ref>>) (s2 Set<Seq<$Ref>>)) (!
  (and
    (=
      (+
        (+ (Set_card (Set_difference s1 s2)) (Set_card (Set_difference s2 s1)))
        (Set_card (Set_intersection s1 s2)))
      (Set_card (Set_union s1 s2)))
    (=
      (Set_card (Set_difference s1 s2))
      (- (Set_card s1) (Set_card (Set_intersection s1 s2)))))
  :pattern ((Set_card (Set_difference s1 s2)))
  )))
(assert (forall ((s Set<Set<$Ref>>)) (!
  (<= 0 (Set_card s))
  :pattern ((Set_card s))
  )))
(assert (forall ((e Set<$Ref>)) (!
  (not (Set_in e (as Set_empty  Set<Set<$Ref>>)))
  :pattern ((Set_in e (as Set_empty  Set<Set<$Ref>>)))
  )))
(assert (forall ((s Set<Set<$Ref>>)) (!
  (and
    (= (= (Set_card s) 0) (= s (as Set_empty  Set<Set<$Ref>>)))
    (implies
      (not (= (Set_card s) 0))
      (exists ((e Set<$Ref>)) (!
        (Set_in e s)
        :pattern ((Set_in e s))
        ))))
  :pattern ((Set_card s))
  )))
(assert (forall ((e Set<$Ref>)) (!
  (Set_in e (Set_singleton e))
  :pattern ((Set_singleton e))
  )))
(assert (forall ((e1 Set<$Ref>) (e2 Set<$Ref>)) (!
  (= (Set_in e1 (Set_singleton e2)) (= e1 e2))
  :pattern ((Set_in e1 (Set_singleton e2)))
  )))
(assert (forall ((e Set<$Ref>)) (!
  (= (Set_card (Set_singleton e)) 1)
  :pattern ((Set_card (Set_singleton e)))
  )))
(assert (forall ((s Set<Set<$Ref>>) (e Set<$Ref>)) (!
  (Set_in e (Set_unionone s e))
  :pattern ((Set_unionone s e))
  )))
(assert (forall ((s Set<Set<$Ref>>) (e1 Set<$Ref>) (e2 Set<$Ref>)) (!
  (= (Set_in e1 (Set_unionone s e2)) (or (= e1 e2) (Set_in e1 s)))
  :pattern ((Set_in e1 (Set_unionone s e2)))
  )))
(assert (forall ((s Set<Set<$Ref>>) (e1 Set<$Ref>) (e2 Set<$Ref>)) (!
  (implies (Set_in e1 s) (Set_in e1 (Set_unionone s e2)))
  :pattern ((Set_in e1 s) (Set_unionone s e2))
  )))
(assert (forall ((s Set<Set<$Ref>>) (e Set<$Ref>)) (!
  (implies (Set_in e s) (= (Set_card (Set_unionone s e)) (Set_card s)))
  :pattern ((Set_card (Set_unionone s e)))
  )))
(assert (forall ((s Set<Set<$Ref>>) (e Set<$Ref>)) (!
  (implies
    (not (Set_in e s))
    (= (Set_card (Set_unionone s e)) (+ (Set_card s) 1)))
  :pattern ((Set_card (Set_unionone s e)))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>) (e Set<$Ref>)) (!
  (= (Set_in e (Set_union s1 s2)) (or (Set_in e s1) (Set_in e s2)))
  :pattern ((Set_in e (Set_union s1 s2)))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>) (e Set<$Ref>)) (!
  (implies (Set_in e s1) (Set_in e (Set_union s1 s2)))
  :pattern ((Set_in e s1) (Set_union s1 s2))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>) (e Set<$Ref>)) (!
  (implies (Set_in e s2) (Set_in e (Set_union s1 s2)))
  :pattern ((Set_in e s2) (Set_union s1 s2))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>) (e Set<$Ref>)) (!
  (= (Set_in e (Set_intersection s1 s2)) (and (Set_in e s1) (Set_in e s2)))
  :pattern ((Set_in e (Set_intersection s1 s2)))
  :pattern ((Set_intersection s1 s2) (Set_in e s1))
  :pattern ((Set_intersection s1 s2) (Set_in e s2))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>)) (!
  (= (Set_union s1 (Set_union s1 s2)) (Set_union s1 s2))
  :pattern ((Set_union s1 (Set_union s1 s2)))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>)) (!
  (= (Set_union (Set_union s1 s2) s2) (Set_union s1 s2))
  :pattern ((Set_union (Set_union s1 s2) s2))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>)) (!
  (= (Set_intersection s1 (Set_intersection s1 s2)) (Set_intersection s1 s2))
  :pattern ((Set_intersection s1 (Set_intersection s1 s2)))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>)) (!
  (= (Set_intersection (Set_intersection s1 s2) s2) (Set_intersection s1 s2))
  :pattern ((Set_intersection (Set_intersection s1 s2) s2))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>)) (!
  (=
    (+ (Set_card (Set_union s1 s2)) (Set_card (Set_intersection s1 s2)))
    (+ (Set_card s1) (Set_card s2)))
  :pattern ((Set_card (Set_union s1 s2)))
  :pattern ((Set_card (Set_intersection s1 s2)))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>) (e Set<$Ref>)) (!
  (= (Set_in e (Set_difference s1 s2)) (and (Set_in e s1) (not (Set_in e s2))))
  :pattern ((Set_in e (Set_difference s1 s2)))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>) (e Set<$Ref>)) (!
  (implies (Set_in e s2) (not (Set_in e (Set_difference s1 s2))))
  :pattern ((Set_difference s1 s2) (Set_in e s2))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>)) (!
  (=
    (Set_subset s1 s2)
    (forall ((e Set<$Ref>)) (!
      (implies (Set_in e s1) (Set_in e s2))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_subset s1 s2))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>)) (!
  (=
    (Set_equal s1 s2)
    (forall ((e Set<$Ref>)) (!
      (= (Set_in e s1) (Set_in e s2))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_equal s1 s2))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>)) (!
  (implies (Set_equal s1 s2) (= s1 s2))
  :pattern ((Set_equal s1 s2))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>)) (!
  (=
    (Set_disjoint s1 s2)
    (forall ((e Set<$Ref>)) (!
      (or (not (Set_in e s1)) (not (Set_in e s2)))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_disjoint s1 s2))
  )))
(assert (forall ((s1 Set<Set<$Ref>>) (s2 Set<Set<$Ref>>)) (!
  (and
    (=
      (+
        (+ (Set_card (Set_difference s1 s2)) (Set_card (Set_difference s2 s1)))
        (Set_card (Set_intersection s1 s2)))
      (Set_card (Set_union s1 s2)))
    (=
      (Set_card (Set_difference s1 s2))
      (- (Set_card s1) (Set_card (Set_intersection s1 s2)))))
  :pattern ((Set_card (Set_difference s1 s2)))
  )))
(assert (forall ((s Set<$Snap>)) (!
  (<= 0 (Set_card s))
  :pattern ((Set_card s))
  )))
(assert (forall ((e $Snap)) (!
  (not (Set_in e (as Set_empty  Set<$Snap>)))
  :pattern ((Set_in e (as Set_empty  Set<$Snap>)))
  )))
(assert (forall ((s Set<$Snap>)) (!
  (and
    (= (= (Set_card s) 0) (= s (as Set_empty  Set<$Snap>)))
    (implies
      (not (= (Set_card s) 0))
      (exists ((e $Snap)) (!
        (Set_in e s)
        :pattern ((Set_in e s))
        ))))
  :pattern ((Set_card s))
  )))
(assert (forall ((e $Snap)) (!
  (Set_in e (Set_singleton e))
  :pattern ((Set_singleton e))
  )))
(assert (forall ((e1 $Snap) (e2 $Snap)) (!
  (= (Set_in e1 (Set_singleton e2)) (= e1 e2))
  :pattern ((Set_in e1 (Set_singleton e2)))
  )))
(assert (forall ((e $Snap)) (!
  (= (Set_card (Set_singleton e)) 1)
  :pattern ((Set_card (Set_singleton e)))
  )))
(assert (forall ((s Set<$Snap>) (e $Snap)) (!
  (Set_in e (Set_unionone s e))
  :pattern ((Set_unionone s e))
  )))
(assert (forall ((s Set<$Snap>) (e1 $Snap) (e2 $Snap)) (!
  (= (Set_in e1 (Set_unionone s e2)) (or (= e1 e2) (Set_in e1 s)))
  :pattern ((Set_in e1 (Set_unionone s e2)))
  )))
(assert (forall ((s Set<$Snap>) (e1 $Snap) (e2 $Snap)) (!
  (implies (Set_in e1 s) (Set_in e1 (Set_unionone s e2)))
  :pattern ((Set_in e1 s) (Set_unionone s e2))
  )))
(assert (forall ((s Set<$Snap>) (e $Snap)) (!
  (implies (Set_in e s) (= (Set_card (Set_unionone s e)) (Set_card s)))
  :pattern ((Set_card (Set_unionone s e)))
  )))
(assert (forall ((s Set<$Snap>) (e $Snap)) (!
  (implies
    (not (Set_in e s))
    (= (Set_card (Set_unionone s e)) (+ (Set_card s) 1)))
  :pattern ((Set_card (Set_unionone s e)))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>) (e $Snap)) (!
  (= (Set_in e (Set_union s1 s2)) (or (Set_in e s1) (Set_in e s2)))
  :pattern ((Set_in e (Set_union s1 s2)))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>) (e $Snap)) (!
  (implies (Set_in e s1) (Set_in e (Set_union s1 s2)))
  :pattern ((Set_in e s1) (Set_union s1 s2))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>) (e $Snap)) (!
  (implies (Set_in e s2) (Set_in e (Set_union s1 s2)))
  :pattern ((Set_in e s2) (Set_union s1 s2))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>) (e $Snap)) (!
  (= (Set_in e (Set_intersection s1 s2)) (and (Set_in e s1) (Set_in e s2)))
  :pattern ((Set_in e (Set_intersection s1 s2)))
  :pattern ((Set_intersection s1 s2) (Set_in e s1))
  :pattern ((Set_intersection s1 s2) (Set_in e s2))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>)) (!
  (= (Set_union s1 (Set_union s1 s2)) (Set_union s1 s2))
  :pattern ((Set_union s1 (Set_union s1 s2)))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>)) (!
  (= (Set_union (Set_union s1 s2) s2) (Set_union s1 s2))
  :pattern ((Set_union (Set_union s1 s2) s2))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>)) (!
  (= (Set_intersection s1 (Set_intersection s1 s2)) (Set_intersection s1 s2))
  :pattern ((Set_intersection s1 (Set_intersection s1 s2)))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>)) (!
  (= (Set_intersection (Set_intersection s1 s2) s2) (Set_intersection s1 s2))
  :pattern ((Set_intersection (Set_intersection s1 s2) s2))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>)) (!
  (=
    (+ (Set_card (Set_union s1 s2)) (Set_card (Set_intersection s1 s2)))
    (+ (Set_card s1) (Set_card s2)))
  :pattern ((Set_card (Set_union s1 s2)))
  :pattern ((Set_card (Set_intersection s1 s2)))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>) (e $Snap)) (!
  (= (Set_in e (Set_difference s1 s2)) (and (Set_in e s1) (not (Set_in e s2))))
  :pattern ((Set_in e (Set_difference s1 s2)))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>) (e $Snap)) (!
  (implies (Set_in e s2) (not (Set_in e (Set_difference s1 s2))))
  :pattern ((Set_difference s1 s2) (Set_in e s2))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>)) (!
  (=
    (Set_subset s1 s2)
    (forall ((e $Snap)) (!
      (implies (Set_in e s1) (Set_in e s2))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_subset s1 s2))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>)) (!
  (=
    (Set_equal s1 s2)
    (forall ((e $Snap)) (!
      (= (Set_in e s1) (Set_in e s2))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_equal s1 s2))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>)) (!
  (implies (Set_equal s1 s2) (= s1 s2))
  :pattern ((Set_equal s1 s2))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>)) (!
  (=
    (Set_disjoint s1 s2)
    (forall ((e $Snap)) (!
      (or (not (Set_in e s1)) (not (Set_in e s2)))
      :pattern ((Set_in e s1))
      :pattern ((Set_in e s2))
      )))
  :pattern ((Set_disjoint s1 s2))
  )))
(assert (forall ((s1 Set<$Snap>) (s2 Set<$Snap>)) (!
  (and
    (=
      (+
        (+ (Set_card (Set_difference s1 s2)) (Set_card (Set_difference s2 s1)))
        (Set_card (Set_intersection s1 s2)))
      (Set_card (Set_union s1 s2)))
    (=
      (Set_card (Set_difference s1 s2))
      (- (Set_card s1) (Set_card (Set_intersection s1 s2)))))
  :pattern ((Set_card (Set_difference s1 s2)))
  )))
(assert (forall ((g Bool) (k $Ref) (v Int)) (!
  (= (Measure$guard<Bool> (Measure$create<Measure$> g k v)) g)
  :pattern ((Measure$guard<Bool> (Measure$create<Measure$> g k v)))
  )))
(assert (forall ((g Bool) (k $Ref) (v Int)) (!
  (= (Measure$key<Ref> (Measure$create<Measure$> g k v)) k)
  :pattern ((Measure$key<Ref> (Measure$create<Measure$> g k v)))
  )))
(assert (forall ((g Bool) (k $Ref) (v Int)) (!
  (= (Measure$value<Int> (Measure$create<Measure$> g k v)) v)
  :pattern ((Measure$value<Int> (Measure$create<Measure$> g k v)))
  )))
(assert (forall ((x $Ref)) (!
  (Low<Bool> x)
  :pattern ((Low<Bool> x))
  )))
(assert (forall ((sub PyType) (middle PyType) (super PyType)) (!
  (implies
    (and (issubtype<Bool> sub middle) (issubtype<Bool> middle super))
    (issubtype<Bool> sub super))
  :pattern ((issubtype<Bool> sub middle) (issubtype<Bool> middle super))
  )))
(assert (forall ((type_ PyType)) (!
  (issubtype<Bool> type_ type_)
  :pattern ((issubtype<Bool> type_ type_))
  )))
(assert (forall ((sub PyType) (sub2 PyType)) (!
  (implies (extends_<Bool> sub sub2) (issubtype<Bool> sub sub2))
  :pattern ((extends_<Bool> sub sub2))
  )))
(assert (forall ((r $Ref)) (!
  (=
    (issubtype<Bool> (typeof<PyType> r) (as NoneType<PyType>  PyType))
    (= r $Ref.null))
  :pattern ((typeof<PyType> r))
  )))
(assert (forall ((type_ PyType)) (!
  (issubtype<Bool> type_ (as object<PyType>  PyType))
  :pattern ((issubtype<Bool> type_ (as object<PyType>  PyType)))
  )))
(assert (forall ((sub PyType) (sub2 PyType) (super PyType)) (!
  (implies
    (and
      (and (extends_<Bool> sub super) (extends_<Bool> sub2 super))
      (not (= sub sub2)))
    (and (isnotsubtype<Bool> sub sub2) (isnotsubtype<Bool> sub2 sub)))
  :pattern ((extends_<Bool> sub super) (extends_<Bool> sub2 super))
  )))
(assert (forall ((sub PyType) (super PyType)) (!
  (implies
    (and (issubtype<Bool> sub super) (not (= sub super)))
    (not (issubtype<Bool> super sub)))
  :pattern ((issubtype<Bool> sub super))
  :pattern ((issubtype<Bool> super sub))
  )))
(assert (forall ((sub PyType) (middle PyType) (super PyType)) (!
  (implies
    (and (issubtype<Bool> sub middle) (isnotsubtype<Bool> middle super))
    (not (issubtype<Bool> sub super)))
  :pattern ((issubtype<Bool> sub middle) (isnotsubtype<Bool> middle super))
  )))
(assert (forall ((seq Seq<PyType>) (i Int) (Z PyType)) (!
  (implies
    (issubtype<Bool> Z (tuple<PyType> seq))
    (issubtype<Bool> (tuple_arg<PyType> Z i) (Seq_index seq i)))
  :pattern ((tuple<PyType> seq) (tuple_arg<PyType> Z i))
  )))
(assert (forall ((seq Seq<PyType>) (Z PyType)) (!
  (implies
    (issubtype<Bool> Z (tuple<PyType> seq))
    (= (Seq_length (tuple_args<Seq<PyType>> Z)) (Seq_length seq)))
  :pattern ((issubtype<Bool> Z (tuple<PyType> seq)))
  )))
(assert (forall ((seq1 Seq<PyType>) (seq2 Seq<PyType>)) (!
  (implies
    (and
      (and (not (Seq_equal seq1 seq2)) (= (Seq_length seq1) (Seq_length seq2)))
      (forall ((i Int)) (!
        (implies
          (and (>= i 0) (< i (Seq_length seq1)))
          (issubtype<Bool> (Seq_index seq1 i) (Seq_index seq2 i)))
        :pattern ((issubtype<Bool> (Seq_index seq1 i) (Seq_index seq2 i)))
        )))
    (issubtype<Bool> (tuple<PyType> seq1) (tuple<PyType> seq2)))
  :pattern ((Seq_length seq1) (Seq_length seq2))
  :pattern ((Seq_length seq1) (tuple<PyType> seq2))
  :pattern ((Seq_length seq1) (issubtype<Bool> (tuple<PyType> seq1) (tuple<PyType> seq2)))
  :pattern ((Seq_length seq2) (Seq_length seq1))
  :pattern ((Seq_length seq2) (tuple<PyType> seq1))
  :pattern ((Seq_length seq2) (issubtype<Bool> (tuple<PyType> seq1) (tuple<PyType> seq2)))
  :pattern ((issubtype<Bool> (tuple<PyType> seq1) (tuple<PyType> seq2)))
  )))
(assert (forall ((arg_1 PyType) (X PyType)) (!
  (= (issubtype<Bool> X (union_type_1<PyType> arg_1)) (issubtype<Bool> X arg_1))
  :pattern ((issubtype<Bool> X (union_type_1<PyType> arg_1)))
  )))
(assert (forall ((arg_1 PyType) (arg_2 PyType) (X PyType)) (!
  (=
    (issubtype<Bool> X (union_type_2<PyType> arg_1 arg_2))
    (or (issubtype<Bool> X arg_1) (issubtype<Bool> X arg_2)))
  :pattern ((issubtype<Bool> X (union_type_2<PyType> arg_1 arg_2)))
  )))
(assert (forall ((arg_1 PyType) (arg_2 PyType) (arg_3 PyType) (X PyType)) (!
  (=
    (issubtype<Bool> X (union_type_3<PyType> arg_1 arg_2 arg_3))
    (or
      (or (issubtype<Bool> X arg_1) (issubtype<Bool> X arg_2))
      (issubtype<Bool> X arg_3)))
  :pattern ((issubtype<Bool> X (union_type_3<PyType> arg_1 arg_2 arg_3)))
  )))
(assert (forall ((arg_1 PyType) (arg_2 PyType) (arg_3 PyType) (arg_4 PyType) (X PyType)) (!
  (=
    (issubtype<Bool> X (union_type_4<PyType> arg_1 arg_2 arg_3 arg_4))
    (or
      (or
        (or (issubtype<Bool> X arg_1) (issubtype<Bool> X arg_2))
        (issubtype<Bool> X arg_3))
      (issubtype<Bool> X arg_4)))
  :pattern ((issubtype<Bool> X (union_type_4<PyType> arg_1 arg_2 arg_3 arg_4)))
  )))
(assert (forall ((arg_1 PyType) (X PyType)) (!
  (= (issubtype<Bool> (union_type_1<PyType> arg_1) X) (issubtype<Bool> arg_1 X))
  :pattern ((issubtype<Bool> (union_type_1<PyType> arg_1) X))
  )))
(assert (forall ((arg_1 PyType) (arg_2 PyType) (X PyType)) (!
  (=
    (issubtype<Bool> (union_type_2<PyType> arg_1 arg_2) X)
    (and (issubtype<Bool> arg_1 X) (issubtype<Bool> arg_2 X)))
  :pattern ((issubtype<Bool> (union_type_2<PyType> arg_1 arg_2) X))
  )))
(assert (forall ((arg_1 PyType) (arg_2 PyType) (arg_3 PyType) (X PyType)) (!
  (=
    (issubtype<Bool> (union_type_3<PyType> arg_1 arg_2 arg_3) X)
    (and
      (and (issubtype<Bool> arg_1 X) (issubtype<Bool> arg_2 X))
      (issubtype<Bool> arg_3 X)))
  :pattern ((issubtype<Bool> (union_type_3<PyType> arg_1 arg_2 arg_3) X))
  )))
(assert (forall ((arg_1 PyType) (arg_2 PyType) (arg_3 PyType) (arg_4 PyType) (X PyType)) (!
  (=
    (issubtype<Bool> (union_type_4<PyType> arg_1 arg_2 arg_3 arg_4) X)
    (and
      (and
        (and (issubtype<Bool> arg_1 X) (issubtype<Bool> arg_2 X))
        (issubtype<Bool> arg_3 X))
      (issubtype<Bool> arg_4 X)))
  :pattern ((issubtype<Bool> (union_type_4<PyType> arg_1 arg_2 arg_3 arg_4) X))
  )))
(assert (forall ((var0 PyType)) (!
  (and
    (extends_<Bool> (list<PyType> var0) (as object<PyType>  PyType))
    (= (get_basic<PyType> (list<PyType> var0)) (as list_basic<PyType>  PyType)))
  :pattern ((list<PyType> var0))
  )))
(assert (forall ((Z PyType) (arg0 PyType)) (!
  (implies
    (issubtype<Bool> Z (list<PyType> arg0))
    (= (list_arg<PyType> Z 0) arg0))
  :pattern ((list<PyType> arg0) (list_arg<PyType> Z 0))
  )))
(assert (forall ((var0 PyType)) (!
  (and
    (extends_<Bool> (set<PyType> var0) (as object<PyType>  PyType))
    (= (get_basic<PyType> (set<PyType> var0)) (as set_basic<PyType>  PyType)))
  :pattern ((set<PyType> var0))
  )))
(assert (forall ((Z PyType) (arg0 PyType)) (!
  (implies (issubtype<Bool> Z (set<PyType> arg0)) (= (set_arg<PyType> Z 0) arg0))
  :pattern ((set<PyType> arg0) (set_arg<PyType> Z 0))
  )))
(assert (forall ((var0 PyType) (var1 PyType)) (!
  (and
    (extends_<Bool> (dict<PyType> var0 var1) (as object<PyType>  PyType))
    (=
      (get_basic<PyType> (dict<PyType> var0 var1))
      (as dict_basic<PyType>  PyType)))
  :pattern ((dict<PyType> var0 var1))
  )))
(assert (forall ((Z PyType) (arg0 PyType) (arg1 PyType)) (!
  (implies
    (issubtype<Bool> Z (dict<PyType> arg0 arg1))
    (= (dict_arg<PyType> Z 0) arg0))
  :pattern ((dict<PyType> arg0 arg1) (dict_arg<PyType> Z 0))
  )))
(assert (forall ((Z PyType) (arg0 PyType) (arg1 PyType)) (!
  (implies
    (issubtype<Bool> Z (dict<PyType> arg0 arg1))
    (= (dict_arg<PyType> Z 1) arg1))
  :pattern ((dict<PyType> arg0 arg1) (dict_arg<PyType> Z 1))
  )))
(assert (and
  (extends_<Bool> (as int<PyType>  PyType) (as float<PyType>  PyType))
  (= (get_basic<PyType> (as int<PyType>  PyType)) (as int<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as float<PyType>  PyType) (as object<PyType>  PyType))
  (= (get_basic<PyType> (as float<PyType>  PyType)) (as float<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as bool<PyType>  PyType) (as int<PyType>  PyType))
  (= (get_basic<PyType> (as bool<PyType>  PyType)) (as bool<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as NoneType<PyType>  PyType) (as object<PyType>  PyType))
  (=
    (get_basic<PyType> (as NoneType<PyType>  PyType))
    (as NoneType<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as Exception<PyType>  PyType) (as object<PyType>  PyType))
  (=
    (get_basic<PyType> (as Exception<PyType>  PyType))
    (as Exception<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as traceback<PyType>  PyType) (as object<PyType>  PyType))
  (=
    (get_basic<PyType> (as traceback<PyType>  PyType))
    (as traceback<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as str<PyType>  PyType) (as object<PyType>  PyType))
  (= (get_basic<PyType> (as str<PyType>  PyType)) (as str<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as bytes<PyType>  PyType) (as object<PyType>  PyType))
  (= (get_basic<PyType> (as bytes<PyType>  PyType)) (as bytes<PyType>  PyType))))
(assert (forall ((args Seq<PyType>)) (!
  (and
    (implies
      (forall ((e PyType)) (!
        (implies (Seq_contains args e) (= e (as object<PyType>  PyType)))
        :pattern ((Seq_contains args e))
        ))
      (extends_<Bool> (tuple<PyType> args) (as object<PyType>  PyType)))
    (= (get_basic<PyType> (tuple<PyType> args)) (as tuple_basic<PyType>  PyType)))
  :pattern ((tuple<PyType> args))
  )))
(assert (forall ((var0 PyType)) (!
  (and
    (extends_<Bool> (PSeq<PyType> var0) (as object<PyType>  PyType))
    (= (get_basic<PyType> (PSeq<PyType> var0)) (as PSeq_basic<PyType>  PyType)))
  :pattern ((PSeq<PyType> var0))
  )))
(assert (forall ((Z PyType) (arg0 PyType)) (!
  (implies
    (issubtype<Bool> Z (PSeq<PyType> arg0))
    (= (PSeq_arg<PyType> Z 0) arg0))
  :pattern ((PSeq<PyType> arg0) (PSeq_arg<PyType> Z 0))
  )))
(assert (forall ((var0 PyType)) (!
  (and
    (extends_<Bool> (PSet<PyType> var0) (as object<PyType>  PyType))
    (= (get_basic<PyType> (PSet<PyType> var0)) (as PSet_basic<PyType>  PyType)))
  :pattern ((PSet<PyType> var0))
  )))
(assert (forall ((Z PyType) (arg0 PyType)) (!
  (implies
    (issubtype<Bool> Z (PSet<PyType> arg0))
    (= (PSet_arg<PyType> Z 0) arg0))
  :pattern ((PSet<PyType> arg0) (PSet_arg<PyType> Z 0))
  )))
(assert (forall ((var0 PyType)) (!
  (and
    (extends_<Bool> (PMultiset<PyType> var0) (as object<PyType>  PyType))
    (=
      (get_basic<PyType> (PMultiset<PyType> var0))
      (as PMultiset_basic<PyType>  PyType)))
  :pattern ((PMultiset<PyType> var0))
  )))
(assert (forall ((Z PyType) (arg0 PyType)) (!
  (implies
    (issubtype<Bool> Z (PMultiset<PyType> arg0))
    (= (PMultiset_arg<PyType> Z 0) arg0))
  :pattern ((PMultiset<PyType> arg0) (PMultiset_arg<PyType> Z 0))
  )))
(assert (and
  (extends_<Bool> (as slice<PyType>  PyType) (as object<PyType>  PyType))
  (= (get_basic<PyType> (as slice<PyType>  PyType)) (as slice<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as range<PyType>  PyType) (as object<PyType>  PyType))
  (= (get_basic<PyType> (as range<PyType>  PyType)) (as range<PyType>  PyType))))
(assert (forall ((var0 PyType)) (!
  (and
    (extends_<Bool> (Iterator<PyType> var0) (as object<PyType>  PyType))
    (=
      (get_basic<PyType> (Iterator<PyType> var0))
      (as Iterator_basic<PyType>  PyType)))
  :pattern ((Iterator<PyType> var0))
  )))
(assert (forall ((Z PyType) (arg0 PyType)) (!
  (implies
    (issubtype<Bool> Z (Iterator<PyType> arg0))
    (= (Iterator_arg<PyType> Z 0) arg0))
  :pattern ((Iterator<PyType> arg0) (Iterator_arg<PyType> Z 0))
  )))
(assert (and
  (extends_<Bool> (as Thread_0<PyType>  PyType) (as object<PyType>  PyType))
  (=
    (get_basic<PyType> (as Thread_0<PyType>  PyType))
    (as Thread_0<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as LevelType<PyType>  PyType) (as object<PyType>  PyType))
  (=
    (get_basic<PyType> (as LevelType<PyType>  PyType))
    (as LevelType<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as type<PyType>  PyType) (as object<PyType>  PyType))
  (= (get_basic<PyType> (as type<PyType>  PyType)) (as type<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as Place<PyType>  PyType) (as object<PyType>  PyType))
  (= (get_basic<PyType> (as Place<PyType>  PyType)) (as Place<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as __prim__Seq_type<PyType>  PyType) (as object<PyType>  PyType))
  (=
    (get_basic<PyType> (as __prim__Seq_type<PyType>  PyType))
    (as __prim__Seq_type<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as NNAgent<PyType>  PyType) (as Agent<PyType>  PyType))
  (=
    (get_basic<PyType> (as NNAgent<PyType>  PyType))
    (as NNAgent<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as Agent<PyType>  PyType) (as object<PyType>  PyType))
  (= (get_basic<PyType> (as Agent<PyType>  PyType)) (as Agent<PyType>  PyType))))
(assert (and
  (extends_<Bool> (as Vehicle<PyType>  PyType) (as object<PyType>  PyType))
  (=
    (get_basic<PyType> (as Vehicle<PyType>  PyType))
    (as Vehicle<PyType>  PyType))))
(assert (forall ((___s Seq<$Ref>)) (!
  (= (Seq_length ___s) (seq_ref_length<Int> ___s))
  :pattern ((Seq_length ___s))
  )))
(assert (forall ((___s Seq<$Ref>) (___i Int)) (!
  (= (Seq_index ___s ___i) (seq_ref_index<Ref> ___s ___i))
  :pattern ((Seq_index ___s ___i))
  )))
(assert (forall ((i Int)) (!
  (= (_get_value<Int> (_single<_Name> i)) i)
  :pattern ((_single<_Name> i))
  )))
(assert (forall ((n _Name)) (!
  (implies (_is_single<Bool> n) (= n (_single<_Name> (_get_value<Int> n))))
  :pattern ((_get_value<Int> n))
  )))
(assert (forall ((i Int)) (!
  (_name_type<Bool> (_single<_Name> i))
  :pattern ((_single<_Name> i))
  )))
(assert (forall ((n1 _Name) (n2 _Name)) (!
  (and
    (= (_get_combined_prefix<_Name> (_combine<_Name> n1 n2)) n1)
    (= (_get_combined_name<_Name> (_combine<_Name> n1 n2)) n2))
  :pattern ((_combine<_Name> n1 n2))
  )))
(assert (forall ((n _Name)) (!
  (implies
    (_is_combined<Bool> n)
    (=
      n
      (_combine<_Name> (_get_combined_prefix<_Name> n) (_get_combined_name<_Name> n))))
  :pattern ((_get_combined_prefix<_Name> n))
  :pattern ((_get_combined_name<_Name> n))
  )))
(assert (forall ((n1 _Name) (n2 _Name)) (!
  (not (_name_type<Bool> (_combine<_Name> n1 n2)))
  :pattern ((_combine<_Name> n1 n2))
  )))
(assert (forall ((n _Name)) (!
  (= (_name_type<Bool> n) (_is_single<Bool> n))
  :pattern ((_name_type<Bool> n))
  )))
(assert (forall ((n _Name)) (!
  (= (not (_name_type<Bool> n)) (_is_combined<Bool> n))
  :pattern ((_name_type<Bool> n))
  )))
; /field_value_functions_axioms.smt2 [Vehicle_id: Ref]
(assert (forall ((vs $FVF<$Ref>) (ws $FVF<$Ref>)) (!
    (implies
      (and
        (Set_equal ($FVF.domain_Vehicle_id vs) ($FVF.domain_Vehicle_id ws))
        (forall ((x $Ref)) (!
          (implies
            (Set_in x ($FVF.domain_Vehicle_id vs))
            (= ($FVF.lookup_Vehicle_id vs x) ($FVF.lookup_Vehicle_id ws x)))
          :pattern (($FVF.lookup_Vehicle_id vs x) ($FVF.lookup_Vehicle_id ws x))
          :qid |qp.$FVF<$Ref>-eq-inner|
          )))
      (= vs ws))
    :pattern (($SortWrappers.$FVF<$Ref>To$Snap vs)
              ($SortWrappers.$FVF<$Ref>To$Snap ws)
              )
    :qid |qp.$FVF<$Ref>-eq-outer|
    )))
(assert (forall ((r $Ref) (pm $FPM)) (!
    ($Perm.isValidVar ($FVF.perm_Vehicle_id pm r))
    :pattern ($FVF.perm_Vehicle_id pm r))))
(assert (forall ((r $Ref) (f $Ref)) (!
    (= ($FVF.loc_Vehicle_id f r) true)
    :pattern ($FVF.loc_Vehicle_id f r))))
; /field_value_functions_axioms.smt2 [list_acc: Seq[Ref]]
(assert (forall ((vs $FVF<Seq<$Ref>>) (ws $FVF<Seq<$Ref>>)) (!
    (implies
      (and
        (Set_equal ($FVF.domain_list_acc vs) ($FVF.domain_list_acc ws))
        (forall ((x $Ref)) (!
          (implies
            (Set_in x ($FVF.domain_list_acc vs))
            (= ($FVF.lookup_list_acc vs x) ($FVF.lookup_list_acc ws x)))
          :pattern (($FVF.lookup_list_acc vs x) ($FVF.lookup_list_acc ws x))
          :qid |qp.$FVF<Seq<$Ref>>-eq-inner|
          )))
      (= vs ws))
    :pattern (($SortWrappers.$FVF<Seq<$Ref>>To$Snap vs)
              ($SortWrappers.$FVF<Seq<$Ref>>To$Snap ws)
              )
    :qid |qp.$FVF<Seq<$Ref>>-eq-outer|
    )))
(assert (forall ((r $Ref) (pm $FPM)) (!
    ($Perm.isValidVar ($FVF.perm_list_acc pm r))
    :pattern ($FVF.perm_list_acc pm r))))
(assert (forall ((r $Ref) (f Seq<$Ref>)) (!
    (= ($FVF.loc_list_acc f r) true)
    :pattern ($FVF.loc_list_acc f r))))
; /field_value_functions_axioms.smt2 [Vehicle_loc_x: Ref]
(assert (forall ((vs $FVF<$Ref>) (ws $FVF<$Ref>)) (!
    (implies
      (and
        (Set_equal ($FVF.domain_Vehicle_loc_x vs) ($FVF.domain_Vehicle_loc_x ws))
        (forall ((x $Ref)) (!
          (implies
            (Set_in x ($FVF.domain_Vehicle_loc_x vs))
            (= ($FVF.lookup_Vehicle_loc_x vs x) ($FVF.lookup_Vehicle_loc_x ws x)))
          :pattern (($FVF.lookup_Vehicle_loc_x vs x) ($FVF.lookup_Vehicle_loc_x ws x))
          :qid |qp.$FVF<$Ref>-eq-inner|
          )))
      (= vs ws))
    :pattern (($SortWrappers.$FVF<$Ref>To$Snap vs)
              ($SortWrappers.$FVF<$Ref>To$Snap ws)
              )
    :qid |qp.$FVF<$Ref>-eq-outer|
    )))
(assert (forall ((r $Ref) (pm $FPM)) (!
    ($Perm.isValidVar ($FVF.perm_Vehicle_loc_x pm r))
    :pattern ($FVF.perm_Vehicle_loc_x pm r))))
(assert (forall ((r $Ref) (f $Ref)) (!
    (= ($FVF.loc_Vehicle_loc_x f r) true)
    :pattern ($FVF.loc_Vehicle_loc_x f r))))
; /field_value_functions_axioms.smt2 [Vehicle_loc_y: Ref]
(assert (forall ((vs $FVF<$Ref>) (ws $FVF<$Ref>)) (!
    (implies
      (and
        (Set_equal ($FVF.domain_Vehicle_loc_y vs) ($FVF.domain_Vehicle_loc_y ws))
        (forall ((x $Ref)) (!
          (implies
            (Set_in x ($FVF.domain_Vehicle_loc_y vs))
            (= ($FVF.lookup_Vehicle_loc_y vs x) ($FVF.lookup_Vehicle_loc_y ws x)))
          :pattern (($FVF.lookup_Vehicle_loc_y vs x) ($FVF.lookup_Vehicle_loc_y ws x))
          :qid |qp.$FVF<$Ref>-eq-inner|
          )))
      (= vs ws))
    :pattern (($SortWrappers.$FVF<$Ref>To$Snap vs)
              ($SortWrappers.$FVF<$Ref>To$Snap ws)
              )
    :qid |qp.$FVF<$Ref>-eq-outer|
    )))
(assert (forall ((r $Ref) (pm $FPM)) (!
    ($Perm.isValidVar ($FVF.perm_Vehicle_loc_y pm r))
    :pattern ($FVF.perm_Vehicle_loc_y pm r))))
(assert (forall ((r $Ref) (f $Ref)) (!
    (= ($FVF.loc_Vehicle_loc_y f r) true)
    :pattern ($FVF.loc_Vehicle_loc_y f r))))
; /field_value_functions_axioms.smt2 [Vehicle_is_junction: Ref]
(assert (forall ((vs $FVF<$Ref>) (ws $FVF<$Ref>)) (!
    (implies
      (and
        (Set_equal ($FVF.domain_Vehicle_is_junction vs) ($FVF.domain_Vehicle_is_junction ws))
        (forall ((x $Ref)) (!
          (implies
            (Set_in x ($FVF.domain_Vehicle_is_junction vs))
            (= ($FVF.lookup_Vehicle_is_junction vs x) ($FVF.lookup_Vehicle_is_junction ws x)))
          :pattern (($FVF.lookup_Vehicle_is_junction vs x) ($FVF.lookup_Vehicle_is_junction ws x))
          :qid |qp.$FVF<$Ref>-eq-inner|
          )))
      (= vs ws))
    :pattern (($SortWrappers.$FVF<$Ref>To$Snap vs)
              ($SortWrappers.$FVF<$Ref>To$Snap ws)
              )
    :qid |qp.$FVF<$Ref>-eq-outer|
    )))
(assert (forall ((r $Ref) (pm $FPM)) (!
    ($Perm.isValidVar ($FVF.perm_Vehicle_is_junction pm r))
    :pattern ($FVF.perm_Vehicle_is_junction pm r))))
(assert (forall ((r $Ref) (f $Ref)) (!
    (= ($FVF.loc_Vehicle_is_junction f r) true)
    :pattern ($FVF.loc_Vehicle_is_junction f r))))
; /field_value_functions_axioms.smt2 [NNAgent_vehicle_list: Ref]
(assert (forall ((vs $FVF<$Ref>) (ws $FVF<$Ref>)) (!
    (implies
      (and
        (Set_equal ($FVF.domain_NNAgent_vehicle_list vs) ($FVF.domain_NNAgent_vehicle_list ws))
        (forall ((x $Ref)) (!
          (implies
            (Set_in x ($FVF.domain_NNAgent_vehicle_list vs))
            (= ($FVF.lookup_NNAgent_vehicle_list vs x) ($FVF.lookup_NNAgent_vehicle_list ws x)))
          :pattern (($FVF.lookup_NNAgent_vehicle_list vs x) ($FVF.lookup_NNAgent_vehicle_list ws x))
          :qid |qp.$FVF<$Ref>-eq-inner|
          )))
      (= vs ws))
    :pattern (($SortWrappers.$FVF<$Ref>To$Snap vs)
              ($SortWrappers.$FVF<$Ref>To$Snap ws)
              )
    :qid |qp.$FVF<$Ref>-eq-outer|
    )))
(assert (forall ((r $Ref) (pm $FPM)) (!
    ($Perm.isValidVar ($FVF.perm_NNAgent_vehicle_list pm r))
    :pattern ($FVF.perm_NNAgent_vehicle_list pm r))))
(assert (forall ((r $Ref) (f $Ref)) (!
    (= ($FVF.loc_NNAgent_vehicle_list f r) true)
    :pattern ($FVF.loc_NNAgent_vehicle_list f r))))
; /field_value_functions_axioms.smt2 [NNAgent_vehicle_list1: Ref]
(assert (forall ((vs $FVF<$Ref>) (ws $FVF<$Ref>)) (!
    (implies
      (and
        (Set_equal ($FVF.domain_NNAgent_vehicle_list1 vs) ($FVF.domain_NNAgent_vehicle_list1 ws))
        (forall ((x $Ref)) (!
          (implies
            (Set_in x ($FVF.domain_NNAgent_vehicle_list1 vs))
            (= ($FVF.lookup_NNAgent_vehicle_list1 vs x) ($FVF.lookup_NNAgent_vehicle_list1 ws x)))
          :pattern (($FVF.lookup_NNAgent_vehicle_list1 vs x) ($FVF.lookup_NNAgent_vehicle_list1 ws x))
          :qid |qp.$FVF<$Ref>-eq-inner|
          )))
      (= vs ws))
    :pattern (($SortWrappers.$FVF<$Ref>To$Snap vs)
              ($SortWrappers.$FVF<$Ref>To$Snap ws)
              )
    :qid |qp.$FVF<$Ref>-eq-outer|
    )))
(assert (forall ((r $Ref) (pm $FPM)) (!
    ($Perm.isValidVar ($FVF.perm_NNAgent_vehicle_list1 pm r))
    :pattern ($FVF.perm_NNAgent_vehicle_list1 pm r))))
(assert (forall ((r $Ref) (f $Ref)) (!
    (= ($FVF.loc_NNAgent_vehicle_list1 f r) true)
    :pattern ($FVF.loc_NNAgent_vehicle_list1 f r))))
; /field_value_functions_axioms.smt2 [__previous: Seq[Ref]]
(assert (forall ((vs $FVF<Seq<$Ref>>) (ws $FVF<Seq<$Ref>>)) (!
    (implies
      (and
        (Set_equal ($FVF.domain___previous vs) ($FVF.domain___previous ws))
        (forall ((x $Ref)) (!
          (implies
            (Set_in x ($FVF.domain___previous vs))
            (= ($FVF.lookup___previous vs x) ($FVF.lookup___previous ws x)))
          :pattern (($FVF.lookup___previous vs x) ($FVF.lookup___previous ws x))
          :qid |qp.$FVF<Seq<$Ref>>-eq-inner|
          )))
      (= vs ws))
    :pattern (($SortWrappers.$FVF<Seq<$Ref>>To$Snap vs)
              ($SortWrappers.$FVF<Seq<$Ref>>To$Snap ws)
              )
    :qid |qp.$FVF<Seq<$Ref>>-eq-outer|
    )))
(assert (forall ((r $Ref) (pm $FPM)) (!
    ($Perm.isValidVar ($FVF.perm___previous pm r))
    :pattern ($FVF.perm___previous pm r))))
(assert (forall ((r $Ref) (f Seq<$Ref>)) (!
    (= ($FVF.loc___previous f r) true)
    :pattern ($FVF.loc___previous f r))))
; End preamble
; ------------------------------------------------------------
; State saturation: after preamble
(set-option :timeout 100)
(check-sat)
; unknown
; ---------- FUNCTION tuple___val__----------
(declare-fun self@0@00 () $Ref)
(declare-fun result@1@00 () Seq<$Ref>)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@0@00 $Ref)) (!
  (Seq_equal (tuple___val__%limited s@$ self@0@00) (tuple___val__ s@$ self@0@00))
  :pattern ((tuple___val__ s@$ self@0@00))
  )))
(assert (forall ((s@$ $Snap) (self@0@00 $Ref)) (!
  (tuple___val__%stateless self@0@00)
  :pattern ((tuple___val__%limited s@$ self@0@00))
  )))
; ---------- FUNCTION range___val__----------
(declare-fun self@2@00 () $Ref)
(declare-fun result@3@00 () Seq<Int>)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@2@00 $Ref)) (!
  (Seq_equal (range___val__%limited s@$ self@2@00) (range___val__ s@$ self@2@00))
  :pattern ((range___val__ s@$ self@2@00))
  )))
(assert (forall ((s@$ $Snap) (self@2@00 $Ref)) (!
  (range___val__%stateless self@2@00)
  :pattern ((range___val__%limited s@$ self@2@00))
  )))
; ---------- FUNCTION tuple___len__----------
(declare-fun self@4@00 () $Ref)
(declare-fun result@5@00 () Int)
; ----- Well-definedness of specifications -----
(push) ; 1
(declare-const $t@100@00 $Snap)
(assert (= $t@100@00 ($Snap.combine ($Snap.first $t@100@00) ($Snap.second $t@100@00))))
(assert (= ($Snap.first $t@100@00) $Snap.unit))
; [eval] result == |tuple_args(typeof(self))|
; [eval] |tuple_args(typeof(self))|
; [eval] tuple_args(typeof(self))
; [eval] typeof(self)
(assert (= result@5@00 (Seq_length (tuple_args<Seq<PyType>> (typeof<PyType> self@4@00)))))
(assert (= ($Snap.second $t@100@00) $Snap.unit))
; [eval] result == |tuple___val__(self)|
; [eval] |tuple___val__(self)|
; [eval] tuple___val__(self)
(push) ; 2
(pop) ; 2
; Joined path conditions
(assert (= result@5@00 (Seq_length (tuple___val__ $Snap.unit self@4@00))))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@4@00 $Ref)) (!
  (= (tuple___len__%limited s@$ self@4@00) (tuple___len__ s@$ self@4@00))
  :pattern ((tuple___len__ s@$ self@4@00))
  )))
(assert (forall ((s@$ $Snap) (self@4@00 $Ref)) (!
  (tuple___len__%stateless self@4@00)
  :pattern ((tuple___len__%limited s@$ self@4@00))
  )))
(assert (forall ((s@$ $Snap) (self@4@00 $Ref)) (!
  (let ((result@5@00 (tuple___len__%limited s@$ self@4@00))) (and
    (=
      result@5@00
      (Seq_length (tuple_args<Seq<PyType>> (typeof<PyType> self@4@00))))
    (= result@5@00 (Seq_length (tuple___val__ $Snap.unit self@4@00)))))
  :pattern ((tuple___len__%limited s@$ self@4@00))
  )))
; ---------- FUNCTION int___unbox__----------
(declare-fun box@6@00 () $Ref)
(declare-fun result@7@00 () Int)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ $Snap.unit))
; [eval] issubtype(typeof(box), int())
; [eval] typeof(box)
; [eval] int()
(assert (issubtype<Bool> (typeof<PyType> box@6@00) (as int<PyType>  PyType)))
(declare-const $t@101@00 $Snap)
(assert (= $t@101@00 ($Snap.combine ($Snap.first $t@101@00) ($Snap.second $t@101@00))))
(assert (= ($Snap.first $t@101@00) $Snap.unit))
; [eval] !issubtype(typeof(box), bool()) ==> __prim__int___box__(result) == box
; [eval] !issubtype(typeof(box), bool())
; [eval] issubtype(typeof(box), bool())
; [eval] typeof(box)
; [eval] bool()
(push) ; 2
(set-option :timeout 10)
(push) ; 3
(assert (not (issubtype<Bool> (typeof<PyType> box@6@00) (as bool<PyType>  PyType))))
(check-sat)
; unknown
(pop) ; 3
; 0.00s
; (get-info :all-statistics)
(push) ; 3
(assert (not (not (issubtype<Bool> (typeof<PyType> box@6@00) (as bool<PyType>  PyType)))))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
; [then-branch: 0 | !(issubtype[Bool](typeof[PyType](box@6@00), bool[PyType])) | live]
; [else-branch: 0 | issubtype[Bool](typeof[PyType](box@6@00), bool[PyType]) | live]
(push) ; 3
; [then-branch: 0 | !(issubtype[Bool](typeof[PyType](box@6@00), bool[PyType]))]
(assert (not (issubtype<Bool> (typeof<PyType> box@6@00) (as bool<PyType>  PyType))))
; [eval] __prim__int___box__(result) == box
; [eval] __prim__int___box__(result)
(push) ; 4
(pop) ; 4
; Joined path conditions
(pop) ; 3
(push) ; 3
; [else-branch: 0 | issubtype[Bool](typeof[PyType](box@6@00), bool[PyType])]
(assert (issubtype<Bool> (typeof<PyType> box@6@00) (as bool<PyType>  PyType)))
(pop) ; 3
(pop) ; 2
; Joined path conditions
; Joined path conditions
(assert (implies
  (not (issubtype<Bool> (typeof<PyType> box@6@00) (as bool<PyType>  PyType)))
  (= (__prim__int___box__ $Snap.unit result@7@00) box@6@00)))
(assert (= ($Snap.second $t@101@00) $Snap.unit))
; [eval] issubtype(typeof(box), bool()) ==> __prim__bool___box__(result != 0) == box
; [eval] issubtype(typeof(box), bool())
; [eval] typeof(box)
; [eval] bool()
(push) ; 2
(push) ; 3
(assert (not (not (issubtype<Bool> (typeof<PyType> box@6@00) (as bool<PyType>  PyType)))))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
(push) ; 3
(assert (not (issubtype<Bool> (typeof<PyType> box@6@00) (as bool<PyType>  PyType))))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
; [then-branch: 1 | issubtype[Bool](typeof[PyType](box@6@00), bool[PyType]) | live]
; [else-branch: 1 | !(issubtype[Bool](typeof[PyType](box@6@00), bool[PyType])) | live]
(push) ; 3
; [then-branch: 1 | issubtype[Bool](typeof[PyType](box@6@00), bool[PyType])]
(assert (issubtype<Bool> (typeof<PyType> box@6@00) (as bool<PyType>  PyType)))
; [eval] __prim__bool___box__(result != 0) == box
; [eval] __prim__bool___box__(result != 0)
; [eval] result != 0
(push) ; 4
(pop) ; 4
; Joined path conditions
(pop) ; 3
(push) ; 3
; [else-branch: 1 | !(issubtype[Bool](typeof[PyType](box@6@00), bool[PyType]))]
(assert (not (issubtype<Bool> (typeof<PyType> box@6@00) (as bool<PyType>  PyType))))
(pop) ; 3
(pop) ; 2
; Joined path conditions
; Joined path conditions
(assert (implies
  (issubtype<Bool> (typeof<PyType> box@6@00) (as bool<PyType>  PyType))
  (= (__prim__bool___box__ $Snap.unit (not (= result@7@00 0))) box@6@00)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (box@6@00 $Ref)) (!
  (= (int___unbox__%limited s@$ box@6@00) (int___unbox__ s@$ box@6@00))
  :pattern ((int___unbox__ s@$ box@6@00))
  )))
(assert (forall ((s@$ $Snap) (box@6@00 $Ref)) (!
  (int___unbox__%stateless box@6@00)
  :pattern ((int___unbox__%limited s@$ box@6@00))
  )))
(assert (forall ((s@$ $Snap) (box@6@00 $Ref)) (!
  (let ((result@7@00 (int___unbox__%limited s@$ box@6@00))) (implies
    (issubtype<Bool> (typeof<PyType> box@6@00) (as int<PyType>  PyType))
    (and
      (implies
        (not
          (issubtype<Bool> (typeof<PyType> box@6@00) (as bool<PyType>  PyType)))
        (= (__prim__int___box__%limited $Snap.unit result@7@00) box@6@00))
      (implies
        (issubtype<Bool> (typeof<PyType> box@6@00) (as bool<PyType>  PyType))
        (=
          (__prim__bool___box__%limited $Snap.unit (not (= result@7@00 0)))
          box@6@00)))))
  :pattern ((int___unbox__%limited s@$ box@6@00))
  )))
; ---------- FUNCTION __prim__bool___box__----------
(declare-fun prim@8@00 () Bool)
(declare-fun result@9@00 () $Ref)
; ----- Well-definedness of specifications -----
(push) ; 1
(declare-const $t@102@00 $Snap)
(assert (= $t@102@00 ($Snap.combine ($Snap.first $t@102@00) ($Snap.second $t@102@00))))
(assert (= ($Snap.first $t@102@00) $Snap.unit))
; [eval] typeof(result) == bool()
; [eval] typeof(result)
; [eval] bool()
(assert (= (typeof<PyType> result@9@00) (as bool<PyType>  PyType)))
(assert (=
  ($Snap.second $t@102@00)
  ($Snap.combine
    ($Snap.first ($Snap.second $t@102@00))
    ($Snap.second ($Snap.second $t@102@00)))))
(assert (= ($Snap.first ($Snap.second $t@102@00)) $Snap.unit))
; [eval] bool___unbox__(result) == prim
; [eval] bool___unbox__(result)
(push) ; 2
; [eval] issubtype(typeof(box), bool())
; [eval] typeof(box)
; [eval] bool()
(set-option :timeout 0)
(push) ; 3
(assert (not (issubtype<Bool> (typeof<PyType> result@9@00) (as bool<PyType>  PyType))))
(check-sat)
; unsat
(pop) ; 3
; 0.00s
; (get-info :all-statistics)
(assert (issubtype<Bool> (typeof<PyType> result@9@00) (as bool<PyType>  PyType)))
(pop) ; 2
; Joined path conditions
(assert (issubtype<Bool> (typeof<PyType> result@9@00) (as bool<PyType>  PyType)))
(assert (= (bool___unbox__ $Snap.unit result@9@00) prim@8@00))
(assert (= ($Snap.second ($Snap.second $t@102@00)) $Snap.unit))
; [eval] int___unbox__(result) == (prim ? 1 : 0)
; [eval] int___unbox__(result)
(push) ; 2
; [eval] issubtype(typeof(box), int())
; [eval] typeof(box)
; [eval] int()
(push) ; 3
(assert (not (issubtype<Bool> (typeof<PyType> result@9@00) (as int<PyType>  PyType))))
(check-sat)
; unsat
(pop) ; 3
; 0.00s
; (get-info :all-statistics)
(assert (issubtype<Bool> (typeof<PyType> result@9@00) (as int<PyType>  PyType)))
(pop) ; 2
; Joined path conditions
(assert (issubtype<Bool> (typeof<PyType> result@9@00) (as int<PyType>  PyType)))
; [eval] (prim ? 1 : 0)
(push) ; 2
(set-option :timeout 10)
(push) ; 3
(assert (not (not prim@8@00)))
(check-sat)
; unknown
(pop) ; 3
; 0.00s
; (get-info :all-statistics)
(push) ; 3
(assert (not prim@8@00))
(check-sat)
; unknown
(pop) ; 3
; 0.00s
; (get-info :all-statistics)
; [then-branch: 2 | prim@8@00 | live]
; [else-branch: 2 | !(prim@8@00) | live]
(push) ; 3
; [then-branch: 2 | prim@8@00]
(assert prim@8@00)
(pop) ; 3
(push) ; 3
; [else-branch: 2 | !(prim@8@00)]
(assert (not prim@8@00))
(pop) ; 3
(pop) ; 2
; Joined path conditions
; Joined path conditions
(assert (= (int___unbox__ $Snap.unit result@9@00) (ite prim@8@00 1 0)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (prim@8@00 Bool)) (!
  (=
    (__prim__bool___box__%limited s@$ prim@8@00)
    (__prim__bool___box__ s@$ prim@8@00))
  :pattern ((__prim__bool___box__ s@$ prim@8@00))
  )))
(assert (forall ((s@$ $Snap) (prim@8@00 Bool)) (!
  (__prim__bool___box__%stateless prim@8@00)
  :pattern ((__prim__bool___box__%limited s@$ prim@8@00))
  )))
(assert (forall ((s@$ $Snap) (prim@8@00 Bool)) (!
  (let ((result@9@00 (__prim__bool___box__%limited s@$ prim@8@00))) (and
    (= (typeof<PyType> result@9@00) (as bool<PyType>  PyType))
    (= (bool___unbox__%limited $Snap.unit result@9@00) prim@8@00)
    (= (int___unbox__%limited $Snap.unit result@9@00) (ite prim@8@00 1 0))))
  :pattern ((__prim__bool___box__%limited s@$ prim@8@00))
  )))
; ---------- FUNCTION bool___unbox__----------
(declare-fun box@10@00 () $Ref)
(declare-fun result@11@00 () Bool)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ $Snap.unit))
; [eval] issubtype(typeof(box), bool())
; [eval] typeof(box)
; [eval] bool()
(assert (issubtype<Bool> (typeof<PyType> box@10@00) (as bool<PyType>  PyType)))
(declare-const $t@103@00 $Snap)
(assert (= $t@103@00 $Snap.unit))
; [eval] __prim__bool___box__(result) == box
; [eval] __prim__bool___box__(result)
(push) ; 2
(pop) ; 2
; Joined path conditions
(assert (= (__prim__bool___box__ $Snap.unit result@11@00) box@10@00))
(pop) ; 1
(assert (forall ((s@$ $Snap) (box@10@00 $Ref)) (!
  (= (bool___unbox__%limited s@$ box@10@00) (bool___unbox__ s@$ box@10@00))
  :pattern ((bool___unbox__ s@$ box@10@00))
  )))
(assert (forall ((s@$ $Snap) (box@10@00 $Ref)) (!
  (bool___unbox__%stateless box@10@00)
  :pattern ((bool___unbox__%limited s@$ box@10@00))
  )))
(assert (forall ((s@$ $Snap) (box@10@00 $Ref)) (!
  (let ((result@11@00 (bool___unbox__%limited s@$ box@10@00))) (implies
    (issubtype<Bool> (typeof<PyType> box@10@00) (as bool<PyType>  PyType))
    (= (__prim__bool___box__%limited $Snap.unit result@11@00) box@10@00)))
  :pattern ((bool___unbox__%limited s@$ box@10@00))
  )))
; ---------- FUNCTION __prim__int___box__----------
(declare-fun prim@12@00 () Int)
(declare-fun result@13@00 () $Ref)
; ----- Well-definedness of specifications -----
(push) ; 1
(declare-const $t@104@00 $Snap)
(assert (= $t@104@00 ($Snap.combine ($Snap.first $t@104@00) ($Snap.second $t@104@00))))
(assert (= ($Snap.first $t@104@00) $Snap.unit))
; [eval] typeof(result) == int()
; [eval] typeof(result)
; [eval] int()
(assert (= (typeof<PyType> result@13@00) (as int<PyType>  PyType)))
(assert (= ($Snap.second $t@104@00) $Snap.unit))
; [eval] int___unbox__(result) == prim
; [eval] int___unbox__(result)
(push) ; 2
; [eval] issubtype(typeof(box), int())
; [eval] typeof(box)
; [eval] int()
(set-option :timeout 0)
(push) ; 3
(assert (not (issubtype<Bool> (typeof<PyType> result@13@00) (as int<PyType>  PyType))))
(check-sat)
; unsat
(pop) ; 3
; 0.00s
; (get-info :all-statistics)
(assert (issubtype<Bool> (typeof<PyType> result@13@00) (as int<PyType>  PyType)))
(pop) ; 2
; Joined path conditions
(assert (issubtype<Bool> (typeof<PyType> result@13@00) (as int<PyType>  PyType)))
(assert (= (int___unbox__ $Snap.unit result@13@00) prim@12@00))
(pop) ; 1
(assert (forall ((s@$ $Snap) (prim@12@00 Int)) (!
  (=
    (__prim__int___box__%limited s@$ prim@12@00)
    (__prim__int___box__ s@$ prim@12@00))
  :pattern ((__prim__int___box__ s@$ prim@12@00))
  )))
(assert (forall ((s@$ $Snap) (prim@12@00 Int)) (!
  (__prim__int___box__%stateless prim@12@00)
  :pattern ((__prim__int___box__%limited s@$ prim@12@00))
  )))
(assert (forall ((s@$ $Snap) (prim@12@00 Int)) (!
  (let ((result@13@00 (__prim__int___box__%limited s@$ prim@12@00))) (and
    (= (typeof<PyType> result@13@00) (as int<PyType>  PyType))
    (= (int___unbox__%limited $Snap.unit result@13@00) prim@12@00)))
  :pattern ((__prim__int___box__%limited s@$ prim@12@00))
  )))
; ---------- FUNCTION range___len__----------
(declare-fun self@14@00 () $Ref)
(declare-fun result@15@00 () Int)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ $Snap.unit))
; [eval] issubtype(typeof(self), range())
; [eval] typeof(self)
; [eval] range()
(assert (issubtype<Bool> (typeof<PyType> self@14@00) (as range<PyType>  PyType)))
(declare-const $t@105@00 $Snap)
(assert (= $t@105@00 $Snap.unit))
; [eval] result == |range___val__(self)|
; [eval] |range___val__(self)|
; [eval] range___val__(self)
(push) ; 2
(pop) ; 2
; Joined path conditions
(assert (= result@15@00 (Seq_length (range___val__ $Snap.unit self@14@00))))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@14@00 $Ref)) (!
  (= (range___len__%limited s@$ self@14@00) (range___len__ s@$ self@14@00))
  :pattern ((range___len__ s@$ self@14@00))
  )))
(assert (forall ((s@$ $Snap) (self@14@00 $Ref)) (!
  (range___len__%stateless self@14@00)
  :pattern ((range___len__%limited s@$ self@14@00))
  )))
(assert (forall ((s@$ $Snap) (self@14@00 $Ref)) (!
  (let ((result@15@00 (range___len__%limited s@$ self@14@00))) (implies
    (issubtype<Bool> (typeof<PyType> self@14@00) (as range<PyType>  PyType))
    (= result@15@00 (Seq_length (range___val__ $Snap.unit self@14@00)))))
  :pattern ((range___len__%limited s@$ self@14@00))
  )))
; ---------- FUNCTION _isDefined----------
(declare-fun id@16@00 () Int)
(declare-fun result@17@00 () Bool)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (id@16@00 Int)) (!
  (= (_isDefined%limited s@$ id@16@00) (_isDefined s@$ id@16@00))
  :pattern ((_isDefined s@$ id@16@00))
  )))
(assert (forall ((s@$ $Snap) (id@16@00 Int)) (!
  (_isDefined%stateless id@16@00)
  :pattern ((_isDefined%limited s@$ id@16@00))
  )))
; ---------- FUNCTION tuple___getitem__----------
(declare-fun self@18@00 () $Ref)
(declare-fun key@19@00 () Int)
(declare-fun result@20@00 () $Ref)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ $Snap.unit))
; [eval] (let ln == (tuple___len__(self)) in (key >= 0 ==> key < ln) && (key < 0 ==> key >= -ln))
; [eval] tuple___len__(self)
(push) ; 2
(pop) ; 2
; Joined path conditions
; [eval] (key >= 0 ==> key < ln) && (key < 0 ==> key >= -ln)
; [eval] key >= 0 ==> key < ln
; [eval] key >= 0
(push) ; 2
(set-option :timeout 10)
(push) ; 3
(assert (not (not (>= key@19@00 0))))
(check-sat)
; unknown
(pop) ; 3
; 0.00s
; (get-info :all-statistics)
(push) ; 3
(assert (not (>= key@19@00 0)))
(check-sat)
; unknown
(pop) ; 3
; 0.00s
; (get-info :all-statistics)
; [then-branch: 3 | key@19@00 >= 0 | live]
; [else-branch: 3 | !(key@19@00 >= 0) | live]
(push) ; 3
; [then-branch: 3 | key@19@00 >= 0]
(assert (>= key@19@00 0))
; [eval] key < ln
(pop) ; 3
(push) ; 3
; [else-branch: 3 | !(key@19@00 >= 0)]
(assert (not (>= key@19@00 0)))
(pop) ; 3
(pop) ; 2
; Joined path conditions
; Joined path conditions
(push) ; 2
; [then-branch: 4 | key@19@00 >= 0 ==> key@19@00 < tuple___len__(_, self@18@00) | live]
; [else-branch: 4 | !(key@19@00 >= 0 ==> key@19@00 < tuple___len__(_, self@18@00)) | live]
(push) ; 3
; [then-branch: 4 | key@19@00 >= 0 ==> key@19@00 < tuple___len__(_, self@18@00)]
(assert (implies (>= key@19@00 0) (< key@19@00 (tuple___len__ $Snap.unit self@18@00))))
; [eval] key < 0 ==> key >= -ln
; [eval] key < 0
(push) ; 4
(push) ; 5
(assert (not (not (< key@19@00 0))))
(check-sat)
; unknown
(pop) ; 5
; 0.00s
; (get-info :all-statistics)
(push) ; 5
(assert (not (< key@19@00 0)))
(check-sat)
; unknown
(pop) ; 5
; 0.01s
; (get-info :all-statistics)
; [then-branch: 5 | key@19@00 < 0 | live]
; [else-branch: 5 | !(key@19@00 < 0) | live]
(push) ; 5
; [then-branch: 5 | key@19@00 < 0]
(assert (< key@19@00 0))
; [eval] key >= -ln
; [eval] -ln
(pop) ; 5
(push) ; 5
; [else-branch: 5 | !(key@19@00 < 0)]
(assert (not (< key@19@00 0)))
(pop) ; 5
(pop) ; 4
; Joined path conditions
; Joined path conditions
(pop) ; 3
(push) ; 3
; [else-branch: 4 | !(key@19@00 >= 0 ==> key@19@00 < tuple___len__(_, self@18@00))]
(assert (not
  (implies (>= key@19@00 0) (< key@19@00 (tuple___len__ $Snap.unit self@18@00)))))
(pop) ; 3
(pop) ; 2
; Joined path conditions
(assert (implies
  (and
    (implies
      (>= key@19@00 0)
      (< key@19@00 (tuple___len__ $Snap.unit self@18@00)))
    (>= key@19@00 0))
  (< key@19@00 (tuple___len__ $Snap.unit self@18@00))))
; Joined path conditions
(assert (and
  (implies
    (< key@19@00 0)
    (>= key@19@00 (- 0 (tuple___len__ $Snap.unit self@18@00))))
  (implies (>= key@19@00 0) (< key@19@00 (tuple___len__ $Snap.unit self@18@00)))))
(declare-const $t@106@00 $Snap)
(assert (= $t@106@00 ($Snap.combine ($Snap.first $t@106@00) ($Snap.second $t@106@00))))
(assert (= ($Snap.first $t@106@00) $Snap.unit))
; [eval] key >= 0 ==> issubtype(typeof(result), tuple_arg(typeof(self), key))
; [eval] key >= 0
(push) ; 2
(push) ; 3
(assert (not (not (>= key@19@00 0))))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
(push) ; 3
(assert (not (>= key@19@00 0)))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
; [then-branch: 6 | key@19@00 >= 0 | live]
; [else-branch: 6 | !(key@19@00 >= 0) | live]
(push) ; 3
; [then-branch: 6 | key@19@00 >= 0]
(assert (>= key@19@00 0))
; [eval] issubtype(typeof(result), tuple_arg(typeof(self), key))
; [eval] typeof(result)
; [eval] tuple_arg(typeof(self), key)
; [eval] typeof(self)
(pop) ; 3
(push) ; 3
; [else-branch: 6 | !(key@19@00 >= 0)]
(assert (not (>= key@19@00 0)))
(pop) ; 3
(pop) ; 2
; Joined path conditions
; Joined path conditions
(assert (implies
  (>= key@19@00 0)
  (issubtype<Bool> (typeof<PyType> result@20@00) (tuple_arg<PyType> (typeof<PyType> self@18@00) key@19@00))))
(assert (=
  ($Snap.second $t@106@00)
  ($Snap.combine
    ($Snap.first ($Snap.second $t@106@00))
    ($Snap.second ($Snap.second $t@106@00)))))
(assert (= ($Snap.first ($Snap.second $t@106@00)) $Snap.unit))
; [eval] key < 0 ==> issubtype(typeof(result), tuple_arg(typeof(self), tuple___len__(self) + key))
; [eval] key < 0
(push) ; 2
(push) ; 3
(assert (not (not (< key@19@00 0))))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
(push) ; 3
(assert (not (< key@19@00 0)))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
; [then-branch: 7 | key@19@00 < 0 | live]
; [else-branch: 7 | !(key@19@00 < 0) | live]
(push) ; 3
; [then-branch: 7 | key@19@00 < 0]
(assert (< key@19@00 0))
; [eval] issubtype(typeof(result), tuple_arg(typeof(self), tuple___len__(self) + key))
; [eval] typeof(result)
; [eval] tuple_arg(typeof(self), tuple___len__(self) + key)
; [eval] typeof(self)
; [eval] tuple___len__(self) + key
; [eval] tuple___len__(self)
(push) ; 4
(pop) ; 4
; Joined path conditions
(pop) ; 3
(push) ; 3
; [else-branch: 7 | !(key@19@00 < 0)]
(assert (not (< key@19@00 0)))
(pop) ; 3
(pop) ; 2
; Joined path conditions
; Joined path conditions
(assert (implies
  (< key@19@00 0)
  (issubtype<Bool> (typeof<PyType> result@20@00) (tuple_arg<PyType> (typeof<PyType> self@18@00) (+
    (tuple___len__ $Snap.unit self@18@00)
    key@19@00)))))
(assert (=
  ($Snap.second ($Snap.second $t@106@00))
  ($Snap.combine
    ($Snap.first ($Snap.second ($Snap.second $t@106@00)))
    ($Snap.second ($Snap.second ($Snap.second $t@106@00))))))
(assert (= ($Snap.first ($Snap.second ($Snap.second $t@106@00))) $Snap.unit))
; [eval] key >= 0 ==> result == tuple___val__(self)[key]
; [eval] key >= 0
(push) ; 2
(push) ; 3
(assert (not (not (>= key@19@00 0))))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
(push) ; 3
(assert (not (>= key@19@00 0)))
(check-sat)
; unknown
(pop) ; 3
; 0.00s
; (get-info :all-statistics)
; [then-branch: 8 | key@19@00 >= 0 | live]
; [else-branch: 8 | !(key@19@00 >= 0) | live]
(push) ; 3
; [then-branch: 8 | key@19@00 >= 0]
(assert (>= key@19@00 0))
; [eval] result == tuple___val__(self)[key]
; [eval] tuple___val__(self)[key]
; [eval] tuple___val__(self)
(push) ; 4
(pop) ; 4
; Joined path conditions
(set-option :timeout 0)
(push) ; 4
(assert (not (< key@19@00 (Seq_length (tuple___val__ $Snap.unit self@18@00)))))
(check-sat)
; unsat
(pop) ; 4
; 0.00s
; (get-info :all-statistics)
(pop) ; 3
(push) ; 3
; [else-branch: 8 | !(key@19@00 >= 0)]
(assert (not (>= key@19@00 0)))
(pop) ; 3
(pop) ; 2
; Joined path conditions
; Joined path conditions
(assert (implies
  (>= key@19@00 0)
  (= result@20@00 (Seq_index (tuple___val__ $Snap.unit self@18@00) key@19@00))))
(assert (= ($Snap.second ($Snap.second ($Snap.second $t@106@00))) $Snap.unit))
; [eval] key < 0 ==> result == tuple___val__(self)[tuple___len__(self) + key]
; [eval] key < 0
(push) ; 2
(set-option :timeout 10)
(push) ; 3
(assert (not (not (< key@19@00 0))))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
(push) ; 3
(assert (not (< key@19@00 0)))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
; [then-branch: 9 | key@19@00 < 0 | live]
; [else-branch: 9 | !(key@19@00 < 0) | live]
(push) ; 3
; [then-branch: 9 | key@19@00 < 0]
(assert (< key@19@00 0))
; [eval] result == tuple___val__(self)[tuple___len__(self) + key]
; [eval] tuple___val__(self)[tuple___len__(self) + key]
; [eval] tuple___val__(self)
(push) ; 4
(pop) ; 4
; Joined path conditions
; [eval] tuple___len__(self) + key
; [eval] tuple___len__(self)
(push) ; 4
(pop) ; 4
; Joined path conditions
(set-option :timeout 0)
(push) ; 4
(assert (not (>= (+ (tuple___len__ $Snap.unit self@18@00) key@19@00) 0)))
(check-sat)
; unsat
(pop) ; 4
; 0.00s
; (get-info :all-statistics)
(push) ; 4
(assert (not (<
  (+ (tuple___len__ $Snap.unit self@18@00) key@19@00)
  (Seq_length (tuple___val__ $Snap.unit self@18@00)))))
(check-sat)
; unsat
(pop) ; 4
; 0.00s
; (get-info :all-statistics)
(pop) ; 3
(push) ; 3
; [else-branch: 9 | !(key@19@00 < 0)]
(assert (not (< key@19@00 0)))
(pop) ; 3
(pop) ; 2
; Joined path conditions
; Joined path conditions
(assert (implies
  (< key@19@00 0)
  (=
    result@20@00
    (Seq_index
      (tuple___val__ $Snap.unit self@18@00)
      (+ (tuple___len__ $Snap.unit self@18@00) key@19@00)))))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@18@00 $Ref) (key@19@00 Int)) (!
  (=
    (tuple___getitem__%limited s@$ self@18@00 key@19@00)
    (tuple___getitem__ s@$ self@18@00 key@19@00))
  :pattern ((tuple___getitem__ s@$ self@18@00 key@19@00))
  )))
(assert (forall ((s@$ $Snap) (self@18@00 $Ref) (key@19@00 Int)) (!
  (tuple___getitem__%stateless self@18@00 key@19@00)
  :pattern ((tuple___getitem__%limited s@$ self@18@00 key@19@00))
  )))
(assert (forall ((s@$ $Snap) (self@18@00 $Ref) (key@19@00 Int)) (!
  (let ((result@20@00 (tuple___getitem__%limited s@$ self@18@00 key@19@00))) (implies
    (let ((ln (tuple___len__ $Snap.unit self@18@00))) (and
      (implies (>= key@19@00 0) (< key@19@00 ln))
      (implies (< key@19@00 0) (>= key@19@00 (- 0 ln)))))
    (and
      (implies
        (>= key@19@00 0)
        (issubtype<Bool> (typeof<PyType> result@20@00) (tuple_arg<PyType> (typeof<PyType> self@18@00) key@19@00)))
      (implies
        (< key@19@00 0)
        (issubtype<Bool> (typeof<PyType> result@20@00) (tuple_arg<PyType> (typeof<PyType> self@18@00) (+
          (tuple___len__ $Snap.unit self@18@00)
          key@19@00))))
      (implies
        (>= key@19@00 0)
        (=
          result@20@00
          (Seq_index (tuple___val__ $Snap.unit self@18@00) key@19@00)))
      (implies
        (< key@19@00 0)
        (=
          result@20@00
          (Seq_index
            (tuple___val__ $Snap.unit self@18@00)
            (+ (tuple___len__ $Snap.unit self@18@00) key@19@00)))))))
  :pattern ((tuple___getitem__%limited s@$ self@18@00 key@19@00))
  )))
; ---------- FUNCTION list___len__----------
(declare-fun self@21@00 () $Ref)
(declare-fun result@22@00 () Int)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ ($Snap.combine ($Snap.first s@$) ($Snap.second s@$))))
(assert (= ($Snap.first s@$) $Snap.unit))
; [eval] issubtype(typeof(self), list(list_arg(typeof(self), 0)))
; [eval] typeof(self)
; [eval] list(list_arg(typeof(self), 0))
; [eval] list_arg(typeof(self), 0)
; [eval] typeof(self)
(assert (issubtype<Bool> (typeof<PyType> self@21@00) (list<PyType> (list_arg<PyType> (typeof<PyType> self@21@00) 0))))
(declare-const $k@107@00 $Perm)
(assert ($Perm.isReadVar $k@107@00 $Perm.Write))
(assert (<= $Perm.No $k@107@00))
(assert (<= $k@107@00 $Perm.Write))
(assert (implies (< $Perm.No $k@107@00) (not (= self@21@00 $Ref.null))))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@21@00 $Ref)) (!
  (= (list___len__%limited s@$ self@21@00) (list___len__ s@$ self@21@00))
  :pattern ((list___len__ s@$ self@21@00))
  )))
(assert (forall ((s@$ $Snap) (self@21@00 $Ref)) (!
  (list___len__%stateless self@21@00)
  :pattern ((list___len__%limited s@$ self@21@00))
  )))
; ----- Verification of function body and postcondition -----
(push) ; 1
(assert (= s@$ ($Snap.combine ($Snap.first s@$) ($Snap.second s@$))))
(assert (= ($Snap.first s@$) $Snap.unit))
(assert (issubtype<Bool> (typeof<PyType> self@21@00) (list<PyType> (list_arg<PyType> (typeof<PyType> self@21@00) 0))))
(assert ($Perm.isReadVar $k@107@00 $Perm.Write))
(assert (<= $Perm.No $k@107@00))
(assert (<= $k@107@00 $Perm.Write))
(assert (implies (< $Perm.No $k@107@00) (not (= self@21@00 $Ref.null))))
; State saturation: after contract
(set-option :timeout 50)
(check-sat)
; unknown
; [eval] |self.list_acc|
(set-option :timeout 10)
(push) ; 2
(assert (not (< $Perm.No $k@107@00)))
(check-sat)
; unsat
(pop) ; 2
; 0.00s
; (get-info :all-statistics)
(assert (= result@22@00 (Seq_length ($SortWrappers.$SnapToSeq<$Ref> ($Snap.second s@$)))))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@21@00 $Ref)) (!
  (implies
    (issubtype<Bool> (typeof<PyType> self@21@00) (list<PyType> (list_arg<PyType> (typeof<PyType> self@21@00) 0)))
    (=
      (list___len__ s@$ self@21@00)
      (Seq_length ($SortWrappers.$SnapToSeq<$Ref> ($Snap.second s@$)))))
  :pattern ((list___len__ s@$ self@21@00))
  )))
; ---------- FUNCTION str___val__----------
(declare-fun self@23@00 () $Ref)
(declare-fun result@24@00 () Int)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@23@00 $Ref)) (!
  (= (str___val__%limited s@$ self@23@00) (str___val__ s@$ self@23@00))
  :pattern ((str___val__ s@$ self@23@00))
  )))
(assert (forall ((s@$ $Snap) (self@23@00 $Ref)) (!
  (str___val__%stateless self@23@00)
  :pattern ((str___val__%limited s@$ self@23@00))
  )))
; ---------- FUNCTION str___len__----------
(declare-fun self@25@00 () $Ref)
(declare-fun result@26@00 () Int)
; ----- Well-definedness of specifications -----
(push) ; 1
(declare-const $t@108@00 $Snap)
(assert (= $t@108@00 $Snap.unit))
; [eval] result >= 0
(assert (>= result@26@00 0))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@25@00 $Ref)) (!
  (= (str___len__%limited s@$ self@25@00) (str___len__ s@$ self@25@00))
  :pattern ((str___len__ s@$ self@25@00))
  )))
(assert (forall ((s@$ $Snap) (self@25@00 $Ref)) (!
  (str___len__%stateless self@25@00)
  :pattern ((str___len__%limited s@$ self@25@00))
  )))
(assert (forall ((s@$ $Snap) (self@25@00 $Ref)) (!
  (let ((result@26@00 (str___len__%limited s@$ self@25@00))) (>= result@26@00 0))
  :pattern ((str___len__%limited s@$ self@25@00))
  )))
; ---------- FUNCTION range___stop__----------
(declare-fun self@27@00 () $Ref)
(declare-fun result@28@00 () Int)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@27@00 $Ref)) (!
  (= (range___stop__%limited s@$ self@27@00) (range___stop__ s@$ self@27@00))
  :pattern ((range___stop__ s@$ self@27@00))
  )))
(assert (forall ((s@$ $Snap) (self@27@00 $Ref)) (!
  (range___stop__%stateless self@27@00)
  :pattern ((range___stop__%limited s@$ self@27@00))
  )))
; ---------- FUNCTION range___start__----------
(declare-fun self@29@00 () $Ref)
(declare-fun result@30@00 () Int)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@29@00 $Ref)) (!
  (= (range___start__%limited s@$ self@29@00) (range___start__ s@$ self@29@00))
  :pattern ((range___start__ s@$ self@29@00))
  )))
(assert (forall ((s@$ $Snap) (self@29@00 $Ref)) (!
  (range___start__%stateless self@29@00)
  :pattern ((range___start__%limited s@$ self@29@00))
  )))
; ---------- FUNCTION Measure$check----------
(declare-fun map@31@00 () Seq<Measure$>)
(declare-fun key@32@00 () $Ref)
(declare-fun value@33@00 () Int)
(declare-fun result@34@00 () Bool)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (map@31@00 Seq<Measure$>) (key@32@00 $Ref) (value@33@00 Int)) (!
  (=
    (Measure$check%limited s@$ map@31@00 key@32@00 value@33@00)
    (Measure$check s@$ map@31@00 key@32@00 value@33@00))
  :pattern ((Measure$check s@$ map@31@00 key@32@00 value@33@00))
  )))
(assert (forall ((s@$ $Snap) (map@31@00 Seq<Measure$>) (key@32@00 $Ref) (value@33@00 Int)) (!
  (Measure$check%stateless map@31@00 key@32@00 value@33@00)
  :pattern ((Measure$check%limited s@$ map@31@00 key@32@00 value@33@00))
  )))
; ----- Verification of function body and postcondition -----
(push) ; 1
; State saturation: after contract
(set-option :timeout 50)
(check-sat)
; unknown
; [eval] (forall m: Measure$ :: { (m in map) } (m in map) ==> Measure$guard(m) && Measure$key(m) == key ==> Measure$value(m) > value)
(declare-const m@109@00 Measure$)
(push) ; 2
; [eval] (m in map) ==> Measure$guard(m) && Measure$key(m) == key ==> Measure$value(m) > value
; [eval] (m in map)
(push) ; 3
; [then-branch: 10 | m@109@00 in map@31@00 | live]
; [else-branch: 10 | !(m@109@00 in map@31@00) | live]
(push) ; 4
; [then-branch: 10 | m@109@00 in map@31@00]
(assert (Seq_contains map@31@00 m@109@00))
; [eval] Measure$guard(m) && Measure$key(m) == key ==> Measure$value(m) > value
; [eval] Measure$guard(m) && Measure$key(m) == key
; [eval] Measure$guard(m)
(push) ; 5
; [then-branch: 11 | Measure$guard[Bool](m@109@00) | live]
; [else-branch: 11 | !(Measure$guard[Bool](m@109@00)) | live]
(push) ; 6
; [then-branch: 11 | Measure$guard[Bool](m@109@00)]
(assert (Measure$guard<Bool> m@109@00))
; [eval] Measure$key(m) == key
; [eval] Measure$key(m)
(pop) ; 6
(push) ; 6
; [else-branch: 11 | !(Measure$guard[Bool](m@109@00))]
(assert (not (Measure$guard<Bool> m@109@00)))
(pop) ; 6
(pop) ; 5
; Joined path conditions
; Joined path conditions
(push) ; 5
; [then-branch: 12 | Measure$key[Ref](m@109@00) == key@32@00 && Measure$guard[Bool](m@109@00) | live]
; [else-branch: 12 | !(Measure$key[Ref](m@109@00) == key@32@00 && Measure$guard[Bool](m@109@00)) | live]
(push) ; 6
; [then-branch: 12 | Measure$key[Ref](m@109@00) == key@32@00 && Measure$guard[Bool](m@109@00)]
(assert (and (= (Measure$key<Ref> m@109@00) key@32@00) (Measure$guard<Bool> m@109@00)))
; [eval] Measure$value(m) > value
; [eval] Measure$value(m)
(pop) ; 6
(push) ; 6
; [else-branch: 12 | !(Measure$key[Ref](m@109@00) == key@32@00 && Measure$guard[Bool](m@109@00))]
(assert (not
  (and (= (Measure$key<Ref> m@109@00) key@32@00) (Measure$guard<Bool> m@109@00))))
(pop) ; 6
(pop) ; 5
; Joined path conditions
; Joined path conditions
(pop) ; 4
(push) ; 4
; [else-branch: 10 | !(m@109@00 in map@31@00)]
(assert (not (Seq_contains map@31@00 m@109@00)))
(pop) ; 4
(pop) ; 3
; Joined path conditions
; Joined path conditions
(pop) ; 2
; Nested auxiliary terms: globals (aux)
; Nested auxiliary terms: globals (tlq)
; Nested auxiliary terms: non-globals (aux)
; Nested auxiliary terms: non-globals (tlq)
(assert (=
  result@34@00
  (forall ((m@109@00 Measure$)) (!
    (implies
      (and
        (Seq_contains map@31@00 m@109@00)
        (and
          (= (Measure$key<Ref> m@109@00) key@32@00)
          (Measure$guard<Bool> m@109@00)))
      (> (Measure$value<Int> m@109@00) value@33@00))
    :pattern ((Seq_contains map@31@00 m@109@00))
    ))))
(pop) ; 1
(assert (forall ((s@$ $Snap) (map@31@00 Seq<Measure$>) (key@32@00 $Ref) (value@33@00 Int)) (!
  (=
    (Measure$check s@$ map@31@00 key@32@00 value@33@00)
    (forall ((m Measure$)) (!
      (implies
        (and
          (Seq_contains map@31@00 m)
          (and (Measure$guard<Bool> m) (= (Measure$key<Ref> m) key@32@00)))
        (> (Measure$value<Int> m) value@33@00))
      :pattern ((Seq_contains map@31@00 m))
      )))
  :pattern ((Measure$check s@$ map@31@00 key@32@00 value@33@00))
  )))
; ---------- FUNCTION list___contains__----------
(declare-fun self@35@00 () $Ref)
(declare-fun item@36@00 () $Ref)
(declare-fun result@37@00 () Bool)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ ($Snap.combine ($Snap.first s@$) ($Snap.second s@$))))
(assert (= ($Snap.first s@$) $Snap.unit))
; [eval] issubtype(typeof(self), list(list_arg(typeof(self), 0)))
; [eval] typeof(self)
; [eval] list(list_arg(typeof(self), 0))
; [eval] list_arg(typeof(self), 0)
; [eval] typeof(self)
(assert (issubtype<Bool> (typeof<PyType> self@35@00) (list<PyType> (list_arg<PyType> (typeof<PyType> self@35@00) 0))))
(declare-const $k@110@00 $Perm)
(assert ($Perm.isReadVar $k@110@00 $Perm.Write))
(assert (<= $Perm.No $k@110@00))
(assert (<= $k@110@00 $Perm.Write))
(assert (implies (< $Perm.No $k@110@00) (not (= self@35@00 $Ref.null))))
(declare-const $t@111@00 $Snap)
(assert (= $t@111@00 $Snap.unit))
; [eval] result == (item in self.list_acc)
; [eval] (item in self.list_acc)
(set-option :timeout 10)
(push) ; 2
(assert (not (< $Perm.No $k@110@00)))
(check-sat)
; unsat
(pop) ; 2
; 0.00s
; (get-info :all-statistics)
(assert (=
  result@37@00
  (Seq_contains ($SortWrappers.$SnapToSeq<$Ref> ($Snap.second s@$)) item@36@00)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@35@00 $Ref) (item@36@00 $Ref)) (!
  (=
    (list___contains__%limited s@$ self@35@00 item@36@00)
    (list___contains__ s@$ self@35@00 item@36@00))
  :pattern ((list___contains__ s@$ self@35@00 item@36@00))
  )))
(assert (forall ((s@$ $Snap) (self@35@00 $Ref) (item@36@00 $Ref)) (!
  (list___contains__%stateless self@35@00 item@36@00)
  :pattern ((list___contains__%limited s@$ self@35@00 item@36@00))
  )))
(assert (forall ((s@$ $Snap) (self@35@00 $Ref) (item@36@00 $Ref)) (!
  (let ((result@37@00 (list___contains__%limited s@$ self@35@00 item@36@00))) (implies
    (issubtype<Bool> (typeof<PyType> self@35@00) (list<PyType> (list_arg<PyType> (typeof<PyType> self@35@00) 0)))
    (=
      result@37@00
      (Seq_contains
        ($SortWrappers.$SnapToSeq<$Ref> ($Snap.second s@$))
        item@36@00))))
  :pattern ((list___contains__%limited s@$ self@35@00 item@36@00))
  )))
; ---------- FUNCTION object___eq__----------
(declare-fun self@38@00 () $Ref)
(declare-fun other@39@00 () $Ref)
(declare-fun result@40@00 () Bool)
; ----- Well-definedness of specifications -----
(push) ; 1
(declare-const $t@112@00 $Snap)
(assert (= $t@112@00 ($Snap.combine ($Snap.first $t@112@00) ($Snap.second $t@112@00))))
(assert (= ($Snap.first $t@112@00) $Snap.unit))
; [eval] self == other ==> result
; [eval] self == other
(push) ; 2
(push) ; 3
(assert (not (not (= self@38@00 other@39@00))))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
(push) ; 3
(assert (not (= self@38@00 other@39@00)))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
; [then-branch: 13 | self@38@00 == other@39@00 | live]
; [else-branch: 13 | self@38@00 != other@39@00 | live]
(push) ; 3
; [then-branch: 13 | self@38@00 == other@39@00]
(assert (= self@38@00 other@39@00))
(pop) ; 3
(push) ; 3
; [else-branch: 13 | self@38@00 != other@39@00]
(assert (not (= self@38@00 other@39@00)))
(pop) ; 3
(pop) ; 2
; Joined path conditions
; Joined path conditions
(assert (implies (= self@38@00 other@39@00) result@40@00))
(assert (= ($Snap.second $t@112@00) $Snap.unit))
; [eval] (self == null) != (other == null) ==> !result
; [eval] (self == null) != (other == null)
; [eval] self == null
; [eval] other == null
(push) ; 2
(push) ; 3
(assert (not (= (= self@38@00 $Ref.null) (= other@39@00 $Ref.null))))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
(push) ; 3
(assert (not (not (= (= self@38@00 $Ref.null) (= other@39@00 $Ref.null)))))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
; [then-branch: 14 | self@38@00 == Null != other@39@00 == Null | live]
; [else-branch: 14 | self@38@00 == Null == other@39@00 == Null | live]
(push) ; 3
; [then-branch: 14 | self@38@00 == Null != other@39@00 == Null]
(assert (not (= (= self@38@00 $Ref.null) (= other@39@00 $Ref.null))))
; [eval] !result
(pop) ; 3
(push) ; 3
; [else-branch: 14 | self@38@00 == Null == other@39@00 == Null]
(assert (= (= self@38@00 $Ref.null) (= other@39@00 $Ref.null)))
(pop) ; 3
(pop) ; 2
; Joined path conditions
; Joined path conditions
(assert (implies
  (not (= (= self@38@00 $Ref.null) (= other@39@00 $Ref.null)))
  (not result@40@00)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@38@00 $Ref) (other@39@00 $Ref)) (!
  (=
    (object___eq__%limited s@$ self@38@00 other@39@00)
    (object___eq__ s@$ self@38@00 other@39@00))
  :pattern ((object___eq__ s@$ self@38@00 other@39@00))
  )))
(assert (forall ((s@$ $Snap) (self@38@00 $Ref) (other@39@00 $Ref)) (!
  (object___eq__%stateless self@38@00 other@39@00)
  :pattern ((object___eq__%limited s@$ self@38@00 other@39@00))
  )))
(assert (forall ((s@$ $Snap) (self@38@00 $Ref) (other@39@00 $Ref)) (!
  (let ((result@40@00 (object___eq__%limited s@$ self@38@00 other@39@00))) (and
    (implies (= self@38@00 other@39@00) result@40@00)
    (implies
      (not (= (= self@38@00 $Ref.null) (= other@39@00 $Ref.null)))
      (not result@40@00))))
  :pattern ((object___eq__%limited s@$ self@38@00 other@39@00))
  )))
; ---------- FUNCTION int___mul__----------
(declare-fun self@41@00 () Int)
(declare-fun other@42@00 () Int)
(declare-fun result@43@00 () Int)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@41@00 Int) (other@42@00 Int)) (!
  (=
    (int___mul__%limited s@$ self@41@00 other@42@00)
    (int___mul__ s@$ self@41@00 other@42@00))
  :pattern ((int___mul__ s@$ self@41@00 other@42@00))
  )))
(assert (forall ((s@$ $Snap) (self@41@00 Int) (other@42@00 Int)) (!
  (int___mul__%stateless self@41@00 other@42@00)
  :pattern ((int___mul__%limited s@$ self@41@00 other@42@00))
  )))
; ----- Verification of function body and postcondition -----
(push) ; 1
; State saturation: after contract
(set-option :timeout 50)
(check-sat)
; unknown
; [eval] self * other
(assert (= result@43@00 (* self@41@00 other@42@00)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@41@00 Int) (other@42@00 Int)) (!
  (= (int___mul__ s@$ self@41@00 other@42@00) (* self@41@00 other@42@00))
  :pattern ((int___mul__ s@$ self@41@00 other@42@00))
  )))
; ---------- FUNCTION int___sub__----------
(declare-fun self@44@00 () Int)
(declare-fun other@45@00 () Int)
(declare-fun result@46@00 () Int)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@44@00 Int) (other@45@00 Int)) (!
  (=
    (int___sub__%limited s@$ self@44@00 other@45@00)
    (int___sub__ s@$ self@44@00 other@45@00))
  :pattern ((int___sub__ s@$ self@44@00 other@45@00))
  )))
(assert (forall ((s@$ $Snap) (self@44@00 Int) (other@45@00 Int)) (!
  (int___sub__%stateless self@44@00 other@45@00)
  :pattern ((int___sub__%limited s@$ self@44@00 other@45@00))
  )))
; ----- Verification of function body and postcondition -----
(push) ; 1
; State saturation: after contract
(check-sat)
; unknown
; [eval] self - other
(assert (= result@46@00 (- self@44@00 other@45@00)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@44@00 Int) (other@45@00 Int)) (!
  (= (int___sub__ s@$ self@44@00 other@45@00) (- self@44@00 other@45@00))
  :pattern ((int___sub__ s@$ self@44@00 other@45@00))
  )))
; ---------- FUNCTION int___gt__----------
(declare-fun self@47@00 () Int)
(declare-fun other@48@00 () Int)
(declare-fun result@49@00 () Bool)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@47@00 Int) (other@48@00 Int)) (!
  (=
    (int___gt__%limited s@$ self@47@00 other@48@00)
    (int___gt__ s@$ self@47@00 other@48@00))
  :pattern ((int___gt__ s@$ self@47@00 other@48@00))
  )))
(assert (forall ((s@$ $Snap) (self@47@00 Int) (other@48@00 Int)) (!
  (int___gt__%stateless self@47@00 other@48@00)
  :pattern ((int___gt__%limited s@$ self@47@00 other@48@00))
  )))
; ----- Verification of function body and postcondition -----
(push) ; 1
; State saturation: after contract
(check-sat)
; unknown
; [eval] self > other
(assert (= result@49@00 (> self@47@00 other@48@00)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@47@00 Int) (other@48@00 Int)) (!
  (= (int___gt__ s@$ self@47@00 other@48@00) (> self@47@00 other@48@00))
  :pattern ((int___gt__ s@$ self@47@00 other@48@00))
  )))
; ---------- FUNCTION object___cast__----------
(declare-fun typ@50@00 () PyType)
(declare-fun obj@51@00 () $Ref)
(declare-fun result@52@00 () $Ref)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ $Snap.unit))
; [eval] issubtype(typeof(obj), typ)
; [eval] typeof(obj)
(assert (issubtype<Bool> (typeof<PyType> obj@51@00) typ@50@00))
(declare-const $t@113@00 $Snap)
(assert (= $t@113@00 ($Snap.combine ($Snap.first $t@113@00) ($Snap.second $t@113@00))))
(assert (= ($Snap.first $t@113@00) $Snap.unit))
; [eval] result == obj
(assert (= result@52@00 obj@51@00))
(assert (= ($Snap.second $t@113@00) $Snap.unit))
; [eval] issubtype(typeof(obj), typ)
; [eval] typeof(obj)
(pop) ; 1
(assert (forall ((s@$ $Snap) (typ@50@00 PyType) (obj@51@00 $Ref)) (!
  (=
    (object___cast__%limited s@$ typ@50@00 obj@51@00)
    (object___cast__ s@$ typ@50@00 obj@51@00))
  :pattern ((object___cast__ s@$ typ@50@00 obj@51@00))
  )))
(assert (forall ((s@$ $Snap) (typ@50@00 PyType) (obj@51@00 $Ref)) (!
  (object___cast__%stateless typ@50@00 obj@51@00)
  :pattern ((object___cast__%limited s@$ typ@50@00 obj@51@00))
  )))
(assert (forall ((s@$ $Snap) (typ@50@00 PyType) (obj@51@00 $Ref)) (!
  (let ((result@52@00 (object___cast__%limited s@$ typ@50@00 obj@51@00))) (implies
    (issubtype<Bool> (typeof<PyType> obj@51@00) typ@50@00)
    (and
      (= result@52@00 obj@51@00)
      (issubtype<Bool> (typeof<PyType> obj@51@00) typ@50@00))))
  :pattern ((object___cast__%limited s@$ typ@50@00 obj@51@00))
  )))
; ---------- FUNCTION range___sil_seq__----------
(declare-fun self@53@00 () $Ref)
(declare-fun result@54@00 () Seq<$Ref>)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ $Snap.unit))
; [eval] issubtype(typeof(self), range())
; [eval] typeof(self)
; [eval] range()
(assert (issubtype<Bool> (typeof<PyType> self@53@00) (as range<PyType>  PyType)))
(declare-const $t@114@00 $Snap)
(assert (= $t@114@00 ($Snap.combine ($Snap.first $t@114@00) ($Snap.second $t@114@00))))
(assert (= ($Snap.first $t@114@00) $Snap.unit))
; [eval] |result| == range___len__(self)
; [eval] |result|
; [eval] range___len__(self)
(push) ; 2
; [eval] issubtype(typeof(self), range())
; [eval] typeof(self)
; [eval] range()
(pop) ; 2
; Joined path conditions
(assert (= (Seq_length result@54@00) (range___len__ $Snap.unit self@53@00)))
(assert (=
  ($Snap.second $t@114@00)
  ($Snap.combine
    ($Snap.first ($Snap.second $t@114@00))
    ($Snap.second ($Snap.second $t@114@00)))))
(assert (= ($Snap.first ($Snap.second $t@114@00)) $Snap.unit))
; [eval] (forall i: Int :: { result[i] } i >= 0 && i < |range___val__(self)| ==> result[i] == __prim__int___box__(range___val__(self)[i]))
(declare-const i@115@00 Int)
(push) ; 2
; [eval] i >= 0 && i < |range___val__(self)| ==> result[i] == __prim__int___box__(range___val__(self)[i])
; [eval] i >= 0 && i < |range___val__(self)|
; [eval] i >= 0
(push) ; 3
; [then-branch: 15 | i@115@00 >= 0 | live]
; [else-branch: 15 | !(i@115@00 >= 0) | live]
(push) ; 4
; [then-branch: 15 | i@115@00 >= 0]
(assert (>= i@115@00 0))
; [eval] i < |range___val__(self)|
; [eval] |range___val__(self)|
; [eval] range___val__(self)
(push) ; 5
(pop) ; 5
; Joined path conditions
(pop) ; 4
(push) ; 4
; [else-branch: 15 | !(i@115@00 >= 0)]
(assert (not (>= i@115@00 0)))
(pop) ; 4
(pop) ; 3
; Joined path conditions
; Joined path conditions
(push) ; 3
; [then-branch: 16 | i@115@00 < |range___val__(_, self@53@00)| && i@115@00 >= 0 | live]
; [else-branch: 16 | !(i@115@00 < |range___val__(_, self@53@00)| && i@115@00 >= 0) | live]
(push) ; 4
; [then-branch: 16 | i@115@00 < |range___val__(_, self@53@00)| && i@115@00 >= 0]
(assert (and
  (< i@115@00 (Seq_length (range___val__ $Snap.unit self@53@00)))
  (>= i@115@00 0)))
; [eval] result[i] == __prim__int___box__(range___val__(self)[i])
; [eval] result[i]
(set-option :timeout 0)
(push) ; 5
(assert (not (< i@115@00 (Seq_length result@54@00))))
(check-sat)
; unsat
(pop) ; 5
; 0.00s
; (get-info :all-statistics)
; [eval] __prim__int___box__(range___val__(self)[i])
; [eval] range___val__(self)[i]
; [eval] range___val__(self)
(push) ; 5
(pop) ; 5
; Joined path conditions
(push) ; 5
(pop) ; 5
; Joined path conditions
(pop) ; 4
(push) ; 4
; [else-branch: 16 | !(i@115@00 < |range___val__(_, self@53@00)| && i@115@00 >= 0)]
(assert (not
  (and
    (< i@115@00 (Seq_length (range___val__ $Snap.unit self@53@00)))
    (>= i@115@00 0))))
(pop) ; 4
(pop) ; 3
; Joined path conditions
; Joined path conditions
(pop) ; 2
; Nested auxiliary terms: globals (aux)
; Nested auxiliary terms: globals (tlq)
; Nested auxiliary terms: non-globals (aux)
; Nested auxiliary terms: non-globals (tlq)
(assert (forall ((i@115@00 Int)) (!
  (implies
    (and
      (< i@115@00 (Seq_length (range___val__ $Snap.unit self@53@00)))
      (>= i@115@00 0))
    (=
      (Seq_index result@54@00 i@115@00)
      (__prim__int___box__ $Snap.unit (Seq_index
        (range___val__ $Snap.unit self@53@00)
        i@115@00))))
  :pattern ((Seq_index result@54@00 i@115@00))
  )))
(assert (= ($Snap.second ($Snap.second $t@114@00)) $Snap.unit))
; [eval] (forall i: Ref :: { (i in result) } (i in result) == (typeof(i) == int() && (int___unbox__(i) in range___val__(self))))
(declare-const i@116@00 $Ref)
(push) ; 2
; [eval] (i in result) == (typeof(i) == int() && (int___unbox__(i) in range___val__(self)))
; [eval] (i in result)
; [eval] typeof(i) == int() && (int___unbox__(i) in range___val__(self))
; [eval] typeof(i) == int()
; [eval] typeof(i)
; [eval] int()
(push) ; 3
; [then-branch: 17 | typeof[PyType](i@116@00) == int[PyType] | live]
; [else-branch: 17 | typeof[PyType](i@116@00) != int[PyType] | live]
(push) ; 4
; [then-branch: 17 | typeof[PyType](i@116@00) == int[PyType]]
(assert (= (typeof<PyType> i@116@00) (as int<PyType>  PyType)))
; [eval] (int___unbox__(i) in range___val__(self))
; [eval] range___val__(self)
(push) ; 5
(pop) ; 5
; Joined path conditions
; [eval] int___unbox__(i)
(push) ; 5
; [eval] issubtype(typeof(box), int())
; [eval] typeof(box)
; [eval] int()
(push) ; 6
(assert (not (issubtype<Bool> (typeof<PyType> i@116@00) (as int<PyType>  PyType))))
(check-sat)
; unsat
(pop) ; 6
; 0.00s
; (get-info :all-statistics)
(assert (issubtype<Bool> (typeof<PyType> i@116@00) (as int<PyType>  PyType)))
(pop) ; 5
; Joined path conditions
(assert (issubtype<Bool> (typeof<PyType> i@116@00) (as int<PyType>  PyType)))
(pop) ; 4
(push) ; 4
; [else-branch: 17 | typeof[PyType](i@116@00) != int[PyType]]
(assert (not (= (typeof<PyType> i@116@00) (as int<PyType>  PyType))))
(pop) ; 4
(pop) ; 3
; Joined path conditions
(assert (implies
  (= (typeof<PyType> i@116@00) (as int<PyType>  PyType))
  (and
    (= (typeof<PyType> i@116@00) (as int<PyType>  PyType))
    (issubtype<Bool> (typeof<PyType> i@116@00) (as int<PyType>  PyType)))))
; Joined path conditions
(pop) ; 2
; Nested auxiliary terms: globals (aux)
; Nested auxiliary terms: globals (tlq)
; Nested auxiliary terms: non-globals (aux)
(assert (forall ((i@116@00 $Ref)) (!
  (implies
    (= (typeof<PyType> i@116@00) (as int<PyType>  PyType))
    (and
      (= (typeof<PyType> i@116@00) (as int<PyType>  PyType))
      (issubtype<Bool> (typeof<PyType> i@116@00) (as int<PyType>  PyType))))
  :pattern ((Seq_contains result@54@00 i@116@00))
  :qid |prog.l31-aux|)))
; Nested auxiliary terms: non-globals (tlq)
(assert (forall ((i@116@00 $Ref)) (!
  (=
    (Seq_contains result@54@00 i@116@00)
    (and
      (Seq_contains
        (range___val__ $Snap.unit self@53@00)
        (int___unbox__ $Snap.unit i@116@00))
      (= (typeof<PyType> i@116@00) (as int<PyType>  PyType))))
  :pattern ((Seq_contains result@54@00 i@116@00))
  )))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@53@00 $Ref)) (!
  (Seq_equal
    (range___sil_seq__%limited s@$ self@53@00)
    (range___sil_seq__ s@$ self@53@00))
  :pattern ((range___sil_seq__ s@$ self@53@00))
  )))
(assert (forall ((s@$ $Snap) (self@53@00 $Ref)) (!
  (range___sil_seq__%stateless self@53@00)
  :pattern ((range___sil_seq__%limited s@$ self@53@00))
  )))
(assert (forall ((s@$ $Snap) (self@53@00 $Ref)) (!
  (let ((result@54@00 (range___sil_seq__%limited s@$ self@53@00))) (implies
    (issubtype<Bool> (typeof<PyType> self@53@00) (as range<PyType>  PyType))
    (and
      (= (Seq_length result@54@00) (range___len__ $Snap.unit self@53@00))
      (forall ((i Int)) (!
        (implies
          (and (>= i 0) (< i (Seq_length (range___val__ $Snap.unit self@53@00))))
          (=
            (Seq_index result@54@00 i)
            (__prim__int___box__ $Snap.unit (Seq_index
              (range___val__ $Snap.unit self@53@00)
              i))))
        :pattern ((Seq_index result@54@00 i))
        ))
      (forall ((i $Ref)) (!
        (=
          (Seq_contains result@54@00 i)
          (and
            (= (typeof<PyType> i) (as int<PyType>  PyType))
            (Seq_contains
              (range___val__ $Snap.unit self@53@00)
              (int___unbox__ $Snap.unit i))))
        :pattern ((Seq_contains result@54@00 i))
        )))))
  :pattern ((range___sil_seq__%limited s@$ self@53@00))
  )))
; ---------- FUNCTION bool___eq__----------
(declare-fun self@55@00 () $Ref)
(declare-fun other@56@00 () $Ref)
(declare-fun result@57@00 () Bool)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ ($Snap.combine ($Snap.first s@$) ($Snap.second s@$))))
(assert (= ($Snap.first s@$) $Snap.unit))
; [eval] issubtype(typeof(self), bool())
; [eval] typeof(self)
; [eval] bool()
(assert (issubtype<Bool> (typeof<PyType> self@55@00) (as bool<PyType>  PyType)))
(assert (= ($Snap.second s@$) $Snap.unit))
; [eval] issubtype(typeof(other), bool())
; [eval] typeof(other)
; [eval] bool()
(assert (issubtype<Bool> (typeof<PyType> other@56@00) (as bool<PyType>  PyType)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@55@00 $Ref) (other@56@00 $Ref)) (!
  (=
    (bool___eq__%limited s@$ self@55@00 other@56@00)
    (bool___eq__ s@$ self@55@00 other@56@00))
  :pattern ((bool___eq__ s@$ self@55@00 other@56@00))
  )))
(assert (forall ((s@$ $Snap) (self@55@00 $Ref) (other@56@00 $Ref)) (!
  (bool___eq__%stateless self@55@00 other@56@00)
  :pattern ((bool___eq__%limited s@$ self@55@00 other@56@00))
  )))
; ----- Verification of function body and postcondition -----
(push) ; 1
(assert (= s@$ ($Snap.combine ($Snap.first s@$) ($Snap.second s@$))))
(assert (= ($Snap.first s@$) $Snap.unit))
(assert (issubtype<Bool> (typeof<PyType> self@55@00) (as bool<PyType>  PyType)))
(assert (= ($Snap.second s@$) $Snap.unit))
(assert (issubtype<Bool> (typeof<PyType> other@56@00) (as bool<PyType>  PyType)))
; State saturation: after contract
(set-option :timeout 50)
(check-sat)
; unknown
; [eval] bool___unbox__(self) == bool___unbox__(other)
; [eval] bool___unbox__(self)
(push) ; 2
; [eval] issubtype(typeof(box), bool())
; [eval] typeof(box)
; [eval] bool()
(pop) ; 2
; Joined path conditions
; [eval] bool___unbox__(other)
(push) ; 2
; [eval] issubtype(typeof(box), bool())
; [eval] typeof(box)
; [eval] bool()
(pop) ; 2
; Joined path conditions
(assert (=
  result@57@00
  (=
    (bool___unbox__ $Snap.unit self@55@00)
    (bool___unbox__ $Snap.unit other@56@00))))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@55@00 $Ref) (other@56@00 $Ref)) (!
  (implies
    (and
      (issubtype<Bool> (typeof<PyType> self@55@00) (as bool<PyType>  PyType))
      (issubtype<Bool> (typeof<PyType> other@56@00) (as bool<PyType>  PyType)))
    (=
      (bool___eq__ s@$ self@55@00 other@56@00)
      (=
        (bool___unbox__ $Snap.unit self@55@00)
        (bool___unbox__ $Snap.unit other@56@00))))
  :pattern ((bool___eq__ s@$ self@55@00 other@56@00))
  )))
; ---------- FUNCTION int___lt__----------
(declare-fun self@58@00 () Int)
(declare-fun other@59@00 () Int)
(declare-fun result@60@00 () Bool)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@58@00 Int) (other@59@00 Int)) (!
  (=
    (int___lt__%limited s@$ self@58@00 other@59@00)
    (int___lt__ s@$ self@58@00 other@59@00))
  :pattern ((int___lt__ s@$ self@58@00 other@59@00))
  )))
(assert (forall ((s@$ $Snap) (self@58@00 Int) (other@59@00 Int)) (!
  (int___lt__%stateless self@58@00 other@59@00)
  :pattern ((int___lt__%limited s@$ self@58@00 other@59@00))
  )))
; ----- Verification of function body and postcondition -----
(push) ; 1
; State saturation: after contract
(check-sat)
; unknown
; [eval] self < other
(assert (= result@60@00 (< self@58@00 other@59@00)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@58@00 Int) (other@59@00 Int)) (!
  (= (int___lt__ s@$ self@58@00 other@59@00) (< self@58@00 other@59@00))
  :pattern ((int___lt__ s@$ self@58@00 other@59@00))
  )))
; ---------- FUNCTION Level----------
(declare-fun r@61@00 () $Ref)
(declare-fun result@62@00 () $Perm)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (r@61@00 $Ref)) (!
  (= (Level%limited s@$ r@61@00) (Level s@$ r@61@00))
  :pattern ((Level s@$ r@61@00))
  )))
(assert (forall ((s@$ $Snap) (r@61@00 $Ref)) (!
  (Level%stateless r@61@00)
  :pattern ((Level%limited s@$ r@61@00))
  )))
; ---------- FUNCTION _checkDefined----------
(declare-fun val@63@00 () $Ref)
(declare-fun id@64@00 () Int)
(declare-fun result@65@00 () $Ref)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ $Snap.unit))
; [eval] _isDefined(id)
(push) ; 2
(pop) ; 2
; Joined path conditions
(assert (_isDefined $Snap.unit id@64@00))
(pop) ; 1
(assert (forall ((s@$ $Snap) (val@63@00 $Ref) (id@64@00 Int)) (!
  (=
    (_checkDefined%limited s@$ val@63@00 id@64@00)
    (_checkDefined s@$ val@63@00 id@64@00))
  :pattern ((_checkDefined s@$ val@63@00 id@64@00))
  )))
(assert (forall ((s@$ $Snap) (val@63@00 $Ref) (id@64@00 Int)) (!
  (_checkDefined%stateless val@63@00 id@64@00)
  :pattern ((_checkDefined%limited s@$ val@63@00 id@64@00))
  )))
; ----- Verification of function body and postcondition -----
(push) ; 1
(assert (= s@$ $Snap.unit))
(assert (_isDefined $Snap.unit id@64@00))
; State saturation: after contract
(check-sat)
; unknown
(assert (= result@65@00 val@63@00))
(pop) ; 1
(assert (forall ((s@$ $Snap) (val@63@00 $Ref) (id@64@00 Int)) (!
  (implies
    (_isDefined $Snap.unit id@64@00)
    (= (_checkDefined s@$ val@63@00 id@64@00) val@63@00))
  :pattern ((_checkDefined s@$ val@63@00 id@64@00))
  )))
; ---------- FUNCTION tuple___create2__----------
(declare-fun arg0@66@00 () $Ref)
(declare-fun arg1@67@00 () $Ref)
(declare-fun t0@68@00 () PyType)
(declare-fun t1@69@00 () PyType)
(declare-fun ctr@70@00 () Int)
(declare-fun result@71@00 () $Ref)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ ($Snap.combine ($Snap.first s@$) ($Snap.second s@$))))
(assert (= ($Snap.first s@$) $Snap.unit))
; [eval] issubtype(typeof(arg0), t0)
; [eval] typeof(arg0)
(assert (issubtype<Bool> (typeof<PyType> arg0@66@00) t0@68@00))
(assert (= ($Snap.second s@$) $Snap.unit))
; [eval] issubtype(typeof(arg1), t1)
; [eval] typeof(arg1)
(assert (issubtype<Bool> (typeof<PyType> arg1@67@00) t1@69@00))
(declare-const $t@117@00 $Snap)
(assert (= $t@117@00 ($Snap.combine ($Snap.first $t@117@00) ($Snap.second $t@117@00))))
(assert (= ($Snap.first $t@117@00) $Snap.unit))
; [eval] result != null
(assert (not (= result@71@00 $Ref.null)))
(assert (=
  ($Snap.second $t@117@00)
  ($Snap.combine
    ($Snap.first ($Snap.second $t@117@00))
    ($Snap.second ($Snap.second $t@117@00)))))
(assert (= ($Snap.first ($Snap.second $t@117@00)) $Snap.unit))
; [eval] typeof(result) == tuple(Seq(t0, t1))
; [eval] typeof(result)
; [eval] tuple(Seq(t0, t1))
; [eval] Seq(t0, t1)
(assert (= (Seq_length (Seq_append (Seq_singleton t0@68@00) (Seq_singleton t1@69@00))) 2))
(assert (=
  (typeof<PyType> result@71@00)
  (tuple<PyType> (Seq_append (Seq_singleton t0@68@00) (Seq_singleton t1@69@00)))))
(assert (=
  ($Snap.second ($Snap.second $t@117@00))
  ($Snap.combine
    ($Snap.first ($Snap.second ($Snap.second $t@117@00)))
    ($Snap.second ($Snap.second ($Snap.second $t@117@00))))))
(assert (= ($Snap.first ($Snap.second ($Snap.second $t@117@00))) $Snap.unit))
; [eval] tuple_args(typeof(result)) == Seq(t0, t1)
; [eval] tuple_args(typeof(result))
; [eval] typeof(result)
; [eval] Seq(t0, t1)
(assert (Seq_equal
  (tuple_args<Seq<PyType>> (typeof<PyType> result@71@00))
  (Seq_append (Seq_singleton t0@68@00) (Seq_singleton t1@69@00))))
(assert (=
  ($Snap.second ($Snap.second ($Snap.second $t@117@00)))
  ($Snap.combine
    ($Snap.first ($Snap.second ($Snap.second ($Snap.second $t@117@00))))
    ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00)))))))
(assert (=
  ($Snap.first ($Snap.second ($Snap.second ($Snap.second $t@117@00))))
  $Snap.unit))
; [eval] tuple_args(typeof(result)) == Seq(t0, t1)
; [eval] tuple_args(typeof(result))
; [eval] typeof(result)
; [eval] Seq(t0, t1)
(assert (=
  ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00))))
  ($Snap.combine
    ($Snap.first ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00)))))
    ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00))))))))
(assert (=
  ($Snap.first ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00)))))
  $Snap.unit))
; [eval] tuple___val__(result) == Seq(arg0, arg1)
; [eval] tuple___val__(result)
(push) ; 2
(pop) ; 2
; Joined path conditions
; [eval] Seq(arg0, arg1)
(assert (=
  (Seq_length (Seq_append (Seq_singleton arg0@66@00) (Seq_singleton arg1@67@00)))
  2))
(assert (Seq_equal
  (tuple___val__ $Snap.unit result@71@00)
  (Seq_append (Seq_singleton arg0@66@00) (Seq_singleton arg1@67@00))))
(assert (=
  ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00)))))
  ($Snap.combine
    ($Snap.first ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00))))))
    ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00)))))))))
(assert (=
  ($Snap.first ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00))))))
  $Snap.unit))
; [eval] tuple___len__(result) == 2
; [eval] tuple___len__(result)
(push) ; 2
(pop) ; 2
; Joined path conditions
(assert (= (tuple___len__ $Snap.unit result@71@00) 2))
(assert (=
  ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00))))))
  ($Snap.combine
    ($Snap.first ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00)))))))
    ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00))))))))))
(assert (=
  ($Snap.first ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00)))))))
  $Snap.unit))
; [eval] tuple___getitem__(result, 0) == arg0
; [eval] tuple___getitem__(result, 0)
(push) ; 2
; [eval] (let ln == (tuple___len__(self)) in (key >= 0 ==> key < ln) && (key < 0 ==> key >= -ln))
; [eval] tuple___len__(self)
(push) ; 3
(pop) ; 3
; Joined path conditions
; [eval] (key >= 0 ==> key < ln) && (key < 0 ==> key >= -ln)
; [eval] key >= 0 ==> key < ln
; [eval] key >= 0
(push) ; 3
(set-option :timeout 10)
(push) ; 4
(assert (not false))
(check-sat)
; unknown
(pop) ; 4
; 0.01s
; (get-info :all-statistics)
; [then-branch: 18 | True | live]
; [else-branch: 18 | False | dead]
(push) ; 4
; [then-branch: 18 | True]
; [eval] key < ln
(pop) ; 4
(pop) ; 3
; Joined path conditions
(push) ; 3
; [then-branch: 19 | 0 < tuple___len__(_, result@71@00) | live]
; [else-branch: 19 | !(0 < tuple___len__(_, result@71@00)) | live]
(push) ; 4
; [then-branch: 19 | 0 < tuple___len__(_, result@71@00)]
(assert (< 0 (tuple___len__ $Snap.unit result@71@00)))
; [eval] key < 0 ==> key >= -ln
; [eval] key < 0
(push) ; 5
; [then-branch: 20 | False | dead]
; [else-branch: 20 | True | live]
(push) ; 6
; [else-branch: 20 | True]
(pop) ; 6
(pop) ; 5
; Joined path conditions
(pop) ; 4
(push) ; 4
; [else-branch: 19 | !(0 < tuple___len__(_, result@71@00))]
(assert (not (< 0 (tuple___len__ $Snap.unit result@71@00))))
(pop) ; 4
(pop) ; 3
; Joined path conditions
; Joined path conditions
(set-option :timeout 0)
(push) ; 3
(assert (not (< 0 (tuple___len__ $Snap.unit result@71@00))))
(check-sat)
; unsat
(pop) ; 3
; 0.00s
; (get-info :all-statistics)
(assert (< 0 (tuple___len__ $Snap.unit result@71@00)))
(pop) ; 2
; Joined path conditions
(assert (< 0 (tuple___len__ $Snap.unit result@71@00)))
(assert (= (tuple___getitem__ $Snap.unit result@71@00 0) arg0@66@00))
(assert (=
  ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second ($Snap.second $t@117@00)))))))
  $Snap.unit))
; [eval] tuple___getitem__(result, 1) == arg1
; [eval] tuple___getitem__(result, 1)
(push) ; 2
; [eval] (let ln == (tuple___len__(self)) in (key >= 0 ==> key < ln) && (key < 0 ==> key >= -ln))
; [eval] tuple___len__(self)
(push) ; 3
(pop) ; 3
; Joined path conditions
; [eval] (key >= 0 ==> key < ln) && (key < 0 ==> key >= -ln)
; [eval] key >= 0 ==> key < ln
; [eval] key >= 0
(push) ; 3
(set-option :timeout 10)
(push) ; 4
(assert (not false))
(check-sat)
; unknown
(pop) ; 4
; 0.02s
; (get-info :all-statistics)
; [then-branch: 21 | True | live]
; [else-branch: 21 | False | dead]
(push) ; 4
; [then-branch: 21 | True]
; [eval] key < ln
(pop) ; 4
(pop) ; 3
; Joined path conditions
(push) ; 3
; [then-branch: 22 | 1 < tuple___len__(_, result@71@00) | live]
; [else-branch: 22 | !(1 < tuple___len__(_, result@71@00)) | live]
(push) ; 4
; [then-branch: 22 | 1 < tuple___len__(_, result@71@00)]
(assert (< 1 (tuple___len__ $Snap.unit result@71@00)))
; [eval] key < 0 ==> key >= -ln
; [eval] key < 0
(push) ; 5
; [then-branch: 23 | False | dead]
; [else-branch: 23 | True | live]
(push) ; 6
; [else-branch: 23 | True]
(pop) ; 6
(pop) ; 5
; Joined path conditions
(pop) ; 4
(push) ; 4
; [else-branch: 22 | !(1 < tuple___len__(_, result@71@00))]
(assert (not (< 1 (tuple___len__ $Snap.unit result@71@00))))
(pop) ; 4
(pop) ; 3
; Joined path conditions
; Joined path conditions
(set-option :timeout 0)
(push) ; 3
(assert (not (< 1 (tuple___len__ $Snap.unit result@71@00))))
(check-sat)
; unsat
(pop) ; 3
; 0.00s
; (get-info :all-statistics)
(assert (< 1 (tuple___len__ $Snap.unit result@71@00)))
(pop) ; 2
; Joined path conditions
(assert (< 1 (tuple___len__ $Snap.unit result@71@00)))
(assert (= (tuple___getitem__ $Snap.unit result@71@00 1) arg1@67@00))
(pop) ; 1
(assert (forall ((s@$ $Snap) (arg0@66@00 $Ref) (arg1@67@00 $Ref) (t0@68@00 PyType) (t1@69@00 PyType) (ctr@70@00 Int)) (!
  (=
    (tuple___create2__%limited s@$ arg0@66@00 arg1@67@00 t0@68@00 t1@69@00 ctr@70@00)
    (tuple___create2__ s@$ arg0@66@00 arg1@67@00 t0@68@00 t1@69@00 ctr@70@00))
  :pattern ((tuple___create2__ s@$ arg0@66@00 arg1@67@00 t0@68@00 t1@69@00 ctr@70@00))
  )))
(assert (forall ((s@$ $Snap) (arg0@66@00 $Ref) (arg1@67@00 $Ref) (t0@68@00 PyType) (t1@69@00 PyType) (ctr@70@00 Int)) (!
  (tuple___create2__%stateless arg0@66@00 arg1@67@00 t0@68@00 t1@69@00 ctr@70@00)
  :pattern ((tuple___create2__%limited s@$ arg0@66@00 arg1@67@00 t0@68@00 t1@69@00 ctr@70@00))
  )))
(assert (forall ((s@$ $Snap) (arg0@66@00 $Ref) (arg1@67@00 $Ref) (t0@68@00 PyType) (t1@69@00 PyType) (ctr@70@00 Int)) (!
  (let ((result@71@00 (tuple___create2__%limited s@$ arg0@66@00 arg1@67@00 t0@68@00 t1@69@00 ctr@70@00))) (implies
    (and
      (issubtype<Bool> (typeof<PyType> arg0@66@00) t0@68@00)
      (issubtype<Bool> (typeof<PyType> arg1@67@00) t1@69@00))
    (and
      (not (= result@71@00 $Ref.null))
      (=
        (typeof<PyType> result@71@00)
        (tuple<PyType> (Seq_append
          (Seq_singleton t0@68@00)
          (Seq_singleton t1@69@00))))
      (Seq_equal
        (tuple_args<Seq<PyType>> (typeof<PyType> result@71@00))
        (Seq_append (Seq_singleton t0@68@00) (Seq_singleton t1@69@00)))
      (Seq_equal
        (tuple___val__ $Snap.unit result@71@00)
        (Seq_append (Seq_singleton arg0@66@00) (Seq_singleton arg1@67@00)))
      (and
        (= (tuple___len__ $Snap.unit result@71@00) 2)
        (and
          (= (tuple___getitem__ $Snap.unit result@71@00 0) arg0@66@00)
          (= (tuple___getitem__ $Snap.unit result@71@00 1) arg1@67@00))))))
  :pattern ((tuple___create2__%limited s@$ arg0@66@00 arg1@67@00 t0@68@00 t1@69@00 ctr@70@00))
  )))
; ---------- FUNCTION Agent_execute_nn_control----------
(declare-fun self_2@72@00 () $Ref)
(declare-fun result@73@00 () $Ref)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ ($Snap.combine ($Snap.first s@$) ($Snap.second s@$))))
(assert (= ($Snap.first s@$) $Snap.unit))
; [eval] issubtype(typeof(self_2), Agent())
; [eval] typeof(self_2)
; [eval] Agent()
(assert (issubtype<Bool> (typeof<PyType> self_2@72@00) (as Agent<PyType>  PyType)))
(assert (= ($Snap.second s@$) $Snap.unit))
; [eval] self_2 != null
(assert (not (= self_2@72@00 $Ref.null)))
(declare-const $t@118@00 $Snap)
(assert (= $t@118@00 $Snap.unit))
; [eval] issubtype(typeof(result), int())
; [eval] typeof(result)
; [eval] int()
(assert (issubtype<Bool> (typeof<PyType> result@73@00) (as int<PyType>  PyType)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self_2@72@00 $Ref)) (!
  (=
    (Agent_execute_nn_control%limited s@$ self_2@72@00)
    (Agent_execute_nn_control s@$ self_2@72@00))
  :pattern ((Agent_execute_nn_control s@$ self_2@72@00))
  )))
(assert (forall ((s@$ $Snap) (self_2@72@00 $Ref)) (!
  (Agent_execute_nn_control%stateless self_2@72@00)
  :pattern ((Agent_execute_nn_control%limited s@$ self_2@72@00))
  )))
(assert (forall ((s@$ $Snap) (self_2@72@00 $Ref)) (!
  (let ((result@73@00 (Agent_execute_nn_control%limited s@$ self_2@72@00))) (implies
    (and
      (issubtype<Bool> (typeof<PyType> self_2@72@00) (as Agent<PyType>  PyType))
      (not (= self_2@72@00 $Ref.null)))
    (issubtype<Bool> (typeof<PyType> result@73@00) (as int<PyType>  PyType))))
  :pattern ((Agent_execute_nn_control%limited s@$ self_2@72@00))
  )))
; ----- Verification of function body and postcondition -----
(push) ; 1
(assert (= s@$ ($Snap.combine ($Snap.first s@$) ($Snap.second s@$))))
(assert (= ($Snap.first s@$) $Snap.unit))
(assert (issubtype<Bool> (typeof<PyType> self_2@72@00) (as Agent<PyType>  PyType)))
(assert (= ($Snap.second s@$) $Snap.unit))
(assert (not (= self_2@72@00 $Ref.null)))
; State saturation: after contract
(set-option :timeout 50)
(check-sat)
; unknown
; [eval] __prim__int___box__(50)
(push) ; 2
(pop) ; 2
; Joined path conditions
(assert (= result@73@00 (__prim__int___box__ $Snap.unit 50)))
; [eval] issubtype(typeof(result), int())
; [eval] typeof(result)
; [eval] int()
(set-option :timeout 0)
(push) ; 2
(assert (not (issubtype<Bool> (typeof<PyType> result@73@00) (as int<PyType>  PyType))))
(check-sat)
; unsat
(pop) ; 2
; 0.00s
; (get-info :all-statistics)
(assert (issubtype<Bool> (typeof<PyType> result@73@00) (as int<PyType>  PyType)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self_2@72@00 $Ref)) (!
  (implies
    (and
      (issubtype<Bool> (typeof<PyType> self_2@72@00) (as Agent<PyType>  PyType))
      (not (= self_2@72@00 $Ref.null)))
    (=
      (Agent_execute_nn_control s@$ self_2@72@00)
      (__prim__int___box__ $Snap.unit 50)))
  :pattern ((Agent_execute_nn_control s@$ self_2@72@00))
  )))
; ---------- FUNCTION float___create__----------
(declare-fun i@74@00 () Int)
(declare-fun result@75@00 () $Ref)
; ----- Well-definedness of specifications -----
(push) ; 1
(declare-const $t@119@00 $Snap)
(assert (= $t@119@00 $Snap.unit))
; [eval] typeof(result) == float()
; [eval] typeof(result)
; [eval] float()
(assert (= (typeof<PyType> result@75@00) (as float<PyType>  PyType)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (i@74@00 Int)) (!
  (= (float___create__%limited s@$ i@74@00) (float___create__ s@$ i@74@00))
  :pattern ((float___create__ s@$ i@74@00))
  )))
(assert (forall ((s@$ $Snap) (i@74@00 Int)) (!
  (float___create__%stateless i@74@00)
  :pattern ((float___create__%limited s@$ i@74@00))
  )))
(assert (forall ((s@$ $Snap) (i@74@00 Int)) (!
  (let ((result@75@00 (float___create__%limited s@$ i@74@00))) (=
    (typeof<PyType> result@75@00)
    (as float<PyType>  PyType)))
  :pattern ((float___create__%limited s@$ i@74@00))
  )))
; ---------- FUNCTION set___contains__----------
(declare-fun self@76@00 () $Ref)
(declare-fun item@77@00 () $Ref)
(declare-fun result@78@00 () Bool)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ ($Snap.combine ($Snap.first s@$) ($Snap.second s@$))))
(assert (= ($Snap.first s@$) $Snap.unit))
; [eval] issubtype(typeof(self), set(set_arg(typeof(self), 0)))
; [eval] typeof(self)
; [eval] set(set_arg(typeof(self), 0))
; [eval] set_arg(typeof(self), 0)
; [eval] typeof(self)
(assert (issubtype<Bool> (typeof<PyType> self@76@00) (set<PyType> (set_arg<PyType> (typeof<PyType> self@76@00) 0))))
(declare-const $k@120@00 $Perm)
(assert ($Perm.isReadVar $k@120@00 $Perm.Write))
(assert (<= $Perm.No $k@120@00))
(assert (<= $k@120@00 $Perm.Write))
(assert (implies (< $Perm.No $k@120@00) (not (= self@76@00 $Ref.null))))
(declare-const $t@121@00 $Snap)
(assert (= $t@121@00 $Snap.unit))
; [eval] result == (item in self.set_acc)
; [eval] (item in self.set_acc)
(set-option :timeout 10)
(push) ; 2
(assert (not (< $Perm.No $k@120@00)))
(check-sat)
; unsat
(pop) ; 2
; 0.00s
; (get-info :all-statistics)
(assert (=
  result@78@00
  (Set_in item@77@00 ($SortWrappers.$SnapToSet<$Ref> ($Snap.second s@$)))))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@76@00 $Ref) (item@77@00 $Ref)) (!
  (=
    (set___contains__%limited s@$ self@76@00 item@77@00)
    (set___contains__ s@$ self@76@00 item@77@00))
  :pattern ((set___contains__ s@$ self@76@00 item@77@00))
  )))
(assert (forall ((s@$ $Snap) (self@76@00 $Ref) (item@77@00 $Ref)) (!
  (set___contains__%stateless self@76@00 item@77@00)
  :pattern ((set___contains__%limited s@$ self@76@00 item@77@00))
  )))
(assert (forall ((s@$ $Snap) (self@76@00 $Ref) (item@77@00 $Ref)) (!
  (let ((result@78@00 (set___contains__%limited s@$ self@76@00 item@77@00))) (implies
    (issubtype<Bool> (typeof<PyType> self@76@00) (set<PyType> (set_arg<PyType> (typeof<PyType> self@76@00) 0)))
    (=
      result@78@00
      (Set_in item@77@00 ($SortWrappers.$SnapToSet<$Ref> ($Snap.second s@$))))))
  :pattern ((set___contains__%limited s@$ self@76@00 item@77@00))
  )))
; ---------- FUNCTION int___eq__----------
(declare-fun self@79@00 () $Ref)
(declare-fun other@80@00 () $Ref)
(declare-fun result@81@00 () Bool)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ ($Snap.combine ($Snap.first s@$) ($Snap.second s@$))))
(assert (= ($Snap.first s@$) $Snap.unit))
; [eval] issubtype(typeof(self), int())
; [eval] typeof(self)
; [eval] int()
(assert (issubtype<Bool> (typeof<PyType> self@79@00) (as int<PyType>  PyType)))
(assert (= ($Snap.second s@$) $Snap.unit))
; [eval] issubtype(typeof(other), int())
; [eval] typeof(other)
; [eval] int()
(assert (issubtype<Bool> (typeof<PyType> other@80@00) (as int<PyType>  PyType)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@79@00 $Ref) (other@80@00 $Ref)) (!
  (=
    (int___eq__%limited s@$ self@79@00 other@80@00)
    (int___eq__ s@$ self@79@00 other@80@00))
  :pattern ((int___eq__ s@$ self@79@00 other@80@00))
  )))
(assert (forall ((s@$ $Snap) (self@79@00 $Ref) (other@80@00 $Ref)) (!
  (int___eq__%stateless self@79@00 other@80@00)
  :pattern ((int___eq__%limited s@$ self@79@00 other@80@00))
  )))
; ----- Verification of function body and postcondition -----
(push) ; 1
(assert (= s@$ ($Snap.combine ($Snap.first s@$) ($Snap.second s@$))))
(assert (= ($Snap.first s@$) $Snap.unit))
(assert (issubtype<Bool> (typeof<PyType> self@79@00) (as int<PyType>  PyType)))
(assert (= ($Snap.second s@$) $Snap.unit))
(assert (issubtype<Bool> (typeof<PyType> other@80@00) (as int<PyType>  PyType)))
; State saturation: after contract
(set-option :timeout 50)
(check-sat)
; unknown
; [eval] int___unbox__(self) == int___unbox__(other)
; [eval] int___unbox__(self)
(push) ; 2
; [eval] issubtype(typeof(box), int())
; [eval] typeof(box)
; [eval] int()
(pop) ; 2
; Joined path conditions
; [eval] int___unbox__(other)
(push) ; 2
; [eval] issubtype(typeof(box), int())
; [eval] typeof(box)
; [eval] int()
(pop) ; 2
; Joined path conditions
(assert (=
  result@81@00
  (=
    (int___unbox__ $Snap.unit self@79@00)
    (int___unbox__ $Snap.unit other@80@00))))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@79@00 $Ref) (other@80@00 $Ref)) (!
  (implies
    (and
      (issubtype<Bool> (typeof<PyType> self@79@00) (as int<PyType>  PyType))
      (issubtype<Bool> (typeof<PyType> other@80@00) (as int<PyType>  PyType)))
    (=
      (int___eq__ s@$ self@79@00 other@80@00)
      (=
        (int___unbox__ $Snap.unit self@79@00)
        (int___unbox__ $Snap.unit other@80@00))))
  :pattern ((int___eq__ s@$ self@79@00 other@80@00))
  )))
; ---------- FUNCTION list___getitem__----------
(declare-fun self@82@00 () $Ref)
(declare-fun key@83@00 () $Ref)
(declare-fun result@84@00 () $Ref)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ ($Snap.combine ($Snap.first s@$) ($Snap.second s@$))))
(assert (= ($Snap.first s@$) $Snap.unit))
; [eval] issubtype(typeof(self), list(list_arg(typeof(self), 0)))
; [eval] typeof(self)
; [eval] list(list_arg(typeof(self), 0))
; [eval] list_arg(typeof(self), 0)
; [eval] typeof(self)
(assert (issubtype<Bool> (typeof<PyType> self@82@00) (list<PyType> (list_arg<PyType> (typeof<PyType> self@82@00) 0))))
(assert (=
  ($Snap.second s@$)
  ($Snap.combine
    ($Snap.first ($Snap.second s@$))
    ($Snap.second ($Snap.second s@$)))))
(assert (= ($Snap.first ($Snap.second s@$)) $Snap.unit))
; [eval] issubtype(typeof(key), int())
; [eval] typeof(key)
; [eval] int()
(assert (issubtype<Bool> (typeof<PyType> key@83@00) (as int<PyType>  PyType)))
(assert (=
  ($Snap.second ($Snap.second s@$))
  ($Snap.combine
    ($Snap.first ($Snap.second ($Snap.second s@$)))
    ($Snap.second ($Snap.second ($Snap.second s@$))))))
(declare-const $k@122@00 $Perm)
(assert ($Perm.isReadVar $k@122@00 $Perm.Write))
(assert (<= $Perm.No $k@122@00))
(assert (<= $k@122@00 $Perm.Write))
(assert (implies (< $Perm.No $k@122@00) (not (= self@82@00 $Ref.null))))
(assert (= ($Snap.second ($Snap.second ($Snap.second s@$))) $Snap.unit))
; [eval] (let ln == (list___len__(self)) in (int___unbox__(key) < 0 ==> int___unbox__(key) >= -ln) && (int___unbox__(key) >= 0 ==> int___unbox__(key) < ln))
; [eval] list___len__(self)
(push) ; 2
; [eval] issubtype(typeof(self), list(list_arg(typeof(self), 0)))
; [eval] typeof(self)
; [eval] list(list_arg(typeof(self), 0))
; [eval] list_arg(typeof(self), 0)
; [eval] typeof(self)
(declare-const $k@123@00 $Perm)
(assert ($Perm.isReadVar $k@123@00 $Perm.Write))
(set-option :timeout 0)
(push) ; 3
(assert (not (or (= $k@123@00 $Perm.No) (< $Perm.No $k@123@00))))
(check-sat)
; unsat
(pop) ; 3
; 0.00s
; (get-info :all-statistics)
(set-option :timeout 10)
(push) ; 3
(assert (not (not (= $k@122@00 $Perm.No))))
(check-sat)
; unsat
(pop) ; 3
; 0.00s
; (get-info :all-statistics)
(assert (< $k@123@00 $k@122@00))
(assert (<= $Perm.No (- $k@122@00 $k@123@00)))
(assert (<= (- $k@122@00 $k@123@00) $Perm.Write))
(assert (implies (< $Perm.No (- $k@122@00 $k@123@00)) (not (= self@82@00 $Ref.null))))
(pop) ; 2
; Joined path conditions
(assert (and
  ($Perm.isReadVar $k@123@00 $Perm.Write)
  (< $k@123@00 $k@122@00)
  (<= $Perm.No (- $k@122@00 $k@123@00))
  (<= (- $k@122@00 $k@123@00) $Perm.Write)
  (implies (< $Perm.No (- $k@122@00 $k@123@00)) (not (= self@82@00 $Ref.null)))))
; [eval] (int___unbox__(key) < 0 ==> int___unbox__(key) >= -ln) && (int___unbox__(key) >= 0 ==> int___unbox__(key) < ln)
; [eval] int___unbox__(key) < 0 ==> int___unbox__(key) >= -ln
; [eval] int___unbox__(key) < 0
; [eval] int___unbox__(key)
(push) ; 2
; [eval] issubtype(typeof(box), int())
; [eval] typeof(box)
; [eval] int()
(pop) ; 2
; Joined path conditions
(push) ; 2
(push) ; 3
(assert (not (not (< (int___unbox__ $Snap.unit key@83@00) 0))))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
(push) ; 3
(assert (not (< (int___unbox__ $Snap.unit key@83@00) 0)))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
; [then-branch: 24 | int___unbox__(_, key@83@00) < 0 | live]
; [else-branch: 24 | !(int___unbox__(_, key@83@00) < 0) | live]
(push) ; 3
; [then-branch: 24 | int___unbox__(_, key@83@00) < 0]
(assert (< (int___unbox__ $Snap.unit key@83@00) 0))
; [eval] int___unbox__(key) >= -ln
; [eval] int___unbox__(key)
(push) ; 4
; [eval] issubtype(typeof(box), int())
; [eval] typeof(box)
; [eval] int()
(pop) ; 4
; Joined path conditions
; [eval] -ln
(pop) ; 3
(push) ; 3
; [else-branch: 24 | !(int___unbox__(_, key@83@00) < 0)]
(assert (not (< (int___unbox__ $Snap.unit key@83@00) 0)))
(pop) ; 3
(pop) ; 2
; Joined path conditions
; Joined path conditions
(push) ; 2
; [then-branch: 25 | int___unbox__(_, key@83@00) < 0 ==> int___unbox__(_, key@83@00) >= 0 - list___len__((_, First:(Second:(Second:(s@$)))), self@82@00) | live]
; [else-branch: 25 | !(int___unbox__(_, key@83@00) < 0 ==> int___unbox__(_, key@83@00) >= 0 - list___len__((_, First:(Second:(Second:(s@$)))), self@82@00)) | live]
(push) ; 3
; [then-branch: 25 | int___unbox__(_, key@83@00) < 0 ==> int___unbox__(_, key@83@00) >= 0 - list___len__((_, First:(Second:(Second:(s@$)))), self@82@00)]
(assert (implies
  (< (int___unbox__ $Snap.unit key@83@00) 0)
  (>=
    (int___unbox__ $Snap.unit key@83@00)
    (-
      0
      (list___len__ ($Snap.combine
        $Snap.unit
        ($Snap.first ($Snap.second ($Snap.second s@$)))) self@82@00)))))
; [eval] int___unbox__(key) >= 0 ==> int___unbox__(key) < ln
; [eval] int___unbox__(key) >= 0
; [eval] int___unbox__(key)
(push) ; 4
; [eval] issubtype(typeof(box), int())
; [eval] typeof(box)
; [eval] int()
(pop) ; 4
; Joined path conditions
(push) ; 4
(push) ; 5
(assert (not (not (>= (int___unbox__ $Snap.unit key@83@00) 0))))
(check-sat)
; unknown
(pop) ; 5
; 0.01s
; (get-info :all-statistics)
(push) ; 5
(assert (not (>= (int___unbox__ $Snap.unit key@83@00) 0)))
(check-sat)
; unknown
(pop) ; 5
; 0.00s
; (get-info :all-statistics)
; [then-branch: 26 | int___unbox__(_, key@83@00) >= 0 | live]
; [else-branch: 26 | !(int___unbox__(_, key@83@00) >= 0) | live]
(push) ; 5
; [then-branch: 26 | int___unbox__(_, key@83@00) >= 0]
(assert (>= (int___unbox__ $Snap.unit key@83@00) 0))
; [eval] int___unbox__(key) < ln
; [eval] int___unbox__(key)
(push) ; 6
; [eval] issubtype(typeof(box), int())
; [eval] typeof(box)
; [eval] int()
(pop) ; 6
; Joined path conditions
(pop) ; 5
(push) ; 5
; [else-branch: 26 | !(int___unbox__(_, key@83@00) >= 0)]
(assert (not (>= (int___unbox__ $Snap.unit key@83@00) 0)))
(pop) ; 5
(pop) ; 4
; Joined path conditions
; Joined path conditions
(pop) ; 3
(push) ; 3
; [else-branch: 25 | !(int___unbox__(_, key@83@00) < 0 ==> int___unbox__(_, key@83@00) >= 0 - list___len__((_, First:(Second:(Second:(s@$)))), self@82@00))]
(assert (not
  (implies
    (< (int___unbox__ $Snap.unit key@83@00) 0)
    (>=
      (int___unbox__ $Snap.unit key@83@00)
      (-
        0
        (list___len__ ($Snap.combine
          $Snap.unit
          ($Snap.first ($Snap.second ($Snap.second s@$)))) self@82@00))))))
(pop) ; 3
(pop) ; 2
; Joined path conditions
(assert (implies
  (and
    (implies
      (< (int___unbox__ $Snap.unit key@83@00) 0)
      (>=
        (int___unbox__ $Snap.unit key@83@00)
        (-
          0
          (list___len__ ($Snap.combine
            $Snap.unit
            ($Snap.first ($Snap.second ($Snap.second s@$)))) self@82@00))))
    (< (int___unbox__ $Snap.unit key@83@00) 0))
  (>=
    (int___unbox__ $Snap.unit key@83@00)
    (-
      0
      (list___len__ ($Snap.combine
        $Snap.unit
        ($Snap.first ($Snap.second ($Snap.second s@$)))) self@82@00)))))
; Joined path conditions
(assert (and
  (implies
    (>= (int___unbox__ $Snap.unit key@83@00) 0)
    (<
      (int___unbox__ $Snap.unit key@83@00)
      (list___len__ ($Snap.combine
        $Snap.unit
        ($Snap.first ($Snap.second ($Snap.second s@$)))) self@82@00)))
  (implies
    (< (int___unbox__ $Snap.unit key@83@00) 0)
    (>=
      (int___unbox__ $Snap.unit key@83@00)
      (-
        0
        (list___len__ ($Snap.combine
          $Snap.unit
          ($Snap.first ($Snap.second ($Snap.second s@$)))) self@82@00))))))
(declare-const $t@124@00 $Snap)
(assert (= $t@124@00 ($Snap.combine ($Snap.first $t@124@00) ($Snap.second $t@124@00))))
(assert (= ($Snap.first $t@124@00) $Snap.unit))
; [eval] result == (int___unbox__(key) >= 0 ? self.list_acc[int___unbox__(key)] : self.list_acc[list___len__(self) + int___unbox__(key)])
; [eval] (int___unbox__(key) >= 0 ? self.list_acc[int___unbox__(key)] : self.list_acc[list___len__(self) + int___unbox__(key)])
; [eval] int___unbox__(key) >= 0
; [eval] int___unbox__(key)
(push) ; 2
; [eval] issubtype(typeof(box), int())
; [eval] typeof(box)
; [eval] int()
(pop) ; 2
; Joined path conditions
(push) ; 2
(push) ; 3
(assert (not (not (>= (int___unbox__ $Snap.unit key@83@00) 0))))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
(push) ; 3
(assert (not (>= (int___unbox__ $Snap.unit key@83@00) 0)))
(check-sat)
; unknown
(pop) ; 3
; 0.01s
; (get-info :all-statistics)
; [then-branch: 27 | int___unbox__(_, key@83@00) >= 0 | live]
; [else-branch: 27 | !(int___unbox__(_, key@83@00) >= 0) | live]
(push) ; 3
; [then-branch: 27 | int___unbox__(_, key@83@00) >= 0]
(assert (>= (int___unbox__ $Snap.unit key@83@00) 0))
; [eval] self.list_acc[int___unbox__(key)]
(push) ; 4
(assert (not (< $Perm.No $k@122@00)))
(check-sat)
; unsat
(pop) ; 4
; 0.00s
; (get-info :all-statistics)
; [eval] int___unbox__(key)
(push) ; 4
; [eval] issubtype(typeof(box), int())
; [eval] typeof(box)
; [eval] int()
(pop) ; 4
; Joined path conditions
(set-option :timeout 0)
(push) ; 4
(assert (not (<
  (int___unbox__ $Snap.unit key@83@00)
  (Seq_length
    ($SortWrappers.$SnapToSeq<$Ref> ($Snap.first ($Snap.second ($Snap.second s@$))))))))
(check-sat)
; unsat
(pop) ; 4
; 0.00s
; (get-info :all-statistics)
(pop) ; 3
(push) ; 3
; [else-branch: 27 | !(int___unbox__(_, key@83@00) >= 0)]
(assert (not (>= (int___unbox__ $Snap.unit key@83@00) 0)))
; [eval] self.list_acc[list___len__(self) + int___unbox__(key)]
(set-option :timeout 10)
(push) ; 4
(assert (not (< $Perm.No $k@122@00)))
(check-sat)
; unsat
(pop) ; 4
; 0.00s
; (get-info :all-statistics)
; [eval] list___len__(self) + int___unbox__(key)
; [eval] list___len__(self)
(push) ; 4
; [eval] issubtype(typeof(self), list(list_arg(typeof(self), 0)))
; [eval] typeof(self)
; [eval] list(list_arg(typeof(self), 0))
; [eval] list_arg(typeof(self), 0)
; [eval] typeof(self)
(declare-const $k@125@00 $Perm)
(assert ($Perm.isReadVar $k@125@00 $Perm.Write))
(set-option :timeout 0)
(push) ; 5
(assert (not (or (= $k@125@00 $Perm.No) (< $Perm.No $k@125@00))))
(check-sat)
; unsat
(pop) ; 5
; 0.00s
; (get-info :all-statistics)
(set-option :timeout 10)
(push) ; 5
(assert (not (not (= $k@122@00 $Perm.No))))
(check-sat)
; unsat
(pop) ; 5
; 0.00s
; (get-info :all-statistics)
(assert (< $k@125@00 $k@122@00))
(assert (<= $Perm.No (- $k@122@00 $k@125@00)))
(assert (<= (- $k@122@00 $k@125@00) $Perm.Write))
(assert (implies (< $Perm.No (- $k@122@00 $k@125@00)) (not (= self@82@00 $Ref.null))))
(pop) ; 4
; Joined path conditions
(assert (and
  ($Perm.isReadVar $k@125@00 $Perm.Write)
  (< $k@125@00 $k@122@00)
  (<= $Perm.No (- $k@122@00 $k@125@00))
  (<= (- $k@122@00 $k@125@00) $Perm.Write)
  (implies (< $Perm.No (- $k@122@00 $k@125@00)) (not (= self@82@00 $Ref.null)))))
; [eval] int___unbox__(key)
(push) ; 4
; [eval] issubtype(typeof(box), int())
; [eval] typeof(box)
; [eval] int()
(pop) ; 4
; Joined path conditions
(set-option :timeout 0)
(push) ; 4
(assert (not (>=
  (+
    (list___len__ ($Snap.combine
      $Snap.unit
      ($Snap.first ($Snap.second ($Snap.second s@$)))) self@82@00)
    (int___unbox__ $Snap.unit key@83@00))
  0)))
(check-sat)
; unsat
(pop) ; 4
; 0.00s
; (get-info :all-statistics)
(push) ; 4
(assert (not (<
  (+
    (list___len__ ($Snap.combine
      $Snap.unit
      ($Snap.first ($Snap.second ($Snap.second s@$)))) self@82@00)
    (int___unbox__ $Snap.unit key@83@00))
  (Seq_length
    ($SortWrappers.$SnapToSeq<$Ref> ($Snap.first ($Snap.second ($Snap.second s@$))))))))
(check-sat)
; unsat
(pop) ; 4
; 0.00s
; (get-info :all-statistics)
(pop) ; 3
(pop) ; 2
; Joined path conditions
; Joined path conditions
(assert (implies
  (not (>= (int___unbox__ $Snap.unit key@83@00) 0))
  (and
    (not (>= (int___unbox__ $Snap.unit key@83@00) 0))
    ($Perm.isReadVar $k@125@00 $Perm.Write)
    (< $k@125@00 $k@122@00)
    (<= $Perm.No (- $k@122@00 $k@125@00))
    (<= (- $k@122@00 $k@125@00) $Perm.Write)
    (implies (< $Perm.No (- $k@122@00 $k@125@00)) (not (= self@82@00 $Ref.null))))))
(assert (=
  result@84@00
  (ite
    (>= (int___unbox__ $Snap.unit key@83@00) 0)
    (Seq_index
      ($SortWrappers.$SnapToSeq<$Ref> ($Snap.first ($Snap.second ($Snap.second s@$))))
      (int___unbox__ $Snap.unit key@83@00))
    (Seq_index
      ($SortWrappers.$SnapToSeq<$Ref> ($Snap.first ($Snap.second ($Snap.second s@$))))
      (+
        (list___len__ ($Snap.combine
          $Snap.unit
          ($Snap.first ($Snap.second ($Snap.second s@$)))) self@82@00)
        (int___unbox__ $Snap.unit key@83@00))))))
(assert (= ($Snap.second $t@124@00) $Snap.unit))
; [eval] issubtype(typeof(result), list_arg(typeof(self), 0))
; [eval] typeof(result)
; [eval] list_arg(typeof(self), 0)
; [eval] typeof(self)
(assert (issubtype<Bool> (typeof<PyType> result@84@00) (list_arg<PyType> (typeof<PyType> self@82@00) 0)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@82@00 $Ref) (key@83@00 $Ref)) (!
  (=
    (list___getitem__%limited s@$ self@82@00 key@83@00)
    (list___getitem__ s@$ self@82@00 key@83@00))
  :pattern ((list___getitem__ s@$ self@82@00 key@83@00))
  )))
(assert (forall ((s@$ $Snap) (self@82@00 $Ref) (key@83@00 $Ref)) (!
  (list___getitem__%stateless self@82@00 key@83@00)
  :pattern ((list___getitem__%limited s@$ self@82@00 key@83@00))
  )))
(assert (forall ((s@$ $Snap) (self@82@00 $Ref) (key@83@00 $Ref)) (!
  (let ((result@84@00 (list___getitem__%limited s@$ self@82@00 key@83@00))) (implies
    (and
      (issubtype<Bool> (typeof<PyType> self@82@00) (list<PyType> (list_arg<PyType> (typeof<PyType> self@82@00) 0)))
      (issubtype<Bool> (typeof<PyType> key@83@00) (as int<PyType>  PyType))
      (let ((ln (list___len__ ($Snap.combine
        $Snap.unit
        ($Snap.first ($Snap.second ($Snap.second s@$)))) self@82@00))) (and
        (implies
          (< (int___unbox__ $Snap.unit key@83@00) 0)
          (>= (int___unbox__ $Snap.unit key@83@00) (- 0 ln)))
        (implies
          (>= (int___unbox__ $Snap.unit key@83@00) 0)
          (< (int___unbox__ $Snap.unit key@83@00) ln)))))
    (and
      (=
        result@84@00
        (ite
          (>= (int___unbox__ $Snap.unit key@83@00) 0)
          (Seq_index
            ($SortWrappers.$SnapToSeq<$Ref> ($Snap.first ($Snap.second ($Snap.second s@$))))
            (int___unbox__ $Snap.unit key@83@00))
          (Seq_index
            ($SortWrappers.$SnapToSeq<$Ref> ($Snap.first ($Snap.second ($Snap.second s@$))))
            (+
              (list___len__ ($Snap.combine
                $Snap.unit
                ($Snap.first ($Snap.second ($Snap.second s@$)))) self@82@00)
              (int___unbox__ $Snap.unit key@83@00)))))
      (issubtype<Bool> (typeof<PyType> result@84@00) (list_arg<PyType> (typeof<PyType> self@82@00) 0)))))
  :pattern ((list___getitem__%limited s@$ self@82@00 key@83@00))
  )))
; ---------- FUNCTION int___add__----------
(declare-fun self@85@00 () Int)
(declare-fun other@86@00 () Int)
(declare-fun result@87@00 () Int)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@85@00 Int) (other@86@00 Int)) (!
  (=
    (int___add__%limited s@$ self@85@00 other@86@00)
    (int___add__ s@$ self@85@00 other@86@00))
  :pattern ((int___add__ s@$ self@85@00 other@86@00))
  )))
(assert (forall ((s@$ $Snap) (self@85@00 Int) (other@86@00 Int)) (!
  (int___add__%stateless self@85@00 other@86@00)
  :pattern ((int___add__%limited s@$ self@85@00 other@86@00))
  )))
; ----- Verification of function body and postcondition -----
(push) ; 1
; State saturation: after contract
(set-option :timeout 50)
(check-sat)
; unknown
; [eval] self + other
(assert (= result@87@00 (+ self@85@00 other@86@00)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@85@00 Int) (other@86@00 Int)) (!
  (= (int___add__ s@$ self@85@00 other@86@00) (+ self@85@00 other@86@00))
  :pattern ((int___add__ s@$ self@85@00 other@86@00))
  )))
; ---------- FUNCTION str___create__----------
(declare-fun len@88@00 () Int)
(declare-fun value@89@00 () Int)
(declare-fun result@90@00 () $Ref)
; ----- Well-definedness of specifications -----
(push) ; 1
(declare-const $t@126@00 $Snap)
(assert (= $t@126@00 ($Snap.combine ($Snap.first $t@126@00) ($Snap.second $t@126@00))))
(assert (= ($Snap.first $t@126@00) $Snap.unit))
; [eval] str___len__(result) == len
; [eval] str___len__(result)
(push) ; 2
(pop) ; 2
; Joined path conditions
(assert (= (str___len__ $Snap.unit result@90@00) len@88@00))
(assert (=
  ($Snap.second $t@126@00)
  ($Snap.combine
    ($Snap.first ($Snap.second $t@126@00))
    ($Snap.second ($Snap.second $t@126@00)))))
(assert (= ($Snap.first ($Snap.second $t@126@00)) $Snap.unit))
; [eval] str___val__(result) == value
; [eval] str___val__(result)
(push) ; 2
(pop) ; 2
; Joined path conditions
(assert (= (str___val__ $Snap.unit result@90@00) value@89@00))
(assert (= ($Snap.second ($Snap.second $t@126@00)) $Snap.unit))
; [eval] typeof(result) == str()
; [eval] typeof(result)
; [eval] str()
(assert (= (typeof<PyType> result@90@00) (as str<PyType>  PyType)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (len@88@00 Int) (value@89@00 Int)) (!
  (=
    (str___create__%limited s@$ len@88@00 value@89@00)
    (str___create__ s@$ len@88@00 value@89@00))
  :pattern ((str___create__ s@$ len@88@00 value@89@00))
  )))
(assert (forall ((s@$ $Snap) (len@88@00 Int) (value@89@00 Int)) (!
  (str___create__%stateless len@88@00 value@89@00)
  :pattern ((str___create__%limited s@$ len@88@00 value@89@00))
  )))
(assert (forall ((s@$ $Snap) (len@88@00 Int) (value@89@00 Int)) (!
  (let ((result@90@00 (str___create__%limited s@$ len@88@00 value@89@00))) (and
    (= (str___len__ $Snap.unit result@90@00) len@88@00)
    (= (str___val__ $Snap.unit result@90@00) value@89@00)
    (= (typeof<PyType> result@90@00) (as str<PyType>  PyType))))
  :pattern ((str___create__%limited s@$ len@88@00 value@89@00))
  )))
; ---------- FUNCTION list___sil_seq__----------
(declare-fun self@91@00 () $Ref)
(declare-fun result@92@00 () Seq<$Ref>)
; ----- Well-definedness of specifications -----
(push) ; 1
(declare-const $k@127@00 $Perm)
(assert ($Perm.isReadVar $k@127@00 $Perm.Write))
(assert (<= $Perm.No $k@127@00))
(assert (<= $k@127@00 $Perm.Write))
(assert (implies (< $Perm.No $k@127@00) (not (= self@91@00 $Ref.null))))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@91@00 $Ref)) (!
  (Seq_equal
    (list___sil_seq__%limited s@$ self@91@00)
    (list___sil_seq__ s@$ self@91@00))
  :pattern ((list___sil_seq__ s@$ self@91@00))
  )))
(assert (forall ((s@$ $Snap) (self@91@00 $Ref)) (!
  (list___sil_seq__%stateless self@91@00)
  :pattern ((list___sil_seq__%limited s@$ self@91@00))
  )))
; ----- Verification of function body and postcondition -----
(push) ; 1
(assert ($Perm.isReadVar $k@127@00 $Perm.Write))
(assert (<= $Perm.No $k@127@00))
(assert (<= $k@127@00 $Perm.Write))
(assert (implies (< $Perm.No $k@127@00) (not (= self@91@00 $Ref.null))))
; State saturation: after contract
(check-sat)
; unknown
(set-option :timeout 10)
(push) ; 2
(assert (not (< $Perm.No $k@127@00)))
(check-sat)
; unsat
(pop) ; 2
; 0.00s
; (get-info :all-statistics)
(assert (Seq_equal result@92@00 ($SortWrappers.$SnapToSeq<$Ref> s@$)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@91@00 $Ref)) (!
  (Seq_equal
    (list___sil_seq__ s@$ self@91@00)
    ($SortWrappers.$SnapToSeq<$Ref> s@$))
  :pattern ((list___sil_seq__ s@$ self@91@00))
  )))
; ---------- FUNCTION range___create__----------
(declare-fun start@93@00 () Int)
(declare-fun stop@94@00 () Int)
(declare-fun ctr@95@00 () Int)
(declare-fun result@96@00 () $Ref)
; ----- Well-definedness of specifications -----
(push) ; 1
(assert (= s@$ $Snap.unit))
; [eval] stop >= start
(assert (>= stop@94@00 start@93@00))
(declare-const $t@128@00 $Snap)
(assert (= $t@128@00 ($Snap.combine ($Snap.first $t@128@00) ($Snap.second $t@128@00))))
(assert (= ($Snap.first $t@128@00) $Snap.unit))
; [eval] range___val__(result) == [start..stop)
; [eval] range___val__(result)
(push) ; 2
(pop) ; 2
; Joined path conditions
; [eval] [start..stop)
(assert (Seq_equal
  (range___val__ $Snap.unit result@96@00)
  (Seq_range start@93@00 stop@94@00)))
(assert (=
  ($Snap.second $t@128@00)
  ($Snap.combine
    ($Snap.first ($Snap.second $t@128@00))
    ($Snap.second ($Snap.second $t@128@00)))))
(assert (= ($Snap.first ($Snap.second $t@128@00)) $Snap.unit))
; [eval] range___start__(result) == start
; [eval] range___start__(result)
(push) ; 2
(pop) ; 2
; Joined path conditions
(assert (= (range___start__ $Snap.unit result@96@00) start@93@00))
(assert (=
  ($Snap.second ($Snap.second $t@128@00))
  ($Snap.combine
    ($Snap.first ($Snap.second ($Snap.second $t@128@00)))
    ($Snap.second ($Snap.second ($Snap.second $t@128@00))))))
(assert (= ($Snap.first ($Snap.second ($Snap.second $t@128@00))) $Snap.unit))
; [eval] range___stop__(result) == stop
; [eval] range___stop__(result)
(push) ; 2
(pop) ; 2
; Joined path conditions
(assert (= (range___stop__ $Snap.unit result@96@00) stop@94@00))
(assert (= ($Snap.second ($Snap.second ($Snap.second $t@128@00))) $Snap.unit))
; [eval] typeof(result) == range()
; [eval] typeof(result)
; [eval] range()
(assert (= (typeof<PyType> result@96@00) (as range<PyType>  PyType)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (start@93@00 Int) (stop@94@00 Int) (ctr@95@00 Int)) (!
  (=
    (range___create__%limited s@$ start@93@00 stop@94@00 ctr@95@00)
    (range___create__ s@$ start@93@00 stop@94@00 ctr@95@00))
  :pattern ((range___create__ s@$ start@93@00 stop@94@00 ctr@95@00))
  )))
(assert (forall ((s@$ $Snap) (start@93@00 Int) (stop@94@00 Int) (ctr@95@00 Int)) (!
  (range___create__%stateless start@93@00 stop@94@00 ctr@95@00)
  :pattern ((range___create__%limited s@$ start@93@00 stop@94@00 ctr@95@00))
  )))
(assert (forall ((s@$ $Snap) (start@93@00 Int) (stop@94@00 Int) (ctr@95@00 Int)) (!
  (let ((result@96@00 (range___create__%limited s@$ start@93@00 stop@94@00 ctr@95@00))) (implies
    (>= stop@94@00 start@93@00)
    (and
      (Seq_equal
        (range___val__ $Snap.unit result@96@00)
        (Seq_range start@93@00 stop@94@00))
      (= (range___start__ $Snap.unit result@96@00) start@93@00)
      (= (range___stop__ $Snap.unit result@96@00) stop@94@00)
      (= (typeof<PyType> result@96@00) (as range<PyType>  PyType)))))
  :pattern ((range___create__%limited s@$ start@93@00 stop@94@00 ctr@95@00))
  )))
; ---------- FUNCTION int___le__----------
(declare-fun self@97@00 () Int)
(declare-fun other@98@00 () Int)
(declare-fun result@99@00 () Bool)
; ----- Well-definedness of specifications -----
(push) ; 1
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@97@00 Int) (other@98@00 Int)) (!
  (=
    (int___le__%limited s@$ self@97@00 other@98@00)
    (int___le__ s@$ self@97@00 other@98@00))
  :pattern ((int___le__ s@$ self@97@00 other@98@00))
  )))
(assert (forall ((s@$ $Snap) (self@97@00 Int) (other@98@00 Int)) (!
  (int___le__%stateless self@97@00 other@98@00)
  :pattern ((int___le__%limited s@$ self@97@00 other@98@00))
  )))
; ----- Verification of function body and postcondition -----
(push) ; 1
; State saturation: after contract
(set-option :timeout 50)
(check-sat)
; unknown
; [eval] self <= other
(assert (= result@99@00 (<= self@97@00 other@98@00)))
(pop) ; 1
(assert (forall ((s@$ $Snap) (self@97@00 Int) (other@98@00 Int)) (!
  (= (int___le__ s@$ self@97@00 other@98@00) (<= self@97@00 other@98@00))
  :pattern ((int___le__ s@$ self@97@00 other@98@00))
  )))
; ---------- MustTerminate ----------
(declare-const r@129@00 $Ref)
; ---------- MustInvokeBounded ----------
(declare-const r@130@00 $Ref)
; ---------- MustInvokeUnbounded ----------
(declare-const r@131@00 $Ref)
; ---------- _MaySet ----------
(declare-const rec@132@00 $Ref)
(declare-const id@133@00 Int)
