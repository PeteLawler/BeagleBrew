1) P9-1 (GND) to GND on breadboard
2) P9-2 (3v3) to breadboard
3) Connect 1-W data line (temp_sensor_id) to P9.27 (SPI1_DO GPIO3[19])
4) Connect relay (heat_pin) to P8.7 (TIMER4 GPIO2[2]). Additional heat_pins recommended on P8.8(TIMER7 GPIO2[3]), P8.9(TIMER5 GPIO2[5]) & P8.10(TIMER6 GPIO2[4]).
### Suggestions
5) Connect SMS monitoring to UART4. P9.11 (UART4_RXD GPIO0[30]) -> FONA PIN TX, P9.13 (UART4_TXD GPIO0[31]) -> FONA PIN RX
6) Connect UPS to USB, using nut for monitoring and SMS for notifications
7) Add systemd scripts for SMS status updates
8) RTC
