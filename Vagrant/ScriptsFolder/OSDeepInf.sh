cript de informacion del sistema KVM/Libvirt
# Proposito: Recopilar y mostrar informacion del sistema para propositos de diagnostico y configuracion

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==============================================================================
#  - PROPOSITO DEL SCRIPT
# ==============================================================================
# Este script recopila informacion del sistema donde se ejecuta.
# Puede usarse en el host o en VMs como provisioner de Vagrant.
# Su funcion es mostrar informacion del sistema para diagnostico y configuracion.
# ==============================================================================

mostrar_seccion() {
    local titulo="$1"
    local contenido="$2"
    
    echo -e "${CYAN}+==============================================================+${NC}"
    echo -e "${CYAN}|${NC} ${YELLOW}${titulo}${NC}"
    echo -e "${CYAN}+==============================================================+${NC}"
    echo -e "${contenido}"
    echo -e "${CYAN}+==============================================================+${NC}"
    echo ""
}

echo -e "${BLUE}+==============================================================+${NC}"
echo -e "${BLUE}|${NC}            INFORMACION DEL SISTEMA                     ${BLUE}|${NC}"
echo -e "${BLUE}|${NC}            (Script de diagnostico)                    ${BLUE}|${NC}"
echo -e "${BLUE}+==============================================================+${NC}"
echo ""

SYS_INFO="Hostname: $(hostname)\n"
if [ -f /etc/os-release ]; then
    SYS_INFO+="SO: $(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"')\n"
elif [ -f /etc/redhat-release ]; then
    SYS_INFO+="SO: $(cat /etc/redhat-release)\n"
fi
SYS_INFO+="Kernel: $(uname -r)\n"
SYS_INFO+="Arquitectura: $(arch)\n"
SYS_INFO+="Virtualizacion: $(systemd-detect-virt 2>/dev/null || echo 'Desconocida')\n"
mostrar_seccion "INFORMACION DEL SISTEMA" "${SYS_INFO}"

# 2. CPU
CPU_INFO="Procesador: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)\n"
CPU_INFO+="Nucleos Fisicos: $(grep 'cpu cores' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)\n"
CPU_INFO+="Nucleos Logicos: $(nproc)\n"
CPU_INFO+="Frecuencia: $(grep 'cpu MHz' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs) MHz\n"
mostrar_seccion "INFORMACION DE CPU" "${CPU_INFO}"

MEM_INFO="$(free -h | sed 's/^/  /')"
mostrar_seccion "MEMORIA RAM" "${MEM_INFO}"

DISK_INFO=""
DISK_INFO+="$(df -h / /home /var /tmp 2>/dev/null | sed 's/^/  /')\n\n"
DISK_INFO+="Discos detectados:\n"
if command -v lsblk &>/dev/null; then
    DISK_INFO+="$(lsblk -o NAME,SIZE,TYPE,MOUNTPOINT | grep -v '^loop' | sed 's/^/  /')"
else
    DISK_INFO+="  $(ls /dev/sd* /dev/vd* 2>/dev/null | xargs)"
fi
mostrar_seccion "ALMACENAMIENTO" "${DISK_INFO}"

NET_INFO=""
if command -v ip &>/dev/null; then
    NET_INFO+="Interfaces:\n"
    NET_INFO+="$(ip -brief address | sed 's/^/  /')\n\n"
elif command -v ifconfig &>/dev/null; then
    NET_INFO+="Interfaces:\n"
    NET_INFO+="$(ifconfig -s | sed 's/^/  /')\n\n"
fi

NET_INFO+="Rutas de red:\n"
NET_INFO+="$(ip route | head -10 | sed 's/^/  /')\n\n"

NET_INFO+="Puertos escuchando:\n"
if command -v ss &>/dev/null; then
    NET_INFO+="$(ss -tlnp | head -10 | sed 's/^/  /')"
elif command -v netstat &>/dev/null; then
    NET_INFO+="$(netstat -tlnp | head -10 | sed 's/^/  /')"
fi
mostrar_seccion "REDES" "${NET_INFO}"

PROC_INFO=""
PROC_INFO+="Carga del sistema: $(uptime)\n"
PROC_INFO+="Procesos activos: $(ps aux | wc -l)\n"
PROC_INFO+="Usuarios conectados: $(who | wc -l)\n\n"
PROC_INFO+="Top 5 procesos por CPU:\n"
PROC_INFO+="$(ps aux --sort=-%cpu | head -6 | sed 's/^/  /')\n\n"
PROC_INFO+="Top 5 procesos por RAM:\n"
PROC_INFO+="$(ps aux --sort=-%mem | head -6 | sed 's/^/  /')"
mostrar_seccion "PROCESOS Y CARGA" "${PROC_INFO}"

USER_INFO=""
USER_INFO+="Usuario actual: $(whoami)\n"
USER_INFO+="UID: $(id -u)\n"
USER_INFO+="GID: $(id -g)\n"
USER_INFO+="Grupos: $(id -Gn)\n\n"
USER_INFO+="Usuarios del sistema:\n"
USER_INFO+="  Total: $(cut -d: -f1 /etc/passwd | wc -l)\n"
USER_INFO+="  Conectados: $(who | cut -d' ' -f1 | sort -u | wc -l)"
mostrar_seccion "USUARIOS Y GRUPOS" "${USER_INFO}"

PKG_INFO=""
if command -v dpkg &>/dev/null; then
    PKG_INFO+="Sistema: Debian/Ubuntu\n"
    PKG_INFO+="Paquetes instalados: $(dpkg -l | grep ^ii | wc -l)\n"
elif command -v rpm &>/dev/null; then
    PKG_INFO+="Sistema: RHEL/CentOS/Fedora\n"
    PKG_INFO+="Paquetes instalados: $(rpm -qa | wc -l)\n"
fi

PKG_INFO+="\nServicios del sistema:\n"
if command -v systemctl &>/dev/null; then
    PKG_INFO+="  Activos: $(systemctl list-units --state=active | grep -c '\.service')\n"
    PKG_INFO+="  Fallidos: $(systemctl list-units --state=failed | grep -c '\.service')"
else
    PKG_INFO+="  Systemd no disponible"
fi
mostrar_seccion "PAQUETES Y SERVICIOS" "${PKG_INFO}"

echo -e "${BLUE}+==============================================================+${NC}"
echo -e "${BLUE}|${NC}       Script de diagnostico completado                 ${BLUE}|${NC}"
echo -e "${BLUE}+==============================================================+${NC}"
