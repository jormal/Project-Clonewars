FROM ocaml/opam2:ubuntu-18.04
WORKDIR /home/opam/

LABEL maintainer="jormal <jormal@korea.ac.kr>"
LABEL name="ir-translator"
LABEL version="1.0.0"

# Install Dependencies
RUN sudo apt-get -y -qq update
RUN sudo apt-get -y -qq upgrade
RUN sudo apt-get -y -qq install apt-utils software-properties-common
RUN sudo apt-get -y -qq install unzip pkg-config build-essential
RUN sudo apt-get -y -qq install m4 python2.7 libgmp-dev mercurial darcs
RUN sudo apt-get -y -qq install ocamlbuild ocaml-native-compilers

# Install Solidity
RUN sudo curl -L -o /bin/solc_0.4.16 https://github.com/ethereum/solidity/releases/download/v0.4.16/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.4.16
RUN sudo curl -L -o /bin/solc_0.4.17 https://github.com/ethereum/solidity/releases/download/v0.4.17/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.4.17
RUN sudo curl -L -o /bin/solc_0.4.18 https://github.com/ethereum/solidity/releases/download/v0.4.18/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.4.18
RUN sudo curl -L -o /bin/solc_0.4.19 https://github.com/ethereum/solidity/releases/download/v0.4.19/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.4.19
RUN sudo curl -L -o /bin/solc_0.4.20 https://github.com/ethereum/solidity/releases/download/v0.4.20/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.4.20
RUN sudo curl -L -o /bin/solc_0.4.21 https://github.com/ethereum/solidity/releases/download/v0.4.21/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.4.21
RUN sudo curl -L -o /bin/solc_0.4.22 https://github.com/ethereum/solidity/releases/download/v0.4.22/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.4.22
RUN sudo curl -L -o /bin/solc_0.4.23 https://github.com/ethereum/solidity/releases/download/v0.4.23/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.4.23
RUN sudo curl -L -o /bin/solc_0.4.24 https://github.com/ethereum/solidity/releases/download/v0.4.24/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.4.24
RUN sudo curl -L -o /bin/solc_0.4.25 https://github.com/ethereum/solidity/releases/download/v0.4.25/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.4.25
RUN sudo curl -L -o /home/opam/solc_0.4.26.zip https://github.com/ethereum/solidity/releases/download/v0.4.26/solidity-ubuntu-trusty.zip \
    && sudo mkdir /home/opam/solc_0.4.26/ && sudo unzip /home/opam/solc_0.4.26.zip -d /home/opam/solc_0.4.26/ \
    && sudo cp /home/opam/solc_0.4.26/solc /bin/solc_0.4.26 \
    && sudo chmod a+x /bin/solc_0.4.26 && sudo rm -rf /home/opam/solc_0.4.26/ && sudo rm /home/opam/solc_0.4.26.zip
RUN sudo curl -L -o /bin/solc_0.5.1 https://github.com/ethereum/solidity/releases/download/v0.5.1/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.1
RUN sudo curl -L -o /bin/solc_0.5.2 https://github.com/ethereum/solidity/releases/download/v0.5.2/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.2
RUN sudo curl -L -o /bin/solc_0.5.3 https://github.com/ethereum/solidity/releases/download/v0.5.3/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.3
RUN sudo curl -L -o /bin/solc_0.5.4 https://github.com/ethereum/solidity/releases/download/v0.5.4/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.4
RUN sudo curl -L -o /bin/solc_0.5.5 https://github.com/ethereum/solidity/releases/download/v0.5.5/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.5
RUN sudo curl -L -o /bin/solc_0.5.6 https://github.com/ethereum/solidity/releases/download/v0.5.6/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.6
RUN sudo curl -L -o /bin/solc_0.5.7 https://github.com/ethereum/solidity/releases/download/v0.5.7/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.7
RUN sudo curl -L -o /bin/solc_0.5.8 https://github.com/ethereum/solidity/releases/download/v0.5.8/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.8
RUN sudo curl -L -o /bin/solc_0.5.9 https://github.com/ethereum/solidity/releases/download/v0.5.9/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.9
RUN sudo curl -L -o /bin/solc_0.5.10 https://github.com/ethereum/solidity/releases/download/v0.5.10/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.10
RUN sudo curl -L -o /bin/solc_0.5.11 https://github.com/ethereum/solidity/releases/download/v0.5.11/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.11
RUN sudo curl -L -o /bin/solc_0.5.12 https://github.com/ethereum/solidity/releases/download/v0.5.12/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.12
RUN sudo curl -L -o /bin/solc_0.5.13 https://github.com/ethereum/solidity/releases/download/v0.5.13/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.13
RUN sudo curl -L -o /bin/solc_0.5.14 https://github.com/ethereum/solidity/releases/download/v0.5.14/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.14
RUN sudo curl -L -o /bin/solc_0.5.15 https://github.com/ethereum/solidity/releases/download/v0.5.15/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.15
RUN sudo curl -L -o /bin/solc_0.5.16 https://github.com/ethereum/solidity/releases/download/v0.5.16/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.16
RUN sudo curl -L -o /bin/solc_0.5.17 https://github.com/ethereum/solidity/releases/download/v0.5.17/solc-static-linux \
    && sudo chmod a+x /bin/solc_0.5.17

# Install OCaml Dependencies
RUN opam init
RUN opam update
RUN opam switch 4.07
RUN opam install -y ocamlbuild
RUN opam install -y -j 8 "batteries>=2.9.0" "yojson>=1.7.0" "ocamlgraph>=1.8.8"

# Install IR translator
ADD ./translator ./translator
RUN sudo chmod -R a+rwx ~/translator
RUN eval $(opam config env) && cd ~/translator/ && ~/translator/build
RUN ln -s ~/translator/_build/main.native ~/main.native && sudo chmod a+x ~/main.native

RUN mkdir ~/input && mkdir ~/output

ENTRYPOINT [ "/home/opam/main.native" ]