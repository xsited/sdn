#!/bin/bash 



# Documentation and Notes
# =======================
# Required Linux components:
# sudo apt-get install vlc vlc-nox libavcodec-extra-53

#on linux
vlc_path="vlc"
#on mac
# echo "alias vlc='/Applications/VLC.app/Contents/MacOS/VLC -I rc'" >> ~/.bash_profile
vlc_path=""/Applications/VLC.app/Contents/MacOS/VLC
# windows?
vlc_path="%ProgramFiles(x86)%\VideoLAN\VLC\vlc.exe"

cam_device="/dev/video0"
vlc_path="cvlc"
#mine
video_file="./test.mp4"
#yours
video_file="~/Desktop/non.mp3"
video_url="http://iipr.com/test.mp4"

instnum=2
menu()
{
    echo "Streaming Server "
    echo "================ "
    echo "1) Stream the CAM using WMV over HTTP" 
    echo "2) Stream the CAM using TS over HTTP" 
    echo "3) Stream the CAM using MS-WMV over HTTP for Windows Media Player (not tested)"
    echo "4) Stream a Video file over RTSP" 
    echo "5) Stream a Video URL over TS over HTTP" 
    echo "Quit" 
    echo  "Enter choice : "
    read instnum
}    

 

case "$instnum" in
  1)  
    echo "Starting CAM to HTTP/WMV server ..."
    cvlc v4l2:// :v4l2-vdev="/dev/video0" --sout '#transcode{vcodec=x264{keyint=60,idrint=2},vcodec=h264,vb=400,width=368,heigh=208,acodec=mp4a,ab=32 ,channels=2,samplerate=22100}:duplicate{dst=std{access=http{mime=video/x-ms-wmv},mux=asf,dst=:8082/stream.wmv}}'

   echo "Example of starting the client from another machine using the command line:"
   echo "vlc  http://192.168.1.4:8082/stream.wmv"
    ;;
  2)  
    echo "Starting CAM to HTTP/TS server ..."
# try this for orginally document http stream with ts transcoding
   cvlc -vvv v4l2:// :v4l-vdev="/dev/video0" --sout '#transcode{vcodec=h264,vb=800,scale=1,acodec=mpga,ab=128,channels=2,samplerate=44100}:http{mux=ts,dst=:8080/}' --no-sout-audio

   echo "Example of starting the client from another machine using the command line:"
   # tested!!!
   echo "mplayer http://192.168.200.100:8080/"
   echo "vlc http://192.168.200.100:8080/"
    ;;
  3)  
    echo "Starting CAM using HTTP/MS-WMV server ..."
   # example to encode for windows media ????
   cvlc v4l2:// :v4l2-vdev="dshow://" --sout '#transcode{vcodec=x264{keyint=60,idrint=2},vcodec=h264,vb=400,width=368,heigh=208,acodec=mp4a,ab=32 ,channels=2,samplerate=22100}:duplicate{dst=std{access=http{mime=video/x-ms-wmv},mux=asf,dst=:8082/stream.wmv}}' --no-sout-audio

   echo "Example of starting the client from another machine using the command line:"
   #WindowsMedia from the command line use:
   # untested !!!!
   echo "Mplayer2.exe /play http://192.168.200.100:8082/stream.wmv"
   echo "Mplayer2.exe http://192.168.200.100:8080/"
    ;;
  4) 
    echo "Starting File $video_file to RTSP video streaming"
    sleep 2 
    cvlc -vvv $video_file --sout '#rtp{dst=192.168.1.5,port=1234,sdp=rtsp://192.168.1.4:8081/test.sdp}'
    # Why do we have to hard code the IP address of both the server and the client -- it wont work with 2 clients?
    # cvlc -vvv $video_file --sout '#rtp{sdp=:8081/test.sdp}'
    # Shouldn't we generalize and  document this?

    echo "Example of starting the client from another machine using the command line:"
    echo "vlc rtsp://192.168.1.4:8081/test.sdp"
    ;;

  5) 
    echo "Starting URL $video_url to HTTP/TS server ..."
    $vlc_path -vvv "$video_url" --sout '#transcode{vcodec=h264,vb=800,scale=1,acodec=mpga,ab=128,channels=2,samplerate=44100}:http{mux=ts,dst=:8080/}' 
    echo "Example of starting the client from another machine using the command line:"
   echo "vlc http://192.168.200.100:8080/"
    ;;
  q | Q ) exit
   ;;
  *) echo "Option number $instnum is not valid"
   ;;
esac


