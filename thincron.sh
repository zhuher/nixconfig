#!/bin/env zsh
if [[ "$(curl -s "https://education.tbank.ru/start/cpp/")" != *"Набор"*"закрыт."* ]]; then
  osascript -e 'display alert "Набор не закрыт!!!!" message "Бегом подавать заявку!!!!!!!!!!!!" as critical buttons { "LESSGOO" } default button "LESSGOO"' \
    -e 'set response to button returned of the result' \
    -e 'if response is "LESSGOO" then open location "https://education.tbank.ru/start/cpp/"'
fi
