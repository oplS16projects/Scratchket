#lang racket/gui
(require racket/gui/base)
(require racket/gui/base)
(require racket/draw)

;;;;;;; TO DO's for Kyle
; Add (display-list can) to deselection
; Add #f argument to the 3 create-obj calls in button clicking code
; 

;; Master list of objects
(define ls '())

;; Get procedures for data objects
(define (get-data obj)     (cdr obj))
(define (get-tag obj)      (caar obj))
(define (selected? obj)    (cadar obj))
(define (get-x obj)        (car (caddar obj)))
(define (get-y obj)        (cdr (caddar obj)))
(define (get-mylength obj) (caar (cdddar obj)))
(define (get-mywidth obj)  (cdar (cdddar obj)))

;;;;;;;
(define (menu-item? obj)   (cadddr (cdar obj))) 
;;;;;;;

(define (get-selected)
    (if (null? (filter (lambda (x) (selected? x)) ls))
        #f
        (car (filter (lambda (x) (selected? x))  ls))))
  
(define frame (new frame%
                   [label "Scratchket"]
                   [width 600]
                   [height 600]))

;; CREATE AN OBJECT AND RETURN IT
(define (create-obj tag selected pos size menu-item data)
  (cons (list tag selected pos size menu-item) data))

;; ADD AN OBJECT TO THE LIST
(define (add-obj-to-list obj)
  (set! ls (cons obj ls)))

;;;;;;;;;;;
;;;;;;;;;;;
;;;;;;;;;;;
;; ADD OBJECTS TO LIST FOR THE MENU
(define (initialize-list)
  (begin
    ; (create-obj tag selected pos size menu-item data)
    (set! ls '())
    (add-obj-to-list (create-obj 'primitive #f (cons 25 20)  (cons 30 30) #t 'red))
    (add-obj-to-list (create-obj 'primitive #f (cons 25 70)  (cons 30 30) #t 'green))
    (add-obj-to-list (create-obj 'primitive #f (cons 25 120) (cons 30 30) #t 'blue))
    (add-obj-to-list (create-obj 'primitive #f (cons 25 170) (cons 30 30) #t 'null))
    (add-obj-to-list (create-obj 'machine   #f (cons 10 220) (cons 60 60) #t 'cons))
    (add-obj-to-list (create-obj 'button    #f (cons 10 500) (cons 60 20) #t 'RESET))
    (add-obj-to-list (create-obj 'text      #f (cons 11 0)   (cons 20 20) #t 'MENU))))

(initialize-list)

;; OBJECTS FOR TESTING LIST
;(add-obj-to-list (create-obj 'primitive #f (cons 100 100) (cons 30 30) #f 'green))
;(add-obj-to-list (create-obj 'primitive #f (cons 150 150) (cons 30 30) #f 'red))
;(add-obj-to-list (create-obj 'primitive #f (cons 300 400) (cons 30 30) #f 'blue))
;;;;;;;;;;;;;
;;;;;;;;;;;;;


;; SEND A PRIMITIVE OBJECT TO THE DISPLAY
(define (send-primitive dc obj)
  (begin
    (let ((x (get-x obj))
          (y (get-y obj))
          (l (get-mylength obj))
          (w (get-mywidth  obj))
          (sym (get-data obj))
          (color (if (eq? (get-data obj) 'null)
                     "white"
                     (symbol->string (get-data obj)))))
      (send dc set-brush color 'solid)
      (if (selected? obj)
          (send dc set-pen "orange" 2 'solid)
          (send dc set-pen "black" 1 'solid))
      (send dc draw-rectangle x y l w)
      (send dc set-pen "black" 2 'solid)
      (if (eq? sym 'null)
          (send dc draw-line
                (+ x 1)  (+ y 29)
                (+ x 29) (+ y 1))
                
          '())
      )))

;; SEND A MACHINE OBJECT TO THE DISPLAY
(define (send-machine dc obj)
  (let ((x (get-x obj))
        (y (get-y obj))
        (l (get-mylength obj))
        (w (get-mywidth  obj)))
    (begin
      (send dc set-brush "gray" 'solid)
      (if (selected? obj)
          (send dc set-pen "orange" 2 'solid)
          (send dc set-pen "black" 1 'solid))
      (send dc draw-rectangle x y l w)
      (send dc draw-rectangle (+ x 9) y 41 16)
      (send dc draw-text " CONS" (+ x 9) y)
    
    )))

;; SEND A BUTTON OBJECT TO THE DISPLAY
(define (send-button dc obj)
  (let ((x (get-x obj))
        (y (get-y obj))
        (l (get-mylength obj))
        (w (get-mywidth  obj))
        (t (symbol->string (get-data obj))))
    (begin
      (send dc set-brush "yellow" 'solid)
      (send dc set-pen "black" 1 'solid)
      (send dc draw-rectangle x y l w)
      ;(send dc draw-rectangle (+ x 9) y 41 16)
      (send dc draw-text t (+ x 12) (+ y 3))
    )))

;; SEND A TEXT OBJECT TO THE DISPLAY
(define (send-text dc obj)
  (let ((x (get-x obj))
        (y (get-y obj))
        (l (get-mylength obj))
        (w (get-mywidth  obj))
        (t (symbol->string (get-data obj))))
    (begin
      (send dc set-brush "yellow" 'solid)
      (send dc set-pen "black" 1 'solid)
      ;(send dc draw-rectangle x y l w)
      ;(send dc draw-rectangle (+ x 9) y 41 16)
      (send dc draw-text t (+ x 12) (+ y 3))
    )))

;; DISPLAY THE CURRENT LIST IN THE CANVAS
(define (display-list canvas)
  (send canvas
        refresh-now
        (lambda (dc)
          (define (iter ls)
            (if (null? ls)
                (display 'done)
                (begin
                  (let ((tag (get-tag (car ls))))
                    (cond ((eq? tag 'primitive) (send-primitive dc (car ls)))
                          ((eq? tag 'machine  ) (send-machine   dc (car ls)))
                          ((eq? tag 'button   ) (send-button    dc (car ls)))
                          ((eq? tag 'text     ) (send-text     dc (car ls)))))
                  (iter (cdr ls)))))
          (iter ls)))
  ) ;; END OF DISPLAY-LIST

(define (move-square x y)
  (display-list can))
; Start of Kyle's code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define mouse-x 0)
(define mouse-y 0)


(define (in-range x)
  (and
   (<= (get-x x) mouse-x)
   (>= (+ (get-x x) (get-mywidth x)) mouse-x)
   (<= (get-y x) mouse-y)
   (>= (+ (get-y x) (get-mylength x)) mouse-y)))

(define (get-object-in-range)
  (let ((x (filter in-range ls)))
    (if (null? x)
        #f
        (car x))))

(define (get-objects-not-selected)
  (filter (lambda (x) (not (selected? x))) ls))

(define (all-but-in-range)
  (filter (lambda (x) (not (in-range x))) ls))


(define my-canvas%
  (class canvas% ; The base class is canvas%(send message set-label (string-append "Selected:     " (symbol->string (get-tag ())
    (inherit get-width get-height refresh)
    ; Define overriding method to handle mouse events

    (define message
      (new message%
         [label "Selected:     Nothing"]
         [parent frame]
         [min-width 100]
         [vert-margin 5]))

    ; Updates the message to the currently selected item
    (define update-message
         (lambda ()
           (let ((return (get-selected)))
           (send message set-label (string-append "Selected:     "
                                               (if (not (eq? return #f))
                                                   (string-append
                                                    (symbol->string
                                                     (get-tag return))
                                                    " : ")
                                                    "Nothing")
                                               (if (not (eq? return #f))
                                                   (symbol->string
                                                    (get-data return))
                                                   ""))))))


    
    (define/override (on-event event)
       ;Grab the x and y coords
      (set! mouse-x (send event get-x))
      (set! mouse-y (send event get-y))
      (let ((keep     (get-objects-not-selected))
            (change    (get-object-in-range))
            (selected (get-selected))
            (all-but  (all-but-in-range)))
        
        ; Creates new object if we select the menu item
          (define (menu-create-new)
            (let ((tag   (if change (get-tag change)      '()))
                  (x     (if change (get-x   change)      '()))
                  (y     (if change (get-y   change)      '()))
                  (l     (if change (get-mylength change) '()))
                  (w     (if change (get-mywidth change)  '()))
                  (data  (if change (get-data change)     '())))
              (begin (add-obj-to-list (create-obj tag #f (cons (+ x 130) y) (cons l w) #f data))
                     (display-list can))))

        ; Moves an object if it is selected
          (define (move-selected)
            (let ((tag  (get-tag      selected))
                  (x    (get-x        selected))
                  (y    (get-y        selected))
                  (l    (get-mylength selected))
                  (w    (get-mywidth  selected))
                  (data (get-data     selected)))
              (begin
                (set! ls (cons (create-obj tag #t (cons mouse-x mouse-y) (cons l w) #f data) keep))
                (display-list can))))

        ; Selects an item if nothing is selected
          (define (select-item)
            (let ((tag   (if change (get-tag change)      '()))
                  (x     (if change (get-x   change)      '()))
                  (y     (if change (get-y   change)      '()))
                  (l     (if change (get-mylength change) '()))
                  (w     (if change (get-mywidth change)  '()))
                  (data  (if change (get-data change)     '())))
              (begin
                (set! ls (cons (create-obj tag #t (cons x y) (cons l w) #f data) all-but))
                (display-list can))))

        ; Deselects a selected item
          (define (deselect-item)
            (let ((tag  (get-tag      selected))
                  (x    (get-x        selected))
                  (y    (get-y        selected))
                  (l    (get-mylength selected))
                  (w    (get-mywidth  selected))
                  (data (get-data     selected)))
              (begin
                (set! ls (cons (create-obj tag #f (cons x y) (cons l w) #f data) keep))
                (display-list can))))
          
          
          ; Did the user left click?
          (define (left-click?)
            (send event button-down? 'left))
          
          ; Did the user right click?
          (define (right-click?)
            (send event button-down? 'right))
          
          ; What occurs when the left click is pressed
          (define (left-click-action)
            (cond
              ; If something is selected, move it.
              (selected (move-selected))
              ; If someting is in range of the mouse and is the reset button,
              ; reset the list and refresh the canvas
              ((and change (menu-item? change) (eq? 'RESET (get-data change)))
               (begin
                 (initialize-list)
                 (display-list can)))
              ; If something is in range of the mouse and is a menu item, create a new object
              ((and change (menu-item? change)) (menu-create-new))
              ; If nothing is selected, but something is in range, select it.
              (change    (begin
                           (select-item)
                           (update-message)))))
          
          
          (define (right-click-action)
            ; If something is selected, deselect it
            (cond (selected (begin
                              (deselect-item)
                              (update-message)))))
          
         
          ; If the user left clicks, take the left click action
          ; If the user right clicks, take the right click action
          (cond ((left-click?)  (left-click-action))
                ((right-click?) (right-click-action)))
         
          
          
         ; ) ; END of let
    )) ;END let and define/override

; Call the superclass init, passing on all init args
(super-new))) 

; Make a canvas that handles events in the frame
(define can (new my-canvas%
                 [parent frame]
                 [paint-callback
                  (lambda (canvas dc)
                    (display-list can)
                    )
]
                 ))
(display-list can)
(send frame show #t)
(display-list can)

;;; DISP-MENU
;;; send the menu with primitive types to the canvas
;(define (disp-menu dc)
;          ;Display red block
;          (send dc set-brush "red" 'solid)
;          (send dc set-pen "black" 1 'solid)
;          (send dc draw-rectangle 20 20 30 30)
;          ;Display green block
;          (send dc set-brush "green" 'solid)
;          (send dc set-pen "black" 1 'solid)
;          (send dc draw-rectangle 20 70 30 30)
;          ;Display blue block
;          (send dc set-brush "blue" 'solid)
;          (send dc set-pen "black" 1 'solid)
;          (send dc draw-rectangle 20 120 30 30)
;  ) ;; END OF DISP-MENU