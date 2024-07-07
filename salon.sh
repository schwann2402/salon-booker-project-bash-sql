#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

 echo -e "\n~~~~ Salon Les Cheveux ~~~\n"
SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "What service do you want today?\n"
  echo -e "1) Hair cut\n2) Blower\n3) Nail polish"
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then 
    SERVICE_MENU "You must enter a number"
  elif [[ ! $SERVICE_ID_SELECTED =~ ^[0-3]$ ]]
  then
    SERVICE_MENU "You must enter an available service option number"
  else
    echo -e "What's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE' ")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "What's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    echo -e "\nAt what time do you want your service?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    VALIDATE_APPOINTMENT=$($PSQL "SELECT * FROM appointments WHERE customer_id=$CUSTOMER_ID AND service_id=$SERVICE_ID_SELECTED AND time = '$SERVICE_TIME'")
    if [[ -z $VALIDATE_APPOINTMENT ]]
    then
      MAKE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    fi
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    echo -e "I have put you down for a $(echo $SERVICE_NAME | sed 's/^ *[a-z]$//') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ *[a-z]$//')."
  fi
}

SERVICE_MENU