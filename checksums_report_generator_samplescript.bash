#!/bin/bash

# A simple script for generating checksums for an entire directory
# structure (and it then sends reports to a specific email address)
# which may be of use to our users. You’ll likely want to modify it
# slightly for other users’ needs — please do come ask me about
# modifying and running it before using it.
#
# Example use case: you would like to see which files have been
# modified by users on a regular (e.g., weekly) basis.
#
# the files containing previous checksums are hidden
# the code searches through the current directory and all subdirectories, and prints the checksums to a file
# the script output is in file checksums[date+time].txt
# the -f flag forces the script to run. Without it, the script searches to find a checksums file 
# created 14 days ago or earlier before running

# set email address for reports  
emailaddress="tharsen@uchicago.edu"

if [ $(ls check* 2> /dev/null | wc -l) == 1 ]; then
  # create a checksum file if none exists yet
  date_=`date +"%Y%m%d%H%M%S"`
  find .. -type f -name "*" -exec sha256sum {} + > checksums${date_}.txt  
  #timediff="0"
else 
  # extract date from title of last checksum file
  #checksum_name=$(find ./ -type f -name "checksums*.txt")
  checksum_name=$(ls -t checksums*.txt | head -1)
  checksum_dstr=${checksum_name#*sums}  
  cyear=${checksum_dstr:0:4} 
  cmonth=${checksum_dstr:4:2} 
  cday=${checksum_dstr:6:2} 
  # get the difference in seconds between today's date and the date of last checksum file
  timediff=$(expr $(date '+%s') - $(date '+%s' -d ${cyear}-${cmonth}-${cday}))
fi   

if [ "$1" == "-f" ];then
  echo "-f flag detected (forces new checksums report to be created)"
fi

if [ $timediff -gt $((14*24*60*60)) ] || [ "$1" == "-f" ]; then
  #  echo "the time difference is greater than 14 days"
  #set full date string
  fds1=`date +"%F"`
  fds2=`date +"%T"`
  fulldatestring="${fds1} at ${fds2}"
  echo "Current Date and Time : $fulldatestring"
  # generate today's checksums and store them in a new checksum file
  date_=`date +"%Y%m%d%H%M%S"`
  find .. -type f -name "*" -exec sha256sum {} + > checksums${date_}.txt  
  # check the above file against last checksum file
  echo "Previous checksums report file: $checksum_name"
  echo "New checksums report file created: checksums${date_}.txt"

  if [[ -z $(diff checksums${date_}.txt $checksum_name | grep -v "checksums" | grep -v "^[0-9]\+,*[0-9]*[cad][0-9]\+,*[0-9]*$" | grep -v "^\-\-\-$") ]]; then
    nochanges="There have not been changes to any files besides the checksums report files themselves (see below).\n\n"
  else
    nochanges=" "
  fi
  
#  send report to screen
  diff $checksum_name checksums${date_}.txt | awk -v "nochanges=${nochanges}" -v file1="${checksum_name}" -v "file2=checksums${date_}.txt" '
BEGIN{
print nochanges 
print "Checksums report :"
}
#test if the first field is an instruction (4a5 ; 4,7c6,22 ; )
{
  if ( $1 ~ /[0-9]*[,]*[0-9]+[a][0-9]*[,]*[0-9]+/ ) {
    split($1, a, "a")
    sub(",","-",a[1])
    sub(",","-",a[2])
    print "\n  Files added since checksums report " file1 " :\n"
  }
  else  if ( $1 ~ /[0-9]*[,]*[0-9]+[c][0-9]*[,]*[0-9]+/ ) {
    split($1, a, "c")
    sub(",","-",a[1])
    sub(",","-",a[2])
    print "\n  The checksums in these files have changed since the previous checksums report :\n"
  }
  else if ( $1 ~ /[0-9]*[,]*[0-9]+[d][0-9]*[,]*[0-9]+/ ) {
    split($1, a, "d")
    sub(",","-",a[1])
    sub(",","-",a[2])
    print "\n  Files deleted since checksums report " file1 " :\n"
  }
  else if ( $1 ~ /[-]+/ ) {
    print "\n  The current checksums are now :\n"
  }
  else{
    print "      " $0
  } 
}' | tr '<>' '-' 
 
#  send report via email
  diff $checksum_name checksums${date_}.txt | awk -v "nochanges=${nochanges}" -v "file1=${checksum_name}" -v "file2=checksums${date_}.txt" '
BEGIN{
print nochanges
print "Checksums report :"
}
#test if the first field is an instruction (4a5 ; 4,7c6,22 ; )
{
  if ( $1 ~ /[0-9]*[,]*[0-9]+[a][0-9]*[,]*[0-9]+/ ) {
    split($1, a, "a")
    sub(",","-",a[1])
    sub(",","-",a[2])
    print "\n  Files added since checksums report " file1 " :\n"
  }
  else  if ( $1 ~ /[0-9]*[,]*[0-9]+[c][0-9]*[,]*[0-9]+/ ) {
    split($1, a, "c")
    sub(",","-",a[1])
    sub(",","-",a[2])
    print "\n  The checksums in these files have changed since the previous checksums report :\n"
  }
  else if ( $1 ~ /[0-9]*[,]*[0-9]+[d][0-9]*[,]*[0-9]+/ ) {
    split($1, a, "d")
    sub(",","-",a[1])
    sub(",","-",a[2])
    print "\n  Files deleted since checksums report " file1 " :\n"
  }
  else if ( $1 ~ /[-]+/ ) {
    print "\n  The current checksums are now :\n"
  }
  else{
    print "      " $0
  } 
}' | tr '<>' '-' | mail -s "Checksum Differences Report for $fulldatestring" $emailaddress
  #  delete previous checksum file? *** No ***
  #  rm $checksum_name
fi
  # create a checksum file if user enters flag "-f"
exit 1
