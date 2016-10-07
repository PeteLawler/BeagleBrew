# file:///usr/share/doc/gnuplot-doc/htmldocs/node525.html
reset

set datafile separator ","
set key outside right box
set yrange [12:*] # really need to use conditional logic to only plot values inside given ranges, eg between 12 and 40
#set autoscale fix
set border linewidth 2
set style line 1 linecolor rgb '#0060ad' linetype 1 linewidth 5
set style line 2 linecolor rgb '#00181f' linetype 1 linewidth 5


set title "BeagleBrew Vessel 1 (Data 0)"
set ylabel "'C"
set terminal svg size 640,480 dynamic background '#ffffff' enhanced font "LiberationSans-Regular,12" name "BeagleBrew" butt dashlength 1.0 mousing
set term svg
set output "/home/debian/BeagleBrewStatus0.svg"
plot '/var/log/beaglebrew/BeagleBrewStatus0.csv' using 2 title "Measured Temp" with lines, '/var/log/beaglebrew/BeagleBrewStatus0.csv' using 3 title "Target Temp" with lines
unset output # close svg tag

set terminal png size 640,480 background '#ffffff' enhanced font "LiberationSans-Regular,12" butt dashlength 1.0 
set term png
set ylabel "'C"

set output "/home/debian/BeagleBrewStatus0.png"
replot

