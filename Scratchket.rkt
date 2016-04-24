#lang racket/gui
(require racket/gui/base)
(require racket/gui/base)
(require racket/draw)

;; Create an object and return it
(define (create-obj tag selected pos size menu-item input data)
  (cons (list tag selected pos size menu-item input) data))

;; Nil obj
(define nil-obj (create-obj 'primitive #f (cons 25 170) (cons 30 30) #t '() 'null))

;; Master list of objects
(define ls '())

;; Get procedures for data objects
(define (get-data obj)     (cdr obj))
(define (get-tag obj)      (caar obj))
(define (selected? obj)    (cadar obj))
(define (get-x obj)        (car (caddar obj)))
(define (get-y obj)        (cdr (caddar obj)))
(define (get-mylength obj) (cdar (cdddar obj)))
(define (get-mywidth obj)  (caar (cdddar obj)))
(define (menu-item? obj)   (cadddr (cdar obj)))
(define (get-input  obj)   (cadddr (cddar obj)))

(define (count-inputs obj)
  (define (iter count lst)
    (if (null? lst)
        count
        (iter (+ count 1) (cdr lst))))
  (iter 0 (get-input obj)))

(define (get-machines)
  (if (null? (filter (lambda (x) (eq? (get-tag x) 'machine)) ls))
             #f
             (filter (lambda (x) (eq? (get-tag x) 'machine)) ls)))

(define (get-non-machines)
  (let ((non-machines (filter (lambda (x) (not (eq? (get-tag x) 'machine))) ls)))
    (if (null? non-machines)
        #f
        non-machines)))


(define (get-selected)
    (if (null? (filter (lambda (x) (selected? x)) ls))
        #f
        (car (filter (lambda (x) (selected? x))  ls))))
  
(define frame (new frame%
                   [label "Scratchket"]
                   [width 600]
                   [height 600]))

(define (get-machine-in-range)
  (define (iter machines)
    (cond ((null? machines) 'ERROR)
          ((in-range (car machines)) (car machines))
          (else (iter (cdr machines)))))
  (iter (get-machines)))
  
  
  (define (get-cons-size obj)
  (let ((siz1 (get-size (car  (get-input obj))))
        (siz2 (get-size (cadr (get-input obj)))))
          (let ((x1 (car  siz1))
                (x2 (car  siz2))
                (y1 (cdr siz1))
                (y2 (cdr siz2)))
            (cons (+ x1 x2) (if (> y1 y2)
                                y1
                                y2)))))

(define (get-size obj)
  (cond ((eq? (get-tag obj) 'primitive) (cons 30 30))
        ((eq? (get-tag obj) 'cons     ) (get-cons-size obj))
        ((eq? (get-tag obj) 'list     ) 30)))

(define (calc-size lst)
  (define (iter width height lst)
    (if (null? lst)
        (cons width height)
        (iter (+ width (get-mywidth (car lst))) (get-mylength (car lst)) (cdr lst))))
  (iter 0 0 lst))
  

; Create a cons object
(define (create-cons pos in)
  (create-obj 'cons #f pos (calc-size in) #f in 'cons))

(define create-list create-cons)

;; ADD AN OBJECT TO THE LIST
(define (add-obj-to-list obj)
  (set! ls (cons obj ls)))
  
;; Add input to a machine - returns #f if unable to add input or
;;                          returns a new machine with the input added to the machine.
(define (add-input-to-machine machine input lst)
  (let ((tag (get-tag      machine))
        (sel (selected?    machine))
        (x   (get-x        machine))
        (y   (get-y        machine))
        (w   (get-mywidth  machine))
        (l   (get-mylength machine))
        (men (menu-item?   machine))
        (dat (get-data     machine))
        (in  (get-input    machine)))
    (cond ((and (eq? dat 'cons)
                (< (count-inputs machine) 2)) (begin
                                                (set! ls (cons (create-obj tag sel (cons x y) (cons w l) men (cons input in) dat) lst))
                                                #t))
          ((eq? dat 'list) (begin
                             (set! ls (cons (create-obj tag sel (cons x y) (cons w l) men (cons input in) dat) lst))
                             #t))
          (else #f))))


;; ADD OBJECTS TO LIST FOR THE MENU
(define (initialize-list)
  (begin
    ; (create-obj tag selected pos size menu-item data)
    (set! ls '())
    (add-obj-to-list (create-obj 'primitive #f (cons 25 20)  (cons 30 30) #t '() 'red))
    (add-obj-to-list (create-obj 'primitive #f (cons 25 70)  (cons 30 30) #t '() 'green))
    (add-obj-to-list (create-obj 'primitive #f (cons 25 120) (cons 30 30) #t '() 'blue))
    (add-obj-to-list (create-obj 'primitive #f (cons 25 170) (cons 30 30) #t '() 'null))
    (add-obj-to-list (create-obj 'machine   #f (cons 10 220) (cons 60 60) #t '() 'cons))
    (add-obj-to-list (create-obj 'machine   #f (cons 10 290) (cons 60 60) #t '() 'list))
    (add-obj-to-list (create-obj 'button    #f (cons 10 500) (cons 60 20) #t '() 'RESET))
    (add-obj-to-list (create-obj 'button    #f (cons 10 400) (cons 60 20) #t '() 'PROCESS))
    (add-obj-to-list (create-obj 'text      #f (cons 11 0)   (cons 20 20) #t '() 'MENU))))

(initialize-list)

;; OBJECTS FOR TESTING LIST
;(add-obj-to-list (create-obj 'primitive #f (cons 100 100) (cons 30 30) #f '() 'green))
;(add-obj-to-list (create-obj 'primitive #f (cons 150 150) (cons 30 30) #f '() 'red))
;(add-obj-to-list (create-obj 'primitive #f (cons 300 400) (cons 30 30) #f '() 'blue))
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
      (send dc draw-rectangle x y w l)
      (send dc set-pen "black" 2 'solid)
      (if (eq? sym 'null)
          (send dc draw-line
                (+ x 1)  (+ y 29)
                (+ x 29) (+ y 1))
          '())
      )))

;; Send a cons cell to the screen
(define (send-cons dc obj x y)
  (let ((w    (car (get-size obj)))
        (l    (cdr (get-size obj)))
        (obj1 (car  (get-input obj)))
        (obj2 (cadr (get-input obj)))
        (sel  (selected? obj)))
    (begin
      (cond ((eq? (get-tag obj1) 'primitive) (send-cons-obj dc obj1 sel x y))
            ((eq? (get-tag obj1) 'cons     ) (send-cons     dc obj1)))
      (cond ((eq? (get-tag obj2) 'primitive) (send-cons-obj dc obj2 sel (+ x (car (get-size obj1))) y))
            ((eq? (get-tag obj2) 'cons     ) (send-cons     dc obj2))))
    )) ;End let, end define.


(define (send-cons-obj dc obj select x y)
  (send-primitive dc (create-obj 'primitive select (cons x y)  (cons 30 30) #f '() (get-data obj))))



(define (send-list dc obj)
  (define (iter remaining)
    (let ((x (get-x remaining))
          (y (get-y remaining))
          (obj1 (car get-input remaining))
          (sel (selected? remaining)))
      (begin
        (if (eq? 'primitive (get-tag obj1))
            (send-cons-prim dc obj1 sel x y)
            '()) ;print complex obj
        (if (null? remaining)
            '()
            (iter (cdr remaining)))
        #t)))
  (iter obj))

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
      (send dc draw-rectangle x y w l)
      (send dc draw-rectangle (+ x 9) y 41 16)
      (send dc set-font (make-font #:size 12
                                   #:family 'roman
                                   #:weight 'bold
                                   #:size-in-pixels? #t))
      (cond ((eq? (get-data obj) 'cons) (send dc draw-text "CONS" (+ x 10) (+ y 2)))
             ((eq? (get-data obj) 'list) (send dc draw-text "LIST" (+ x 10) (+ y 2))))
             
      (send dc set-brush "yellow" 'solid)
      (if (eq? (get-data obj) 'cons)
          (cond ((= (count-inputs obj) 0) '())
                ((= (count-inputs obj) 1)
                 (send dc draw-rectangle (+ x 13) (+ y 40) 10 10))
                (else 
                 (begin
                   (send dc draw-rectangle (+ x 13) (+ y 40) 10 10)
                   (send dc draw-rectangle (+ x 36) (+ y 40) 10 10))))
          '())
            
    ))) ; End of send-machine

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
      (send dc draw-rectangle x y w l)
      (send dc set-font (make-font #:size 12
                                   #:family 'roman
                                   #:weight 'bold
                                   #:size-in-pixels? #t))
      (send dc draw-text t (+ x 8) (+ y 4))
    ))) ; End of send-button

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
      (send dc set-font (make-font #:size 14 #:family 'roman
                             #:weight 'bold
                             #:size-in-pixels? #t))
      (send dc draw-text t (+ x 10) (+ y 3))
    ))) ;End of send-text

;; DISPLAY THE CURRENT LIST IN THE CANVAS
(define (display-list canvas)
  (send canvas
        refresh-now
        (lambda (dc)
          (define (iter ls)
            (if (null? ls)
                '()
                (begin
                  (let ((tag (get-tag (car ls))))
                    (cond ((eq? tag 'primitive) (send-primitive dc (car ls)))
                          ((eq? tag 'cons     ) (send-cons      dc (car ls)))
                          ((eq? tag 'machine  ) (send-machine   dc (car ls)))
                          ((eq? tag 'button   ) (send-button    dc (car ls)))
                          ((eq? tag 'text     ) (send-text      dc (car ls)))))
                  (iter (cdr ls)))))
          (iter ls)))
  ) ;; END OF DISPLAY-LIST

;(define (move-square x y)
;  (display-list can))

; Start of Kyle's code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define mouse-x 0)
(define mouse-y 0)

(define (in-range x)
  (if (eq? 'ERROR x)
      #f
      (and
       (<= (get-x x) mouse-x)
       (>= (+ (get-x x) (get-mywidth x)) mouse-x)
       (<= (get-y x) mouse-y)
       (>= (+ (get-y x) (get-mylength x)) mouse-y))))

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
  (class canvas% 
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
              (begin (add-obj-to-list (create-obj tag #f (cons (+ x 130) y) (cons l w) #f '() data))
                     (display-list can))))

        ; Determines if something selected should be added as input to the cons machine
        (define (add-as-cons-input?)
          (if (and selected change (eq? 'machine (get-tag change)) (eq? 'cons (get-data change)))
              #t
              #f))
        ; Determines if something selected should be added as input to the list machine
        (define (add-as-list-input?)
          (if (and selected change (eq? 'machine (get-tag change)) (eq? 'list (get-data change)))
              #t
              #f))

        ; Moves an object if it is selected
          (define (move-selected)
            (let ((tag  (get-tag      selected))
                  (x    (get-x        selected))
                  (y    (get-y        selected))
                  (l    (get-mylength selected))
                  (w    (get-mywidth  selected))
                  (data (get-data     selected)))
              (begin
                (cond ((add-as-cons-input?) (if (add-input-to-machine change selected (filter (lambda (x) (not (in-range x))) keep))
                                                (display "Added input to the cons machine")
                                                (display "ERROR: You can't add more than 2 inputs to a cons machine")))
                      ((add-as-list-input?) (if (add-input-to-machine change selected (filter (lambda (x) (not (in-range x))) keep))
                                                (display "Added input to the list machine")
                                                (display "ERROR: You can't add more than 2 inputs to a list machine")))
                      (else (set! ls (cons (create-obj tag #t (cons mouse-x mouse-y) (cons l w) #f (get-input selected) data) keep))))
                
              (update-message)
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
                (set! ls (cons (create-obj tag #t (cons x y) (cons l w) #f (get-input change) data) all-but))
                (display-list can)
                (update-message))))

        ; Deselects a selected item
          (define (deselect-item)
            (let ((tag  (get-tag      selected))
                  (x    (get-x        selected))
                  (y    (get-y        selected))
                  (l    (get-mylength selected))
                  (w    (get-mywidth  selected))
                  (data (get-data     selected)))
              (begin
                (set! ls (cons (create-obj tag #f (cons x y) (cons l w) #f (get-input selected) data) keep))
                (display-list can)
                (update-message))))

        ; Was the reset button hit?
        (define (reset?)
          (and change (menu-item? change) (eq? 'RESET (get-data change))))

        ; Reset all objects to original state
        (define (reset)
          (begin
            (initialize-list)
            (display-list can)))

        ; Do you want to duplicate a menu item?
        (define (dup-menu-item?)
          (and change (menu-item? change)))

        ;Was the process button pushed?
        (define (process?)
          (and change (menu-item? change) (eq? 'PROCESS (get-data change))))

        (define (process non-machines machines)
          (begin
            (set! ls non-machines)
            (define (iter machines)
              (if (null? machines)
                  '()
                  (let ((tag   (get-tag      (car machines)))
                        (x     (get-x        (car machines)))
                        (y     (get-y        (car machines)))
                        (l     (get-mylength (car machines)))
                        (w     (get-mywidth  (car machines)))
                        (data  (get-data     (car machines)))
                        (sel   (selected?    (car machines)))
                        (menu  (menu-item?   (car machines)))
                        (in    (get-input    (car machines)))
                        (numin (count-inputs (car machines)))
                        (list  (if (and (not (null? (get-input (car machines)))) (equal? (car (get-input (car machines))) nil-obj))
                                   #t
                                   #f)))
                    (begin
                      (cond ((and (eq? data 'cons) (= numin 2)) (begin
                                                                  (display "first cond!")
                                                                  (add-obj-to-list (create-obj tag sel  (cons x y)  (cons w l) menu '() data))
                                                                  (if list
                                                                      (add-obj-to-list (create-list (cons (+ x 80) y) in))
                                                                      (add-obj-to-list (create-cons (cons (+ x 80) y) in)))
                                                                  (display-list can)))
                            ((and (eq? data 'list) (> numin 0) (begin
                                                                 (add-obj-to-list (create-obj tag sel (cons x y) (cons w l) menu '() data))
                                                                 (if list
                                                                     (add-obj-to-list (create-list (cons (+ x 80) y) in))
                                                                     (add-obj-to-list (create-cons (cons (+ x 80) y) in)))
                                                                 (display-list can))))
                                                                 
                            (else
                             (begin
                               (add-obj-to-list (create-obj tag sel  (cons x y)  (cons w l) menu '() data))
                               (display "second cond!")
                               (display-list can))))
                      (iter (cdr machines))))))
            
            (iter machines)))
            
            
          ; Did the user left click?
          (define (left-click?)
            (send event button-down? 'left))
          
          ; Did the user right click?
          (define (right-click?)
            (send event button-down? 'right))
          
          ; What occurs when the left click is pressed
          (define (left-click-action)
            (cond
              (selected (move-selected))
              ((reset?) (reset))
              ((process?) (process (get-non-machines) (get-machines)))
              ((dup-menu-item?) (menu-create-new))
              ; If nothing is selected, but something is in range, select it.
              (change (select-item))))
          
          
          (define (right-click-action)
            ; If something is selected, deselect it
            (cond (selected (deselect-item))))
          
         
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
