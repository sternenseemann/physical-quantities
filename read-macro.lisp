(in-package :pq)

(defun read-quantity (stream char1 char2)
  (declare (ignore char1 char2))
  (let ((expr (parseq 'quantity (read stream t nil t))))
    (unless expr
      (error "Syntax error in quantity definition."))
    (destructuring-bind ((val err) unit-a unit-b) expr
      `(eval-quantity ,val ,err (list ,@unit-a) (list ,@unit-b)))))

(set-dispatch-macro-character #\# #\q #'read-quantity)

(defgeneric eval-quantity (value error unit-a unit-b))
;; #q(<n> [+/- <n>] [m / s])
(defmethod eval-quantity ((value number) (error number) unit-a (unit-b (eql nil)))
  (make-quantity :value value :error error :unit (dereference-unit unit-a)))
;; #q(<n> [+/- <n>] m / s -> km / h)
(defmethod eval-quantity ((value number) (error number) unit-a unit-b)
  (make-quantity :value (convert-units value unit-a unit-b) :error (if (minusp error) error (convert-units error unit-a unit-b)) :unit (dereference-unit unit-b)))
;; #q(<q>)
(defmethod eval-quantity ((value quantity) (error (eql 0)) (unit-a (eql nil)) (unit-b (eql nil)))
  (value value))
;; #q(<q> -> km / h)
(defmethod eval-quantity ((q quantity) (error (eql 0)) unit-a (unit-b (eql nil)))
  (convert-units q (dereference-unit unit-a)))
;; #q(<q> km / h)
(defmethod eval-quantity ((q quantity) (error (eql 0)) (unit-a (eql nil)) unit-b)
  (convert-units q (dereference-unit unit-b)))
