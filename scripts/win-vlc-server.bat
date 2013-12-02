@echo off

"%ProgramFiles(x86)%\VideoLAN\VLC\vlc.exe" -vvv v4l2:// :v4l-vdev="dshow://" --sout '#transcode{vcodec=h264,vb=800,scale=1,acodec=mpga,ab=128,channels=2,samplerate=44100}:http{mux=ts,dst=:8080/}' --no-sout-audio
rem "%ProgramFiles(x86)%\Windows Media Player\wmplayer.exe" http://192.168.200.100:8080/