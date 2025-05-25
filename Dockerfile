FROM tensorchord/cloudnative-vectorchord:16.9-0.3.0

# Re-declare ARGs for use in this stage, as they are needed for the ADD instruction
ARG CNPG_TAG

# Switch to root user to install packages
USER root

# Define the static version for pgvecto.rs using ENV, similar to your combined Dockerfile
# Define static TARGETARCH and PGVECTOR_RS_TAG using ENV
ENV TARGETARCH=amd64
ENV PGVECTOR_RS_TAG=v0.3.0

# Download the pgvecto.rs .deb package
# The URL structure is based on the working example from your combined Dockerfile
ADD https://github.com/tensorchord/pgvecto.rs/releases/download/${PGVECTOR_RS_TAG}/vectors-pg${CNPG_TAG%.*}_${PGVECTOR_RS_TAG#"v"}_${TARGETARCH}_vectors.deb /tmp/pgvecto.rs.deb

# Update package list, install pgvecto.rs, and clean up
RUN apt-get update && apt-get install -y --no-install-recommends /tmp/pgvecto.rs.deb && rm -f /tmp/pgvecto.rs.deb && rm -rf /var/lib/apt/lists/*

# Switch back to the postgres user
USER postgres