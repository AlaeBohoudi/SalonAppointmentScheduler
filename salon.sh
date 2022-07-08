#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n ~~~~~ Sparck Salon ~~~~~\n"
echo -e "Welcome to Sparck Salon how can I help you?\n"

MAIN_MENU(){

 if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do 
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
   # if not a number between 1-5
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$ ]] 
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else

   echo -e "\nWhat's your phone number?"
   read CUSTOMER_PHONE
   CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
   #if no customer found
    if [[ -z $CUSTOMER_NAME ]]
    then 
     echo -e "\nI don't have a record for that phone number, what's your name?"
     read CUSTOMER_NAME
      # insert new customer
     INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
   fi
    #get service name
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED") 
    echo -e "\nWhat time would you like your$SERVICE,$CUSTOMER_NAME?"
    read SERVICE_TIME
    #get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'") 
    #insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')") 
    echo -e "\nI have put you down for a$SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi  
}

MAIN_MENU
