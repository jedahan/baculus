# sets wlan1 to meshpoint mode
change_to_meshpoint() {
  local mesh_dev="${1:-wlan1}"
  local mesh_name="${2:-bacumesh}"
  sudo ifconfig $mesh_dev down
  sudo iw $mesh_dev set type mp
  sudo ifconfig $mesh_dev up
  sudo iw dev $mesh_dev mesh join ${mesh_name} freq 2412 HT40+
  sudo iw dev $mesh_dev set mesh_param mesh_fwding=0
  sudo iw dev $mesh_dev set mesh_param mesh_rssi_threshold -65
}

change_to_meshpoint $*
