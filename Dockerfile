FROM nvidia/cuda:10.2-base


RUN apt-get -y update
RUN apt-get -y upgrade
###RUN apt-get install -y sshfs
###RUN apt-get install net-tools -y
###RUN apt-get install -y nvidia-modprobe

###Not needed, but installing to prevent an annoying warning
RUN apt-get install apt-utils -y
###For downloading 
RUN apt-get -y install -y nano wget
RUN apt-get -y install libxml2 libstdc++6 gcc

###So that I can build FFMPEG for the container. The source
###code will be pulled from a repository
	
RUN apt-get -y install git

#Extending library path to resolve error with a shared library not being found
RUN echo "/usr/lib/x86_64-linux-gnu/libxml2.so.2" >> /etc/ld.so.conf
RUN echo "/usr/lib/x86_64-linux-gnu/libxml2.so.2" >> /etc/ld.so.conf.d/.conf
RUN ldconfig

###Download the CUDA Toolkit. I am only installing the toolkit and not the drivers. 
###   The toolkit is needed for compilation of FFMPEG. The drivers should already be 
###   present in the base Docker image
RUN wget https://developer.download.nvidia.com/compute/cuda/11.6.2/local_installers/cuda_11.6.2_510.47.03_linux.run
RUN chmod +x cuda_11.6.2_510.47.03_linux.run
RUN ./cuda_11.6.2_510.47.03_linux.run --silent --toolkit

##Using WORKDIR here to build out a folder tree that I want
WORKDIR /shares
WORKDIR /shares/video
WORKDIR /shares/ffmpegbin


###COPY ./ffmpegbin ./

###For Building FFMPEG in the container
RUN apt-get install -y build-essential yasm cmake libtool libc6 libc6-dev unzip wget libnuma1 libnuma-dev
WORKDIR /shares/build
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
WORKDIR /shares/build/nv-codec-headers
RUN make install


WORKDIR /shares/build
RUN git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg/
WORKDIR /shares/build/ffmpeg
RUN ./configure --enable-nonfree --enable-cuda-nvcc --enable-libnpp --extra-cflags=-I/usr/local/cuda/include --extra-ldflags=-L/usr/local/cuda/lib64 --disable-static --enable-shared
RUN make -j 8
RUN make install



EXPOSE 22
EXPOSE 80
EXPOSE 8080


COPY ./escape.m4v ./
CMD nvidia-smi

CMD ffmpeg -hwaccel cuda  -i "/app/escape.m4v"   -movflags faststart "/app/escape.mp4" -y
