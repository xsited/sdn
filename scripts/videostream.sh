#!/bin/bash


# Are we saying that the video source can be local or external URI?
# URL verification could be more of a challenge.  Perhaps wget might be a way.

# either pull from an external source 
# use a local source  
video="test.mp4"
video="http://iipr.com/test.mp4"
# rtsp is the default or optionally use http to punch through firewall
server_protocol="http"
server_protocol="rtsp"
# is it possible to use no server ip or 0.0.0.0 to stream from all possible interfaces
server_ip="192.168.1.3"
server_port="8080"
# what is the purpose of server path?  Is it needed?
server_path=""
server_path="test.sdp"

#on mac
# echo "alias vlc='/Applications/VLC.app/Contents/MacOS/VLC -I rc'" >> ~/.bash_profile
vlc_path=""/Applications/VLC.app/Contents/MacOS/VLC

# on windows
vlc_path="%ProgramFiles(x86)%\VideoLAN\VLC\vlc.exe"

#on linux
vlc_path="vlc"

check_url()
{
    if hash wget 2>/dev/null; then
        if wget -q --spider $1; then
          echo "wget URL exists: $1"
          return 0
        else
          echo "wget URL does not exist: $1"
        fi
    else
        if curl --output /dev/null --silent --head --fail "$video"; then
          echo "curl URL exists: $1"
          return 0
        else
          echo "curl URL does not exist: $1"
        fi
    fi
    return 1
}


#if [[ "$video" =~ "http:*" ]]
if [[ "$video" == http* ]]
then
   check_url $video
   if [ $? -ne 0 ]; then
        echo "Video URL does not exist: $video" 
	exit 1
   fi

else
    echo "Not a URL: $video"
    #echo "Enter video path to stream "
    #read video 
    if [ ! -a "$video" ]
    then 
        echo "Video file does not exist: $video" 
	exit 1
    fi 
fi

echo "Ready to start video stream ..." 
#$vlc_path -vvv  "$video" --sout '#rtp{dst= ,port=1234,sdp=$server_protocol://$server_ip:$server_port/$server_path}'
$vlc_path -vvv "$video" --sout '#transcode{vcodec=h264,vb=800,scale=1,acodec=mpga,ab=128,channels=2,samplerate=44100}:http{mux=ts,dst=:8080/}' 

