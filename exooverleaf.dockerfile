FROM sharelatex/sharelatex

# Install wget if missing
RUN apt update && apt install -y wget

# Update TeX Live package manager (tlmgr)
RUN wget -O /tmp/update-tlmgr-latest.sh https://mirror.ctan.org/systems/texlive/tlnet/update-tlmgr-latest.sh && \
    chmod +x /tmp/update-tlmgr-latest.sh && \
    /bin/sh /tmp/update-tlmgr-latest.sh && \
    rm -f /tmp/update-tlmgr-latest.sh

# Install required TeX Live packages
RUN tlmgr install titling
