# Makefile

# Extrae el tag (ej: v0.3.0 → 0.3.0)
TAG := $(shell echo ${GITHUB_REF_NAME:-$(shell git describe --tags --abbrev=0)} | sed 's/^v//')

# Ajusta a snapshot siguiente (0.3.0 → 0.4.0-SNAPSHOT)
define next_snapshot
  major=$$(echo $(TAG) | cut -d. -f1); \
  minor=$$(echo $(TAG) | cut -d. -f2); \
  echo $${major}.$$((minor+1)).0-SNAPSHOT
endef

DEV_SNAPSHOT := $(shell $(next_snapshot))

.PHONY: deploy
deploy:
	@echo "Writing settings.xml..."
	@mkdir -p ~/.m2
	@cat > ~/.m2/settings.xml <<EOF
<settings>
  <servers>
    <server>
      <id>ossrh</id>
      <!-- usa tu Portal User Token -->
      <username>${OSSRH_USERNAME}</username>
      <password>${OSSRH_PASSWORD}</password>
    </server>
  </servers>
</settings>
EOF
	@echo "Setting project version to $(TAG)..."
	mvn versions:set -DnewVersion=$(TAG) -DgenerateBackupPoms=false
	@echo "Deploying version $(TAG)..."
	mvn clean deploy -DskipTests -Dgpg.passphrase="$(GPG_PASSPHRASE)"