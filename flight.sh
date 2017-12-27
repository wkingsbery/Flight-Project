if [ $# -eq 1 ]
then
   debug=true
else
   debug=false
fi

clear

rm -f errlog.txt

wget -qO- https://opensky-network.org/api/states/all >a1
sed s/"],"/"],\n"/g < a1 > a2
echo "Pick an airline company or country to get flights from"
read choice2

grep $choice2 a2 > a3
sed s/" "/"_"/g <a3 >a4

echo "Would you like an email (1), text (2), or neither (any other number) with the flights you selected?"
read choice

if [ $choice -eq 1 ]
then
        cat a4 | mailx wkingsbery@fordham.edu
elif [ $choice -eq 2 ]
then
        cat a4 | mailx 9732299047@vtext.com

fi

row=1
colm=2
counter=0

# $ cat a4 | mailx wkingsbery@fordham.edu

#
# 2 = green, 0 = black
#
echo "What color would you like the background to be?  The choices are"
echo "0- Black"
echo "1- Red"
echo "2- Green"
echo "3- Yellow"
echo "4- Blue"
echo "5- Magenta"
echo "6- Cyan"
echo "7- White"
read choice3
if [ $choice3 -eq 0 ]
then
        tput setab 0;
	tput setaf 7;

elif [ $choice3 -eq 1 ]
then
        tput setab 1;
        tput setaf 0;

elif [ $choice3 -eq 2 ]
then
        tput setab 2;
        tput setaf 0;

elif [ $choice3 -eq 3 ]
then
        tput setab 3;
        tput setaf 0;

elif [ $choice3 -eq 4 ]
then
	tput setab 4;
	tput setaf 0;

elif [ $choice3 -eq 5 ]
then
        tput setab 5;
        tput setaf 0;

elif [ $choice3 -eq 6 ]
then
        tput setab 6;
        tput setaf 0;

elif [ $choice3 -eq 7 ]
then
        tput setab 7;
        tput setaf 0;
fi
clear
counter=0
flightCount=$(cat a4 | wc -l)
while [ $flightCount -ne $counter ]
do
   for line in `cat a4`
   do
      if [ $debug = "true" ]
      then
         echo "---------------------------------------------------------------------" >> errlog.txt
         echo $line                                                                   >> errlog.txt
      fi
     
      transponder=`echo $line | cut -c3-8`
      flightNum=`echo $line   | awk -F, '{print $2}'`
      country=`echo $line     | awk -F, '{print $3}'`
      onTheGround=`echo $line | awk -F, '{print $9}'`

      if [ $debug = "true" ]
      then
         echo "trans=$transponder" >> errlog.txt
         echo "flight=$flightNum" >> errlog.txt
         echo "country=$country" >> errlog.txt
      fi

      if [ $onTheGround = "true" ]
      then
         continue
      fi

      tput cup $row $colm;
      echo "                                                             "
      tput cup $row $colm;
      echo "$transponder       $flightNum      $country"
 
      wget -qO- https://opensky-network.org/api/states/all?icao24=$transponder >t1
      echo >> t1

      size=`cat t1 | wc -c | awk '{print $1}'`
      if [ $size -gt 60 ]
      then
         if [ $debug = "true" ]
         then
            cat t1 >> errlog.txt
         fi

         latitude=`cat t1 | awk -F, {'print $8}'`
         longitude=`cat t1 | awk -F, {'print $7}'`

         if [ $latitude = "null" ] || [ $longitude = "null" ]
         then 
            continue
         fi

         if [ $debug = "true" ]
         then
            echo "lat=$latitude  long=$longitude" >> errlog.txt
         fi
 
         wget -qO- http://maps.google.com/maps/api/geocode/xml?latlng=$latitude,$longitude\&sensor=false >g1
         location=`grep "<formatted_address>" g1 | head -1 | sed s/"<formatted_address>"/""/g | sed s/"<\/formatted_address>"/""/g`

         if [ $debug = "true" ]
         then
            echo "LOC=$location" >> errlog.txt
         fi

         row=$((row + 1))

         size=`echo $location | wc -c | awk '{print $1}'`
         if [ $size -gt 10 ]
         then
            tput cup $row $colm;
            echo "                                                              "
            tput cup $row $colm;
            echo "$location"
         else
            tput cup $row $colm;
            echo "   - OVER WATER -                                             "
         fi

         row=$((row + 2))
      else
         row=$((row + 3))
      fi

      counter=$((counter + 1))
   done

   sleep 10

   row=1
   colm=2
   counter=0

done
