#lang racket/gui
(require racket/gui/base)
(require racket/gui/base)
(require racket/draw)

(define position car)
(define size cdr)

(define (xpos rect) (car (position rect)))
(define (ypos rect) (cdr (position rect)))

(define width car)
(define height cdr)

(define frame (new frame%
                   [label "Scratchket"]
                   [width 600]
                   [height 600]))
;(define mycanvas (new canvas% [parent frame]
;             [paint-callback
;              (lambda (canvas dc)
;                (send dc set-scale 3 3)

;                (send dc draw-rectangle 0 10 20 20); x y width height
                ;(send dc draw-rectangle 20 10 20 20)
;                )]))


(define (move-square x y)
  (send can refresh-now (lambda (dc)
                                (send dc set-brush "red" 'solid)  
                                (send dc set-pen "black" 1 'solid)
                                (send dc draw-rectangle x y 30 30))))
; Start of Kyle's code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define mouse-x 0)
(define mouse-y 0)

(define get-tag (lambda (x) x))
(define get-selected '(kyle 'bar))
(define my-canvas%
  (class canvas% ; The base class is canvas%(send message set-label (string-append "Selected:     " (symbol->string (get-tag ())
    (inherit get-width get-height refresh)
    ; Define overriding method to handle mouse events
    (define direction #f)
    (define message
      (new message%
         [label "Selected:     Nothing"]
         [parent frame]
         [min-width 100]
         [vert-margin 5]))
    
    (define update-message
      (lambda () 
  (send message set-label (string-append "Selected:     "
                                         (symbol->string
                                          (get-tag (car get-selected)))))))
    (define/override (on-event event)
      ;Grab the x and y coords
      (set! mouse-x (send event get-x))
      (set! mouse-y (send event get-y))
      (if (send event button-down? 'left)
          ;Main left click functions
          ;1. Change the message label to show new selected thing
          ;2. Check if something is selected. If not, then select the object.
          ;3. If something is selected, move the object.
        (begin 
          (update-message)
          (move-square mouse-x mouse-y))
         '()
         
        )
      (if (send event dragging?)
          (move-square mouse-x mouse-y)
          '()))
    ; Call the superclass init, passing on all init args
    (super-new)))
 
; Make a canvas that handles events in the frame
(define can (new my-canvas% [parent frame]
                 [paint-callback
              (lambda (canvas dc)
                ;(send dc set-scale 3 3)
                (send dc set-brush "red" 'solid)
                (send dc set-pen "black" 1 'solid)
                (send dc draw-rectangle 0 30 30 30); x y width height
                ;(send dc draw-rectangle 20 10 20 20)
             )]))

(send frame show #t)