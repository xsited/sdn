#!/bin/bash 

# Documentation and Notes
# =======================
# Required Linux components:
# sudo apt-get install vlc vlc-nox libavcodec-extra-53

#on linux
vlc_path="vlc"
#on mac
# echo "alias vlc='/Applications/VLC.app/Contents/MacOS/VLC -I rc'" >> ~/.bash_profile
vlc_path="/Applications/VLC.app/Contents/MacOS/VLC"
# windows?
vlc_path="%ProgramFiles(x86)%\VideoLAN\VLC\vlc.exe"

    echo "this script for streaming server "
    echo "1-for streaming cam http" 
    echo "2-for streaming video using http" 
    echo "3-for streaming video using rtsp" 
    echo "4-for streaming MS-WMV"
    echo "5-for exit" 
    sleep 2
    echo  "Enter choice : "
    read instnum
    
#1-for streaming cam http 
#2-for streaming video using http 
#3-for streaming video using rtsp 
#4-for streaming MS-WMV
#5-for exit 
 
case "$instnum" in
  1)  
    echo "starting webcam using http..."
    sleep 2
    cvlc v4l2:// :v4l2-vdev="/dev/video0" --sout '#transcode{vcodec=x264{keyint=60,idrint=2},vcodec=h264,vb=400,width=368,heigh=208,acodec=mp4a,ab=32 ,channels=2,samplerate=22100}:duplicate{dst=std{access=http{mime=video/x-ms-wmv},mux=asf,dst=:8082/stream.wmv}}'

#Client from the command line use:
#cvlc  http://192.168.1.4:8082/stream.wmv
    ;;
 
  2)  
    echo "Starting HTTP/TS video streaming ..."
    sleep 2
    vlc -vvv ~/Desktop/non.mp3 --sout '#transcode{vcodec=h264,vb=800,scale=1,acodec=mpga,ab=128,channels=2,samplerate=44100}:http{mux=ts,dst=:8080/}'
    #Client from the command line use:
    cvlc  http://192.168.1.4:8080

    ;;
  3) 
    echo "starting  rtsp video streaming"
    sleep 2 
    vlc -vvv ~/Desktop/non.mp3 --sout '#rtp{dst=192.168.1.5,port=1234,sdp=rtsp://192.168.1.4:8080/test.sdp}'
    #on the client side
    #cvlc rtsp://192.168.1.4:8080/test.sdp
   ;;
  
   4)     
     echo "Starting MS-WMV server ..."
     sleep 2
     # example to encode for windows media ????
     cvlc v4l2:// :v4l2-vdev="dshow://" --sout '#transcode{vcodec=x264 
{keyint=60,idrint=2},vcodec=h264,vb=400,width=368,heigh=208,acodec=mp4a,ab=32 ,channels=2,samplerate=22100}:duplicate{dst=std{access=http{mime=video/x-ms-wmv},mux=asf,dst=:8082/stream.wmv}}' --no-sout-audio

     #WindowsMedia from the command line use:
     #Mplayer2.exe /play http://192.168.200.100:8082/stream.wmv
     #Mplayer2.exe http://192.168.200.100:8080/
    
    ;;
  
   5) exit
    ;;
   
   *) echo "Option number $instnum is not valid"
   ;;


esac


