curl --location --request POST 'http://localhost:1026/v2/subscriptions' \
--header 'Content-Type: application/json' \
--data-raw '{
  "description": "Notify Cygnus Postgres of all context changes",
  "subject": {
    "entities": [
      {
        "idPattern": ".*"
      }
    ]
  },
  "notification": {
    "http": {
      "url": "http://cygnus:5055/notify"
    }
  }
}
'
