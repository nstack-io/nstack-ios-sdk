TM_PLIST=TranslationManager/Supporting Files/Info.plist
CURRENT_BRANCH=$(shell git branch | sed -n -e 's/^\* \(.*\)/\1/p')

release:
ifneq ($(CURRENT_BRANCH),master)
	$(error not on master branch, can't make a release)
endif
ifneq ($(strip $(shell git status --untracked-files=no --porcelain 2>/dev/null)),)
	$(error git state is not clean)
endif
	$(eval NEW_VERSION_AND_NAME := $(filter-out $@,$(MAKECMDGOALS)))
	$(eval NEW_VERSION := $(shell echo $(NEW_VERSION_AND_NAME) | sed 's/:.*//' ))
	@sed -i '' 's/## Master/## $(NEW_VERSION_AND_NAME)/g' CHANGELOG.md
	@echo "## Master" | cat - CHANGELOG.md > /tmp/out && mv /tmp/out CHANGELOG.md
	@sed -i '' 's/spec.version      = ".*"/spec.version      = "${NEW_VERSION}"/g' TranslationManager.podspec
	@/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $(NEW_VERSION)" "$(TM_PLIST)"
	git commit -a -m "release $(NEW_VERSION)"
	git tag -a $(NEW_VERSION) -m "$(NEW_VERSION_AND_NAME)"
	git push origin master
	git push origin $(NEW_VERSION)
	pod trunk push