ubuntu-scap
===========

Security validation for Ubuntu 12.04/14.04 (work in progress).

Security Content Automation Protocol (SCAP) is a set of standards for automated security auditing of computer systems. While SCAP tests exist for other platforms such as Red Hat Enterprise Linux, no comprehensive set of tests exists for Ubuntu. This project is an attempt to create a SCAP profile for Ubuntu 12.04/14.04.

This project contains:

* `ubuntu-xccdf.xml`: An Ubuntu profile listing tests to run, in [XCCDF 1.2](http://scap.nist.gov/specifications/xccdf/xccdf_element_dictionary.html) format. This is the main file.
* `ssg-rhel6-oval.xml`: Test definitions from the [scap-security-guide](https://fedorahosted.org/scap-security-guide/) project for testing Red Hat Enterprise Linux 6, as of 2014-06-06, some of which also apply to Ubuntu.
* `run_tests.sh`: An example for calling [OpenSCAP](http://open-scap.org/page/Main_Page) to run the tests.
* `ubuntu-cpe.xml` and `ubuntu-cpe-oval.xml` which define "Ubuntu" for the purposes of the test profiles.
* `Vagrantfile`: A Vagrant configuration for a clean Ubuntu 14.04 server that you can test the profile on.

Installing
----------
To install ubuntu-scap on a ubuntu Linux machine:

	sudo apt-get install libopenscap8
	git clone https://github.com/GovReady/ubuntu-scap.git
	cd ubuntu-scap

Running Tests
-------------

To run these tests on a machine:

	# Start in ubuntu-scap directory
	cd /path/to/ubuntu-scap
	./run_tests.sh

Or start up a virtual machine in Vagrant so you can test in an isolated environment:

	sudo apt-get install vagrant
	vagrant up
	vagrant ssh
	# now you're inside the virtual machine
	cd /vagrant
	sudo ./run_tests.sh

Reading Results
---------------
Results are generated in xml and optionally html reports.

Install lynx browser to read html reports from command line:

	sudo apt-get install lynx
	# read report
	lynx report-name.html

Project Development
-------------------

The `ubuntu-xccdf.xml` file is compiled from other input files:

* `ssg-rhel6-xccdf-1.2.xml` from the [scap-security-guide](https://fedorahosted.org/scap-security-guide/) is placed iside the group named `xccdf_ubuntu_group_redhat`.
* that's all so far

To "compile" `ubuntu-xccdf.xml`:

	# apt-get install some prerequisites needed by the scap-security-guide
	make prereqs

	# download the scap-security guide, compile its ssg-rhel6-xccdf-1.2.xml file, and copy its ssg-rhel6-oval.xml here
	make ssg

	# update ubuntu-xccdf.xml with content from the scap-security-guide
	python import-ssg.py

TODO
----

* Vet the RHEL6 rules to see what we need and don't need.
* Update RHEL6 rules that could apply to Ubuntu but need tweeks.
* Compare to the United States Government Configuration Baseline (USGCB)

Acknowledgements
----------------

Thanks to http://blog.siphos.be/2013/12/running-a-bit-with-the-xccdf-document/.
