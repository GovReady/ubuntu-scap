import lxml.etree

# Check for rules that use tests that won't work on Ubuntu and print their IDs.

unsupported_tests = (
"{http://oval.mitre.org/XMLSchema/oval-definitions-5#linux}rpminfo_test",
"{http://oval.mitre.org/XMLSchema/oval-definitions-5#linux}rpmverifyfile_test",
"{http://oval.mitre.org/XMLSchema/oval-definitions-5#unix}runlevel_test",
	)

xccdf = lxml.etree.parse("ubuntu-xccdf.xml")
oval = lxml.etree.parse("ssg-rhel6-oval.xml")

# Get a list of selected rules.
selected_rules = set()
for rule in xccdf.findall("//{http://checklists.nist.gov/xccdf/1.2}select"):
	selected_rules.add(rule.get("idref"))

# Loop through the rules.
for rule in xccdf.findall('//{http://checklists.nist.gov/xccdf/1.2}Rule'):
	if rule.get("id") not in selected_rules: continue
	for check in rule.findall('.//{http://checklists.nist.gov/xccdf/1.2}check-content-ref'):
		name = check.get("name")
		href = check.get("href")
		definition = oval.find("//*[@id='" + name + "']")
		if definition is None: continue
		for criterion in definition.findall('.//{http://oval.mitre.org/XMLSchema/oval-definitions-5}criterion'):
			test = oval.find("//*[@id='" + criterion.get("test_ref") + "']")
			if test.tag in unsupported_tests:
				print (rule.get("id"))
