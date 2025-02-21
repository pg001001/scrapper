#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install -y dos2unix
sudo apt install python3.11 -y
sudo apt install python3-venv -y
sudo apt install poppler-utils -y
sudo apt install wget -y

# python3 -m venv myenv
# source myenv/bin/activate
# pip install PyPDF2
# deactivate

