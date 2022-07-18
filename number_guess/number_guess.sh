#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(($RANDOM%1000))

echo -e "\n~~ Number Guessing Game ~~\n"
echo -e "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
  then
  echo "Welcome, $(echo $USERNAME | sed -r 's/^ *| *$//g')! It looks like this is your first time here."
    INSERT_USER=$($PSQL "INSERT INTO users (username) VALUES ('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
fi

if [[ ! -z $GAMES_PLAYED ]]
then
  echo -e "\nWelcome back, $(echo $USERNAME | sed -r 's/^ *| *$//g')! You have played $(echo $GAMES_PLAYED | sed -r 's/^ *| *$//g') games, and your best game took $(echo $BEST_GAME | sed -r 's/^ *| *$//g') guesses."
fi

GUESS=-1
GAMES=0
echo -e "\nGuess the secret number between 1 and 1000:"
while [[ $GUESS -ne RANDOM_NUMBER ]]
  
  do
    ((GAMES++))
    
    read GUESS
      if [[ ! $GUESS =~ ^[0-9]+$ ]]
        then
        echo "That is not an integer, guess again:"
      elif [[ $GUESS -eq $RANDOM_NUMBER ]]
        then
          echo "You guessed it in $GAMES tries. The secret number was $RANDOM_NUMBER. Nice job!"
      elif [[ $GUESS -lt $RANDOM_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
      else
        echo "It's lower than that, guess again:"
      fi
done

((GAMES_PLAYED++))
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID")

if [[ -z $BEST_GAME ]] || [[ $GAMES -lt $BEST_GAME ]]
  then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game=$GAMES WHERE user_id=$USER_ID")
fi

