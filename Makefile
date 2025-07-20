# Makefile

# Import environment variables from .env at the same directory level
-include .env
export $(shell sed -n 's/^\([^=]*\)=.*/\1/p' .env)

# Extract tag (e.g., v0.3.0 → 0.3.0)
TAG := $(shell git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "0.0.0")

# Calculate next snapshot (0.3.0 → 0.4.0-SNAPSHOT)
define next_snapshot
  major=$$(echo $(TAG) | cut -d. -f1); \
  minor=$$(echo $(TAG) | cut -d. -f2); \
  echo $${major}.$$((minor+1)).0-SNAPSHOT
endef

DEV_SNAPSHOT := $(shell $(next_snapshot))

.PHONY: write-settings set-version deploy

## write-settings: generate ~/.m2/settings.xml using OSSRH credentials
write-settings:
	@echo "Writing settings.xml..."
	@mkdir -p ~/.m2
	@printf '<settings>\n  <servers>\n    <server>\n      <id>ossrh</id>\n      <!-- usa tu Portal User Token -->\n      <username>%s</username>\n      <password>%s</password>\n    </server>\n  </servers>\n</settings>\n' "$(OSSRH_USERNAME)" "$(OSSRH_PASSWORD)" > ~/.m2/settings.xml

## set-version: update project version in POM based on Git tag
set-version:
	@echo "Setting project version to $(TAG)..."
	cd ether-parent && mvn versions:set -DnewVersion=$(TAG) -DgenerateBackupPoms=false

## deploy: write settings and set version, then deploy to Maven Central
deploy: write-settings set-version
	@echo "Deploying version $(TAG)..."
	cd ether-parent && mvn clean deploy -DskipTests -Dgpg.passphrase="$(GPG_PASSPHRASE)"

