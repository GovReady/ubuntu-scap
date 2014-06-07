import lxml.etree

xccdf = lxml.etree.parse("ubuntu-xccdf.xml")
ssg = lxml.etree.parse("externals/scap-security-guide/RHEL/6/output/ssg-rhel6-xccdf-1.2.xml", lxml.etree.XMLParser(remove_blank_text=True))

# Look for all mentioned rules.
rules = set()
for rule in xccdf.findall("//{http://checklists.nist.gov/xccdf/1.2}select"):
	rules.add(rule.get("idref"))

# Get the element that we'll dump them into.
target_group = xccdf.find("//*[@id='xccdf_ubuntu_group_redhat']")

# Remove any existing content. We're replacing it.
for child in target_group.findall("{http://checklists.nist.gov/xccdf/1.2}Group"):
	target_group.remove(child)

def prune(group):
	# Remove rules we don't want.
	has_rules = False
	for child in group.findall('{http://checklists.nist.gov/xccdf/1.2}Rule'):
		if child.get("id") in rules:
			has_rules = True
		else:
			group.remove(child)

	# Prune all of the children.
	has_groups = False
	for child in group.findall('{http://checklists.nist.gov/xccdf/1.2}Group'):
		if prune(child):
			# This child group has rules we want.
			has_groups = True
		else:
			# If the child group does not contain any rules we need,
			# kill the whole group.
			group.remove(child)

	# Return whether this group contained any rules we want.
	return has_rules or has_groups

# Copy in the Groups from the SSG.
for group in ssg.findall('{http://checklists.nist.gov/xccdf/1.2}Group'):
	# Prune the group so we only bring in rules we want.
	if not prune(group):
		continue

	# Copy the whole group, now pruned, into the Ubuntu document.
	target_group.append(group)

# Write out.
xccdf.write("ubuntu-xccdf.xml", pretty_print=True)
