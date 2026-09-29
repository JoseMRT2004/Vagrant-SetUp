# Vagrant + KVM/Libvirt para Linux Mint

**Versión:** 1.0  
**Sistema:** Linux Mint 22.2 (Zara) - Kernel 6.14.0-37-generic  
**Autor:** [github.com/JoseMRT2004](https://github.com/JoseMRT2004/)

## Índice

1. [Descripción general](#descripción-general)
2. [Requisitos del sistema](#requisitos-del-sistema)
3. [Instalación automatizada](#instalación-automatizada)
4. [Configuración manual (alternativa)](#configuración-manual-alternativa)
5. [Comandos esenciales de Vagrant](#comandos-esenciales-de-vagrant)
6. [Solución de problemas comunes](#solución-de-problemas-comunes)
7. [Preguntas frecuentes (FAQ)](#preguntas-frecuentes-faq)
8. [Recursos y referencias](#recursos-y-referencias)

## Descripción general

Este paquete configura un entorno completo de virtualización para Linux Mint usando tecnologías nativas de Linux:

- **KVM (Kernel-based Virtual Machine):** Hipervisor de tipo 1, integrado en el kernel de Linux. Ofrece mejor rendimiento que VirtualBox.
- **Libvirt:** API y herramienta para gestionar KVM y otros hipervisores. Proporciona una interfaz unificada.
- **Vagrant:** Herramienta para crear y gestionar entornos de desarrollo reproducibles. Automatiza la creación de máquinas virtuales.
- **vagrant-libvirt:** Plugin que permite a Vagrant usar Libvirt como proveedor.

### Ventajas sobre VirtualBox

- Mejor rendimiento (acceso directo al hardware)
- Sin problemas con Secure Boot
- Integración nativa con Linux
- Más estable en kernels modernos
- Menor sobrecarga de recursos

## Requisitos del sistema

### Mínimos

- Linux Mint 20.x o superior (probado en 22.2 "Zara")
- 4 GB de RAM (8 GB recomendado)
- 20 GB de espacio libre en disco
- CPU con soporte de virtualización (Intel VT-x / AMD-V)
- Conexión a Internet para descargar boxes

### Verificar virtualización de hardware

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
# Si muestra 1 o más, tu CPU soporta virtualización
