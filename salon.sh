#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ My Salon ~~\n"

main_menu() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo "Welcome to My Salon, how can I help you?"
  fi

  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")

  if [[ -z $SERVICES ]];  then
      echo "Sorry, we don't have this service available right now"
    else
      echo -e "These are our services:"
      echo "${SERVICES}" | while read SERVICE_ID BAR SERVICE_NAME
      do
        echo "${SERVICE_ID}) ${SERVICE_NAME}"
      done

      echo -e "\n Please pick one of the services above:"
      read SERVICE_ID_SELECTED

      if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
        main_menu "That is not a number."
      else
        SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = ${SERVICE_ID_SELECTED}")

        if [[ -z $SERVICE_ID_SELECTED ]]; then
          main_menu "I could not find that service. What would you like today?"
        else
          echo -e "\n What's your phone number?"
          read CUSTOMER_PHONE
          CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '${CUSTOMER_PHONE}'")

            if [[ -z $CUSTOMER_NAME ]]; then
              echo -e "\nI don't have a record for that phone number, what's your name?"
              read CUSTOMER_NAME
              REGISTER_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('${CUSTOMER_NAME}', '${CUSTOMER_PHONE}')")
            fi

            SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = ${SERVICE_ID_SELECTED}")
            echo -e "\nWhat time would you like your ${SERVICE_NAME}, ${CUSTOMER_NAME}?"
            read SERVICE_TIME
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '${CUSTOMER_PHONE}'")

            if [[ $SERVICE_TIME ]]; then
              REGISTER_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES(${CUSTOMER_ID}, ${SERVICE_ID_SELECTED}, '${SERVICE_TIME}')")
              if [[ $REGISTER_APPOINTMENT ]]; then
                echo -e "\nI have put you down for a ${SERVICE_NAME} at ${SERVICE_TIME}, ${CUSTOMER_NAME}."
              fi
            fi
        fi
      fi  
  fi
}

main_menu
