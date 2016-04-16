#lang racket/gui
(require racket/gui/base)
(require racket/gui/base)
(require racket/draw)


;; Master list of objects
(define ls '())

;; Get procedures for data objects
(define (get-data obj)   (cdr obj))
(define (get-tag obj)    (caar obj))
(define (selected? obj)  +(cadar obj))
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

;; PRIMITIVES FOR THE MENU
(add-obj-to-list (create-obj 'menu #f (cons 20 20)  (cons 30 30) 'red))
(add-obj-to-list (create-obj 'menu #f (cons 20 70)  (cons 30 30) 'green))
(add-obj-to-list (create-obj 'menu #f (cons 20 120) (cons 30 30) 'blue))

;; OBJECTS FOR TESTING LIST
(add-obj-to-list (create-obj 'primitive #f (cons 100 100) (cons 30 30) 'green))
(add-obj-to-list (create-obj 'primitive #f (cons 150 150) (cons 30 30) 'red))
(add-obj-to-list (create-obj 'primitive #f (cons 300 400) (cons 30 30) 'blue))

;; DISPLAY THE CURRENT LIST IN THE CANVAS
(define (display-list canvas)
  (send canvas
        refresh-now
        (lambda (dc)
          (define (iter ls)
            (if (null? ls)
                (display "done")
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

; Checks if 2 objects are the same
; Returns #t if they are, #f if they arent
(define (item-equal? item1 item2)
  (and (equal? (get-data item1) (get-data item2))
           (equal? (get-tag item1) (get-tag item2))
           (equal? (selected? item1) (selected? item2))
           (equal? (get-x item1) (get-x item2))
           (equal? (get-y item1) (get-y item2))
           (equal? (get-mylength item1) (get-mylength item2))
           (equal? (get-mywidth item1) (get-mywidth item2))))

; Finds an item in the list, and removes it if it exists
; Returns a new list without the removed item
(define (delete-item lst item)
  (define (iter remaining total)
    (if (item-equal? (car remaining) item)
        (cons (cdr remaining) total)
        (iter (cdr remaining) (cons (car remaining) total))))
  (iter lst '()))

; Checks if any object is in range of the mouse
(define in-range (lambda (x)
                              (and
                                    (<= (get-x x) mouse-x)
                                    (>= (+ (get-x x) (get-mywidth x)) mouse-x)
                                    (<= (get-y x) mouse-y)
                                    (>= (+ (get-y x) (get-mylength x)) mouse-y))))
; Start canvas definition
(define my-canvas%
  (class canvas% 
    (inherit get-width get-height refresh)
    ; The selection: message
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
    
    ; Start of mouse/keyboard handling 
    (define/override (on-event event)
      ; Grab the x and y coords
      (set! mouse-x (send event get-x))
      (set! mouse-y (send event get-y))
      
      ; Left mouse button handling
      (if (send event button-down? 'left)
          
          ; If there isnt anything selected, select. else, move
          (if (and (null? (get-selected)) (not (null? (filter in-range ls))))

              ; If true, select the object
              (let ((keep (filter (lambda (x) (not (selected? x))) ls))
                    (change (car (filter in-range ls))))
                (set! ls (cons (create-obj (get-tag change) #t (cons (get-x change) (get-y change)) (cons (get-mylength change) (get-mywidth change)) (get-data change))
                                  (delete-item keep change))))
              ; Else
              ; Go to the movement stage of the nested if's              
              ; If something is already selected, move it
              (if (not (null? (get-selected))) 
                  (begin 
                    (update-message)
                    (let ((keep (filter (lambda (x) (not (selected? x))) ls))
                          (wrong (car (filter (lambda (x) (selected? x)) ls))))
                      ;the set to create the new object
                      (set! ls (cons (create-obj (get-tag wrong) #t (cons mouse-x mouse-y) (cons (get-mylength wrong) (get-mywidth wrong)) (get-data wrong))
                                     keep)))
                    (display-list can))
                  (update-message))
              )
          '())
      
      ; Right mouse button handling
      (if (send event button-down? 'right)
          (if (null? (get-selected))
              (update-message)
              (begin
                (let ((keep (filter (lambda (x) (not (selected? x))) ls))
                      (wrong (car (filter (lambda (x) (selected? x)) ls))))
                  (set! ls (cons (create-obj (get-tag wrong) #f (cons (get-x wrong) (get-y wrong)) (cons (get-mylength wrong) (get-mywidth wrong)) (get-data wrong))
                                 (delete-item keep wrong)))
                  )
                (update-message)))
          '()))
      
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