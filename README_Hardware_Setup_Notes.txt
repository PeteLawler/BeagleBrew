1) P9-1 (GND) to GND on breadboard
2) P9-2 (3v3) to breadboard
3) Connect 1-W data line (temp_sensor_id) to P9.27 (GPIO_125, GPIO3[19])
4) Connect relay (heat_pin) to P8.8 (TIMER7)
### Suggestions
5) Connect SMS monitoring to UART4. P9.11 (GPIO_30, GPIO0[30], UART4_RXD) -> FONA PIN TX, P9.13 (GPIO_31, GPIO0[31], UART4_TXD) -> FONA PIN RX
6) Connect UPS to USB, using nut for monitoring and SMS for notifications
7) Add systemd scripts for SMS status updates
