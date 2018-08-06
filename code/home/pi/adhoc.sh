# sets wlan1 to adhoc mode
change_to_adhoc() {
  local mesh_dev="${1:-wlan1}"
  local mesh_name="${2:-bacuhoc}"

  sudo ifconfig $mesh_dev down
  sudo iw $mesh_dev set type ibss
  sudo ifconfig $mesh_dev up
  sudo iw dev $mesh_dev ibss join ${mesh_name} 2412 HT40+

  local selfassigned=$(ip addr show $mesh_dev scope global | awk "/169/ {print \$2}")
  test $selfassigned && sudo ip addr del $_ dev $mesh_dev

  local suffix=5
  if [[ $HOSTNAME == 'baculusA' ]]; then suffix=10; fi
  if [[ $HOSTNAME == 'baculusB' ]]; then suffix=11; fi
  if [[ $HOSTNAME == 'baculusC' ]]; then suffix=12; fi
  local addr=10.0.17.${suffix}

  ip addr show $mesh_dev | grep $addr >/dev/null 2>&1 && return
  sudo ip addr add $addr $mesh_dev
}

change_to_adhoc $*
