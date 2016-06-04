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
    
================================================================================
-main
  -menu
  -tick
    -input
    -player
    -item
    -map
  -render

tick.s
  - GAME STATE & UPDATES
  - Determines victory conditions
  - IMPORTANT: updates everything in the game, from player to map to spawn.
  
  TICK updates every part of the game, and keeps track of the game state. The GAMELOOP is contained in here.

player.s
  - PLAYER
  - Movement & location for player, tracks fuel & lives.

  PLAYER is literally the person playing the game. Has functions for movement and contains all information about the bitch.

input.s
  - INPUTS
  - Buttons and whatnot

  INPUT is just for buttons input. Sends all that shit to player.s and lets that deal with it.

item.s
  - ALL SPAWNS (FUEL & OBSTACLES)
  - Creates, moves, deletes, and keeps track of all spawned items (including type [fuel/ obstacle]).

  ITEM spawns everything, keeps track of those spawned items, and does movement/deletion for those items.

menu.s
  - MAIN MENU
  - Start Game & Quit Game
  
  If you don't know what MENU is fuck you.

main.s
  - MAIN GAME LOOP (ENTIRE PROGRAM)
  - Contains FPS control code.

  MAIN contains the program loop, and the FPS code to limit our game to around 30 FPS. Loop will be tick>render.

render.s
  - DRAWS EVERYTHING
  - Wipes game assets (except the clean map) after every loop iteration.

  RENDER does all of the drawing. It should contain the map and have a function "wipe" that clears everything after each loop.

map.s
  - MAP STUFF
  - Moves the road
  - Tile count should be here so the other parts of our program can function.
  - POTENTIALLY contains Donald Trump reaction code.

  MAP contains everything on the map that moves and isn't the player or a spawned item. Also does tile counting.
  
Disclaimer: We are NOT Donald Trump supporters :33 
===================================OLD===================================
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
