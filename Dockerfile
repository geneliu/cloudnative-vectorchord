ARG CNPG_TAG
FROM ghcr.io/cloudnative-pg/postgresql:$CNPG_TAG-bookworm

# Re-declare ARGs to make them available in this build stage
ARG CNPG_TAG
ARG VECTORCHORD_TAG
ARG TARGETARCH

# drop to root to install packages
USER root

ENV PGVECTOR_RS_TAG=v0.3.0

# Download required .deb packages
ADD https://github.com/tensorchord/VectorChord/releases/download/${VECTORCHORD_TAG#"v"}/postgresql-${CNPG_TAG%.*}-vchord_${VECTORCHORD_TAG#"v"}-1_$TARGETARCH.deb /tmp/vchord.deb
ADD https://github.com/tensorchord/pgvecto.rs/releases/download/$PGVECTOR_RS_TAG/vectors-pg${CNPG_TAG%.*}_${PGVECTOR_RS_TAG#"v"}_${TARGETARCH}_vectors.deb /tmp/pgvecto.rs.deb

RUN apt-get install /tmp/vchord.deb /tmp/pgvecto.rs.deb
USER postgres