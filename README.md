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
of the things we learned in class. 

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
WILL UPLOAD PICTURE

Upload the architecture diagram you made for your slide presentation to your repository, and include it in-line here.

Create several paragraphs of narrative to explain the pieces and how they interoperate.

## Schedule
Explain how you will go from proposal to finished product. 

There are three deliverable milestones to explicitly define, below.

The nature of deliverables depend on your project, but may include things like processed data ready for import, core algorithms implemented, interface design prototyped, etc. 

You will be expected to turn in code, documentation, and data (as appropriate) at each of these stages.

Write concrete steps for your schedule to move from concept to working system. 

### First Milestone (Fri Apr 15)
We will be turning in a finished user interface. Objects will exist, be selectable, and moveable.

### Second Milestone (Fri Apr 22)


### Final Presentation (last week of semester)
What additionally will be done in the last chunk of time?

## Group Responsibilities
Here each group member gets a section where they, as an individual, detail what they are responsible for in this project. Each group member writes their own Responsibility section. Include the milestones and final deliverable.

**Additional instructions for teams of three:** 
* Remember that you must have prior written permission to work in groups of three (specifically, an approved `FP3` team declaration submission).
* The team must nominate a lead. This person is primarily responsible for code integration. This work may be shared, but the team lead has default responsibility.
* The team lead has full partner implementation responsibilities also.
* Identify who is team lead.

In the headings below, replace the silly names and GitHub handles with your actual ones.

### Kyle Jolicoeur @kjolicoeur
will write the....

### Leonard Lambda @lennylambda
will work on...

### Frank Functions @frankiefunk 
Frank is team lead. Additionally, Frank will work on...   
