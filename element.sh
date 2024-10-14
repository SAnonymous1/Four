#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

MENU(){
  if [[ $1 ]]
  then
    SEARCH_ID=
    if [[ $1 =~ ^[0-9]+$ ]]
      then 
        WITH_NUM=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $1")
        if [[ -z $WITH_NUM ]]
        then
          echo 'I could not find that element in the database.'
        else
          SEARCH_ID=$WITH_NUM
        fi
      else
        WITH_SYMBOL=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")
        WITH_NAME=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
        if [[ -z $WITH_SYMBOL ]]
          then
            if [[ -z $WITH_NAME ]]
            then
              echo 'I could not find that element in the database.'
            else
              SEARCH_ID=$WITH_NAME
            fi
          else
            SEARCH_ID=$WITH_SYMBOL
        fi
    fi

    if [[ $SEARCH_ID ]]
    then
      FOR_PRINT=$($PSQL "SELECT symbol, name FROM elements WHERE atomic_number = $SEARCH_ID")
      IFS='|' read SYMBOL NAME <<< $FOR_PRINT

      FOR_PRINT2=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number = $SEARCH_ID")
      IFS='|' read MASS MELT BOIL TYPE <<< $FOR_PRINT2

      if [[ -z $TYPE ]]
      then
        echo 'Element type not found.'
        return
      fi

      FOR_PRINT3=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE")
      TYPE_NAME=$(echo $FOR_PRINT3 | xargs)
      echo "The element with atomic number $SEARCH_ID is $NAME ($SYMBOL). It's a $TYPE_NAME, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
    fi

  else
    echo 'Please provide an element as an argument.'
  fi
}

MENU $1