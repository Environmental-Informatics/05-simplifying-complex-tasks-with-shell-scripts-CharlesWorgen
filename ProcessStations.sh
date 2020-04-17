#!/bin/bash
# This scripted is created by Charles Huang for assignment 05. It should 1.Identify and separate out "high elevation" stations from the rest, 2.Plot the locations of all stations, while highlighting the higher elevation stations, and 3.Convert the figure into other imge formats.

#Part 1. Select data

for file in ./StationData/*
do
	ALT=$(awk 'NR==5{print $4}' $file)
	if (( $(echo "$ALT >= 200" |bc -l) ))
	then
		FILENAME=$(echo "$file")
		if [ -d "./HigherElevation" ] 
		then
   			cp $FILENAME ./HigherElevation
		else
    			mkdir ./HigherElevation
			cp $FILENAME ./HigherElevation
		fi
	fi
done

#Part 2. Combing the coordinate to produce image
awk '/Longitude/ {print -1 * $NF}' StationData/Station_*.txt > Long.list
awk '/Latitude/ {print $NF}' StationData/Station_*.txt > Lat.list
paste Long.list Lat.list > AllStation.xy

awk '/Longitude/ {print -1 * $NF}' HigherElevation/Station_*.txt > HELong.list
awk '/Latitude/ {print $NF}' HigherElevation/Station_*.txt > HELat.list
paste HELong.list HELat.list > HEStation.xy


#GMT for generating image
module load gmt
gmt set PROJ_LENGTH_UNIT = inch
gmt set PS_MEDIA = letter
gmt pscoast -JU16/4i -R-93/-86/36/43 -B2f0.5 -Ia/blue -Na/orange -Cl/blue -Dh -P -K -V > SoilMoistureStations.ps
gmt psxy AllStation.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps
gmt psxy HEStation.xy -J -R -Sc0.08 -Gred -O -V >> SoilMoistureStations.ps
gv SoilMoistureStations.ps &


#Part 3. Image conversion
ps2epsi *.ps SoilMoistureStations.epsi
gv SoilMoistureStations.epsi
convert SoilMoistureStations.epsi -density 150 SoilMoistureStations.tif

