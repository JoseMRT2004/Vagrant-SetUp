#!/bin/bash

# ================================================================================================
# ================================================================================================
# ========================= INFORMACIÓN DEL SISTEMA KVM/Libvirt ==================================
#=================================================================================================
# ================================================================================================

# Descripción: Este script recopila y muestra información relevante sobre el estado del sistema
#              KVM/Libvirt en un host Linux. Proporciona detalles sobre el hardware, la configuración
#              de virtualización, el estado de KVM y Libvirt, así como las máquinas virtuales y redes
#              definidas.

#   1. Información del Host (hostname, SO, kernel, arquitectura)
#   2. CPU y Virtualización (procesador, núcleos, extensiones)
#   3. Memoria RAM disponible
#   4. Estado de KVM (/dev/kvm, módulos cargados)
#   5. Estado de Libvirt (servicio, versión)
#   6. Redes virtuales definidas
#   7. Máquinas virtuales disponibles
#   8. Espacio en disco del sistema
#   9. Puertos en uso por Libvirt

# ================================================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}============================================${NC}"
echo -e "${BLUE}  INFORMACIÓN DEL SISTEMA KVM${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

echo -e "${YELLOW}=== INFORMACIÓN DEL HOST ===${NC}"
echo "Hostname: $(hostname)"
echo "Sistema Operativo: $(lsb_release -d | cut -f2)"
echo "Kernel: $(uname -r)"
echo "Arquitectura: $(arch)"
echo ""

echo -e "${YELLOW}=== CPU Y VIRTUALIZACIÓN ===${NC}"
echo "Procesador: $(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
echo "Núcleos Físicos: $(grep "cpu cores" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
echo "Núcleos Lógicos: $(nproc)"
echo ""

echo -e "${GREEN}Extensiones de Virtualización:${NC}"
if grep -Eq "(vmx|svm)" /proc/cpuinfo; then
    echo -e "✓ Hardware: ${GREEN}Soporte activado${NC}"
    
    if grep -q "vmx" /proc/cpuinfo; then
        echo "  Tipo: Intel VT-x"
    elif grep -q "svm" /proc/cpuinfo; then
        echo "  Tipo: AMD-V"
    fi
else
    echo -e "✗ Hardware: ${RED}No disponible${NC}"
fi
echo ""

echo -e "${YELLOW}=== MEMORIA ===${NC}"
free -h | awk 'NR==1{printf "%-20s %-10s %-10s %-10s\n", $1, $2, $3, $4} NR==2{printf "%-20s %-10s %-10s %-10s\n", "Memoria:", $2, $3, $4}'
echo ""

echo -e "${YELLOW}=== ESTADO DE KVM ===${NC}"
if command -v kvm-ok &> /dev/null; then
    kvm-ok 2>/dev/null || echo "KVM no está listo para uso"
elif [ -f /dev/kvm ]; then
    echo -e "${GREEN}✓ /dev/kvm existe${NC}"
    echo "Permisos: $(ls -l /dev/kvm | awk '{print $1, $3, $4}')"
else
    echo -e "${RED}✗ /dev/kvm no encontrado${NC}"
fi

echo ""
echo -e "${GREEN}Módulos cargados:${NC}"
lsmod | grep -E "kvm|virtio" || echo "No se encontraron módulos KVM"
echo ""

echo -e "${YELLOW}=== LIBVIRT ===${NC}"
if systemctl is-active libvirtd &> /dev/null; then
    echo -e "Estado: ${GREEN}Activo${NC}"
    echo "Versión: $(virsh --version 2>/dev/null || echo "No disponible")"
else
    echo -e "Estado: ${RED}Inactivo${NC}"
fi
echo ""

echo -e "${YELLOW}=== REDES VIRTUALES ===${NC}"
if command -v virsh &> /dev/null; then
    echo -e "${GREEN}Redes definidas:${NC}"
    virsh net-list --all 2>/dev/null || echo "No se pudieron listar redes"
else
    echo "Libvirt no está disponible"
fi
echo ""

echo -e "${YELLOW}=== MÁQUINAS VIRTUALES ===${NC}"
if command -v virsh &> /dev/null; then
    echo -e "${GREEN}Máquinas definidas:${NC}"
    virsh list --all 2>/dev/null || echo "No se pudieron listar VMs"
else
    echo "Libvirt no está disponible"
fi
echo ""

echo -e "${YELLOW}=== ALMACENAMIENTO ===${NC}"
echo -e "${GREEN}Espacio disponible:${NC}"
df -h / /var/lib/libvirt /home 2>/dev/null | awk 'NR==1 || /\/$\|libvirt\|home/'
echo ""

echo -e "${YELLOW}=== PUERTOS LIBVIRT ===${NC}"
ss -tlnp | grep -E "(libvirt|qemu)" | head -10 || echo "No se encontraron puertos activos"
echo ""

echo -e "${CYAN}============================================${NC}"
