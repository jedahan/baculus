function cleanup() {
  local green=/sys/class/leds/led0
  local red=/sys/class/leds/led1
  echo none | sudo tee "$red"/trigger
  echo mmc0 | sudo tee "$green"/trigger
  trap - SIGINT SIGTERM
  kill -- -$$
}

function blink() {
  local green=/sys/class/leds/led0
  local red=/sys/class/leds/led1

  echo gpio | sudo tee "$red"/trigger
  echo gpio | sudo tee "$green"/trigger

  while true; do
    echo 1 | sudo tee "$red"/brightness
    echo 0 | sudo tee "$green"/brightness
    sleep 1
    echo 0 | sudo tee "$red"/brightness
    echo 1 | sudo tee "$green"/brightness
    sleep 1
  done
}

trap cleanup SIGINT SIGTERM
blink
