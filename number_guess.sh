#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


echo -e "\nEnter your username:"
read USERNAME
 
# get user data
USER=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
# get user id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

# if user  not found
if [[ -z $USER ]]
  then
    # greet player
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
    # add player to database
    INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
   
  else
    
   GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT MIN(no_of_guess) FROM games LEFT JOIN users USING(user_id) WHERE username='$USERNAME'")

    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\n"
   
fi

# generate random number between 1 and 1000
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

# variable to store number of guesses/tries
GUESSED=0

# prompt first guess
echo -e "\nGuess the secret number between 1 and 1000:"
read NUMBER


# loop to prompt user to guess until correct
until [[ $NUMBER == $RANDOM_NUMBER ]]
do
  
  # check guess is valid/an integer
  if [[ ! $NUMBER =~ ^[0-9]+$ ]]
    then
      # request valid guess
      echo -e "\nThat is not an integer, guess again:"
      read NUMBER
      # update guess count
      ((GUESSED++))
    
    # if its a valid guess
    else
      # check inequalities and give hint
      if [[ $NUMBER < $RANDOM_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
          read NUMBER
          # update guess count
          ((GUESSED++))
        else 
          echo "It's lower than that, guess again:"
          read NUMBER
          #update guess count
          ((GUESSED++))
      fi  
  fi

done

# loop ends when guess is correct so, update guess
((GUESSED++))

# get user id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
# add result to game history/database
UPDATE_GAMES=$($PSQL "INSERT INTO games(user_id,no_of_guess) VALUES ($USER_ID, $GUESSED)")

# winning message
echo You guessed it in $GUESSED tries. The secret number was $RANDOM_NUMBER. Nice job\!
