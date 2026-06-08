### Running wih Docker

The client requires the following services to be up and running:
	
* game-room-manager  - controls the list of available game-rooms, creates new game-rooms, manages the number of players in each game-room 

* planning-api - receives the scripts submitted by the user 

* redis instance - manages the communication between the game-rooms and other services
	
In order to get all background services running through Docker, you need to have Docker installed and run:

`docker-compose up` 

This will spin up all service instances in the ports required by the client