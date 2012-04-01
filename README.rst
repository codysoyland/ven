===
ven
===

Virtualenv management refined.

Features
========

I wrote ``ven`` as alternative to ``virtualenvwrapper`` with the following features:

- Localize virtualenvs in their project directories (Although a global environment container can be configured with VEN_DIR)
- Emulate git's interface (using subcommands and a .ven directory)
- Make it easy to branch a virtualenv to inherit from another (using ``ven new <name> -i <old>``)
- Bash completion support

Usage
=====

ven init
    initialize a new virtualenv container
ven list
    show all virtualenvs
ven new
    make new virtualenv
ven switch
    deactivate current virtualenv and activate another one
ven delete
    remove a virtualenv from the list
ven help
    show help

Installation
============

Add the following to your ``.bash_profile`` or ``.bashrc``::

    source /path/to/ven.sh

Contributing
============

``ven`` is licensed under BSD. Please fork and contribute!
