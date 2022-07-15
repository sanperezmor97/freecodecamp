#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

EXIT_MENU() {
  echo -e "\nThank you for stopping in.\n"
}


MAIN_MENU() {
  if [[ $1 ]]
    then echo -e "\n$1"
  fi

  #Get available services
  SERVICES=$($PSQL "SELECT service_id,name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      #Print available services
      echo "$SERVICE_ID) $SERVICE_NAME"
    done

  #Ask the user to select a service
  read SERVICE_ID_SELECTED

  #If input is not valid
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "That's not a valid option. What would you like today?"
    #If input is nut an available service
    else
      SERVICE_CHOSEN=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

      if [[ -z $SERVICE_CHOSEN ]]
        then
          MAIN_MENU "I could not find that service. What would you like today?"
        else

        #Get phone
        echo -e "What's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

        #If user don't exist
        if [[ -z $CUSTOMER_NAME ]]
          #Create new user
          then
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME
            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")  
        fi
        #Get customer_id
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

        #Create appointment
        echo -e "\nWhat time would you like your$SERVICE_CHOSEN,$CUSTOMER_NAME"
        read SERVICE_TIME

        INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")

        echo -e "\nI have put you down for a $(echo $SERVICE_CHOSEN | sed -r 's/^ *| *$//g') at $( echo $SERVICE_TIME| sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

      fi
  fi
}



MAIN_MENU "Welcome to My Salon, how can I help you?"
