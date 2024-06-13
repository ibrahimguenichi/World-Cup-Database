#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
TRUNCATE=$($PSQL "TRUNCATE TABLE games, teams")
echo $TRUNCATE

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  WINNER_ID=""
  OPPONENT_ID=""
  GAME_ID=""
  if [[ $WINNER != "winner" ]]
  then
    # Adding the winner teams to the teams table if they are not already added.
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    if [[ -z $WINNER_ID ]]
    then
      WINNER_TEAM_INSERTION=$($PSQL "INSERT INTO teams (name) VALUES ('$WINNER')")
      echo "the {$WINNER} team was added successfully."
      if [[ $WINNER_TEAM_INSERTION = "INSERT 0 1" ]]
      then
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
      fi
    fi

    # Adding the opponent teams to the teams table if they are not already added.
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    
    if [[ -z $OPPONENT_ID ]]
    then
      OPPONENT_TEAM_INSERTION=$($PSQL "INSERT INTO teams (name) VALUES ('$OPPONENT')")
      echo "the {$OPPONENT} team was added successfully."
    fi
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != "winner" ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    # Adding the games table informations
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year = '$YEAR' AND round = '$ROUND' AND winner_id = '$WINNER_ID' AND opponent_id = '$OPPONENT_ID'")
    if [[ -z $GAME_ID ]]
    then
      GAME_INSERTION=$($PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
      echo $GAME_INSERTION
    fi
  fi
done
