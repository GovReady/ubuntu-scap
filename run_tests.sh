#!/bin/bash
oscap xccdf eval \
	--profile xccdf_ubuntu_profile_default \
	--cpe ubuntu-cpe.xml \
	--check-engine-results --oval-results --results results.xml \
	ubuntu-xccdf.xml
