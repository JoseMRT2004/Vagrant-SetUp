#!/bin/bash

# =============================================================================
# setupVagrantVM.sh - Instalación automatizada de Vagrant + KVM/Libvirt
# =============================================================================
# AUTOR: mrtaveras
# SISTEMA: Linux Mint 22.2 (Zara) con kernel 6.14.0-37-generic
# =============================================================================
# DESCRIPCIÓN:
#   Este script configura un entorno completo de virtualización con KVM
#   y automatización con Vagrant. Es la alternativa profesional a VirtualBox.
# =============================================================================
# CARACTERÍSTICAS:
#   - Elimina conflictos de instalaciones anteriores
#   - Instala KVM/Libvirt (hipervisor nativo de Linux)
#   - Configura permisos de usuario adecuados
#   - Instala Vagrant desde repositorio oficial
#   - Configura plugin vagrant-libvirt
# =============================================================================

# =============================================================================
# 1. CONFIGURACIÓN DE COLORES PARA MENSAJES
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones para mensajes con formato
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_info() { echo -e "${BLUE}[i]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

# =============================================================================
# 2. VERIFICACIÓN INICIAL DEL SISTEMA
# =============================================================================
clear
echo -e "${GREEN}"
echo "==================================================================="
echo "   INSTALACIÓN DE VAGRANT + KVM/LIBVIRT PARA LINUX MINT"
echo "==================================================================="
echo -e "${NC}"

# Verificar que estamos en Linux Mint
if ! grep -q "Linux Mint" /etc/os-release; then
    print_warning "Este script está optimizado para Linux Mint"
    print_info "Continuando de todos modos..."
fi

# Verificar virtualización de hardware
if egrep -c '(vmx|svm)' /proc/cpuinfo > /dev/null; then
    print_success "Virtualización por hardware detectada"
else
    print_warning "Virtualización por hardware NO detectada"
    print_info "Puede que KVM no funcione óptimamente"
fi

# =============================================================================
# 3. LIMPIEZA DE INSTALACIONES ANTERIORES
# =============================================================================
echo ""
echo "==================================================================="
echo "   FASE 1: LIMPIEZA DEL SISTEMA"
echo "==================================================================="

    
# Remover VirtualBox si existe -- Puede sustituir esta parte por la eliminación de otros hipervisores si es necesario.
if dpkg -l | grep -q virtualbox; then
    print_info "Removiendo VirtualBox..."
    sudo apt remove --purge virtualbox-* virtualbox-dkms -y 2>/dev/null
    sudo rm -f /etc/apt/sources.list.d/virtualbox.list 2>/dev/null
    print_success "VirtualBox removido"
fi


# Remover Vagrant de repositorios del sistema
if dpkg -l | grep -q vagrant; then
    print_info "Removiendo Vagrant antiguo..."
    sudo apt remove --purge vagrant -y
    print_success "Vagrant removido"
fi

# Limpiar paquetes no usados
sudo apt autoremove -y
sudo apt clean

# =============================================================================
# 4. INSTALACIÓN DE KVM Y LIBVIRT
# =============================================================================
echo ""
echo "==================================================================="
echo "   FASE 2: INSTALACIÓN DEL HIPERVISOR KVM"
echo "==================================================================="

print_info "Actualizando lista de paquetes..."
sudo apt update

print_info "Instalando KVM, Libvirt y herramientas..."
sudo apt install -y \
    qemu-kvm \ 
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    virt-manager \  # Para gestión gráfica opcional
    cpu-checker

if [ $? -eq 0 ]; then
    print_success "KVM y Libvirt instalados correctamente"
else
    print_error "Error en la instalación de KVM"
    exit 1
fi

# =============================================================================
# 5. CONFIGURACIÓN DE PERMISOS DE USUARIO
# =============================================================================
echo ""
echo "==================================================================="
echo "   FASE 3: CONFIGURACIÓN DE PERMISOS"
echo "==================================================================="

print_info "Agregando usuario a grupos de virtualización..."
sudo adduser $USER libvirt
sudo adduser $USER kvm


print_success "Usuario agregado a grupos libvirt y kvm"
print_warning "IMPORTANTE: Debes cerrar sesión y volver a entrar después de este script"
print_info "Los permisos no funcionarán hasta que reinicies la sesión"


# =============================================================================
# 6. INSTALACIÓN DE VAGRANT DESDE HASHICORP
# =============================================================================
echo ""
echo "==================================================================="
echo "   FASE 4: INSTALACIÓN DE VAGRANT"
echo "==================================================================="

print_info "Configurando repositorio oficial de HashiCorp..."
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com jammy main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

print_info "Instalando Vagrant..."
sudo apt update
sudo apt install -y vagrant

if [ $? -eq 0 ]; then
    VAGRANT_VERSION=$(vagrant --version)
    print_success "Vagrant instalado: $VAGRANT_VERSION"
else
    print_error "Error instalando Vagrant"
    exit 1
fi

# =============================================================================
# 7. INSTALACIÓN DEL PLUGIN VAGRANT-LIBVIRT
# =============================================================================
echo ""
echo "==================================================================="
echo "   FASE 5: INSTALACIÓN DEL PLUGIN"
echo "==================================================================="

print_info "Instalando dependencias de desarrollo..."
sudo apt install -y \
    build-essential \
    libxslt-dev \
    libxml2-dev \
    libvirt-dev \
    zlib1g-dev \
    ruby-dev \
    pkg-config

print_info "Instalando plugin vagrant-libvirt..."
vagrant plugin install vagrant-libvirt

if [ $? -eq 0 ]; then
    print_success "Plugin vagrant-libvirt instalado correctamente"
else
    print_error "Error instalando el plugin"
    print_info "Intentando con sudo..."
    sudo vagrant plugin install vagrant-libvirt
fi

# =============================================================================
# 8. VERIFICACIÓN DEL SISTEMA
# =============================================================================
echo ""
echo "==================================================================="
echo "   FASE 6: VERIFICACIÓN FINAL"
echo "==================================================================="

# Verificar servicio libvirt
print_info "Verificando servicio libvirt..."
if sudo systemctl is-active libvirtd > /dev/null; then
    print_success "Servicio libvirt activo"
else
    print_warning "Servicio libvirt inactivo, iniciando..."
    sudo systemctl start libvirtd
    sudo systemctl enable libvirtd
fi



echo "==================================================================="
echo "   FASE 7: VERIFICACIÓN FINAL"
echo "==================================================================="

print_info "Instalación completada. Se recomienda reiniciar la sesión."
print_warning "IMPORTANTE: Debes cerrar sesión y volver a entrar para activar los permisos"

read -p "¿Deseas reiniciar ahora? (s/n): " respuesta

if [[ "$respuesta" =~ ^[Ss]$ ]]; then
    print_info "Reiniciando el sistema..."
    sudo reboot now
else
    print_warning "Reinicio pospuesto. Recuerda reiniciar manualmente después."
fi

# =============================================================================
# 9. PRUEBA OPCIONAL - COMENTADA POR DEFECTO
# =============================================================================
echo ""
echo "==================================================================="
echo "   PRUEBA OPCIONAL DEL SISTEMA"
echo "==================================================================="

print_warning "La prueba automática está comentada por defecto"
print_info "Para ejecutar una prueba de funcionamiento, descomenta el siguiente bloque en el script:"
echo ""
echo "=== INICIO DEL BLOQUE PARA DESCOMENTAR ==========================="
echo "# TEST_DIR=\"\$HOME/vagrant_prueba_\$(date +%s)\""
echo "# print_info \"Creando proyecto de prueba en: \$TEST_DIR\""
echo "# mkdir -p \"\$TEST_DIR\""
echo "# cd \"\$TEST_DIR\""
echo "#"
echo "# print_info \"Inicializando máquina de prueba (Alpine Linux)...\""
echo "# vagrant init generic/alpine38"
echo "#"
echo "# print_info \"Iniciando máquina virtual...\""
echo "# vagrant up --provider=libvirt"
echo "#"
echo "# if [ \$? -eq 0 ]; then"
echo "#     print_success \"¡Máquina virtual creada exitosamente!\""
echo "#     print_info \"Puedes conectarte con: cd \$TEST_DIR && vagrant ssh\""
echo "# else"
echo "#     print_error \"Error al crear la máquina virtual\""
echo "#     print_info \"Puede ser un problema de red o permisos\""
echo "# fi"
echo "=== FIN DEL BLOQUE PARA DESCOMENTAR ==============================="
echo ""

# =============================================================================
# 10. RESUMEN FINAL
# =============================================================================
echo ""
echo "==================================================================="
echo "   INSTALACIÓN COMPLETADA"
echo "==================================================================="
echo ""
print_success "Resumen de la instalación:"
echo "  • KVM/Libvirt: Instalado"
echo "  • Vagrant: Instalado desde HashiCorp"
echo "  • Plugin vagrant-libvirt: Instalado"
echo ""
print_warning "ACCIONES REQUERIDAS:"
echo "  1. CERRAR SESIÓN y volver a entrar (o reiniciar)"
echo "  2. Los permisos de virtualización se activarán después"
echo ""
print_info "COMANDOS BÁSICOS PARA TU CURSO:"
echo "  vagrant init <box>     # Crear nuevo proyecto"
echo "  vagrant up             # Iniciar máquina"
echo "  vagrant ssh            # Conectarse por SSH"
echo "  vagrant halt           # Apagar máquina"
echo "  vagrant destroy        # Eliminar máquina"
echo ""
print_info "BOXES RECOMENDADOS para libvirt:"
echo "  • generic/alpine38    (Ligero, para pruebas)"
echo "  • ubuntu/focal64      (Ubuntu 20.04 LTS)"
echo "  • ubuntu/jammy64      (Ubuntu 22.04 LTS)"
echo ""
echo "==================================================================="
echo ""
