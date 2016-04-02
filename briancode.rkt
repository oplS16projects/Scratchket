#lang racket
(require racket/gui/base)
(require racket/draw)

(define position car)
(define size cdr)

(define (xpos rect) (car (position rect)))
(define (ypos rect) (cdr (position rect)))

(define width car)
(define height cdr)

;(define (set-rect! rect x y width height)
;  (set! rect (cons (cons x y)
;                   (cons width height))))

;(define red1 (cons (cons 0 10) (cons 20 20)))

(define frame (new frame%
                   [label "Scratchket"]
                   [width 600]
                   [height 600]))
(define mycanvas (new canvas% [parent frame]
             [paint-callback
              (lambda (canvas dc)
                (send dc set-scale 3 3)
                (send dc draw-rectangle 0 10 20 20); x y width height
                ;(send dc draw-rectangle 20 10 20 20)
                )]))
(send frame show #t)

;(define (move-cons-right red1 move)
;  (if (> move 0)
;      (begin
;        (send mycanvas refresh-now (lambda (dc)
;                                     (send dc draw-rectangle (+ (xpos red1) 1) 10 20 20)))
;        ;(send mycanvas refresh-now (lambda (dc)
;         ;                            (send dc draw-rectangle (+ x2 1) 10 20 20)))
;        ;(sleep 0.1)
;        (set! red1 (cons (cons (+ (xpos red1) 1) (ypos red1))
;                         (cons 20 20)))
;        (move-cons-right red1 (- move 1)))
;      (display "done move")))

(define (move-square x y)
  (send mycanvas refresh-now (lambda (dc)
                               (send dc draw-rectangle x y 20 20))))
      
;(send mycanvas refresh-now (lambda (dc) (send dc draw-rectangle 60 10 30 10)))

;    (define target (make-bitmap 30 30)) ; A 30x30 bitmap
;    (define dc (new bitmap-dc% [bitmap target]))
;
;;Then, use methods like draw-line on the DC to draw into the bitmap. For example, the sequence
;
;    (send dc draw-rectangle
;          0 10   ; Top-left at (0, 10), 10 pixels down from top-left
;          30 10) ; 30 pixels wide and 10 pixels high
;    (send dc draw-line
;          0 0    ; Start at (0, 0), the top-left corner
;          30 30) ; and draw to (30, 30), the bottom-right corner
;    (send dc draw-line
;          0 30   ; Start at (0, 30), the bottom-left corner
;          30 0)  ; and draw to (30, 0), the top-right corner