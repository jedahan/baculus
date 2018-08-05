# sets wlan1 to adhoc mode
change_to_adhoc() {
  local mesh_dev="${1:-wlan1}"
  local mesh_name="${2:-bacuhoc}"

  sudo ifconfig $mesh_dev down
  sudo iw $mesh_dev set type ibss
  sudo ifconfig $mesh_dev up
  sudo iw dev $mesh_dev ibss join ${mesh_name} 2412 HT40+

  local suffix=5
  local selfassigned=$(ip addr show $mesh_dev | awk "/169/ {print \$2}")

  if [[ $HOST == 'baculusA' ]]; then suffix=10; fi
  if [[ $HOST == 'baculusB' ]]; then suffix=11; fi
  if [[ $HOST == 'baculusC' ]]; then suffix=12; fi

  sudo ip addr del $selfassigned dev $mesh_dev
  sudo ip addr add 10.0.17.${suffix} dev $mesh_dev
}

change_to_adhoc $*
