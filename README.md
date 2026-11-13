# nano-rv32i-bd-vivado2023

Script Tcl para recrear el block design `design_1` (SoC mínimo del nano-rv32i, Lab 3)
en **Vivado 2023.2**.

## Qué es

La plantilla del Lab 3 incluye un `project_1.tcl` generado con Vivado 2024.1 y con rutas
absolutas de otra máquina, por lo que no funciona directamente en 2023.2.

Este script es el procedimiento `cr_bd_design_1` de esa plantilla, adaptado para que:

- no cree un proyecto nuevo, sino que trabaje sobre el proyecto que tengas abierto;
- busque `coe/init_mem.coe` con una ruta relativa al propio script (funciona en cualquier máquina);
- genere `design_1_wrapper` y lo añada al proyecto;
- fije los tops: `design_1_wrapper` para síntesis y `testbench_design_1` para simulación.

El SoC creado contiene: el procesador `nano_rv32i`, la ROM de instrucciones (inicializada con
`init_mem.coe`), la RAM de datos, el AXI GPIO conectado a los LED y el generador de reset.

No contiene ninguna solución de la práctica: solo construye el diseño de bloques de la plantilla.

## Uso

1. Guarda el script como `create_bd_design_1.tcl` en una carpeta `scripts/` **dentro de tu
   carpeta de la plantilla**, al mismo nivel que `coe/` y `hw/`:

   ```
   nano_rv32i/
   ├── coe/init_mem.coe
   ├── constraints/
   ├── hw/
   └── scripts/create_bd_design_1.tcl
   ```

2. En tu proyecto de Vivado 2023.2 deben estar ya añadidos:
   - los ficheros `hw/*.v` (incluidos `nano_rv32i.v` y `cycle_counter_trigger.v`) como fuentes de diseño;
   - el `.xdc` de la Nexys A7 como restricciones;
   - `design_tb.v` como fuente de simulación.

3. Con el proyecto abierto, ejecuta en la consola Tcl de Vivado:

   ```tcl
   source <ruta a tu plantilla>/scripts/create_bd_design_1.tcl
   ```

4. Para ver el diseño: *Flow Navigator → IP INTEGRATOR → Open Block Design*.

## Notas

- Si el proyecto ya tiene un `design_1`, el script se detiene sin tocar nada. Bórralo antes
  si quieres recrearlo.
- Al ejecutarlo aparecen 4 *critical warnings* `Width mismatch` en las direcciones AXI del GPIO
  (9 bits frente a 32). Son esperables: ya estaban en el diseño original y no afectan al
  funcionamiento.
- El testbench del sistema no tiene `$finish`. Antes de simular, limita el tiempo para que no
  corra indefinidamente:

  ```tcl
  set_property -name {xsim.simulate.runtime} -value {1us} -objects [get_filesets sim_1]
  launch_simulation
  ```

  Debe reproducir la figura 3 del guion: `gpio_io_o` pasa a `001F` hacia los 925 ns.

## Origen

Adaptado del `project_1.tcl` de la plantilla del Lab 3 de la asignatura *Diseño de Sistemas
Microelectrónicos Basados en Arquitecturas Abiertas*.

