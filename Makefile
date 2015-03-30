prereqs:
	sudo apt-get install git wget unzip expat

# This build target clones the SSG repository and runs its make command
# to build the RHEL6 tests. We are using just their OVAL file.
ssg: prereqs
	mkdir -p externals
	cd externals; git clone git://git.fedorahosted.org/git/scap-security-guide.git
	cd externals/scap-security-guide; make rhel6
	cp externals/scap-security-guide/RHEL/6/output/ssg-rhel6-oval.xml .

usgcb:
	sudo apt-get install xsltproc expat
	mkdir -p externals/usgcb
	wget -O /tmp/usgcb.zip http://usgcb.nist.gov/usgcb/content/scap/USGCB-rhel5desktop-1.0.5.0.zip
	cd externals/usgcb; unzip /tmp/usgcb.zip
	rm /tmp/usgcb.zip
