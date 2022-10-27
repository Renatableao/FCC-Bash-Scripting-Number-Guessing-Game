#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_game --tuples-only -c"


# function that checks if guessed number is corret and keep count of tries
COMPARE_GUESS() {
   
    # update tries counter
    ((i=i+1))

    # if input is not a number
    if [[ ! $1 =~ ^[0-9]+$ ]]
    then 
        echo -e "\nThat is not an integer, guess again:"
        read INPUT_NUMBER
        COMPARE_GUESS "$INPUT_NUMBER"
    
    # if input is a number
    else
        
        # if guess is correct
        if [[ $1 -eq $NUMBER_TO_GUESS ]]
        then
            echo -e "\nYou guessed it in $i tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
            UPDATE_USER_INFO=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game_guesses = LEAST(best_game_guesses, $i) WHERE user_id=$USER_ID")
        # if guess is lower then random number
        elif [[ $1 -lt $NUMBER_TO_GUESS ]]
        then
            echo -e "It's higher than that, guess again:"
            read INPUT_NUMBER
            # call function with new input
            COMPARE_GUESS "$INPUT_NUMBER"
            # update tries counter
            ((i=i+1))
        # if guess is higher then random number
        else
            echo -e "It's lower than that, guess again:"   
            read INPUT_NUMBER
            # call function with new input
            COMPARE_GUESS "$INPUT_NUMBER" 
            # update tries counter
            ((i=i+1))
        fi
    fi

}

# greeting message: request username
echo -e "\nEnter your username:"

# get input from user
read USERNAME

# get user_id from database
USERNAME_FORMATTED=${USERNAME,,}
USER_ID=$($PSQL "SELECT user_id from users WHERE username='$USERNAME_FORMATTED'")

# if user already exists in database
if [[ ! -z $USER_ID ]]
then
    # get user games info
    USER_RESULTS=$($PSQL "SELECT username, games_played, best_game_guesses from users WHERE user_id='$USER_ID'")

    # display user games infos
    echo "$USER_RESULTS" | while read USERNAME BAR GAMES_PLAYED BAR BEST_GAME_GUESSES 
    do
        echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME_GUESSES guesses."
    done

# if user does not exist in database
else
    # greet and insert user in database
    REGISTER_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME_FORMATTED')")
    USER_ID=$($PSQL "SELECT user_id from users WHERE username='$USERNAME_FORMATTED'")
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
fi

echo -e "\nGuess the secret number between 1 and 1000:"

    # generate random number
    NUMBER_TO_GUESS=$(( $RANDOM % 1000 + 1 ))
    # initialize tries counter
    i=0
    
    #get user input
    read INPUT_NUMBER

    #call function
    COMPARE_GUESS "$INPUT_NUMBER"