# Verwende ein Ubuntu 24.04 LTS Image als Basis
FROM ubuntu:22.04

# Setze Umgebungsvariablen, um das Build-Verfahren nicht-interaktiv zu machen
ENV DEBIAN_FRONTEND=noninteractive

# Add missing dependencies
RUN apt update && apt install -y wget gpg

# Download the key, convert the signing-key to a full
# keyring required by apt and store in the keyring directory
RUN wget https://repo.radeon.com/rocm/rocm.gpg.key -O - | \
    gpg --dearmor | tee /etc/apt/keyrings/rocm.gpg > /dev/null

# Füge das ROCm APT-Repository hinzu
# WICHTIG: Die Version (hier 6.4.1) ist Teil des Pfades.
# Ubuntu 24.04 hat den Codenamen "noble".
ENV ROCM_VERSION=6.4.1
# Register ROCm packages
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/${ROCM_VERSION} jammy main" \
    | tee --append /etc/apt/sources.list.d/rocm.list
COPY rocm-pin.pref /etc/apt/preferences.d/rocm-pin-600

# Update und Installation der notwendigen ROCm-Pakete
# rocm-libs enthält die Basis-Laufzeitbibliotheken.
# rocm-hip-sdk enthält das HIP-SDK, falls du selbst kompilieren möchtest.
# clinfo zur Überprüfung der OpenCL-Geräte.
# libclc-amdgpu ist eine OpenCL-Bibliothek, die oft für AMD GPUs benötigt wird.
RUN rm -rf /var/lib/apt/lists/* \
    && apt clean \
    && apt update \
    && apt install -y \
    rocm \
    clinfo \
    && rm -rf /var/lib/apt/lists/*

# Konfiguriere die Umgebungsvariable für die 780M (gfx1103 Architektur)
# Dies ist der entscheidende Workaround, damit ROCm die 780M erkennt.
# Die genaue Version (z.B. 11.0.0, 11.0.2) kann je nach ROCm-Version und Firmware variieren.
# Beginne mit 11.0.2, da diese oft für gfx1103 funktioniert.
ENV HSA_OVERRIDE_GFX_VERSION=11.0.2

# Füge den Benutzer zur 'render' und 'video' Gruppe hinzu, damit er auf die GPU zugreifen kann
# Dies ist entscheidend für den Zugriff vom Container auf die Host-GPU.
#RUN groupadd -r render && usermod -a -G render root \
#    && groupadd -r video && usermod -a -G video root

# Setze den Arbeitsordner im Container
WORKDIR /app

# Optional: Kopiere deine Anwendung oder Skripte in den Container
# Beispiel: COPY . /app

# Befehl, der ausgeführt wird, wenn der Container startet
# Hier starten wir einfach eine Bash-Shell, damit du testen kannst.
# Du kannst dies ändern, um deine spezifische Anwendung zu starten.
CMD ["bash"]
