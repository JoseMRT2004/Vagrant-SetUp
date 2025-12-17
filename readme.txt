===============================================================================
                    VAGRANT + KVM/LIBVIRT PARA LINUX MINT
===============================================================================

FECHA: $(date)
VERSIÓN: 1.0
SISTEMA: Linux Mint 22.2 (Zara) - Kernel 6.14.0-37-generic
AUTOR: github.com/JoseMRT2004/

===============================================================================
                            TABLA DE CONTENIDOS
===============================================================================
1.  Descripción General
2.  Requisitos del Sistema
3.  Instalación Automatizada
4.  Configuración Manual (Alternativa)
5.  Comandos Esenciales de Vagrant
6.  Solución de Problemas Comunes
7.  Preguntas Frecuentes (FAQ)
8.  Recursos y Referencias

===============================================================================
1. DESCRIPCIÓN GENERAL
===============================================================================

Este paquete configura un entorno completo de virtualización para Linux Mint
usando tecnologías nativas de Linux:

• KVM (Kernel-based Virtual Machine): Hipervisor de tipo 1, integrado en el
  kernel de Linux. Ofrece mejor rendimiento que VirtualBox.

• Libvirt: API y herramienta para gestionar KVM y otros hipervisores.
  Proporciona una interfaz unificada.

• Vagrant: Herramienta para crear y gestionar entornos de desarrollo
  reproducibles. Automatiza la creación de máquinas virtuales.

• vagrant-libvirt: Plugin que permite a Vagrant usar Libvirt como proveedor.

VENTAJAS SOBRE VIRTUALBOX:

  ✓ Mejor rendimiento (acceso directo al hardware)
  ✓ Sin problemas con Secure Boot
  ✓ Integración nativa con Linux
  ✓ Más estable en kernels modernos
  ✓ Menor sobrecarga de recursos

===============================================================================
2. REQUISITOS DEL SISTEMA
===============================================================================

MÍNIMOS:
• Linux Mint 20.x o superior (probado en 22.2 "Zara")
• 4 GB de RAM (8 GB recomendado)
• 20 GB de espacio libre en disco
• CPU con soporte de virtualización (Intel VT-x / AMD-V)
• Conexión a Internet para descargar boxes

VERIFICAR VIRTUALIZACIÓN DE HARDWARE:
    $ egrep -c '(vmx|svm)' /proc/cpuinfo
    # Si muestra 1 o más, tu CPU soporta virtualización

VERIFICAR KERNEL:
    $ uname -r
    # Debe ser 5.15 o superior (6.14.0-37 en este caso)

===============================================================================
3. INSTALACIÓN AUTOMATIZADA
===============================================================================

PASO A PASO:

1. Descarga los archivos:
   - setupVagrantVM.sh
   - README.txt

2. Navega al directorio de descarga:
   $ cd ~/Descargas  # o donde guardaste los archivos

3. Da permisos de ejecución:
   $ chmod +x setupVagrantVM.sh

4. Ejecuta el script:
   $ ./setupVagrantVM.sh

5. El script realizará:
   ✓ Limpieza de instalaciones anteriores conflictivas
   ✓ Instalación de KVM, Libvirt y dependencias
   ✓ Configuración de permisos de usuario
   ✓ Instalación de Vagrant desde repositorio oficial
   ✓ Instalación del plugin vagrant-libvirt

6. POST-INSTALACIÓN OBLIGATORIA:
   Debes CERRAR SESIÓN completamente y volver a entrar.
   Los permisos de grupos (libvirt, kvm) requieren nueva sesión.

VERIFICACIÓN DE INSTALACIÓN:
   $ vagrant --version
   $ virsh list --all
   $ groups  # Debes ver "libvirt" y "kvm" en la lista

===============================================================================
4. CONFIGURACIÓN MANUAL (ALTERNATIVA)
===============================================================================

Si prefieres instalar manualmente:

1. Instalar KVM y Libvirt:
   $ sudo apt update
   $ sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

2. Agregar usuario a grupos:
   $ sudo adduser $USER libvirt
   $ sudo adduser $USER kvm

3. Instalar Vagrant desde HashiCorp:
   $ wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   $ echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com jammy main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   $ sudo apt update && sudo apt install vagrant

4. Instalar plugin vagrant-libvirt:
   $ sudo apt install build-essential libxslt-dev libxml2-dev libvirt-dev zlib1g-dev ruby-dev
   $ vagrant plugin install vagrant-libvirt

===============================================================================
5. COMANDOS ESENCIALES DE VAGRANT
===============================================================================

COMANDOS BÁSICOS:
  vagrant init <box>      # Crear nuevo proyecto Vagrant
  vagrant up              # Iniciar máquina virtual
  vagrant ssh             # Conectarse a la máquina via SSH
  vagrant halt            # Apagar la máquina
  vagrant destroy         # Eliminar completamente la máquina
  vagrant status          # Ver estado de la máquina
  vagrant reload          # Reiniciar máquina con nueva configuración

BOXES RECOMENDADOS (compatibles con libvirt):
  • generic/alpine38      - Alpine Linux (muy ligero)
  • ubuntu/focal64        - Ubuntu 20.04 LTS
  • ubuntu/jammy64        - Ubuntu 22.04 LTS
  • centos/stream8        - CentOS Stream 8
  • fedora/36-cloud-base  - Fedora 36

EJEMPLO DE USO:
  $ mkdir mi_proyecto && cd mi_proyecto
  $ vagrant init ubuntu/focal64
  $ vagrant up --provider=libvirt  # Solo la primera vez
  $ vagrant ssh
  # ... trabajar en la máquina ...
  $ exit  # Salir de la máquina
  $ vagrant halt  # Apagar

===============================================================================
6. SOLUCIÓN DE PROBLEMAS COMUNES
===============================================================================

PROBLEMA 1: Error "Failed to connect socket to '/var/run/libvirt/libvirt-sock'"
SOLUCIÓN: Cerrar sesión y volver a entrar después de agregar usuario a grupos.

PROBLEMA 2: Error al ejecutar 'vagrant up' (permisos denegados)
SOLUCIÓN: Verificar que el usuario está en grupos libvirt y kvm:
          $ groups | grep -E '(libvirt|kvm)'

PROBLEMA 3: Error "Box not found" al usar vagrant init
SOLUCIÓN: Asegurarse que el box existe en Vagrant Cloud y es compatible con libvirt:
          https://app.vagrantup.com/boxes/search?provider=libvirt

PROBLEMA 4: Warning "[fog][WARNING] Unrecognized arguments: libvirt_ip_command"
SOLUCIÓN: Es solo una advertencia, no afecta funcionalidad. Puede ignorarse.

PROBLEMA 5: Error de red (la VM no obtiene IP)
SOLUCIÓN: Verificar que el servicio libvirtd está activo:
          $ sudo systemctl status libvirtd

===============================================================================
7. PREGUNTAS FRECUENTES (FAQ)
===============================================================================

P: ¿Por qué KVM en lugar de VirtualBox?
R: KVM es nativo de Linux, más rápido, sin problemas de Secure Boot y mejor
   integrado con el sistema.

P: ¿Necesito desactivar Secure Boot?
R: NO. KVM usa módulos firmados por Ubuntu/Linux Mint, a diferencia de VirtualBox.

P: ¿Puedo usar VirtualBox después de esta instalación?
R: Sí, pero no simultáneamente con KVM. Debes elegir un hipervisor a la vez.

P: ¿Cómo elimino completamente esta instalación?
R: Ejecutar: sudo apt remove --purge qemu-* libvirt-* vagrant

P: ¿Qué boxes son compatibles?
R: Busca boxes con provider "libvirt" en Vagrant Cloud.

===============================================================================
8. RECURSOS Y REFERENCIAS
===============================================================================

DOCUMENTACIÓN OFICIAL:
• Vagrant: https://www.vagrantup.com/docs
• Libvirt: https://libvirt.org/docs.html
• KVM: https://www.linux-kvm.org/page/Documents

BOXES DISPONIBLES:
• Vagrant Cloud: https://app.vagrantup.com/boxes/search
• Boxes específicos para libvirt: https://app.vagrantup.com/boxes/search?provider=libvirt

COMUNIDAD:
• Foros de Linux Mint: https://forums.linuxmint.com/
• Stack Overflow: Etiquetas [vagrant], [kvm], [libvirt]

===============================================================================
                         ¡CONFIGURACIÓN COMPLETADA!
===============================================================================
Tu entorno de virtualización está listo para usar. Recuerda:
1. Cerrar sesión y volver a entrar
2. Usar 'vagrant init' para crear proyectos
3. Usar 'vagrant ssh' para acceder a las máquinas

Para soporte adicional, consulta la documentación oficial o foros de la comunidad.
