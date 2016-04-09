#lang racket/gui
(require racket/gui/base)
(require racket/gui/base)
(require racket/draw)


;; Master list of objects
(define ls '())

;; Get procedures for data objects
(define (get-data obj)   (cdr obj))
(define (get-tag obj)    (caar obj))
(define (selected? obj)  (cadar obj))
(define (get-x obj)      (car (caddar obj)))
(define (get-y obj)      (cdr (caddar obj)))
(define (get-mylength obj) (caar (cdddar obj)))
(define (get-mywidth obj)  (cdar (cdddar obj)))
(define (get-selected)
  (if (null? (filter (lambda (x) (selected? x)) ls))
      '()
      (car (filter (lambda (x) (selected? x))  ls))))
  
(define frame (new frame%
                   [label "Scratchket"]
                   [width 600]
                   [height 600]))

;; CREATE AN OBJECT AND RETURN IT
(define (create-obj tag selected pos size data)
  (cons (list tag selected pos size) data))

;; ADD AN OBJECT TO THE LIST
(define (add-obj-to-list obj)
  (set! ls (cons obj ls)))

;; OBJECTS FOR TESTING LIST
(add-obj-to-list (create-obj 'primitive #f (cons 100 100) (cons 30 30) 'green))
(add-obj-to-list (create-obj 'primitive #t (cons 150 150) (cons 30 30) 'red))
(add-obj-to-list (create-obj 'primitive #f (cons 300 400) (cons 30 30) 'blue))

;; DISPLAY THE CURRENT LIST IN THE CANVAS
(define (display-list canvas)
  (send canvas
        refresh-now
        (lambda (dc)
          (define (iter ls)
            (if (null? ls)
                (disp-menu dc)
                (begin
                    (send dc set-brush (symbol->string (get-data (car ls))) 'solid)
                    (send dc set-pen "black" 1 'solid)
                    (send dc
                          draw-rectangle
                          (get-x (car ls))
                          (get-y (car ls))
                          (get-mylength (car ls))
                          (get-mywidth (car ls)))
                    (iter (cdr ls)))))
          (iter ls)))
  ) ;; END OF DISPLAY-LIST

(define (move-square x y)
  (display-list can))
; Start of Kyle's code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define mouse-x 0)
(define mouse-y 0)

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
                                               (if (not (null? return))
                                                   (symbol->string
                                                    (get-tag return))
                                                   "Nothing"))))))
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
           ;2. Select an unselected object
           ;If the object is not within the mouse click range, return null
           (if (null? (filter (lambda (x)
                                (and  (>= (get-x x) mouse-x)
                                      (<= (+ (get-x x) (get-mywidth x)) mouse-x)
                                      (>= (get-y x) mouse-y)
                                      (<= (+ (get-y x) (get-mylength x)) mouse-y)))
                              ls))
               '()
           ;Otherwise, set the object to selected true
               (let ((keep (filter (lambda (x) (not (selected? x))) ls))
                     (wrong (car (filter (lambda (x) (selected? x)) ls))))
                 ;the set to create the new object
                  (set! ls (cons (create-obj (get-tag wrong) #t (cons (get-x wrong) (get-y wrong)) (cons (get-mylength wrong) (get-mywidth wrong)) (get-data wrong))
                        keep))))
               
                                     
           ;3. If something is already selected, move it
           (if (not (null? (get-selected))) 
           (begin 
             (update-message)
             (move-square mouse-x mouse-y))
           (update-message))
           '())

      (if (send event button-down? 'right)
          (if (null? (get-selected))
              (update-message)
              (begin
                (let ((keep (filter (lambda (x) (not (selected? x))) ls))
                      (wrong (car (filter (lambda (x) (selected? x)) ls))))
                  (set! ls (cons (create-obj (get-tag wrong) #f (cons (get-x wrong) (get-y wrong)) (cons (get-mylength wrong) (get-mywidth wrong)) (get-data wrong))
                        keep))
                )
                (update-message)))
          '()))
      '())

    ; Call the superclass init, passing on all init args
    (super-new)))
 
; Make a canvas that handles events in the frame
(define can (new my-canvas%
                 [parent frame]
                 [paint-callback
                  (lambda (canvas dc)
                    ;Display red block
                    (send dc set-brush "red" 'solid)
                    (send dc set-pen "black" 1 'solid)
                    (send dc draw-rectangle 20 20 30 30)
                    ;Display green block
                    (send dc set-brush "green" 'solid)
                    (send dc set-pen "black" 1 'solid)
                    (send dc draw-rectangle 20 70 30 30)
                    ;Display blue block
                    (send dc set-brush "blue" 'solid)
                    (send dc set-pen "black" 1 'solid)
                    (send dc draw-rectangle 20 120 30 30)
                    )
]))

(send frame show #t)

;; DISP-MENU
;; send the menu with primitive types to the canvas
(define (disp-menu dc)
          ;Display red block
          (send dc set-brush "red" 'solid)
          (send dc set-pen "black" 1 'solid)
          (send dc draw-rectangle 20 20 30 30)
          ;Display green block
          (send dc set-brush "green" 'solid)
          (send dc set-pen "black" 1 'solid)
          (send dc draw-rectangle 20 70 30 30)
          ;Display blue block
          (send dc set-brush "blue" 'solid)
          (send dc set-pen "black" 1 'solid)
          (send dc draw-rectangle 20 120 30 30)
  ) ;; END OF DISP-MENU