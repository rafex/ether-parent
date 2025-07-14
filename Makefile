# Makefile

# Extrae el tag (ej: v0.3.0 → 0.3.0)
TAG := $(shell git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "0.0.0")

# Ajusta a snapshot siguiente (0.3.0 → 0.4.0-SNAPSHOT)
define next_snapshot
  major=$$(echo $(TAG) | cut -d. -f1); \
  minor=$$(echo $(TAG) | cut -d. -f2); \
  echo $${major}.$$((minor+1)).0-SNAPSHOT
endef

DEV_SNAPSHOT := $(shell $(next_snapshot))

.ONESHELL:
.PHONY: deploy
deploy:
	@echo "Writing settings.xml..."
	@mkdir -p ~/.m2
	@printf '<settings>\n  <servers>\n    <server>\n      <id>ossrh</id>\n      <!-- usa tu Portal User Token -->\n      <username>%s</username>\n      <password>%s</password>\n    </server>\n  </servers>\n</settings>\n' "$$OSSRH_USERNAME" "$$OSSRH_PASSWORD" > ~/.m2/settings.xml
	@echo "Setting project version to $(TAG)..."
	cd ether-parent && mvn versions:set -DnewVersion=$(TAG) -DgenerateBackupPoms=false
	@echo "Deploying version $(TAG)..."
	cd ether-parent && mvn clean deploy -DskipTests -Dgpg.passphrase="$(GPG_PASSPHRASE)"