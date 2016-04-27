# Project Title: Scratchket

### Statement
Scratchket is a Racket program which will visually represent Racket data sctructures. We are planning to
use colored squares to represent data, different colors refering to different data types. i.e. green squares
represent integers, red reperesenting strings. We will combine the colored squares with a procedure "machine"
with a TBD visual look. Combining these in the correct ways will produce a visual output representing the 
resulting structure.

Scratch is used as a visual, educational tool for beginner programmers to learn how to program. Scratchket is interesting
because it does the same exact thing as Scratch, but using the Racket language and concepts. It can help new Racket learners
to understand the certain concepts of Racket. I, Kyle, am interested in this project because it visually represents some
of the things we learned in class. I, Brian, am interested in this project because it will allow those who are more visual learners and those who like to jump in and "play" to pick up on Racket data structures. You will be able to see how two data types can be joined with a cons cell, and how car will retrieve the first of those input.

We hope to learn how to use GUIs/2d graphics in Racket, and utilizing mouse interactions within a program.  

### Analysis
We will be using map, recursion, data abstraction, and objects as of our plan right now. By internally representing all 
data structures as lists of objects, we will be able to Map movement procedures to any object. Recursion would be mostly used 
in some of the procedure machines, maybe also if we decide to animate some of the input/output process, recursion would be 
used for that.
We are using objects for internal representations of certain things, and using our library's objects (mouse events, GUI frames,
etc.). Data abstraction will be used quite a lot because we are using objects. We will be retrieving object metadata with
procedures like the object's size, x and y coordinates, etc. We will be creating objects in an object-orientated way to 
represent each square, to store the coordinates and data inside. The states of the objects will be modified when we move the objects.

### Data set or other source materials
No data sets or other source materials will be used.

### Deliverable and Demonstration
We plan on demonastrating an interactive educational program that will help users understand how data structures are built and represented in Racket using a GUI. We will be able to give live demonstrations and allow users to manipulate data structures using our procedure machines. Output from the machines will be a visual representation of the printed data structure form. All objects, including procedure machines, will be interactive.

### Evaluation of Results
Success will be determined if our visual representation of the data structures agrees with the printed form and users can take away an understanding of the concepts of Racket data structures.

## Architecture Diagram
![Diagram](https://github.com/oplS16projects/Scratchket/blob/master/Scratchket%20diagram.png)

The User Interface branch of the main program is where all user input will be developed. Our mouse events (and keyboard events if we need them) will be developed in this portion of development. The UI will need to be implemented in the objects themselves to keep track of what is selected, where they need to move to, etc. UI needs to work with the objects, which takes place in the internal representation portion.

The GUI/Visual portion of our program is essentially what you can see. The GUI window, layout, and the "data squares" and "procedure machines" will be displayed when the program runs. The "data squares" are planned to be diffrent colors symbolizing different data types (integer, string, etc), while the "procedure machines" are planned to look slightly different than the normal square look, and have an input/output side. Both of these things need an internal representation of an object, which we are considering using classes for, and will link the data to what is on screen.


## Schedule
Our first goal is to get the GUI working. Since a graphical representation of the data structures is our main goal we will need the GUI working in order to test and debug the scratch side of our program. This will be our first milestone. Next we will work on the internal representation of the data structures and the "procedure machines" that will be used to combine the data structures in different ways. This is the second milestone and the bulk of our program. We're leaving a little extra room in the last week for unanticipated bug fixes and refinements. If our program is working and we still have time we will try to incorporate extra bonus features, like challenges. 


### First Milestone (Fri Apr 15)
<strike>We will be turning in a finished user interface. Objects will exist, be selectable, and moveable.</strike><br>
UPDATE 4/15: We have created a GUI that works with primitives only. The internal structure for how all the objects is in place, and data abstraction for the structure exists and works. Complex data structures do not exist on the display yet, but we have laid the foundation to build them internally. We have a small menu of items on the left. When one of the primitive menu items is selected, it will eventually create a primitive data object that you can select and move (we have 3 primitive structures on the screen separate from the left column to compensate for now). There currently is a bug with the selection procedure, but it was not able to be fixed before the milestone, and will be tomorrow (4/16).

### Second Milestone (Fri Apr 22)
<strike>We will be turning in an internal representation of the data structures that are linked to displayed structures.</strike><br>
UPDATE 4/23: Internal representations of the data structures is complete. Primitve types can be input into the cons machine. As primitives are input, lights turn on in the machine to indicate how many inputs it has. In order for the machine to work, a process button has been added. All processing is held off until this button is pushed. This was done so a machine's output can be the input for another machine. Unfortunately the cons machine only works with primitives for right now. Work needs to be done so a cons cell will expand in order to draw larger complex inputs within a cons cell. Lists should be done in time for the presentation as they should just be an implementation of the cons machine which is almost complete. In order to run our program you should only need to install the racket/draw package.

### Final Presentation (last week of semester)
<strike>In combination with the visual form we will also have a printed form of the data structures.</strike><br>
UPDATE 4/27: Added car and cdr to cons and list. All machines appear to be working properly. Machines check for appropriate input (car and cdr can't take primitive inputs) and they can all take lists or cons cells as inputs. However, we did not have
time to make a printed form of the data structures.

## Group Responsibilities
Here each group member gets a section where they, as an individual, detail what they are responsible for in this project. Each group member writes their own Responsibility section. Include the milestones and final deliverable.


### Kyle Jolicoeur @kjolicoeur
I am going to do the user interface, link the user interface to the internal representation, and link the visual and data portion of the "procedure machines" to help balance the workload. The UI will be finished by the first milestone. "procedure machine" visual<->data will be done by the second milestone.

### Brian Thomas @jumpyhoof
I will be working on the graphics side of the GUI and the internal representation of the underlying data structures.

## Favorite code:
###Brian's: The main method to update the visuals for the entire gui. It recursively updates the GUI with the new positions
of the objects.
```
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
  ) ;; END OF DISPLAY-LIST ```
  ```
###Kyle's:
 This is the main method for handling the program's UI. Depending on certain conditions when you left click,
 different procedures will run. This handles all of the left click actions and is the most essential part of the UI.
``` 
; What occurs when the left click is pressed
          (define (left-click-action)
            (cond
              (selected (move-selected))
              ((reset?) (reset))
              ((process?) (process (get-non-machines) (get-machines)))
              ((dup-menu-item?) (menu-create-new))
              ; If nothing is selected, but something is in range, select it.
              (change (select-item))))```
```
## Screenshots:

Basic (clean GUI)
![basic GUI](https://github.com/oplS16projects/Scratchket/blob/master/Scratchket_016.png?raw=true)

A user modified gui (working copy)
![used GUI](https://github.com/oplS16projects/Scratchket/blob/master/Scratchket_015.png?raw=true)
