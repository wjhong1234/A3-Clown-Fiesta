# A3-Clown-Fiesta
Assignment #3

!MAKE AMERICA GREAT AGAIN!

GAME PLAN:
  - 1080x1080 / 27x27 (40px tiles)
  - Donald Trump's journey to the White House
  - Assets:
        - Player = Donald Trump
        - Cars = SJW's, Bernie, Toupee's
        - Fuel = His Quotes
        - Victory will be him in the White House
        - Defeat will be him watching someone in the White House
        - Game map: Trump's face is in bottom-left corner with text bubble on top, superimposed on American flag, wall is being built on the right side of the screen.
        - Measure distance using number of tiles printed
  
MAINLOOP: input > transitions  > state > graphics

map.s
  - MAP OF THE GAME (LIKE THE ENVIRONMENT AND STUFF)
  
state.s
  - BASICALLY THE PLAYER
  - where the dude is (POSITION).
  - contains FUEL, LIVES, and MAP grid.
  - win and lose conditions

transitions.s
  - WHAT HAPPENS WHEN A CHANGE IS MADE
  - flags and UPDATES the state
  
 strangers.s
  - THE CAR AND FUEL STUFF
  - makes cars and fuel show up in game

input.s
  - MOVEMENT OF PLAYER
  - tracks input of player from controls
  - input > transition

main.s
  - LOGIC OF PROGRAM
  - calls all the functions in a loop
  
menu.s
  - DIRTY MAIN MENU SCREEN
  - has start game and 
  
graphics.s
  - DRAWS everything. like bruh, EVERYTHING
  
Disclaimer: We are NOT Donald Trump supporters :33 
------------------------BEFORE STUFF------------------------------
STARTING NOTES:
  - not set in stone cause i have no clue what's going on rn
  - if it happens the points he has are the files we need to create then fuck meh

Note: all capitalized things are either variables or functions probably iunno

player.s
  - will INITIALIZE the player and keep track of player HEALTH, FUEL, LIVES, and POSITION.
  - also DRAWS player on the map, probably also the player stats on screen

map.s
  - INITIALIZE the map
  - UPDATES the map
  - like draws the environment stuff
  
strangers.s
  - INITIALIZES and DRAWS the random stranger cars.
  - keeps track of random cars POSITION

fuel.s
  - can probably be merged with another file
  - randomly generates POSITION of fuel.

game.s / main.s
  - INITIALIZES the game and stuff.
  - include controller here too
  - all the game logic here pls keep it clean children
  
menu.s
  - INITIALIZES the dirty main menu
