# file:///usr/share/doc/gnuplot-doc/htmldocs/node525.html
reset

logfile="/var/log/beaglebrew/BeagleBrewStatus0.csv" # need to get this passed to awk at some stage
pngfile="/home/debian/Documents/Graphs/BeagleBrewStatus0.png"
svgfile="/home/debian/Documents/Graphs/BeagleBrewStatus0.svg"

set datafile separator ","
set key outside right box
set autoscale
set border linewidth 2
set style line 1 linecolor rgb '#0060ad' linetype 1 linewidth 5
set style line 2 linecolor rgb '#00181f' linetype 1 linewidth 5

set title "BeagleBrew Vessel 1 (Data 0)"
set ylabel "'C" # Need to find consistent degree symbol for SVG and PNG formats

set terminal svg size 640,480 dynamic background '#ffffff' enhanced font "LiberationSans-Regular,12" name "BeagleBrew" butt dashlength 1.0 mousing
set term svg
set output svgfile
plot "<awk -F\, '{ if( $2 > 15 ) { print $0 } }' /var/log/beaglebrew/BeagleBrewStatus0.csv " using 2 title "Measured Temp" with lines, "<awk -F\, '{ if( $3 > 15 ) { print $0 } }' /var/log/beaglebrew/BeagleBrewStatus0.csv " using 3 title "Target Temp" with lines
unset output # close svg tag

set terminal png size 640,480 background '#ffffff' enhanced font "LiberationSans-Regular,12" butt dashlength 1.0 
set term png
set output pngfile
replot

