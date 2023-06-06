FROM ubuntu:20.04
LABEL maintainer="Federico 'Larroca' La rocca - flarroca@fing.edu.uy"

ENV NB_USER=gnuradio \
    NB_UID=1000 \
    NB_GID=1000 \
    SHELL=bash \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    CONDA_DIR=/opt/anaconda \
    NB_PYTHON_PREFIX=/opt/anaconda/envs/UHTE

ENV USER=${NB_USER} \
    NB_UID=${NB_UID} \
    HOME=/home/${NB_USER}

RUN apt-get update

# else it will output an error about Gtk namespace not found
RUN apt-get install -y gir1.2-gtk-3.0

# to have add-apt-repository available
RUN apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:gnuradio/gnuradio-releases-3.9

# create user gnuario with sudo (and password gnuradio)
RUN apt-get install -y sudo
RUN groupadd --gid ${NB_GID} ${NB_USER} && useradd --uid ${NB_UID} --gid ${NB_GID} --create-home --shell /bin/bash -G sudo gnuradio
RUN echo 'gnuradio:gnuradio' | chpasswd

# I create a dir at home which I'll use to persist after the container is closed (need to change it's ownership)
RUN mkdir /home/gnuradio/persistent  && chown gnuradio /home/gnuradio/persistent

RUN apt-get update

RUN apt-get install -y gnuradio

# installing other packages needed for downloading and installing OOT modules
RUN apt-get install -y gnuradio-dev cmake git libboost-all-dev libcppunit-dev liblog4cpp5-dev python3-pygccxml pybind11-dev liborc-dev

# of course, nothing useful can be done without vim
RUN apt-get install -y vim wget

ENV PYTHONPATH "${PYTHONPATH}:/usr/local/lib/python3/dist-packages"

WORKDIR /home/gnuradio

#RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh && chmod 777 Miniforge3-Linux-x86_64.sh
#CMD ["/bin/bash","-c","/Miniforge3-Linux-x86_64.sh"]
#ENV DEBIAN_FRONTEND=noninteractive
#RUN yes yes |./Miniforge3-Linux-x86_64.sh


ADD ./install-miniforge.bash /tmp/install-miniforge.bash
ADD environment.yml /tmp/environment.yml
RUN chmod 755 /tmp/install-miniforge.bash && /tmp/install-miniforge.bash

SHELL ["/bin/bash", "-c"]

# create directory for notebooks
RUN mkdir /notebooks
RUN chown -R gnuradio /notebooks /home/gnuradio
RUN chgrp -R gnuradio /notebooks /home/gnuradio
WORKDIR /notebooks

EXPOSE 8888
# start the jupyter notebook in server mode

WORKDIR /home/gnuradio
COPY ./startup.sh .

RUN chmod 755 ./startup.sh

USER gnuradio
ENV PATH="$PATH:${CONDA_DIR}/bin"

CMD ["/bin/bash","-c","./startup.sh"]
