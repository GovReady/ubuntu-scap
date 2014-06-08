# This script checks <refine-value> entries:
#  a) Remove entries that correspond to Values that are not in our XCCDF file (e.g. because we didn't import those rules from SSG)
#  b) Remove entries that don't change the value from its default value.

import lxml.etree

xccdf = lxml.etree.parse("ubuntu-xccdf.xml")

for refine in xccdf.findall("//{http://checklists.nist.gov/xccdf/1.2}refine-value"):
	value = xccdf.find("//{http://checklists.nist.gov/xccdf/1.2}Value[@id='" + refine.get("idref") + "']")
	if value is None:
		print ("Not Used/Deleting:", refine.get("idref"))
		refine.getparent().remove(refine)
		continue
	selector = value.find("{http://checklists.nist.gov/xccdf/1.2}value[@selector='" + refine.get("selector") + "']")
	if selector is None:
		print ("Selector not found:", refine.get("idref"), repr(refine.get("selector")))
		continue

	try:
		default_value = [v for v in value.findall("{http://checklists.nist.gov/xccdf/1.2}value") if v.get("selector")==None][0]
	except IndexError:
		print ("No Default, Skipping:", refine.get("idref"))
		continue

	if selector.text != default_value.text:
		print ("Keeping", refine.get("idref"), "=", default_value.text, "vs.", selector.text)
		continue

	print ("Redundant/Removing", refine.get("idref"), "=", selector.text)
	refine.getparent().remove(refine)
	continue

# Write out.
xccdf.write("ubuntu-xccdf.xml", pretty_print=True)
