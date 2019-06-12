# osx-bootstrap-install

[![GitHub license](https://img.shields.io/github/license/0x4e3/osx-bootstrap.svg)](https://github.com/0x4e3/osx-bootstrap/blob/master/LICENSE)

This script is a main entypoint to bootstrap fresh Mac OS X with all settings and tool required for Python full stack development.

Procedure has tree steps:
* preparing all to be able to run ansible playbooks;
* downloading playbook and roles;
* playing :violin:

## Content

Full procedure contains:
* ```bootstrap.sh``` script from this repository;
* [osx-bootstrap](https://github.com/0x4e3/osx-bootstrap) ansible playbook;
* all roles mentioned in the playbook (you can find full list of roles in the playbook's repository README).

## Getting Started

### Disclaimer

Requires Mac OS X 10.9+
Bootstrap procedure has been tested with Mac OS X 10.12 and 10.13.

### Basic installation

Procedure starts by running this script, so run next commend in your command-line:

```bash
sh -c "$(curl -fsSL https://github.com/0x4e3/osx-bootstrap-install/raw/master/bootstrap.sh)"
```

If you want to install ansible playbook from specific branch (not from "master" branch), you can run:  

```bash
curl -fsSL https://github.com/0x4e3/osx-bootstrap-install/raw/master/bootstrap.sh | bash -s <branch_name>
```

Also you can download the script from the repository manually.  

## Getting updates

If you use zsh with oh-my-zsh, you already have pre-configured ```alias``` to re-run bootstrap. Just run:

```bash
osx-bootstrap
```

and all procedure will be repeated.

Once again, you can re-run script manually.

## Configuring

The script has four main variables:
* ```version``` -- branch or tag to clone playbook from;
* ```source_dir``` -- directory path for playbook source;
* ```remote_source``` -- playbook's repository address;
* ```host_name``` -- your host name.

If you provide an argument to the script, it's value will be saved to the ```version``` variable, so you can controll the branch or tag name for your ansible playbook repository. 

## TODOs

* [ ] add configuration via command-line arguments;
