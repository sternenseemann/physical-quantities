(in-package :pq)

(defrule value () form)
(defrule unit-factor () (and (? (or '/ 'per)) (not '->) (? (and (or '^ '** (and 'to 'the)) form)))
  (:destructure (per symb exponent) `(list ,(symbol-name symb) ,(if exponent (if per `(- ,(second exponent)) (second exponent)) (if per -1 1)))))
(defrule error () (and (or '+/- '+-) value (? '%))
  (:destructure (pm val percent) (declare (ignore pm)) (if percent `(- (/ ,val 100)) val)))
(defrule errval () (and value (? error))
  (:destructure (val err) (list val (if err err 0))))
(defrule conversion () (and '-> (* unit-factor))
  (:destructure (arrow unit-factors) (declare (ignore arrow)) unit-factors))
(defrule quantity () (and errval (* unit-factor) (? conversion)))
(defrule unit-definition () (and form (* unit-factor))
  (:destructure (conv unit-factors) `(,conv (list ,@unit-factors))))