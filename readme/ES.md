Env Validator Shell <br><small>Validador para fichero de configuración de variables de entorno</small>
=================================
Este es un script que permite validar la configuración de variables de entorno de un archivo 
en ambientes de despliegue que no permiten la ejecución de lenguajes específicos de  un proyecto,
si este no es su caso, puede usar librerías como: [Laravel Env Validator](https://github.com/mathiasgrimm/laravel-env-validator)
o [JS  env-validator](https://www.npmjs.com/package/env-validator)
_________________________________        

Como instalar
--------------------------------

Revisar este proyecto: <https://github.com/NekoOs/env-validator-shell>

```bash
wget https://raw.githubusercontent.com/NekoOs/env-validator-shell/master/src/env-validator.bash
```

Como usar
--------------------------------

### Importar librería
Usted puede llamar la librería desde cada script

```bash
#!/usr/bin/env bash

source env-validator

# more sentences...
```
o registrarla en su  fichero `.bashrc` para un uso más cómodo  y generalizado.      

###  Uso 

#### Validación desde fichero
Defina donde se encuentra el fichero que desea validar y el fichero que contiene las reglas para la validación 
vea un [ejemplo de fichero de configuración de reglas](https://github.com/NekoOs/env-validator-shell/blob/master/tests/.env.rules)  
```bash
validate_keys_with_rules_from_file /path/to/.env /path/to/.env.rules
```

Reglas de validación disponibles
--------------------------------

Debajo hay una lista con todas las reglas de validación disponibles y su función:

- [Boolean](#boolean)  
- [Decimal](#decimal)
- [Integer](#integer)
- [Max](#maxvalue)
- [Min](#minvalue)
- [Numeric](#numeric)
- [Regular Expression](#regex)
- [Required](#required) 
- [Size](#sizevalue)  

#### [#](#boolean) boolean

El campo bajo validación debe poder ser convertido como un booleano. Las entrada aceptadas son `true`, `false`, `1`, `0`, `"1"`, y `"0"`.

#### [#](#decimal) decimal

El campo bajo validación debe ser un decimal.

#### [#](#integer) integer

El campo bajo validación debe ser un entero.

> **Nota**
>
> _Esta regla de validación no verifica que el campo sea del tipo de variable "entero", sólo que el campo sea una cadena o valor número que contenga un entero._

#### [#](#maxvalue) max:*value*

El campo bajo validación debe ser menor que o igual a un *valor* máximo. Las cadenas, los números, los arreglos y los archivos son evaluados de la misma forma como la regla [`size`](#rule-size).

#### [#](#minvalue) min:*value*

#### [#](#numeric) numeric

El campo bajo validación debe ser numérico.

#### [#](#regexpattern) regex:*pattern*

El campo bajo validación debe coincidir con la expresión regular dada.

#### [#](#required) required

El campo bajo validación debe estar presente entre los datos entrada y no vacío. Un campo es considerado "vacío" si algunas de las siguientes condiciones es cierta:

-   El valor es `null`.
-   El valor es una cadena vacía.

#### [#](#sizevalue) size:*value*

El campo bajo validación debe tener un tamaño que coincida con el *valor* dado. Para datos de cadena, el *valor* corresponde al número de caracteres. Para datos numéricos, el *valor* corresponde a un valor entero dado. Para un arreglo, el valor *size* corresponde con el número de elementos del arreglo. Para archivos, el valor de *size* corresponde al tamaño del archivo en kilobytes.
