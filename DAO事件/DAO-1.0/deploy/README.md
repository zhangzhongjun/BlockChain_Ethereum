# Scripts for DAO deployment using geth

## Introduction

`prepare.py` compiles `DAO.sol` and populates some helper variables inside `prepare.js`

1. `loadScript("prepare.js")` loads these variables into geth.
2. `loadScript("deploy.js")` deploys them.

## Example usage

At the moment of writting of this README the usage of the prepare script is:

```
usage: prepare.py [-h] [--solc SOLC] [creation-duration-mins CREATION_DURATION_MINS]

DAO deployment script

optional arguments:
  -h, --help            show this help message and exit
  --solc SOLC           Full path to the solc binary to use
  creation-duration-mins CREATION_DURATION_MINS
                        Deployed DAO Creation duration in minutes
```

You can for example call the script with a specifically compiled solc and set
the creation to end in 15 mins by doing:

```
./prepare.py --solc ~/ew/solidity/build/solc/solc creation-duration-mins 15
```
