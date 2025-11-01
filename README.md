# Opticos Repository Structure

- source/ — source files used to run the Opticos Program
- user_manual/ — PDF explaining everything you need to know about Opticos from an end user's perspective
- extras/ — miscellaneous files that aren't part of the source but we still felt were interesting to include such as animation prototypes and the Opticos logo

- requires python version 3.14 or later

# Installation
Enter the directory you want to store Opticos the repository in and clone the repository using the following command
`git clone https://github.com/Drillix08/Opticos.git`
Then enter the Opticos directory:
`cd Opticos`

Opticos requires two additional dependencies, Manim and LaTeX. The installation process for them will differ depending on the OS so from here please follow the instructions for your respective OS.

__**Linux:**__
```bash
python3 -m venv .venv # or python -m venv .venv sometimes
source .venv/bin/activate
pip3 install manim
```
Download LaTeX (for Linux I reccomend using [TeX Live](https://tug.org/texlive/quickinstall.html))

__**Windows:**__
```bash
python -m venv .venv
.venv/Scripts/activate
pip3 install manim
```
Download LaTeX (for Windows I reccomend using [MikTeX](https://miktex.org/download))

__**MacOS:**__
The installation process is a lot more involved and time consuming on Mac, so if you have trouble getting the following commands to work then you may want to consider running Opticos on a virtual Linux or Windows environment instead.
```bash
# Prerequisites
brew install pkg-config
brew install cairo

# Install a version of latex
brew install --cask basictex

python3 -m venv .venv # or python -m venv .venv sometimes
source .venv/bin/activate
pip3 install manim
```
If done correctly, Opticos should be all set to run!

