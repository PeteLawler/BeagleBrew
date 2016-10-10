# file:///usr/share/doc/gnuplot-doc/htmldocs/node525.html
reset

logfile="/var/log/beaglebrew/BeagleBrewData0.csv" # need to get this passed to awk at some stage
tempfile="/home/debian/Documents/Graphs/BeagleBrewTemp0.svg"
powerfile="/home/debian/Documents/Graphs/BeagleBrewPower0.svg"

set autoscale
set border linewidth 2
set datafile separator ","
set grid
set key outside vert right box
set style line 1 linecolor rgb '#0060ad' linetype 1 linewidth 5
set style line 2 linecolor rgb '#00181f' linetype 1 linewidth 5
set tics out

set xdata time
set timefmt "%Y-%m-%d %H:%M:%S" 
set format x "%Y-%m-%d %H:%M:%S"
set xtics rotate by 90 offset 0,-7.5
set bmargin 10

set title "BeagleBrew Vessel 1 (Data 0)"
set xlabel "Time" offset 0,1.5
set ylabel "'C" # Need to find consistent degree symbol for SVG and PNG formats

set terminal svg size 1280,960 dynamic background '#ffffff' enhanced font "LiberationSans-Regular,12" \
 name "BeagleBrew" butt dashlength 1.0 mousing
set term svg
set output tempfile
plot "<awk -F\, '{ if( $3 > 15 ) { print $0 } }' /var/log/beaglebrew/BeagleBrewData0.csv" \
   using 1:3 title "Measured Temp" with lines smooth bezier, \
 "<awk -F\, '{ if( $4 > 15 ) { print $0 } }' /var/log/beaglebrew/BeagleBrewData0.csv" \
   using 1:4 title "Target Temp" with lines
unset output # close svg tag

set title "BeagleBrew Vessel 1 (Data 0)"
set xlabel "Time" offset 0,1.5
set ylabel "Power"

set terminal svg size 1280,960 dynamic background '#ffffff' enhanced font "LiberationSans-Regular,12" \
 name "BeagleBrew" butt dashlength 1.0 mousing
set term svg
set output powerfile
plot "/var/log/beaglebrew/BeagleBrewData0.csv" using 1:5 title "Target Temp" with lines
unset output # close svg tag
