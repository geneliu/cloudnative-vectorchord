FROM ghcr.io/cloudnative-pg/postgresql:$CNPG_TAG-bookworm

# Re-declare ARGs to make them available in this build stage
ARG CNPG_TAG
ARG VECTORCHORD_TAG
ARG TARGETARCH

# drop to root to install packages
USER root

ENV PGVECTOR_RS_VERSION v0.3.0

# Download required .deb packages
ADD https://github.com/tensorchord/VectorChord/releases/download/$VECTORCHORD_TAG/postgresql-${CNPG_TAG%.*}-vchord_${VECTORCHORD_TAG#"v"}-1_$TARGETARCH.deb /tmp/vchord.deb
ADD https://github.com/tensorchord/pgvecto.rs/releases/download/$PGVECTOR_RS_TAG/postgresql-${CNPG_TAG%.*}-pgvecto.rs_${PGVECTOR_RS_TAG#"v"}-1_$TARGETARCH.deb /tmp/pgvecto.rs.deb

RUN \
    # Update package list and install prerequisites for adding PGDG apt repository
    # Using --no-install-recommends to keep the image lean
    apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        ca-certificates \
        gnupg \
        lsb-release && \
    \
    # Add PostgreSQL GPG key
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg && \
    \
    # Add PostgreSQL Apt repository
    # $(lsb_release -cs) will resolve to your Debian version's codename (e.g., bookworm)
    echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    \
    # Update package list again after adding the new repository
    apt-get update && \
    \
    # Install pgvector from PGDG, and the downloaded .deb packages.
    # postgresql-${CNPG_TAG%.*}-pgvector will install pgvector for the correct PostgreSQL major version.
    # The version installed will be the latest stable one from PGDG, which typically meets common version requirements like ">= 0.7.0".
    apt-get install -y --no-install-recommends \
        postgresql-${CNPG_TAG%.*}-pgvector \
        /tmp/vchord.deb \
        /tmp/pgvecto.rs.deb && \
    \
    # Clean up downloaded .deb files
    rm -f /tmp/vchord.deb /tmp/pgvecto.rs.deb && \
    \
    # Clean up apt caches and remove temporary packages to reduce image size
    apt-get purge -y --auto-remove curl ca-certificates gnupg lsb-release && \
    rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/pgdg.list /usr/share/keyrings/postgresql-archive-keyring.gpg

USER postgres