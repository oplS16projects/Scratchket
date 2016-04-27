#lang racket/gui
(require racket/gui/base)
(require racket/gui/base)
(require racket/draw)

(define space    8)
(define whitebar 2)
(define blackbar 4)
(define bars (+ blackbar whitebar))

;; Create an object and return it
(define (create-obj tag selected pos size menu-item input data)
  (cons (list tag selected pos size menu-item input) data))

;; Nil obj
(define nil-obj (create-obj 'primitive #f (cons 25 170) (cons 30 30) #t '() 'null))
(define ptr     (create-obj 'arrow     #f (cons 25 170) (cons 30 30) #t '() 'arrow))

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
                   [height 660]))

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
            (cons (+ x1 x2 bars bars space) (if (> y1 y2)
                                (+ y1 12)
                                (+ y2 12))))))
;
;(define (calc-list-size inputs)
;  (define (iter lst w l)
;    (if (null? lst)
;        (cons (+ (* (- (length inputs) 1) 36) w) l)
;        (iter (cdr lst) (+ w (get-mywidth (car lst)) 30) (if (> l (get-mylength (car lst)))
;                                                          l
;                                                          (+ (get-mylength (car lst)) 12)))))
;  (iter inputs 0 0))



(define (calc-list-size inputs)
  (define (iter lst w l)
    (if (null? lst)
        (cons (- w 36) l)
        (begin
          (let ((next (get-size (create-cons #f (cons 0 0) (list (car lst) ptr)))))
            (iter (cdr lst) (+ w (car next) 36) (if (> l (cdr next))
                                                    l
                                                    (cdr next)))))))
  (iter inputs 0 0))


(define (get-list-size obj)
  (calc-list-size (get-input obj)))
        

(define (get-size obj)
  (cond ((eq? (get-tag obj) 'primitive) (cons 30 30))
        ((eq? (get-tag obj) 'arrow    ) (cons 30 30))
        ((eq? (get-tag obj) 'cons     ) (get-cons-size obj))
        ((eq? (get-tag obj) 'list     ) (get-list-size obj))))

(define (calc-size lst)
  (define (iter width height lst)
    (if (null? lst)
        (cons (+ width bars space bars) (+ height 12))
        (iter (+ width (get-mywidth (car lst))) (get-mylength (car lst)) (cdr lst))))
  (iter 0 0 lst))


;; Returns #t if object is a list, otherwise #f
(define (is-really-list? lst)
  (if (= (length lst) 2)
      (let ((obj1 (car  lst))
            (obj2 (cadr lst)))
        (cond ((eq? 'list (get-data obj2)) #t)
              ((eq? 'null (get-data obj2)) #t)
              (else #f)))
      #f))

; Create a cons object
(define (create-cons sel pos in)
  (create-obj 'cons sel pos (calc-size in) #f in 'cons))


; Create a list object
(define (create-list pos in)
  (create-obj 'list #f pos (calc-list-size in) #f in 'list))

;; Add an object to the master list
(define (add-obj-to-list obj)
  (set! ls (cons obj ls)))


(define (deselect obj)
  (let ((tag (get-tag      obj))
        (sel (selected?    obj))
        (x   (get-x        obj))
        (y   (get-y        obj))
        (w   (get-mywidth  obj))
        (l   (get-mylength obj))
        (men (menu-item?   obj))
        (dat (get-data     obj))
        (in  (get-input    obj)))
    (create-obj tag #f (cons x y) (cons w l) men in dat)))

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
    (if (or men (eq? (get-tag input) 'machine))
        #f
        (cond ((and (eq? dat 'cons)
                    (< (count-inputs machine) 2))(begin
                                                   (set! ls (cons (create-obj tag #f (cons x y) (cons w l) men (append in (list (deselect input))) dat) lst))
                                                   #t))
              ((eq? dat 'list) (begin
                                 (set! ls (cons (create-obj tag #f (cons x y) (cons w l) men (append in (list (deselect input))) dat) lst))
                                 #t))
              ((and (or (eq? dat 'car) (eq? dat 'cdr))
                    (or (eq? (get-tag input) 'list) (eq? (get-tag input) 'cons))
                    (= (count-inputs machine) 0))(begin
                                                   (set! ls (cons (create-obj tag #f (cons x y) (cons w l) men (append in (list (deselect input))) dat) lst))
                                                   #t))
              (else #f)))))


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
    (add-obj-to-list (create-obj 'machine   #f (cons 10 300) (cons 60 60) #t '() 'list))
    (add-obj-to-list (create-obj 'machine   #f (cons 10 380) (cons 60 60) #t '() 'car))
    (add-obj-to-list (create-obj 'machine   #f (cons 10 460) (cons 60 60) #t '() 'cdr))
    (add-obj-to-list (create-obj 'button    #f (cons 10 580) (cons 60 20) #t '() 'RESET))
    (add-obj-to-list (create-obj 'button    #f (cons 10 540) (cons 60 20) #t '() 'PROCESS))
    (add-obj-to-list (create-obj 'text      #f (cons 11 0)   (cons 20 20) #t '() 'MENU))))

(initialize-list)



;; Send a primitive to the display
(define (send-primitive dc obj x y)
  (begin
    (let ((w (get-mywidth  obj))
          (l (get-mylength obj))
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


;; Send an arrow to the display
(define (send-arrow dc obj x y)
  (begin
    ;(send dc set-brush "black" 'solid)
    (send dc set-pen "black" 2 'solid)
    (send dc draw-line x y (+ x 51) y) ;horizontal line
    (send dc draw-line (+ x 31)  (+ y 15) (+ x 51) y)
    (send dc draw-line (+ x 31)  (- y 15) (+ x 51) y)))


;; Send a cons cell to the screen
(define (send-cons dc obj x y)
  (let ((w    (car (get-size obj)))
        (l    (cdr (get-size obj)))
        (obj1 (car  (get-input obj)))
        (obj2 (cadr (get-input obj)))
        (sel  (selected? obj)))
    (begin
      ; If the cons cell is selected, highlight it.
      (cond (sel (begin
                   (send dc set-pen "white" 0 'transparent)
                   (send dc set-brush "orange" 'solid)
                   (send dc draw-rectangle (- x 2) (- y 2) (+ w 4) (+ l 4)))))
      ; Display cons structure (parens and dot)
      (send-cons-cell dc obj x y w l)
      (send dc set-brush "black" 'solid)
      
      ; Display car of cons cell
      (cond ((eq? (get-tag obj1) 'primitive) (send-primitive dc obj1 (+ x bars) (+ y 6)))
            ((eq? (get-tag obj1) 'cons     ) (send-cons      dc obj1 (+ x bars) (+ y 6)))
            ((eq? (get-tag obj1) 'list     ) (send-list      dc obj1 (+ x bars) (+ y 6))))
      
      ; Display cdr of cons cell
      (cond ((eq? (get-tag obj2) 'primitive) (send-primitive dc obj2 (+ x bars space (car (get-size obj1))) (+ y 6)))
            ((eq? (get-tag obj2) 'cons     ) (send-cons      dc obj2 (+ x bars space (car (get-size obj1))) (+ y 6)))
            ((eq? (get-tag obj2) 'list     ) (send-list      dc obj2 (+ x bars space (car (get-size obj1))) (+ y 6)))
            ((eq? (get-tag obj2) 'arrow    ) (send-arrow     dc obj2 (+ x bars space (car (get-size obj1)) 15) (+ y 6 15)))))
    )) ;End let, end define.


(define (send-cons-cell dc obj x y w l)
  (begin
    (send dc set-pen "white" 0 'transparent)
    (send dc set-brush "black" 'solid)
    ; top bar
    (send dc draw-rectangle x y w 4)
    ; bottom bar
    (send dc draw-rectangle x (- (+ y l) 4) w 4)
    ; center bar
    (send dc draw-rectangle (+ x bars (car (get-size (car (get-input obj)))) 2) y 4 l)
    ; side bars
    (send dc draw-rectangle    x      y blackbar l)
    (send dc draw-rectangle (- (+ x w) blackbar) y blackbar l)))


;; Send a list to the screen
(define (send-list dc obj x y)
  (define (iter dc lst sel x y)
;    (cond (sel
;           (begin
;             (define list-size (calc-list-size (get-input obj)))
;             (send dc set-pen "white" 0 'transparent)
;             (send dc set-brush "orange" 'solid)
;             (send dc draw-rectangle (- x 2) (- y 2) (+ (car list-size) 4) (+ (cdr list-size) 4)))))
          ; If the list is not null and this isn't the last element
          ; display the car and an arrow to the next obj
    (cond ((>= (length lst) 2)
           (begin
             (define cons-obj (create-cons sel (cons x y) (list (car lst) ptr)))
             (define next     (car (get-size cons-obj)))
             (send-cons dc cons-obj x y)
             (iter dc (cdr lst) sel (+ x next 36) y)))
          ; If the list is not null and this IS the last element
          ; display the car and a null ptr in the cdr
          ((= (length lst) 1)
           (begin
             (define cons-obj (create-cons sel (cons x y) (list (car lst) nil-obj))) 
             (define next     (car (get-size cons-obj)))
             (send-cons dc cons-obj x y)
             (iter dc (cdr lst) sel (+ x next 36) y)))))
  (iter dc (get-input obj) (selected? obj) x y))
           


;; SEND A MACHINE OBJECT TO THE DISPLAY
(define (send-machine dc obj)
  (let ((x (get-x obj))
        (y (get-y obj))
        (l (get-mylength obj))
        (w (get-mywidth  obj))
        (d (get-data     obj)))
    (begin
      (send dc set-brush "gray" 'solid)
      (if (selected? obj)
          (send dc set-pen "orange" 2 'solid)
          (send dc set-pen "black" 1 'solid))
      (send dc draw-rectangle x y w l)
      (send dc draw-rectangle x y w 16)
      (send dc set-font (make-font #:size 12
                                   #:family 'roman
                                   #:weight 'bold
                                   #:size-in-pixels? #t))
      (cond ((eq? d 'cons) (send dc draw-text "CONS" (+ x 10) (+ y 2)))
            ((eq? d 'list) (send dc draw-text "LIST" (+ x 10) (+ y 2)))
            ((eq? d 'car)  (send dc draw-text "CAR" (+ x 10) (+ y 2)))
            ((eq? d 'cdr)  (send dc draw-text "CDR" (+ x 10) (+ y 2))))
             
      (send dc set-brush "yellow" 'solid)
      (send dc set-font (make-font #:size 14
                                   #:family 'roman
                                   #:weight 'bold
                                   #:size-in-pixels? #t))
      (send dc draw-text "IN:" (+ x 15) (+ y 40))
      (send dc set-text-foreground "yellow")
     
;      (if (eq? (get-data obj) 'cons)
;          (cond ((= (count-inputs obj) 0) '())
;                ((= (count-inputs obj) 1)
;                 (send dc draw-rectangle (+ x 13) (+ y 40) 10 10))
;                (else 
;                 (begin
;                   (send dc draw-rectangle (+ x 13) (+ y 40) 10 10)
;                   (send dc draw-rectangle (+ x 36) (+ y 40) 10 10))))
      ;          '())
      (send dc draw-text (number->string (count-inputs obj)) (+ x 40) (+ y 40))
      (send dc set-text-foreground "black"))
    )) ; End of send-machine

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
      (send dc set-font (make-font #:size 10
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
      
      (send dc draw-text t (+ x 10) (+ y 3)))       
    )) ;End of send-text

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
                    (cond ((eq? tag 'primitive) (send-primitive dc (car ls) (get-x (car ls)) (get-y (car ls))))
                          ((eq? tag 'cons     ) (send-cons      dc (car ls) (get-x (car ls)) (get-y (car ls))))
                          ((eq? tag 'list     ) (send-list      dc (car ls) (get-x (car ls)) (get-y (car ls))))
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

(define (get-other-objects-in-range)
  (let ((x (filter in-range ls)))
    (if (null? x)
        '()
        (cdr x))))

(define (get-objects-not-selected)
  (filter (lambda (x) (not (selected? x))) ls))

(define (all-but-in-range)
  (filter (lambda (x) (not (in-range x))) ls))

(define (slist->string slst)
  (string-join (map (lambda (x) (string-append (symbol->string (get-data x)) ", ")) slst) " "))

(define (mylist->string object-lst)
    (if (null? object-lst) 
        " null"
        (if (null? (get-input object-lst))
            "nothing"
            (string-append (slist->string (get-input object-lst)) " null "))))

(define my-canvas%
  (class canvas% 
    (define message
      (new message%
         [label "Use left click to select, right click to deselect"]
         [parent frame]
         [min-width 100]
         [auto-resize #t]
         [vert-margin 5]))

    ; Updates the message to the currently selected item
    (define update-message
         (lambda ()
           (let ((return (get-selected)))
             (cond
               ((eq? return #f) (send message set-label "Use left click to select, right click to deselect"))
               ((and (eq? (get-data return) 'cons) (eq? (get-tag return) 'machine)) (send message set-label (string-append "Selected: Cons machine, containing: "
                                                                                     (cond ((null? (get-input return)) "[nothing]")
                                                                                           ((if (eqv? (count-inputs return) 1)
                                                                                               (string-append "["
                                                                                                              (symbol->string (get-data (car (get-input return))))
                                                                                                              "]")
                                                                                               (string-append "["
                                                                                                              (symbol->string (get-data (car (get-input return))))
                                                                                                              ", "
                                                                                                              (symbol->string (get-data (cadr (get-input return))))
                                                                                                              "]")))
                                                                                           (else "Unknown")))))
               ((and (eq? (get-data return) 'list) (eq? (get-tag return) 'machine)) (send message set-label
                                                                                          (string-append "Selected: List machine, containing: ["
                                                                                                         (mylist->string return)
                                                                                                         "]")))
                                                                                                         
               ((eq? (get-tag return) 'primitive) (send message set-label
                                                        (string-append "Selected: Primitive object, containing: ["
                                                                       (symbol->string (get-data return))
                                                                       "]")))
                                                         
               (else (send message set-label
                           (string-append "Selected:     "
                                          (if (not (eq? return #f))
                                              (string-append
                                               (symbol->string
                                                (get-tag return))
                                               " : ") "")                                                  
                                          (if (not (eq? return #f))
                                              (symbol->string
                                               (get-data return))
                                              ""))))))))

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
              (begin (add-obj-to-list (create-obj tag #f (cons (+ x 130) y) (cons w l) #f '() data))
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

        ; Determines if something selected should be added as input to the car or cdr machine
        (define (add-as-cadr-input?)
          (if (and selected change (eq? 'machine (get-tag change)) (or (eq? 'car (get-data change)) (eq? 'cdr (get-data change))))
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
                                                (display "Added input to the cons machine\n")
                                                (display "ERROR: Unable to add input\n")))
                      ((add-as-list-input?) (if (add-input-to-machine change selected (filter (lambda (x) (not (in-range x))) keep))
                                                (display "Added input to the list machine\n")
                                                (display "ERROR: Unable to add input.\n")))
                      ((add-as-cadr-input?) (if (add-input-to-machine change selected (filter (lambda (x) (not (in-range x))) keep))
                                                (display "Added input to car or cdr machine\n")
                                                (display "ERROR: Unable to add input.\n")))
                      (else (set! ls (cons (create-obj tag #t (cons mouse-x mouse-y) (cons w l) #f (get-input selected) data) keep))))
                
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
                (set! ls (cons (create-obj tag #t (cons x y) (cons w l) #f (get-input change) data) (append all-but (get-other-objects-in-range))))
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
                (set! ls (cons (create-obj tag #f (cons x y) (cons w l) #f (get-input selected) data) keep))
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

        ; Process the inputs into the machines
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
                        (numin (count-inputs (car machines))))
                    (begin
                      ; If the machine is a cons, process as a cons
                      (cond ((and (eq? data 'cons) (= numin 2)) (begin
                                                                  ; Add the machine back, minus the inputs
                                                                  (add-obj-to-list (create-obj tag sel  (cons x y)  (cons w l) menu '() data))
                                                                  (display "1\n")
                                                                  (cond
                                                                    ; If the cons is really a list because the cdr is the null list
                                                                    ((and (is-really-list? in) (eq? (get-data (cadr in)) 'null))
                                                                     (add-obj-to-list (create-list (cons (+ x 80) y) (list (car in)))))
                                                                    ; If the cons is really a list because you're consing something to a list.
                                                                    ((is-really-list? in)
                                                                     (add-obj-to-list (create-list (cons (+ x 80) y) (append (list (car in)) (get-input (cadr in))))))
                                                                    ; Else create a cons.
                                                                    (else (add-obj-to-list (create-cons #f (cons (+ x 80) y) in))))
                                                                  (display-list can)))
                            ; If the machine is a list, process as a list.
                            ((and (eq? data 'list) (> numin 0)) (begin
                                                                 ; Add the machine back, minus the inputs
                                                                 (add-obj-to-list (create-obj tag sel (cons x y) (cons w l) menu '() data))
                                                                 ; Add a new list obj to the master list
                                                                 (add-obj-to-list (create-list (cons (+ x 80) y) in))
                                                                 (display-list can)))
                            ; If the machine is a car, process as a car
                            ((and (eq? data 'car) (= numin 1)) (begin
                                                                 (let ((obj (car (get-input (car in)))))
                                                                   (let ((tag1   (get-tag        obj))
                                                                         (l1     (get-mylength   obj))
                                                                         (w1     (get-mywidth    obj))
                                                                         (data1  (get-data       obj))
                                                                         (sel1   (selected?      obj))
                                                                         (menu1  (menu-item?     obj))
                                                                         (in1    (get-input      obj)))
                                                                     ; Add the machine back, minus the inputs
                                                                     (add-obj-to-list (create-obj tag sel (cons x y) (cons w l) menu '() data))
                                                                     ; Add a new list obj to the master list
                                                                     (add-obj-to-list (create-obj tag1 sel1 (cons (+ x 80) y) (cons w1 l1) menu1 in1 data1))
                                                                     (display-list can)))))
                            ; If the machine is a cdr, process as a cdr
                            ((and (eq? data 'cdr) (= numin 1)) (if (eq? 'list (get-tag (get-input (car in))))
                                                                   (cond
                                                                     ; If the input is a list of 1 thing, return null
                                                                     ((= (length (get-input (car in))) 1)
                                                                      (begin
                                                                        ; Add the machine back, minus the inputs
                                                                        (add-obj-to-list (create-obj tag sel (cons x y) (cons w l) menu '() data))
                                                                        ; Return the null list
                                                                        (add-obj-to-list (create-obj 'primitive #f (cons (+ x 80) y) (cons 30 30) #f '() 'null))
                                                                        (display-list can)))
                                                                     ((>= (length (get-input (car in))) 2)
                                                                      (begin
                                                                        ; Add the machine back, minus the inputs
                                                                        (add-obj-to-list (create-obj tag sel (cons x y) (cons w l) menu '() data))
                                                                        ; Create a new list containing the cdr of the input lst
                                                                        (add-obj-to-list (create-list (cons (+ x 80) y) (cdr (get-input (car in))))))
                                                                      ))
                                                                   ; Else this is a cons, return the cdr of the cons
                                                                   (begin
                                                                     (let ((obj (cadr (get-input (car in)))))
                                                                       (let ((tag1   (get-tag        obj))
                                                                             (l1     (get-mylength   obj))
                                                                             (w1     (get-mywidth    obj))
                                                                             (data1  (get-data       obj))
                                                                             (sel1   (selected?      obj))
                                                                             (menu1  (menu-item?     obj))
                                                                             (in1    (get-input      obj)))
                                                                     ; Add the machine back, minus the inputs
                                                                     (add-obj-to-list (create-obj tag sel (cons x y) (cons w l) menu '() data))
                                                                     ; Return the cdr of the cons
                                                                     (add-obj-to-list (create-obj tag1 #f (cons (+ x 80) y) (cons w1 l1) #f in1 data1)))))
                                                                 ))
                                                                      
;                                                                   (let ((obj (cdr (get-input (car in))))
;                                                                         (t (get-tag (car in))))
;                                                                     
;                                                                     (begin
;                                                                       (display obj)
;                                                                       ; Add the machine back, minus the inputs
;                                                                       (add-obj-to-list (create-obj tag sel (cons x y) (cons w l) menu '() data))
;                                                                       ; Add a new list obj to the master list
;                                                                       (cond ((eq? t 'cons)
;                                                                              (let ((tag1   (get-tag        obj))
;                                                                                    (l1     (get-mylength   obj))
;                                                                                    (w1     (get-mywidth    obj))
;                                                                                    (data1  (get-data       obj))
;                                                                                    (sel1   (selected?      obj))
;                                                                                    (menu1  (menu-item?     obj))
;                                                                                    (in1    (get-input      obj)))
;                                                                                (add-obj-to-list (create-obj tag1 sel1 (cons (+ x 80) y) (cons w1 l1) menu1 in1 data1))))
;                                                                             ((eq? t 'list)
;                                                                              (add-obj-to-list (create-list (cons (+ x 80) y) (cdr (get-input (car in)))))))
;                                                                                            
;                                                                       (display-list can)))
;                                                                   
;                                                                   ))
                            
                            
                             ; Else, not enough inputs, add the machine back to the list as is
                            (else (begin
                                    (add-obj-to-list (car machines))
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
